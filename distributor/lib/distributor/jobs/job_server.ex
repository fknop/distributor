defmodule Distributor.JobServer do
  use GenServer, restart: :transient, shutdown: 10_000
  require Logger

  alias Distributor.Handoff

  # Timeout (30 minutes) after which the server will shutdown
  # if no messages were received during that time period
  @timeout 30 * 60 * 1_000

  def start_link(opts) do
    id = Keyword.get(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: via_tuple(id))
  end

  def exists?(id) do
    id
    |> via_tuple
    |> GenServer.whereis() != nil
  end

  def init(opts) do
    id = Keyword.get(opts, :id)
    spec_files = Keyword.get(opts, :spec_files)
    node_total = Keyword.get(opts, :node_total)

    state = %{
      job_id: id,
      spec_files: Enum.sort(spec_files),
      node_total: node_total,
      registered_nodes: []
    }

    {:ok, state, {:continue, :after_init}}
  end

  def terminate(:normal, state) do
    Handoff.unrequest(state.job_id)
    :ok
  end

  def terminate(_reason, state) do
    do_handoff(state)
    :ok
  end

  def register_node(id, node_id) do
    id
    |> via_tuple
    |> GenServer.call({:register_node, node_id})
  end

  def request_spec(id) do
    id
    |> via_tuple
    |> GenServer.call({:request_spec})
  end

  def handle_call({:register_node, node_id}, _from, state) do
    node_total = state.node_total
    registered_nodes = state.registered_nodes

    cond do
      Enum.find(registered_nodes, nil, fn value -> value == node_id end) != nil ->
        {:reply, {:error, :already_registered}, state, @timeout}

      Enum.count(registered_nodes) == node_total ->
        {:reply, {:error, :exceed_node_total}, state, @timeout}

      true ->
        nodes = Enum.sort([node_id | registered_nodes])
        {:reply, :ok, %{state | registered_nodes: nodes}, @timeout}
    end
  end

  def handle_call({:request_spec}, _from, %{spec_files: [spec | specs]} = state) do
    {:reply, {:ok, [spec]}, %{state | spec_files: specs}, @timeout}
  end

  def handle_call({:request_spec}, _from, %{spec_files: []} = state) do
    {:reply, {:error, :empty}, state, @timeout}
  end

  def handle_continue(:after_init, state) do
    {migrate, handoff_state} =
      case Handoff.request(state.job_id, self(), :requested_handoff) do
        {:ok, :requested} ->
          {false, state}

        {:ok, data} ->
          {true, data}
      end

    if migrate do
      {:noreply, handoff_state, @timeout}
    else
      {:noreply, state, @timeout}
    end
  end

  defp do_handoff(state) do
    Handoff.unrequest(state.job_id)
    Handoff.handoff(state.job_id, state)

    # Let time for the DeltaCrdt to propagate
    # This will not block anything as Elixir is concurrent
    Process.sleep(500)
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Distributor.GlobalRegistry, {:job, id}}}
  end
end
