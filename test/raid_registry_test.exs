defmodule Autoraid.RaidRegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Autoraid.RaidRegistry.start_link([available_bosses: ["MISSINGNO"]])
    raid = Autoraid.Test.FactoryYard.create("Raid")
    %{bucket: bucket, raid: raid}
  end

  test "returns error on getting missing raid", %{bucket: bucket} do
    assert Autoraid.RaidRegistry.get(bucket, "milk") == {:error, :not_found}
  end

  test "gets empty list at astart", %{bucket: bucket} do
    assert Autoraid.RaidRegistry.get(bucket, "MISSINGNO") == {:ok, []}
  end

  test "adds to raid queue", %{bucket: bucket, raid: raid} do
    assert Autoraid.RaidRegistry.put(bucket, "MISSINGNO", raid) == :ok
    assert Autoraid.RaidRegistry.get(bucket, "MISSINGNO") == {:ok, [raid]}
  end

  describe "with non-empty queue" do
    setup do
      {:ok, bucket} = Autoraid.RaidRegistry.start_link([available_bosses: ["MISSINGNO"]])
      random_size = rem(ExUnit.configuration()[:seed], 8) + 3

      raids = Enum.map(1..random_size, fn _ ->
        raid = Autoraid.Test.FactoryYard.create("Raid")
        :ok = Autoraid.RaidRegistry.put(bucket, "MISSINGNO", raid)
        raid
      end)

      %{bucket: bucket, expected_size: random_size, raids: raids}
    end

    test "adds to raid queue", %{bucket: bucket, raids: raids} do
      raid = Autoraid.Test.FactoryYard.create("Raid")
      assert Autoraid.RaidRegistry.put(bucket, "MISSINGNO", raid) == :ok
      assert Autoraid.RaidRegistry.get(bucket, "MISSINGNO") == {:ok, raids ++ [raid]}
    end

    test "counts correctly", %{bucket: bucket, expected_size: expected_size} do
      assert Autoraid.RaidRegistry.count(bucket, "MISSINGNO") == {:ok, expected_size}
    end

    test "deletes correctly", %{bucket: bucket, raids: raids} do
      raid = Autoraid.Test.FactoryYard.create("Raid")

      assert Autoraid.RaidRegistry.put(bucket, "MISSINGNO", raid) == :ok

      assert {:ok, raids} != Autoraid.RaidRegistry.get(bucket, "MISSINGNO")

      assert :ok == Autoraid.RaidRegistry.delete(bucket, "MISSINGNO", raid)

      assert {:ok, raids} == Autoraid.RaidRegistry.get(bucket, "MISSINGNO")
    end
  end
end
