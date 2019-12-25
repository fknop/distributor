defmodule DistributorWeb.Job.Params.RegisterJob do
  use DistributorWeb, :params

  @primary_key false
  embedded_schema do
    field :build_id, :string
    field :node_index, :integer
    field :node_total, :integer
    field :spec_files, {:array, :string}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:build_id, :node_index, :node_total, :spec_files])
    |> validate_required([:build_id, :node_index, :node_total, :spec_files])
    |> validate_number(:node_total, greater_than: 0)
    |> validate_index(:node_index, :node_total)
  end

  defp validate_index(changeset, index_name, total_name) do
    {_, index_value} = fetch_field(changeset, index_name)
    {_, total_value} = fetch_field(changeset, total_name)

    if (index_value >= 0 and index_value < total_value) or total_value == nil do
      changeset
    else
      add_error(changeset, index_name, "must be greater than zero and smaller than #{total_name}", validation: %{min: 0, max: total_value})
    end
  end
end


