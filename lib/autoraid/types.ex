defmodule Autoraid.Types do
  defmacro __using__(_opts) do
        quote do
          @type user :: %{name: String.t(), fc: 1, level: 1}
          @type poketype :: %{name: String.t(), dex_number: 1}
          @type raid :: %{
            id: String.t(),
            max_invites: String.t(),
            leader: user,
            location_name: String.t(),
            created_at: 1,
            raid_boss: poketype,
          }
          @type room :: %{
            id: String.t(),
            raid: raid,
            members: [user, ...]
          }
        end
  end
end
