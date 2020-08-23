defmodule Autoraid.Logging do
  require Logger

  def log(type, dimension, payload) do
    Logger.log(:debug, Jason.encode!(%{type: type, dimension: dimension, payload: payload}))
  end
end
