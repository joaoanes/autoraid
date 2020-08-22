defmodule Autoraid.Stats do
  use GenServer
  require Logger

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{available_bosses: _} = state) do
    interval = Map.get(state, :interval, 1000)
    schedule_work(interval)

    {:ok, Map.put(state, :interval, interval)}
  end

  def handle_info(
        :broadcast_stats,
        %{
          available_bosses: available_bosses,
          app_supervisor: nil,
          supervisor: supervisor,
          interval: interval
        } = state
      ) do
    %{r_pid: r_pid, q_pid: q_pid} = Autoraid.Supervisor.process_pids(supervisor)

    broadcast(available_bosses, r_pid, q_pid)

    schedule_work(interval)
    {:noreply, state}
  end

  def handle_info(
        :broadcast_stats,
        %{available_bosses: available_bosses, app_supervisor: app_supervisor, interval: interval} =
          state
      ) do
    %{r_pid: r_pid, q_pid: q_pid} = Autoraid.AppSupervisor.process_pids(app_supervisor)

    broadcast(available_bosses, r_pid, q_pid)

    schedule_work(interval)
    {:noreply, state}
  end

  def handle_info(
        :broadcast_stats,
        %{
          available_bosses: available_bosses,
          registry_pid: r_pid,
          queues_pid: q_pid,
          interval: interval
        } = state
      ) do
    broadcast(available_bosses, r_pid, q_pid)

    schedule_work(interval)
    {:noreply, state}
  end

  def broadcast(available_bosses, r_pid, q_pid) do
    stats =
      Enum.map(available_bosses, fn boss_name ->
        {:ok, q_count} = Autoraid.RaidQueues.count(q_pid, boss_name)
        {:ok, r_count} = Autoraid.RaidRegistry.count(r_pid, boss_name)

        {boss_name,
         %{
           rooms: r_count,
           queued: q_count
         }}
      end)
      |> Map.new()

    Registry.Autoraid.Stats
    |> Registry.dispatch(
      :websocket,
      fn registrations ->
        registrations
        |> Enum.each(fn {pid, _user} ->
          Process.send(pid, %{type: :stats, data: stats} |> Jason.encode!(), [])
        end)
      end
    )
  end

  defp schedule_work(interval) do
    Process.send_after(self(), :broadcast_stats, interval)
  end
end
