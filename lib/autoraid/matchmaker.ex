defmodule Autoraid.Matchmaker do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{available_bosses: _, queues_pid: _, registry_pid: _, rooms_pid: _} = state) do
      interval = Map.get(state, :interval, 1000)
      schedule_work(interval)

      {:ok, Map.put(state, "interval", interval)}
  end

  def handle_info(:matchmake, %{available_bosses: available_bosses, registry_pid: r_pid, queues_pid: q_pid, rooms_pid: ro_pid, interval: interval} = state) do
    matchmake_rooms(available_bosses, r_pid, q_pid)
      |> Autoraid.Junkyard.ok!
      |> Enum.map(fn ({_boss, rooms}) ->
        create_rooms(rooms, q_pid, r_pid, ro_pid)
      end)
      schedule_work(interval)
      {:noreply, state}
  end

  def create_room(%{raid: %{raid_boss: %{name: boss}} = raid, users: users}, r_pid, ro_pid) do
    :ok = Autoraid.RaidRegistry.delete(r_pid, boss, raid)
    Autoraid.RoomRegistry.put(ro_pid, %{raid: raid, members: users, id: UUID.uuid4})
  end

  def create_rooms(rooms, q_pid, r_pid, ro_pid) do
    rooms
    |> Enum.map(
      fn room_struct ->
        try do
          :ok = create_room(room_struct, r_pid, ro_pid)
        rescue
          err -> (
            Logger.error(Exception.format(:error, err, __STACKTRACE__))

            %{raid: %{raid_boss: %{name: boss}} = raid, users: users} = room_struct

            users
            |> Enum.each(fn user -> :ok = Autoraid.RaidQueues.append(q_pid, boss, user) end)

            :ok = Autoraid.RaidRegistry.put(r_pid, boss, raid)

            # let's not let it crash?
            :ok
          )
        end
      end
    )
  end

  @spec matchmake_rooms(any, any, any) :: {:error, :processing_failed} | {:ok, any}
  def matchmake_rooms(available_bosses, r_pid, q_pid) do
    Enum.map(available_bosses, fn boss ->
      {:ok, count} = Autoraid.RaidQueues.count(q_pid, boss)
      {:ok, raids} = Autoraid.RaidRegistry.get(r_pid, boss)

      {boss, [count: count, raids: raids]}
    end)
    |> Enum.map(
      fn ({boss, [count: count, raids: raids]}) ->
        possible_rooms = Enum.filter(raids, &(has_players(&1, count)))
        {boss, [possible_rooms: possible_rooms, count: count]}
      end
    )
    |> Enum.filter(fn ({_boss, [possible_rooms: rooms, count: _count]}) -> Enum.count(rooms) > 0 end)
    |> Enum.reduce(
      [],
      fn ({boss, [possible_rooms: possible_rooms, count: count]}, acc) ->
        acc ++ [{
          boss,
          Enum.reduce(
            possible_rooms,
            [current_count: count, rooms: []],
            fn %{max_invites: m_inv} = possible_room, [current_count: count, rooms: rooms] = state ->
              case count > 0 do
                true ->
                  {:ok, users} = Autoraid.RaidQueues.pop(q_pid, boss, m_inv)
                  [
                    current_count: count - m_inv,
                    rooms: rooms ++ [%{raid: possible_room, users: users}],
                  ]
                false -> state
              end
            end
          )
        }]
      end
    )
    |> Enum.map(fn ({boss, [current_count: _, rooms: rooms]}) -> {boss, rooms} end)
    |> Map.new
    |> Autoraid.Junkyard.make_ok

  rescue
    err ->
      Logger.error(Exception.format(:error, err, __STACKTRACE__))
      {:error, :processing_failed}
  end

  defp has_players(%{max_invites: m_inv}, player_count), do: player_count >= m_inv

  defp schedule_work(interval) do
      Process.send_after(self(), :matchmake, interval)
  end
end
