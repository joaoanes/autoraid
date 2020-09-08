defmodule Cyndaquil.RaidQueuesTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Cyndaquil.RaidQueues.start_link([available_bosses: ["MISSINGNO"]])
    user = Cyndaquil.Test.FactoryYard.create("User")
    %{bucket: bucket, user: user}
  end

  test "returns error on getting missing raid", %{bucket: bucket} do
    assert Cyndaquil.RaidQueues.get(bucket, "milk") == {:error, :not_found}
  end

  test "gets empty list at astart", %{bucket: bucket} do
    assert Cyndaquil.RaidQueues.get(bucket, "MISSINGNO") == {:ok, []}
  end

  test "adds to raid queue", %{bucket: bucket, user: user} do
    assert Cyndaquil.RaidQueues.put(bucket, "MISSINGNO", user) == :ok
    assert Cyndaquil.RaidQueues.get(bucket, "MISSINGNO") == {:ok, [user]}
  end

  describe "with non-empty queue" do
    setup do
      {:ok, bucket} = Cyndaquil.RaidQueues.start_link([available_bosses: ["MISSINGNO"]])
      random_size = rem(ExUnit.configuration()[:seed], 8) + 3

      users = Enum.map(1..random_size, fn _ ->
        user = Cyndaquil.Test.FactoryYard.create("User")
        :ok = Cyndaquil.RaidQueues.put(bucket, "MISSINGNO", user)
        user
      end)

      %{bucket: bucket, expected_size: random_size, users: users}
    end

    test "adds to raid queue", %{bucket: bucket, users: users} do
      user = Cyndaquil.Test.FactoryYard.create("User")
      assert Cyndaquil.RaidQueues.put(bucket, "MISSINGNO", user) == :ok
      assert Cyndaquil.RaidQueues.get(bucket, "MISSINGNO") == {:ok, users ++ [user]}
    end

    test "counts correctly", %{bucket: bucket, expected_size: expected_size} do
      assert Cyndaquil.RaidQueues.count(bucket, "MISSINGNO") == {:ok, expected_size}
    end

    test "pops in order", %{bucket: bucket, expected_size: expected_size, users: [first | [second | [third | _rest]]]} do
      assert {:ok, [^first]} = Cyndaquil.RaidQueues.pop(bucket, "MISSINGNO")
      assert {:ok, [^second]} = Cyndaquil.RaidQueues.pop(bucket, "MISSINGNO")
      assert {:ok, [^third]} = Cyndaquil.RaidQueues.pop(bucket, "MISSINGNO")

      assert Cyndaquil.RaidQueues.count(bucket, "MISSINGNO") == {:ok, expected_size - 3}
    end

    test "appends in order", %{bucket: bucket} do
      :ok = Cyndaquil.RaidQueues.append(bucket, "MISSINGNO", 1337)
      assert {:ok, [1337]} = Cyndaquil.RaidQueues.pop(bucket, "MISSINGNO")
    end
  end
end
