defmodule Cyndaquil.Test.FactoryYard do

  def create(factory), do: create(factory, %{})
  def create("Raid", opts) do
    Map.merge(
      %{
        id: UUID.uuid4,
        max_invites: 4,
        leader: create("User"),
        location_name: "Cinnabar",
        created_at: 1,
        raid_boss: %{
          name: "MISSINGNO",
          dex_number: 0,
        },
      },
      opts
    )
  end

  def create("User", opts) do
    %{
      name: Faker.Person.name(),
      fc: :rand.uniform(8999_9999_9999) + 1000_0000_0000,
      level: :rand.uniform(40)
    }
    |> Map.merge(opts)
  end

  def create("Room", opts) do
    %{
      id: UUID.uuid4,
      raid: create("Raid"),
      members: Enum.map(1..4, fn _ -> create("User") end)
    }
    |> Map.merge(opts)
  end
end
