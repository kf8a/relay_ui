defmodule RelayUiWeb.RelayView do
  use Phoenix.LiveView

  alias RelayUi.Relay

  def render(assigns) do
    RelayUiWeb.PageView.render("relay_view.html", assigns)
  end

  def mount(_params, _session, socket) do
    Relay.subscribe()
    relay_hierarchy = Relay.list(RelayUi.Relay)

    {:ok, assign(socket, relay_list: relay_hierarchy)}
  end

  def handle_event("on", %{"relay" => path}, socket) do
    Relay.on(Relay, String.split(path, "."))
    {:noreply, socket}
  end

  def handle_event("off", %{"relay" => path}, socket) do
    Relay.off(Relay, String.split(path, "."))
    {:noreply, socket}
  end

  def handle_info({Relay, [:relay | _relay], chambers}, socket) do
    {:noreply, assign(socket, relay_list: chambers)}
  end
end
