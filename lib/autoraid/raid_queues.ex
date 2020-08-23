defmodule Autoraid.RaidQueues do
  use Agent

  use Autoraid.Types
  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link(), do: start_link(available_bosses: ["MISSINGNO"])

  @spec start_link([{:available_bosses, any}, ...]) :: {:error, any} | {:ok, pid}
  def start_link(available_bosses: available_bosses) do
    Agent.start_link(fn ->
      available_bosses
      |> Enum.map(&{&1, []})
      |> Map.new()
    end)
  end

  @spec get(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
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

  @spec put(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def put(bucket, key, value) do
    Autoraid.Logging.log("queue", "enter", %{payload: %{queue: key}})
    Agent.update(bucket, &Map.update!(&1, key, fn users -> users ++ [value] end))
  end

  def append(bucket, key, value) do
    Autoraid.Logging.log("queue", "enter", %{payload: %{queue: key, append: true}})
    Agent.update(bucket, &Map.update!(&1, key, fn users -> [value] ++ users end))
  end

  def remove_from_all(bucket, value) do
    Autoraid.Logging.log("queue", "remove", %{payload: %{value: value, all: true}})

    Agent.update(
      bucket,
      fn raids ->
        raids
        |> Enum.map(fn {boss, queue} ->
          {
            boss,
            queue
            |> Enum.filter(fn user ->
              Autoraid.Web.Junkyard.registry_id_from_user(user) !=
                Autoraid.Web.Junkyard.registry_id_from_user(value)
            end)
          }
        end)
        |> Map.new()
      end
    )
  end

  def pop(bucket, key, num \\ 1) do
    {users, rest} =
      Agent.get(bucket, fn l ->
        Map.get(l, key)
      end)
      |> Enum.split(num)

    Autoraid.Logging.log("queue", "pop", %{payload: %{queue: key}})

    :ok = Agent.update(bucket, &Map.update!(&1, key, fn _ -> rest end))
    {:ok, users}
  end
end
