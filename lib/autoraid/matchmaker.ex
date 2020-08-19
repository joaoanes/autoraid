defmodule Autoraid.Matchmaker do
  use GenServer
  require Logger

  def init([available_bosses: _, queues_pid: _, registry_pid: _, rooms_pid: _] = state) do
      schedule_work()
      {:ok, state}
  end

  def handle_call(:matchmake, [available_bosses: available_bosses, registry_pid: r_pid, queues_pid: q_pid, rooms_pid: ro_pid] = state) do
      matchmake_rooms(available_bosses, r_pid, q_pid)
      |> Enum.map(fn ({_boss, rooms}) ->
        create_rooms(rooms, q_pid, ro_pid)
      end)
      schedule_work() # Reschedule once more
      {:noreply, state}
  end

  def create_rooms(_rooms, _q_pid, _ro_pid) do
    # create room and warn next service to send room receipts
    # if this fails return users to queue with prio
  end

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
                    rooms: rooms ++ [Map.merge(possible_room, %{users: users})],
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

  rescue
    err ->
      Logger.error(Exception.format(:error, err, __STACKTRACE__))
      {:error, :processing_failed}
  end

  defp has_players(%{max_invites: m_inv}, player_count), do: player_count >= m_inv

  defp schedule_work() do
      Process.send_after(self(), :matchmake, 5000)
  end
end
