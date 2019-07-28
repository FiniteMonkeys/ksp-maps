PROJECT_NAME=kerbal-maps
BUILD_NUMBER ?= DEV
BUILD_SHA ?= $(shell git rev-parse --verify HEAD)
SHORT_BUILD_SHA := $(shell echo $(BUILD_SHA) | head -c 7)
DATE := $(shell date -u "+%Y%m%d")
TAG_NAME := $(DATE)-$(BUILD_NUMBER)-$(SHORT_BUILD_SHA)
DOCKER_TAG := $(PROJECT_NAME):$(TAG_NAME)
DOCKER_TAG_LATEST := $(PROJECT_NAME):latest
DATABASE_USER := postgres
DATABASE_PASSWORD := development
DATABASE_URL := postgres://$(DATABASE_USER):$(DATABASE_PASSWORD)@localhost:5432/kerbal_maps

db_create:
	docker run --name=postgres-kerbal-maps -p 5432:5432 -e POSTGRES_USER=$(DATABASE_USER) -e POSTGRES_PASSWORD=$(DATABASE_PASSWORD) -d postgres:10.9-alpine
	script/wait-for-it localhost:5432 -- sleep 3
	psql -c "CREATE DATABASE kerbal_maps;" postgres://$(DATABASE_USER):$(DATABASE_PASSWORD)@localhost:5432/template1
	pg_restore -Fc -c --if-exists -O -v -x -j 8 -d $(DATABASE_URL) priv/repo/dev.dump
	docker stop postgres-kerbal-maps

db_drop:
	docker stop postgres-kerbal-maps
	docker rm postgres-kerbal-maps

develop:
	docker start postgres-kerbal-maps
	DATABASE_URL=$(DATABASE_URL)                                                         \
		ERLANG_COOKIE=kerbal_maps                                                          \
		SECRET_KEY_BASE="iHKHiC1uLovaKtckLv5FhYl5lUpTYiONenuNWHZOLgvAEJwJavoBZ0sof5+TDfgc" \
	  TILE_CDN_URL=https://d3kmnwgldcmvsd.cloudfront.net/tiles                           \
		mix phx.server

build: buildinfo_file version_file
	docker build -t $(DOCKER_TAG) -t $(DOCKER_TAG_LATEST) .

run:
	docker run --env-file config/docker.env --expose 4000 -p 80:4000 --rm -it $(DOCKER_TAG_LATEST)

push:
	docker push $(DOCKER_TAG)

deploy:
	# @echo "$(APP_VSN)" > VERSION
	heroku container:push web # --arg APP_VSN=$(APP_VSN)
	heroku container:release web

clean:
	docker image prune -f --filter 'label=project=$(PROJECT_NAME)' --filter 'until=72h'
	-docker images -qf "reference=$(PROJECT_NAME)*" | xargs docker rmi -f
	rm rel/BUILD-INFO
	rm VERSION

# create_github_release:

buildinfo_file:
	echo "---" > rel/BUILD-INFO
	echo "version: $(TAG_NAME)" >> rel/BUILD-INFO
	echo "build_number: $(BUILD_NUMBER)" >> rel/BUILD-INFO
	echo "git_commit: $(BUILD_SHA)" >> rel/BUILD-INFO
	BUILD_CONTEXT="BuildInfo" \
	BUILD_DESCRIPTION="Build $(TAG_NAME)" \
	test -e rel/BUILD-INFO

version_file:
	echo "$(TAG_NAME)" > VERSION

.PHONY: develop build run push deploy clean buildinfo_file version_file
