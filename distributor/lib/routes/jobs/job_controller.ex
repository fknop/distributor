defmodule DistributorWeb.Job.Controller do
  use DistributorWeb, :controller

  alias DistributorWeb.Job.Params, as: Params

  plug Params.FetchSpecs, :params when action in [:fetch_queue]

  def fetch_queue(conn, _params) do
    %{
      node_index: node_index,
      node_total: node_total,
      spec_files: spec_files,
      initialize: initialize
    } = conn.assigns[:params]

    id = generate_id(conn.assigns[:params])

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
      case Distributor.JobServer.request_spec(id, conn.assigns[:params]) do
        {:ok, spec_files} ->
          conn
          |> json(%{spec_files: spec_files})
      end
    else
      {:error, error} ->
        conn |> put_status(400) |> json(%{status: :error, message: error})
    end
  end

  defp generate_id(%{build_id: build_id, branch: branch, commit_sha: commit_sha, test_suite: test_suite, api_token: api_token}) do
    {api_token, branch, commit_sha, test_suite, build_id}
  end
end
