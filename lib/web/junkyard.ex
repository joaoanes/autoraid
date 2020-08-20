defmodule Autoraid.Web.Junkyard do

  @name_to_raid_boss %{
    "MISSINGNO" => %{name: "MISSINGNO", dex_number: 0},
    "MEW" => %{name: "MEW", dex_number: 151},
  }

  def raid_from_request(request, leader) do
    %{max_invites: max_invites, location_name: location_name, boss_name: boss_name} = request

    boss = case Map.fetch(@name_to_raid_boss, boss_name) do
      {:ok, boss} -> boss
      any -> any
    end

    %{
      id: UUID.uuid4,
      max_invites: max_invites,
      leader: leader,
      location_name: location_name,
      created_at: 1,
      raid_boss: boss,
    }
  end

  def registry_id_from_user(me) do
    :crypto.hash(:md5, "#{me.name}-#{me.level}-#{me.fc}-woooo") |> Base.encode16()
  end
end
