defmodule DistributorWeb.Job.Params.FetchSpecs do
  use DistributorWeb, :params

  @primary_key false
  embedded_schema do
    field :test_suite, :string
    field :build_id, :string
    field :commit_sha, :string
    field :branch, :string
    field :node_index, :integer
    field :node_total, :integer
    field :spec_files, {:array, :string}
    field :api_token, :string

    field :initialize, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :test_suite,
      :build_id,
      :commit_sha,
      :branch,
      :node_index,
      :node_total,
      :spec_files,
      :api_token,
      :initialize
    ])
    |> validate_required([
      :test_suite,
      :build_id,
      :commit_sha,
      :branch,
      :node_index,
      :node_total,
      :api_token,
      :initialize
    ])
    |> validate_spec_files
    |> validate_number(:node_total, greater_than: 0)
    |> validate_index(:node_index, :node_total)
  end

  defp validate_spec_files(changeset) do
    {_, initialize} = fetch_field(changeset, :initialize)

    if initialize do
      changeset
      |> validate_required([:spec_files])
    else
      {_, spec_files} = fetch_field(changeset, :spec_files)

      if spec_files != nil do
        add_error(changeset, :spec_files, "spec_files must not be present when not initializing the queue")
      else
        changeset
      end
    end
  end

  defp validate_index(changeset, index_name, total_name) do
    {_, index_value} = fetch_field(changeset, index_name)
    {_, total_value} = fetch_field(changeset, total_name)

    if (index_value >= 0 and index_value < total_value) or total_value == nil do
      changeset
    else
      add_error(changeset, index_name, "must be greater than zero and smaller than #{total_name}",
        validation: %{min: 0, max: total_value}
      )
    end
  end
end


defmodule DistributorWeb.Job.Params.TestResult do
  use DistributorWeb, :params

  @primary_key false
  embedded_schema do
    field :name, :string
    field :time, :integer
    field :success, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name, :time, :success
    ])
    |> validate_required([
      :name, :time, :success
    ])
    |> validate_number(:time, greater_than: 0)
  end
end

defmodule DistributorWeb.Job.Params.RecordSpecs do
  use DistributorWeb, :params

  alias DistributorWeb.Job.Params.TestResult

  @primary_key false
  embedded_schema do
    embeds_many :test_results, TestResult
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :test_results
    ])
    |> validate_required([
      :test_results
    ])
  end

end
