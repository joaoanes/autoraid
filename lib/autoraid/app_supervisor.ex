defmodule Autoraid.AppSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  @bosses File.read("priv/boss_registry.json") |> Autoraid.Junkyard.ok! |> Jason.decode! |> Map.keys

  def start_link(init_arg) do
    IO.inspect "Started AppSupervisor with bosses"
    IO.inspect @bosses

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
