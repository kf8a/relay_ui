defmodule RelayUiWeb.RelayView do
  use Phoenix.LiveView

  def render(assigns) do
    RelayUiWeb.PageView.render("relay_view.html", assigns)
  end

  def mount(_session, socket) do
    relay_list = RelayUi.Relay.list(RelayUi.Relay)
    {:ok, assign(socket, relay_list: relay_list, deploy_step: "Ready!")}
  end
end
