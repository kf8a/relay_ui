defmodule RelayUiWeb.PageController do
  use RelayUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
