defmodule Autoraid.MatchmakerTest do
  use ExUnit.Case, async: true

  describe "matchmake_rooms/3 with full queue" do
      setup [:pids, :with_multiple_queues_and_raids]

      test "finds room correctly", %{q_pid: q_pid, r_pid: r_pid, e_x: e_x, e_x2: e_x2} do
        assert {:ok, %{"MISSINGNO" => [^e_x, ^e_x2]}} =
          Autoraid.Matchmaker.matchmake_rooms(["MISSINGNO", "MEW"], r_pid, q_pid)
      end

  end

  describe "create_rooms/3 with full queue" do
    setup [:pids, :with_multiple_queues_and_raids, :without_queued_users]

    test "creates room correctly", %{q_pid: q_pid, r_pid: r_pid, ro_pid: ro_pid, e_x: e_x, e_x2: e_x2} do
      assert {:ok, 0} = Autoraid.RoomRegistry.count(ro_pid)
      assert {:ok, 2} = Autoraid.RaidRegistry.count(r_pid, "MISSINGNO")

      [e_x, e_x2]
      |> Autoraid.Matchmaker.create_rooms(q_pid, r_pid, ro_pid)

      expected_raid_id = e_x.raid.id
      expected_raid_users = e_x.users
      expected_raid2_id = e_x2.raid.id
      expected_raid2_users = e_x2.users

      assert {:ok, [
        %{raid: %{id: ^expected_raid2_id}, members: ^expected_raid2_users},
        %{raid: %{id: ^expected_raid_id}, members: ^expected_raid_users},
      ]} = Autoraid.RoomRegistry.get(ro_pid)
      assert {:ok, 0} = Autoraid.RaidRegistry.count(r_pid, "MISSINGNO")
    end

end

  @tag :long
  describe "genserver" do
    setup [:pids, :with_genserver, :with_multiple_queues_and_raids]

    test "it matchmakes!", %{ro_pid: ro_pid, q_pid: q_pid, r_pid: r_pid} do
      assert {:ok, 0} = Autoraid.RoomRegistry.count(ro_pid)
      assert {:ok, 7} = Autoraid.RaidQueues.count(q_pid, "MISSINGNO")
      assert {:ok, 7} = Autoraid.RaidQueues.count(q_pid, "MEW")
      assert {:ok, 2} = Autoraid.RaidRegistry.count(r_pid, "MISSINGNO")

      # yeah, I don't like this either. but hey, it's short!
      Process.sleep(10)

      assert {:ok, [
        %{raid: %{raid_boss: %{name: "MISSINGNO"}}},
        %{raid: %{raid_boss: %{name: "MISSINGNO"}}},
        %{raid: %{raid_boss: %{name: "MEW"}}},
      ]} = Autoraid.RoomRegistry.get(ro_pid)

      assert {:ok, 2} = Autoraid.RaidQueues.count(q_pid, "MISSINGNO")
      assert {:ok, 6} = Autoraid.RaidQueues.count(q_pid, "MEW")
      assert {:ok, 0} = Autoraid.RaidRegistry.count(r_pid, "MISSINGNO")

      1..10
      |> Enum.map(fn _ ->
        user = Autoraid.Test.FactoryYard.create("User")
        Autoraid.RaidQueues.put(q_pid, "MISSINGNO", user)
        user
      end)

      Process.sleep(10)

      assert {:ok, 3} = Autoraid.RoomRegistry.count(ro_pid)
      assert {:ok, 12} = Autoraid.RaidQueues.count(q_pid, "MISSINGNO")

      raid = Autoraid.Test.FactoryYard.create("Raid", %{max_invites: 12})
      Autoraid.RaidRegistry.put(r_pid, "MISSINGNO", raid)

      Process.sleep(10)

      assert {:ok, 4} = Autoraid.RoomRegistry.count(ro_pid)
      assert {:ok, 0} = Autoraid.RaidQueues.count(q_pid, "MISSINGNO")


      Process.sleep(10)

      assert {:ok, 4} = Autoraid.RoomRegistry.count(ro_pid)
      assert {:ok, 6} = Autoraid.RaidQueues.count(q_pid, "MEW")

      raid = Autoraid.Test.FactoryYard.create("Raid", %{max_invites: 6, raid_boss: %{name: "MEW"}})
      Autoraid.RaidRegistry.put(r_pid, "MEW", raid)

      Process.sleep(10)

      assert {:ok, 5} = Autoraid.RoomRegistry.count(ro_pid)
      assert {:ok, 0} = Autoraid.RaidQueues.count(q_pid, "MEW")
      assert {:ok, 0} = Autoraid.RaidRegistry.count(r_pid, "MEW")
    end

  end

  defp pids(_context) do
    {:ok, q_pid} = Autoraid.RaidQueues.start_link([available_bosses: ["MISSINGNO", "MEW"]])
    {:ok, r_pid} = Autoraid.RaidRegistry.start_link([available_bosses: ["MISSINGNO", "MEW"]])
    {:ok, ro_pid} = Autoraid.RoomRegistry.start_link([])

    %{q_pid: q_pid, r_pid: r_pid, ro_pid: ro_pid}
  end

  defp with_multiple_queues_and_raids(%{q_pid: q_pid, r_pid: r_pid}) do
    raids = [
      Autoraid.Test.FactoryYard.create("Raid"),
      Autoraid.Test.FactoryYard.create("Raid", %{max_invites: 1}),
      Autoraid.Test.FactoryYard.create("Raid", %{max_invites: 1, raid_boss: %{name: "MEW"}})
    ]

    [raid1, raid2, raid3] = raids

    %{users: users} = with_queued_raids("MISSINGNO", q_pid, r_pid, [raid1, raid2])
    %{users: _mew_users} = with_queued_raids("MEW", q_pid, r_pid, [raid3])

    first = Enum.slice(users, 0..3)
    second = Enum.slice(users, 4..4)
    expected_raid = %{raid: raid1, users: first}
    expected_raid2 = %{raid: raid2, users: second}

    %{raid: raid1, raid2: raid2, users: users, e_x: expected_raid, e_x2: expected_raid2}
  end

  def without_queued_users(%{q_pid: q_pid}) do
    {:ok, [_ | _]} = Autoraid.RaidQueues.pop(q_pid, "MISSINGNO", 7)
    :ok
  end

  defp with_queued_raids(name, q_pid, r_pid, raids) do
    raids
    |> Enum.each(&Autoraid.RaidRegistry.put(r_pid, name, &1))

    users = 1..7
    |> Enum.map(fn _ ->
      user = Autoraid.Test.FactoryYard.create("User")
      Autoraid.RaidQueues.put(q_pid, name, user)
      user
    end)

    %{users: users}
  end

  def with_genserver(%{q_pid: q_pid, r_pid: r_pid, ro_pid: ro_pid}) do
    m_pid = start_supervised!({Autoraid.Matchmaker, %{available_bosses: ["MISSINGNO", "MEW"], queues_pid: q_pid, registry_pid: r_pid, rooms_pid: ro_pid, interval: 9} })
    %{m_pid: m_pid}
  end
end
