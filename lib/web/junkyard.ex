defmodule Autoraid.Web.Junkyard do
  #  cat raid_bosses.json | jq ".current | map(.) | flatten | map({key: .name, value: {dex_number: .id, name}}) | from_entries"
  @name_to_raid_boss %{
    "Oshawott" => %{
      dex_number: 501,
      name: "Oshawott"
    },
    "Klink" => %{
      dex_number: 599,
      name: "Klink"
    },
    "Wailmer" => %{
      dex_number: 320,
      name: "Wailmer"
    },
    "Shinx" => %{
      dex_number: 403,
      name: "Shinx"
    },
    "Sandshrew" => %{
      dex_number: 27,
      name: "Sandshrew"
    },
    "Magikarp" => %{
      dex_number: 129,
      name: "Magikarp"
    },
    "Prinplup" => %{
      dex_number: 394,
      name: "Prinplup"
    },
    "Mawile" => %{
      dex_number: 303,
      name: "Mawile"
    },
    "Gligar" => %{
      dex_number: 207,
      name: "Gligar"
    },
    "Breloom" => %{
      dex_number: 286,
      name: "Breloom"
    },
    "Marowak" => %{
      dex_number: 105,
      name: "Marowak"
    },
    "Kingler" => %{
      dex_number: 99,
      name: "Kingler"
    },
    "Onix" => %{
      dex_number: 95,
      name: "Onix"
    },
    "Vaporeon" => %{
      dex_number: 134,
      name: "Vaporeon"
    },
    "Donphan" => %{
      dex_number: 232,
      name: "Donphan"
    },
    "Raichu" => %{
      dex_number: 26,
      name: "Raichu"
    },
    "Claydol" => %{
      dex_number: 344,
      name: "Claydol"
    },
    "Machamp" => %{
      dex_number: 68,
      name: "Machamp"
    },
    "Weezing" => %{
      dex_number: 110,
      name: "Weezing"
    },
    "Golem" => %{
      dex_number: 76,
      name: "Golem"
    },
    "Tyranitar" => %{
      dex_number: 248,
      name: "Tyranitar"
    },
    "Rhydon" => %{
      dex_number: 112,
      name: "Rhydon"
    },
    "Excadrill" => %{
      dex_number: 530,
      name: "Excadrill"
    },
    "Heatran" => %{
      dex_number: 485,
      name: "Heatran"
    }
  }

  def raid_from_request(request, leader) do
    %{max_invites: max_invites, location_name: location_name, boss_name: boss_name} = request

    boss =
      case Map.fetch(@name_to_raid_boss, boss_name) do
        {:ok, boss} -> boss
        any -> any
      end

    %{
      id: UUID.uuid4(),
      max_invites: max_invites,
      leader: leader,
      location_name: location_name,
      created_at: 1,
      raid_boss: boss
    }
  end

  def registry_id_from_user(me) do
    :crypto.hash(:md5, "#{me.name}-#{me.level}-#{me.fc}-woooo") |> Base.encode16()
  end
end
