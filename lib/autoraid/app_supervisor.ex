defmodule Autoraid.AppSupervisor do
  use Supervisor

  @bosses File.read("priv/boss_registry.json") |> Autoraid.Junkyard.ok! |> Jason.decode! |> Map.keys

  def start_link(init_arg, opts \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, opts)
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
  def init(%{} = args) do
    port = case Map.fetch(args, :port) do
      {:ok, p} -> p
      :error -> (
        Autoraid.Logging.log("start", "default_port_missing", %{})
        8080
      )
    end

    bosses = case Map.fetch(args, :bosses) do
      {:ok, p} -> p
      :error -> (
        Autoraid.Logging.log("start", "bosses missing", %{})
        @bosses
      )
    end

    children = [
      Autoraid.Supervisor.child_spec(%{
        available_bosses: bosses,
        interval: 500,
        app_supervisor: self()
      }),
      Autoraid.Web.Supervisor.child_spec(%{supervisor: self(), port: port})
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
