defmodule RelayUiWeb.PageController do
  use RelayUiWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, RelayUiWeb.RelayView, session: %{})
  end
end
