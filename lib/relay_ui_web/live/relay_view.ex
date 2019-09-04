defmodule RelayUiWeb.RelayView do
  use Phoenix.LiveView

  alias RelayUi.Relay

  def render(assigns) do
    RelayUiWeb.PageView.render("relay_view.html", assigns)
  end

  def mount(_session, socket) do
    Relay.subscribe()
    relay_hierarchy = Relay.list(RelayUi.Relay)
    relay_state = Relay.status(RelayUi.Relay)

    {:ok, assign(socket, relay_list: relay_hierarchy)}
  end

  def handle_event("on", id, socket) do
    # Send an 'on' message to the relay with this id
    Relay.on(Relay, id)
    IO.inspect "sending on message to #{id}"
    {:noreply, socket}
  end

  def handle_event("off", id, socket) do
    # Send an 'off' message to the relay with this id
    IO.inspect "sending off message to #{id}"
    {:noreply, socket}
  end

  def handle_event({Relay, [:relay | _ ] , _ }, socket) do
    {:noreply, socket}
  end
end
