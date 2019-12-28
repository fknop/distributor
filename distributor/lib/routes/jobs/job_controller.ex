defmodule DistributorWeb.Job.Controller do
  use DistributorWeb, :controller

  alias DistributorWeb.Job.Params, as: Params

  plug Params.RegisterJob, :params when action in [:register_job]

  def register_job(conn, _params) do
    %{
      node_index: node_index,
      node_total: node_total,
      build_id: build_id,
      spec_files: spec_files
    } = conn.assigns[:params]

    id = generate_id(build_id)

    Distributor.JobInstantiator.instantiate({id, node_total, spec_files})
    case Distributor.JobServer.register_node(id, node_index) do
      :ok ->
        conn |> json(%{message: :success})
      {:error, error} ->
        conn |> put_status(400) |> json(%{message: error})
    end
  end

  def request_spec(conn, %{"id" => id}) do
    id = generate_id(id)

    case Distributor.JobServer.request_spec(id) do
      {:ok, spec_files} ->
        conn
        |> json(%{status: :ok, spec_files: spec_files})

      {:error, :empty} ->
        conn
        |> json(%{status: :empty, spec_files: []})
    end
  end

  # TODO: create unique id
  defp generate_id(id) do
    id
  end
end
