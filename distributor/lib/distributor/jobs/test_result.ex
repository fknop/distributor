defmodule Distributor.TestResult do
  @derive Jason.Encoder
  defstruct [:name, :success, :time, :node]
end
