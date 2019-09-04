defmodule RelayUi.Relay do
  @moduledoc """
  Documentation for Relay.
  """

  @topic inspect(__MODULE__)

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def lookup(pid, chamber) do
    GenServer.call(pid, {:lookup, chamber})
  end

  def close_lid(pid, chamber) do
    GenServer.cast(pid, {:close, chamber})
  end

  def on(pid, relay_number) do
    GenServer.cast(pid, {:on, relay_number})
  end

  def off(pid, relay_number) do
    GenServer.cast(pid, {:off, relay_number})
  end

  def status(pid, relay) do
    GenServer.call(pid, {:relay_state, relay})
  end

  def status(pid) do
    GenServer.call(pid, :relay_state)
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(RelayUi.PubSub, @topic)
  end

  def init(_) do
    {:ok, icp} = IcpDas.start_link
    {:ok, %{icp: icp}, {:continue, :load_relay_mapping}}
  end

  def handle_continue(:load_relay_mapping, state) do
    chambers = load_relay_file()

    relays = extract_relays(chambers)

    #TODO set all relays to zero or query relays for current status
    new_chambers = ammend_chambers(chambers["chamber"])

    new_state = state
                |> Map.put(:chambers, new_chambers)
                |> Map.put(:relays, relays)

    {:noreply, new_state}
  end

  def handle_call({:lookup, chamber}, _from, state) do
    {:reply, Map.fetch(state[:chambers], chamber), state}
  end

  def handle_call({:relay_state, relay}, _from, state) do
    {:reply, IcpDas.state(state[:icp], Integer.to_string(relay)), state}
  end

  def handle_call(:relay_state, _from, state) do
    {:reply, state[:relays], state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state[:chambers], state}
  end

  def handle_cast({:close, chamber}, state) do
    {:ok, the_chamber} = Map.fetch(state[:chambers], chamber)
    GenServer.cast(self(), {:on, the_chamber["lid"]})
    # TODO  update the data
    {:noreply, state}
  end

  def handle_cast({:on, relay}, state) do
    # look up the relay id
    # IcpDas.on(state[:icp], Integer.to_string(relay))
    {_old, relays} = Map.get_and_update(state[:relays], relay, fn current -> {current, :on} end)
    new_chambers = update_in(state[:chambers], relay, fn({key, value}) -> {key, :on} end)
    Phoenix.PubSub.broadcast(RelayUi.PubSub, @topic, {__MODULE__, [:relay, :change], new_chambers})
    new_state = state
                |> Map.put(:relays, relays)
                |> Map.put(:chambers, new_chambers)

    {:noreply, new_state}
  end

  def handle_cast({:off, relay}, state) do
    # look up the relay id
    # IcpDas.off(state[:icp], Integer.to_string(relay))
    # This could probably be done with update_in
    {_old, relays} = Map.get_and_update(state[:relays], relay, fn current -> {current, :off} end)
    new_chambers = update_in(state[:chambers], relay, fn({key, value}) -> {key, :off} end)
    Phoenix.PubSub.broadcast(RelayUi.PubSub, @topic, {__MODULE__, [:relay, :change], new_chambers})

    new_state = state
                |> Map.put(:relays, relays)
                |> Map.put(:chambers, new_chambers)

    {:noreply, new_state}
  end

  defp extract_relays(chambers) do
    chambers["chamber"] |> Enum.map(fn({_key, x})-> x end ) |> Enum.flat_map(fn(x) -> Enum.map(x, fn({_key,y}) -> {y, :off} end) end) |> Map.new
  end

  defp load_relay_file() do
    {:ok, data} = File.read(Path.join(:code.priv_dir(:relay_ui), "relay.toml"))
    {:ok, chamber} = Toml.decode(data)
    chamber
  end

  defp ammend_chambers(chambers) do
    Enum.map(chambers, fn({key, value}) -> {key, Enum.map(value, fn({key, value1}) -> {key, {value1, :off}} end ) |> Map.new} end) |> Map.new
  end

  defp update_relays(relay_map) do
    relay_map
    |> Enum.each(fn(x) -> update_relay(x) end)
  end

  defp update_relay({relay, _state}) do
    IO.inspect relay
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(RelayUi.PubSub, @topic, {__MODULE__, event, result})
  {:ok, result}
end

end
