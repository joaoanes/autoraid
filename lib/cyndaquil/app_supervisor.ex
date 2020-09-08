defmodule Cyndaquil.AppSupervisor do
  use Supervisor

  @bosses File.read("priv/boss_registry.json") |> Cyndaquil.Junkyard.ok! |> Jason.decode! |> Map.keys

  def start_link(init_arg, opts \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, opts)
  end

  def process_pids(supervisor_process) do
    Supervisor.which_children(supervisor_process)
    |> Enum.reduce(%{}, fn {module, pid, _, _}, acc ->
      case module do
        Cyndaquil.Supervisor -> Map.merge(acc, Cyndaquil.Supervisor.process_pids(pid))
        Cyndaquil.Web.Supervisor -> Map.merge(acc, Cyndaquil.Web.Supervisor.process_pids(pid))
        _ -> acc
      end
    end)
  end

  @impl true
  def init(%{} = args) do
    port = case Map.fetch(args, :port) do
      {:ok, p} -> p
      :error -> (
        Cyndaquil.Logging.log("start", "default_port_missing", %{})
        8080
      )
    end

    bosses = case Map.fetch(args, :bosses) do
      {:ok, p} -> p
      :error -> (
        Cyndaquil.Logging.log("start", "bosses missing", %{})
        @bosses
      )
    end

    interval = case Map.fetch(args, :interval) do
      {:ok, p} -> p
      :error -> (
        Cyndaquil.Logging.log("start", "interval missing", %{})
        500
      )
    end

    children = [
      Cyndaquil.Supervisor.child_spec(%{
        available_bosses: bosses,
        interval: interval,
        app_supervisor: self()
      }),
      Cyndaquil.Web.Supervisor.child_spec(%{supervisor: self(), port: port})
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
