defmodule Distributor.NodeConnector do
  use GenServer

  require Logger

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    modules = Keyword.get(options, :modules, [])
    connect(modules)
    {:ok, modules}
  end

  def handle_info({:nodeup, node, _info}, state) do
    Logger.info("NodeConnector: node #{inspect(node)} is up")
    connect(state)
    {:noreply, state}
  end

  def handle_info({:nodedown, node, _info}, state) do
    Logger.info("NodeConnector: node #{inspect(node)} is down")
    connect(state)
    {:noreply, state}
  end

  defp connect(modules) do
    for {name, connector} <- modules do
      connector.(name)
    end
  end
end
