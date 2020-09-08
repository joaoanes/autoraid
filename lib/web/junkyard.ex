defmodule Cyndaquil.Web.Junkyard do

  def raid_from_request(request, leader) do
    %{max_invites: max_invites, location_name: location_name, boss_name: boss_name} = request

    boss = find_boss(boss_name)

    %{
      id: UUID.uuid4(),
      max_invites: max_invites,
      leader: leader,
      location_name: location_name,
      created_at: 1,
      raid_boss: boss
    }

  end

  @spec registry_id_from_user(atom | %{fc: any, level: any, name: any}) :: binary
  def registry_id_from_user(me) do
    :crypto.hash(:md5, "#{me.name}-#{me.level}-#{me.fc}-woooo") |> Base.encode16()
  end

  def find_boss(boss_name) do
    boss_list = case Application.get_env(:cyndaquil, :boss_provider) do
      atom when is_atom(atom) -> (
        apply(atom, :bosses, [])
      )
      _ -> File.read("priv/boss_registry.json") |> Cyndaquil.Junkyard.ok! |> Jason.decode!
    end

    case Map.fetch(boss_list, boss_name) do
      {:ok, boss} -> boss |> Morphix.atomorphiform!()
      any -> any
    end
  end
end
