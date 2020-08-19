
defmodule Autoraid.RoomRegistry do
  use Agent

  use Autoraid.Types
  @doc """
  Starts a new bucket.
  """
  def start_link([]) do
    Agent.start_link(fn ->
      []
    end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, fn list ->
      case Map.has_key?(list, key) do
        true -> {:ok, Map.get(list, key)}
        false -> {:error, :not_found}
      end
    end )
  end

  def count(bucket, key) do
    Agent.get(bucket, fn list ->
      case Map.has_key?(list, key) do
        true -> {:ok, Enum.count(Map.get(list, key))}
        false -> {:error, :not_found}
      end
    end )
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, room) do
    Agent.update(bucket, &Map.update!(&1, key, fn rooms -> rooms ++ [room] end))
  end
end
