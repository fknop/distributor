defmodule Distributor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies), [name: Distributor.ClusterSupervisor]]},
      crdt_worker(
        name: Distributor.Handoff.Crdt,
        sync_interval: 5,
        listener: Distributor.Handoff
      ),
      {
        Distributor.Handoff,
        [
          crdt: Distributor.Handoff.Crdt,
          shutdown: 10_000
        ]
      },
      {Horde.Registry, [name: Distributor.GlobalRegistry, keys: :unique]},
      {Horde.DynamicSupervisor,
       [name: Distributor.GlobalSupervisor, strategy: :one_for_one, shutdown: 10_000]},
      {Distributor.NodeConnector,
       modules: [
         {Distributor.GlobalRegistry, &set_members/1},
         {Distributor.GlobalSupervisor, &set_members/1},
         {Distributor.Handoff.Crdt, &set_neighbours/1}
       ]},
      DistributorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Distributor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp crdt_worker(options) do
    listener = Keyword.get(options, :listener, nil)

    {
      DeltaCrdt,
      crdt: DeltaCrdt.AWLWWMap,
      name: Keyword.get(options, :name),
      sync_interval: Keyword.get(options, :sync_interval),
      on_diffs: fn diffs ->
        send(listener, {:crdt_update, diffs})
      end
    }
  end

  defp set_members(name) do
    members =
      [Node.self() | Node.list()]
      |> Enum.map(fn node -> {name, node} end)

    :ok = Horde.Cluster.set_members(name, members)
  end

  defp set_neighbours(crdt) do
    neighbours = Node.list() |> Enum.map(&{crdt, &1})
    DeltaCrdt.set_neighbours({crdt, Node.self()}, neighbours)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DistributorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
