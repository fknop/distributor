defmodule DistributorWeb.JobController do
  use DistributorWeb, :controller

  defmodule DistributorWeb.Params.RegisterJob do
    use DistributorWeb.Params

    @primary_key false
    embedded_schema do
      field :build_id, :string
      field :node_index, :number
      field :node_total, :number
      field :spec_files, {:array, :string}
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:build_id, :node_index, :node_total, :spec_files])
      |> validate_required([:build_id, :node_index, :node_total, :spec_files])
      |> validate_number(:node_total, greater_than: 0)
      |> validate_index(:node_index, :node_total)
    end

    defp validate_index(changeset, index_name, total_name, opts \\ []) do
      {_, index_value} = fetch_field(changeset, index_name)
      {_, total_value} = fetch_field(changeset, total_name)

      if index_value >= 0 and index_value < total_value do
        changeset
      else
        msg = message(opts, "must be greater than zero and smaller than #{total_name}")
        add_error(changeset, index_name, msg, to_field: total_name)
      end
    end
  end

  plug DistributorWeb.Params.RegisterJob, :body when action in [:register_job]

  def register_job(conn, _params) do
    %{
      node_index: node_index,
      node_total: node_total,
      build_id: build_id,
      spec_files: spec_files
    } = conn.assigns[:body]

    id = generate_id(build_id)

    Distributor.JobInstantiator.instantiate({id, node_total, spec_files})
    Distributor.JobServer.register_node(id, node_index)
  end

  def request_spec(conn, _params) do
    %{
      build_id: build_id
    } = conn.assigns[:body]

    id = generate_id(build_id)

    case Distributor.JobServer.request_spec(id) do
      {:ok, spec_file} ->
        conn
        |> json(%{status: :ok, spec_file: spec_file})

      {:error, :empty} ->
        conn
        |> json(%{status: :empty, spec_file: nil})
    end
  end

  # TODO: create unique id
  defp generate_id(id) do
    id
  end
end
