defmodule Distributor.JobServer do
  use GenServer, restart: :transient, shutdown: 10_000
  require Logger
  require Distributor.SpecUtils

  alias Distributor.Handoff
  alias Distributor.TestResult
  alias Distributor.RunningSpec

  # Timeout (30 minutes) after which the server will shutdown
  # if no messages were received during that time period
  @timeout 30 * 60 * 1_000

  defguardp is_completed(spec_files, test_results) when map_size(test_results) == length(spec_files)

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
    spec_files = Keyword.get(opts, :spec_files) |> Enum.sort
    node_total = Keyword.get(opts, :node_total)


    state = %{
      job_id: id,
      spec_files: spec_files,
      remaining_spec_files: spec_files,
      running_spec_files: %{},
      test_results: %{},
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

  def register_node(id, node_index) do
    id
    |> via_tuple
    |> GenServer.call({:register_node, node_index})
  end

  def request_spec(id, opts) do
    id
    |> via_tuple
    |> GenServer.call({:request_spec, opts})
  end

  def record(id, opts) do
    id
    |> via_tuple
    |> GenServer.call({:record, opts})
  end

  def get_test_results(id) do
    id
    |> via_tuple
    |> GenServer.call({:get_test_results})
  end

  def get_spec_files(id) do
    id
    |> via_tuple
    |> GenServer.call({:get_spec_files})
  end

  def handle_call({:register_node, node_index}, _from, state) do
    node_total = state.node_total
    registered_nodes = state.registered_nodes

    cond do
      Enum.find(registered_nodes, nil, fn value -> value == node_index end) != nil ->
        {:reply, {:error, :already_registered}, state, @timeout}

      Enum.count(registered_nodes) == node_total ->
        {:reply, {:error, :exceed_node_total}, state, @timeout}

      true ->
        nodes = Enum.sort([node_index | registered_nodes])
        {:reply, :ok, %{state | registered_nodes: nodes}, @timeout}
    end
  end

  def handle_call({:request_spec, _}, _from, %{spec_files: spec_files, test_results: test_results} = state) when is_completed(spec_files, test_results) do
    {:reply, {:ok, []}, state, @timeout}
  end

  def handle_call({:request_spec, opts}, _from, %{remaining_spec_files: [spec | specs]} = state) do
    %{
      node_index: node_index
    } = opts

    running_spec = %RunningSpec{name: spec, node: node_index, start: :os.system_time(:millisecond)}

    new_state =
      state
      |> add_running(running_spec)
      |> Map.put(:remaining_spec_files, specs)

    {:reply, {:ok, [spec]}, new_state , @timeout}
  end

  def handle_call({:request_spec, _}, _from, %{remaining_spec_files: []} = state) do
    {:reply, {:ok, []}, state, @timeout}
  end

  def handle_call({:record, _}, _from, %{spec_files: spec_files, test_results: test_results} = state) when is_completed(spec_files, test_results) do
    {:reply, :ok, state, @timeout}
  end

  def handle_call({:record, opts}, _from, state) do
    %{
      node_index: node_index,
      test_results: test_results
    } = opts

    recorded_test_results =
      test_results
        |> Enum.filter(
          &Map.has_key?(state.running_spec_files, &1.name)
        )
        |> Enum.map(
          &Map.put(&1, :node, node_index)
        )
        |> Enum.map(&struct(TestResult, &1))

    new_state =
      Enum.reduce(
        recorded_test_results,
        state,
        &add_completed(&2, &1)
      )

    # TODO: if completed, schedule server shutdown sooner than @timeout

    {:reply, :ok, new_state, @timeout}
  end

  def handle_call({:get_spec_files}, _from, %{spec_files: spec_files} = state) do
    {:reply, spec_files, state, @timeout}
  end

  def handle_call({:get_test_results}, _from, %{test_results: test_results} = state) do
    {:reply, test_results, state, @timeout}
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


  defp add_running(state, %RunningSpec{name: name} = running_spec) do
    %{
      running_spec_files: specs
    } = state

    if Map.has_key?(specs, name) do
      state
    else
      running_spec_files = Map.put(specs, name, running_spec)
      %{state | running_spec_files: running_spec_files}
    end
  end

  defp add_completed(state, %TestResult{name: name} = test_result) do
    %{
      test_results: results
    } = state

    if Map.has_key?(results, name) do
      state
    else
      test_results = Map.put(results, name, test_result)
      running_spec_files = Map.delete(state.running_spec_files, name)
      %{state | test_results: test_results, running_spec_files: running_spec_files}
    end
  end
end
