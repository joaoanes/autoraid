defmodule Autoraid.RaidQueuesTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Autoraid.RaidQueues.start_link([available_bosses: ["MISSINGNO"]])
    %{bucket: bucket}
  end

  test "returns error on getting missing raid", %{bucket: bucket} do
    assert Autoraid.RaidQueues.get(bucket, "milk") == {:error, :not_found}
  end

  test "gets empty list at astart", %{bucket: bucket} do
    assert Autoraid.RaidQueues.get(bucket, "MISSINGNO") == {:ok, []}
  end

  test "adds to raid queue", %{bucket: bucket} do
    assert Autoraid.RaidQueues.put(bucket, "MISSINGNO", 1) == :ok
    assert Autoraid.RaidQueues.get(bucket, "MISSINGNO") == {:ok, [1]}
  end

  describe "with non-empty queue" do
    setup do
      {:ok, bucket} = Autoraid.RaidQueues.start_link([available_bosses: ["MISSINGNO"]])
      random_size = rem(ExUnit.configuration()[:seed], 8) + 2

      Enum.each(1..random_size, fn i ->
        :ok = Autoraid.RaidQueues.put(bucket, "MISSINGNO", i)
      end)

      %{bucket: bucket, expected_size: random_size}
    end

    test "adds to raid queue", %{bucket: bucket, expected_size: expected_size} do
      assert Autoraid.RaidQueues.put(bucket, "MISSINGNO", expected_size + 1) == :ok
      assert Autoraid.RaidQueues.get(bucket, "MISSINGNO") == {:ok, Enum.map(1..(expected_size + 1), fn i -> i end)}
    end

    test "counts correctly", %{bucket: bucket, expected_size: expected_size} do
      assert Autoraid.RaidQueues.count(bucket, "MISSINGNO") == {:ok, expected_size}
    end

    test "pops in order", %{bucket: bucket, expected_size: expected_size} do
      assert {:ok, [1]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")
      assert {:ok, [2]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")
      assert {:ok, [3]} = Autoraid.RaidQueues.pop(bucket, "MISSINGNO")

      assert Autoraid.RaidQueues.count(bucket, "MISSINGNO") == {:ok, expected_size - 3}
    end
  end
end
