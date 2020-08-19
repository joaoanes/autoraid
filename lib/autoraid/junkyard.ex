defmodule Autoraid.Junkyard do
  require IEx
  def pry!(x) do
    IEx.pry()
    x
  end

  def inspect!(x) do
    IO.inspect x
    x
  end
end
