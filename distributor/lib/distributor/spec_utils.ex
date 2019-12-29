defmodule Distributor.SpecUtils do
  def compare_files(a, b) when length(a) != length(b), do: false
  def compare_files([], []), do: true
  def compare_files([H1 | T1], [H2 | T2]) when H1 == H2, do: compare_files(T1, T2)

  def compare_files(_, _), do: false

  def hash_files(spec_files) do
    :crypto.hash(:sha3_256, spec_files) |> Base.encode16(case: :lower)
  end
end
