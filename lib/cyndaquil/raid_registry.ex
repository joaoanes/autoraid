defmodule Cyndaquil.RaidRegistry do
  use Agent

  use Cyndaquil.Types

  @doc """
  Starts a new bucket.
  """
  def start_link(opts) do
    [available_bosses: a_b] = opts

    {:ok, _pid} =
      Agent.start_link(fn ->
        a_b
        |> Enum.map(&{&1, []})
        |> Map.new()
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
    end)
  end

  def count(bucket, key) do
    Agent.get(bucket, fn list ->
      case Map.has_key?(list, key) do
        true -> {:ok, Enum.count(Map.get(list, key))}
        false -> {:error, :not_found}
      end
    end)
  end

  def delete(bucket, key, value) do
    Cyndaquil.Logging.log("raid", "delete", %{payload: %{queue: key}})
    Agent.update(bucket, &Map.update!(&1, key, fn list -> List.delete(list, value) end))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, raid) do
    Cyndaquil.Logging.log("raid", "add", %{payload: %{queue: key}})

    Agent.update(bucket, &Map.update!(&1, key, fn raids -> raids ++ [raid] end))
  end
end
