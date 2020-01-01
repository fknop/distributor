defmodule Distributor.RunningSpec do
  @derive Jason.Encoder
  defstruct [:name, :start, :node]
end
