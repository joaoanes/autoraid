defmodule Autoraid.RoomRegistry do
  use Agent

  use Autoraid.Types

  @doc """
  Starts a new bucket.
  """
  def start_link(opts) do
    Agent.start_link(
      fn ->
        []
      end,
      opts
    )
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket) do
    Agent.get(bucket, &Autoraid.Junkyard.make_ok/1)
  end

  def count(bucket) do
    Agent.get(bucket, &Enum.count/1)
    |> Autoraid.Junkyard.make_ok()
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, room) do
    Autoraid.Logging.log("room", "create", %{
      payload: %{id: room.id, boss_name: room.raid.raid_boss.name}
    })

    Agent.update(bucket, &([room] ++ &1))
  end
end
