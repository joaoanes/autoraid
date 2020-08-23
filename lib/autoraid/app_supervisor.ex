defmodule Autoraid.AppSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  @bosses [
    "Oshawott",
    "Klink",
    "Wailmer",
    "Shinx",
    "Sandshrew",
    "Magikarp",
    "Prinplup",
    "Mawile",
    "Gligar",
    "Breloom",
    "Marowak",
    "Kingler",
    "Onix",
    "Vaporeon",
    "Donphan",
    "Raichu",
    "Claydol",
    "Machamp",
    "Weezing",
    "Golem",
    "Tyranitar",
    "Rhydon",
    "Excadrill",
    "Marowak",
    "Heatran"
  ]

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def process_pids(supervisor_process) do
    Supervisor.which_children(supervisor_process)
    |> Enum.reduce(%{}, fn {module, pid, _, _}, acc ->
      case module do
        Autoraid.Supervisor -> Map.merge(acc, Autoraid.Supervisor.process_pids(pid))
        Autoraid.Web.Supervisor -> Map.merge(acc, Autoraid.Web.Supervisor.process_pids(pid))
        _ -> acc
      end
    end)
  end

  @impl true
  def init(_) do
    children = [
      Autoraid.Supervisor.child_spec(%{
        available_bosses: @bosses,
        interval: 500,
        app_supervisor: self()
      }),
      Autoraid.Web.Supervisor.child_spec(supervisor: self())
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
