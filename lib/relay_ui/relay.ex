defmodule RelayUi.Relay do
  @moduledoc """
  Documentation for Relay.
  """

  @topic inspect(__MODULE__)
  @testing Application.get_env(:relay_ui, :testing)

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def lookup(pid, chamber) do
    GenServer.call(pid, {:lookup, chamber})
  end

  def on(pid, relay_path) do
    GenServer.cast(pid, {:on, relay_path})
  end

  def off(pid, relay_path) do
    GenServer.cast(pid, {:off, relay_path})
  end

  def status(pid, relay) do
    GenServer.call(pid, {:relay_state, relay})
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(RelayUi.PubSub, @topic)
  end

  def init(_) do
    {:ok, icp} = IcpDas.start_link("ttyUSB1")
    {:ok, %{icp: icp}, {:continue, :load_relay_mapping}}
  end

  def handle_continue(:load_relay_mapping, state) do
    chambers = load_relay_file()

    new_chambers = ammend_chambers(chambers["chamber"], state[:icp])

    {:noreply, Map.put(state, :chambers, new_chambers)}
  end

  def handle_call({:lookup, chamber}, _from, state) do
    {:reply, Map.fetch(state[:chambers], chamber), state}
  end

  def handle_call({:relay_state, relay}, _from, state) do
    # TODO this needs to translate to a chamber array
    {:reply, IcpDas.state(state[:icp], Integer.to_string(relay)), state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state[:chambers], state}
  end

  def handle_cast({:on, path}, state) do
    # look up the relay id
    {relay, _state} = get_in(state[:chambers], path)

    if (@testing == false) do
      IcpDas.on(state[:icp], Integer.to_string(relay))
    end
    new_chambers = update_in(state[:chambers], path, fn({key, _value}) -> {key, :on} end)
    Phoenix.PubSub.broadcast(RelayUi.PubSub, @topic, {__MODULE__, [:relay, :change], new_chambers})

    Phoenix.PubSub.broadcast(
      RelayUi.PubSub,
      @topic,
      {__MODULE__, [:relay, :change], new_chambers}
    )

    {:noreply, Map.put(state, :chambers, new_chambers)}
  end

  def handle_cast({:off, path}, state) do
    # look up the relay id
    {relay, _state} = get_in(state[:chambers], path)

    if (@testing == false) do
      IcpDas.off(state[:icp], Integer.to_string(relay))
    end
    new_chambers = update_in(state[:chambers], path, fn({key, _value}) -> {key, :off} end)
    Phoenix.PubSub.broadcast(RelayUi.PubSub, @topic, {__MODULE__, [:relay, :change], new_chambers})

    {:noreply, Map.put(state, :chambers, new_chambers)}
  end

  defp load_relay_file() do
    {:ok, data} = File.read(Path.join(:code.priv_dir(:relay_ui), "relay.toml"))
    {:ok, chamber} = Toml.decode(data)
    chamber
  end

  defp ammend_chambers(chambers, icp) do
    Enum.map(chambers, fn {key, value} ->
      {key,
       Enum.map(value, fn {key, value1} -> {key, {value1, relay_status(value1, icp)}} end)
       |> Map.new()}
    end)
    |> Map.new()
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(RelayUi.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  defp relay_status(relay, icp) do
    if (@testing == false) do
      IcpDas.state(icp, Integer.to_string(relay))
    end
    :off
  end
end
