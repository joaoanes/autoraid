defmodule Cyndaquil.Supervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg, opts \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, opts)
  end

  def process_pids(supervisor) do
    Supervisor.which_children(supervisor)
    |> Enum.reduce(%{}, fn {module, pid, _, _}, acc ->
      case module do
        Cyndaquil.RaidQueues -> Map.merge(acc, %{q_pid: pid})
        Cyndaquil.RaidRegistry -> Map.merge(acc, %{r_pid: pid})
        Cyndaquil.RoomRegistry -> Map.merge(acc, %{ro_pid: pid})
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
      {Cyndaquil.RaidQueues, [available_bosses: available_bosses]},
      {Cyndaquil.RaidRegistry, [available_bosses: available_bosses]},
      {Cyndaquil.RoomRegistry, []},
      {Cyndaquil.Matchmaker, %{available_bosses: available_bosses, supervisor: self(), app_supervisor: supervisor, interval: interval}}
    ]

    case Map.fetch(opts, :without_stats) do
      {:ok, _} -> children
      :error -> children ++ [{Cyndaquil.Stats, %{available_bosses: available_bosses, supervisor: self(), app_supervisor: supervisor, interval: Integer.floor_div(interval, 4)}},
    ]
    end
    |> Supervisor.init(strategy: :one_for_one)
  end
end
