defmodule Autoraid.Junkyard do
  require IEx
  def pry!(x) do
    IEx.pry()
    x
  end

  def inspect!(x) do
    inspect!(x, nil)
  end
  def inspect!(x, prefix) do
    if prefix, do: IO.puts(prefix)
    IO.inspect x
    x
  end

  def make_ok(x) do
    {:ok, x}
  end

  def ok!(x) do
    {:ok, res} = x
    res
  end
end
