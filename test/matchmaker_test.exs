defmodule Autoraid.MatchmakerTest do
  use ExUnit.Case, async: true

  describe "matchmake_rooms/3 with full queue" do
      setup [:pids, :with_multiple_queues_and_raids]

      test "finds room correctly", %{q_pid: q_pid, r_pid: r_pid, raid: raid, raid2: raid2} do
        expected_raid = Map.merge(raid, %{users: [1,2,3,4]})
        expected_raid2 = Map.merge(raid2, %{users: [5]})
        assert %{"MISSINGNO" => [^expected_raid, ^expected_raid2]} =
          Autoraid.Matchmaker.matchmake_rooms(["MISSINGNO"], r_pid, q_pid)
          |> Map.new
      end

  end

  defp pids(_context) do
    {:ok, q_pid} = Autoraid.RaidQueues.start_link([available_bosses: ["MISSINGNO", "MEW"]])
    {:ok, r_pid} = Autoraid.RaidRegistry.start_link([available_bosses: ["MISSINGNO", "MEW"]])

    %{q_pid: q_pid, r_pid: r_pid}
  end

  defp with_multiple_queues_and_raids(%{q_pid: q_pid, r_pid: r_pid}) do
    raid = Autoraid.Test.Factory.create("Raid")
    raid2 = Autoraid.Test.Factory.create("Raid", %{max_invites: 1, raid_boss: [name: "MEW"]})
    _raid3 = Autoraid.Test.Factory.create("Raid", %{max_invites: 6, raid_boss: [name: "MISSINGNO"]})

    :ok = with_queued_raids("MISSINGNO", q_pid, r_pid, raid, raid2)

    %{raid: raid, raid2: raid2}
  end

  defp with_queued_raids(name, q_pid, r_pid, raid, raid2) do
    Autoraid.RaidRegistry.put(r_pid, name, raid)
    Autoraid.RaidRegistry.put(r_pid, name, raid2)
    Autoraid.RaidQueues.put(q_pid, name, 1)
    Autoraid.RaidQueues.put(q_pid, name, 2)
    Autoraid.RaidQueues.put(q_pid, name, 3)
    Autoraid.RaidQueues.put(q_pid, name, 4)
    Autoraid.RaidQueues.put(q_pid, name, 5)
  end
end
