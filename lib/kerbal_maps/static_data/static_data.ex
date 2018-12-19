defmodule KerbalMaps.StaticData do
  @moduledoc """
  The StaticData context.
  """

  import Ecto.Query, warn: false
  alias KerbalMaps.Repo

  alias KerbalMaps.StaticData.CelestialBody

  @doc """
  Returns the list of celestial_bodies.

  ## Examples

      iex> list_celestial_bodies()
      [%CelestialBody{}, ...]

  """
  def list_celestial_bodies do
    Repo.all(CelestialBody)
  end

  @doc """
  Gets a single celestial_body.

  Raises `Ecto.NoResultsError` if the Celestial body does not exist.

  ## Examples

      iex> get_celestial_body!(123)
      %CelestialBody{}

      iex> get_celestial_body!(456)
      ** (Ecto.NoResultsError)

  """
  def get_celestial_body!(id), do: Repo.get!(CelestialBody, id)

  @doc """
  Creates a celestial_body.

  ## Examples

      iex> create_celestial_body(%{field: value})
      {:ok, %CelestialBody{}}

      iex> create_celestial_body(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_celestial_body(attrs \\ %{}) do
    %CelestialBody{}
    |> CelestialBody.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a celestial_body.

  ## Examples

      iex> update_celestial_body(celestial_body, %{field: new_value})
      {:ok, %CelestialBody{}}

      iex> update_celestial_body(celestial_body, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_celestial_body(%CelestialBody{} = celestial_body, attrs) do
    celestial_body
    |> CelestialBody.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CelestialBody.

  ## Examples

      iex> delete_celestial_body(celestial_body)
      {:ok, %CelestialBody{}}

      iex> delete_celestial_body(celestial_body)
      {:error, %Ecto.Changeset{}}

  """
  def delete_celestial_body(%CelestialBody{} = celestial_body) do
    Repo.delete(celestial_body)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking celestial_body changes.

  ## Examples

      iex> change_celestial_body(celestial_body)
      %Ecto.Changeset{source: %CelestialBody{}}

  """
  def change_celestial_body(%CelestialBody{} = celestial_body) do
    CelestialBody.changeset(celestial_body, %{})
  end
end
