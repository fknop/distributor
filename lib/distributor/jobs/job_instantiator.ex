defmodule Distributor.JobInstantiator do
  def instantiate({id, node_total, spec_files}) do
    if !Distributor.JobServer.exists?(id) do
      Horde.DynamicSupervisor.start_child(
        Distributor.GlobalSupervisor,
        Distributor.JobServer.child_spec(
          id: id,
          node_total: node_total,
          spec_files: spec_files
        )
      )
    end
  end
end
