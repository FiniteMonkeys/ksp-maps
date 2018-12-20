defmodule KerbalMapsWeb.DataChannel do
  @moduledoc false

  use KerbalMapsWeb, :channel

  require Logger

  def join("data:" <> username, _payload, socket) do
    user = KerbalMaps.find_user_by_email(username)
    if user do
      {:ok, Phoenix.Socket.assign(socket, :user_id, user.id)}
    else
      {:error, "username #{username} not found"}
    end
  end

  def handle_in("get_data", _payload, socket) do
    user_id = socket.assigns[:user_id]
    user = KerbalMaps.get_user(user_id)
    if user do
      markers = KerbalMaps.Symbols.list_markers_for_user(user)
                |> Enum.map(fn m -> %{latitude: m.latitude, longitude: m.longitude, label: "<strong>#{m.name}</strong><br/>#{m.description}"} end)
      {:reply, {:ok, %{data: markers}}, socket}
    else
      {:reply, {:error, "user with id #{user_id} not found"}}
    end
  end
end
