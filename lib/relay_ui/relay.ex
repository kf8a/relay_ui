defmodule RelayUi.Relay do
  @moduledoc """
  Documentation for Relay.
  """

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

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def init(_) do
    {:ok, icp} = IcpDas.start_link
    {:ok, %{icp: icp}, {:continue, :load_relay_mapping}}
  end

  def handle_continue(:load_relay_mapping, state) do
    chambers = load_relay_file()

    relays = extract_relays(chambers)

    #TODO set all relays to zero or query relays for current status

    new_state = state
                |> Map.put(:chambers, chambers["chamber"])
                |> Map.put(:relays, relays)

    {:noreply, new_state}
  end

  def handle_call({:lookup, chamber}, _from, state) do
    {:reply, Map.fetch(state[:chambers], chamber), state}
  end

  def handle_call({:relay_state, relay}, _from, state) do
    {:reply, IcpDas.state(state[:icp], Integer.to_string(relay)), state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state[:chambers], state}
  end

  def handle_cast({:close, chamber}, state) do
    {:ok, the_chamber} = Map.fetch(state[:chambers], chamber)
    IO.inspect chamber
    IO.inspect the_chamber
    GenServer.cast(self(), {:on, the_chamber["lid"]})
    # TODO  update the data
    {:noreply, state}
  end

  def handle_cast({:on, relay}, state) do
    IcpDas.on(state[:icp], Integer.to_string(relay))
    {_old, relays} = Map.get_and_update(state[:relays], relay, fn current -> {current, :on} end)
    {:noreply, Map.put(state, :relays, relays)}
  end

  def handle_cast({:off, relay}, state) do
    IcpDas.off(state[:icp], Integer.to_string(relay))
    {_old, relays} = Map.get_and_update(state[:relays], relay, fn current -> {current, :off} end)
    {:noreply, Map.put(state, :relays, relays)}
  end

  defp extract_relays(chambers) do
    chambers["chamber"] |> Enum.map(fn({_key, x})-> x end ) |> Enum.flat_map(fn(x) -> Enum.map(x, fn({_key,y}) -> {y, :off} end) end) |> Map.new
  end

  defp load_relay_file() do
    {:ok, data} = File.read(Path.join(:code.priv_dir(:relay_ui), "relay.toml"))
    {:ok, chamber} = Toml.decode(data)
    chamber
  end

  defp update_relays(relay_map) do
    relay_map
    |> Enum.each(fn(x) -> update_relay(x) end)
  end

  defp update_relay({relay, _state}) do
    IO.inspect relay
  end
end
