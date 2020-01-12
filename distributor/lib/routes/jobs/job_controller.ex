defmodule DistributorWeb.Job.Controller do
  use DistributorWeb, :controller

  alias DistributorWeb.Job.Params, as: Params

  plug Params.Environment, :environment when action in [:fetch_specs, :fetch_queue, :record_queue]
  plug Params.FetchSpecs, :params when action in [:fetch_specs]
  plug Params.RecordSpecs, :results when action in [:record_queue]


  def fetch_queue(conn, _params) do
    id = generate_id(conn.assigns[:environment])

    if Distributor.JobServer.exists?(id) do
      state = Distributor.JobServer.get_state(id)
      conn |> json(state)
    else
      conn |> send_resp(404, "")
    end
  end


  def fetch_specs(conn, _params) do
    %{
      spec_files: spec_files,
      initialize: initialize
    } = conn.assigns[:params]

    %{
      node_index: node_index,
      node_total: node_total
    } = conn.assigns[:environment]


    IO.inspect(conn.assigns[:environment])
    IO.inspect(conn.assigns[:params])

    id = generate_id(conn.assigns[:environment])

    result =
      if initialize do
        Distributor.JobInstantiator.instantiate({id, node_total, spec_files})

        case Distributor.JobServer.register_node(id, node_index) do
          :ok ->
            :ok

          {:error, error} ->
            {:error, error}
        end
      else
        :ok
      end


    with :ok <- result do
      case Distributor.JobServer.request_spec(id, Map.merge(conn.assigns[:params], conn.assigns[:environment])) do
        {:ok, spec_files} ->
          conn
          |> json(%{spec_files: spec_files})
      end
    else
      {:error, error} ->
        conn |> put_status(400) |> json(%{status: :error, message: error})
    end
  end


  def record_queue(conn, _params) do
    id = generate_id(conn.assigns[:environment])

    %{
      node_index: node_index,
      node_total: node_total,
    } = conn.assigns[:environment]

    %{
      test_results: test_results
    } = conn.assigns[:results]

    if Distributor.JobServer.exists?(id) do
      transformed_test_results = Enum.map(test_results,
        fn test_result ->
          for {key, val} <- test_result, into: %{}, do: {String.to_atom(key), val}
        end)

      Distributor.JobServer.record(id, Map.merge(conn.assigns[:environment], %{ test_results: transformed_test_results }))
      conn |> json(%{ message: :ok })
    else
      conn |> send_resp(404, "")
    end
  end

  defp generate_id(%{build_id: build_id, branch: branch, commit_sha: commit_sha, test_suite: test_suite, api_token: api_token}) do
    {api_token, branch, commit_sha, test_suite, build_id}
  end
end
