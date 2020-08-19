defmodule Autoraid.Test.Factory do

  def create(factory), do: create(factory, %{})
  def create("Raid", opts) do
    Map.merge(
      %{
        id: make_ref() |> :erlang.ref_to_list() |> List.to_string(),
        max_invites: 4,
        leader: [name: "Red", fc: 000000000000, level: 40],
        location_name: "Cinnabar",
        created_at: 1,
        raid_boss: [
          name: "MISSINGNO",
          dex_number: 0,
        ],
      },
      opts
    )
  end
end
