defmodule Autoraid.RaidQueuesTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Autoraid.RaidQueues.start_link([available_bosses: ["MISSINGNO"]])
    user = Autoraid.Test.FactoryYard.create("User")
    %{bucket: bucket, user: user}
  end

  test "returns error on getting missing raid", %{bucket: bucket} do
    assert Autoraid.RaidQueues.get(bucket, "milk") == {:error, :not_found}
  end

  test "gets empty list at astart", %{bucket: bucket} do
    assert Autoraid.RaidQueues.get(bucket, "MISSINGNO") == {:ok, []}
  end

  test "adds to raid queue", %{bucket: bucket, user: user} do
    assert Autoraid.RaidQueues.put(bucket, "MISSINGNO", user) == :ok
    assert Autoraid.RaidQueues.get(bucket, "MISSINGNO") == {:ok, [user]}
  end

  describe "with non-empty queue" do
    setup do
      {:ok, bucket} = Autoraid.RaidQueues.start_link([available_bosses: ["MISSINGNO"]])
      random_size = rem(ExUnit.configuration()[:seed], 8) + 3

      users = Enum.map(1..random_size, fn _ ->
        user = Autoraid.Test.FactoryYard.create("User")
        :ok = Autoraid.RaidQueues.put(bucket, "MISSINGNO", user)
        user
      end)

      %{bucket: bucket, expected_size: random_size, users: users}
    end

    test "adds to raid queue", %{bucket: bucket, users: users} do
      user = Autoraid.Test.FactoryYard.create("User")
      assert Autoraid.RaidQueues.put(bucket, "MISSINGNO", user) == :ok
      assert Autoraid.RaidQueues.get(bucket, "MISSINGNO") == {:ok, users ++ [user]}
    end

    test "counts correctly", %{bucket: bucket, expected_size: expected_size} do
      assert Autoraid.RaidQueues.count(bucket, "MISSINGNO") == {:ok, expected_size}
    end

    test "pops in order", %{bucket: bucket, expected_size: expected_size, users: [first | [second | [third | _rest]]]} do
      assert {:ok, [^first]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")
      assert {:ok, [^second]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")
      assert {:ok, [^third]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")

      assert Autoraid.RaidQueues.count(bucket, "MISSINGNO") == {:ok, expected_size - 3}
    end

    test "appends in order", %{bucket: bucket} do
      :ok = Autoraid.RaidQueues.append(bucket, "MISSINGNO", 1337)
      assert {:ok, [1337]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")
    end
  end
end
