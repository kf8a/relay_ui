defmodule RelayUiWeb.PageController do
  use RelayUiWeb, :controller
  alias Phoenix.LiveView
  alias RelayUiWeb.AuthHelper

  # plug :authenticate

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def admin(conn, _params) do
    authenticate(conn)
    LiveView.Controller.live_render(conn, RelayUiWeb.RelayView, session: %{})
  end

  defp authenticate(conn) do
    case AuthHelper.logged_in?(conn) do
      true ->
        conn
      false ->
        conn |> put_flash(:info, "You must be logged in") |> redirect(to: "/") |> halt()
    end
  end
end
