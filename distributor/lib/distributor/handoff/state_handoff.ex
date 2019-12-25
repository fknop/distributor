defmodule Distributor.Handoff do
  use GenServer

  require Logger

  defmodule State do
    defstruct ets_table: nil,
              requests: %{},
              crdt: nil
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def handoff(id, state) do
    GenServer.call(__MODULE__, {:handoff, id, state})
  end

  def request(id, pid, message) do
    GenServer.call(__MODULE__, {:request, id, pid, message})
  end

  def unrequest(id) do
    GenServer.call(__MODULE__, {:unrequest, id})
  end

  def init(options) do
    Process.flag(:trap_exit, true)
    crdt = Keyword.get(options, :crdt)

    :ets.new(__MODULE__, [:named_table, {:read_concurrency, true}])

    state = %State{
      ets_table: __MODULE__,
      crdt: crdt
    }

    {:ok, state}
  end

  def handle_call({:handoff, id, handoff_state}, _from, state) do
    DeltaCrdt.mutate(state.crdt, :add, [id, handoff_state])
    Logger.info("Handoff: added #{id}")
    {:reply, :ok, state}
  end

  def handle_call({:request, id, pid, message}, _from, state) do
    case :ets.lookup(state.ets_table, id) do
      [{^id, data}] ->
        Logger.info("Handoff fulfilling request for #{inspect(id)}")
        DeltaCrdt.mutate(state.crdt, :remove, [id])
        {:reply, {:ok, data}, state}

      _ ->
        request = {pid, message}
        {:reply, {:ok, :requested}, %{state | requests: Map.put(state.requests, id, request)}}
    end
  end

  def handle_call({:unrequest, id}, _from, state) do
    {:reply, :ok, %{state | requests: Map.delete(state.requests, id)}}
  end

  def handle_info({:crdt_update, diffs}, state) do
    Logger.debug("crdt_udpate: node #{Node.self()} - #{inspect(diffs)}")
    {:noreply, process_diffs(state, diffs)}
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    {:stop, reason, state}
  end

  defp process_diffs(state, []), do: state

  defp process_diffs(state, [diff | diffs]) do
    process_diff(state, diff) |> process_diffs(diffs)
  end

  defp process_diff(state, {:add, id, value}) do
    :ets.insert(state.ets_table, {id, value})

    requests = state.requests

    case Map.get(requests, id) do
      nil ->
        state

      {pid, message} ->
        send(pid, {message, value})
        Logger.info("Handoff sending message for #{inspect(id)}")
        DeltaCrdt.mutate(state.crdt, :remove, [id])
        %{state | requests: Map.delete(requests, id)}
    end
  end

  defp process_diff(state, {:remove, id}) do
    :ets.delete(state.ets_table, id)
    state
  end
end
