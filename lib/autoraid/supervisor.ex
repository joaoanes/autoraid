defmodule Autoraid.Supervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg, opts \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, opts)
  end

  def process_pids(supervisor) do
    Supervisor.which_children(supervisor)
    |> Enum.reduce(%{}, fn {module, pid, _, _}, acc ->
      case module do
        Autoraid.RaidQueues -> Map.merge(acc, %{q_pid: pid})
        Autoraid.RaidRegistry -> Map.merge(acc, %{r_pid: pid})
        Autoraid.RoomRegistry -> Map.merge(acc, %{ro_pid: pid})
        _ -> (
          acc
        )
      end
    end)
  end

  @impl true
  def init(opts) do
    %{available_bosses: available_bosses, interval: interval, app_supervisor: supervisor} = opts
    
    children = [
      {Autoraid.RaidQueues, [available_bosses: available_bosses]},
      {Autoraid.RaidRegistry, [available_bosses: available_bosses]},
      {Autoraid.RoomRegistry, []},
      {Autoraid.Matchmaker, %{available_bosses: available_bosses, supervisor: self(), app_supervisor: supervisor, interval: interval}}
    ]

    case Map.fetch(opts, :without_stats) do
      {:ok, _} -> children
      :error -> children ++ [{Autoraid.Stats, %{available_bosses: available_bosses, supervisor: self(), app_supervisor: supervisor, interval: Integer.floor_div(interval, 2)}},
    ]
    end
    |> Supervisor.init(strategy: :one_for_one)
  end
end
