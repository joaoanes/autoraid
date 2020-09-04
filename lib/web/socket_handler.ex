defmodule Autoraid.Web.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, [%{supervisor: supervisor}]) do
    websocket_state =
      %{request: request, registry_key: request.path}
      |> Map.merge(%{supervisor: supervisor})

    {:cowboy_websocket, request, websocket_state}
  end

  def websocket_init(state) do
    {:ok, state}
  end

  def websocket_handle({:text, json}, %{supervisor: supervisor} = state) do
    payload =
      Jason.decode!(json)
      |> Morphix.atomorphiform!()

    %{action: action} = payload
    me = Map.get(payload, :me, nil)
    data = Map.get(payload, :data, nil)
    {:ok, new_state, ret} = handle_action(action, data, me, supervisor)
    # Registry.Autoraid
    # |> Registry.dispatch(state.registry_key, fn(entries) ->
    #  for {pid, _} <- entries do
    #    if pid != self() do
    #      Process.send(pid, message, [])
    #    end
    #  end
    # end)

    {:reply, {:text, ret |> Jason.encode!()}, Map.merge(new_state, Map.merge(state, %{me: me}))}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  @spec terminate(any, any, map) :: :ok
  def terminate(_reason, _req, %{supervisor: supervisor} = state) do
    case Map.fetch(state, :me) do
      :error ->
        :ok

      {:ok, nil} ->
        nil

      {:ok, me} ->
        %{q_pid: q_pid} = Autoraid.AppSupervisor.process_pids(supervisor)
        Autoraid.RaidQueues.remove_from_all(q_pid, me)
        IO.puts("Removed #{me.name}")
    end

    case Map.fetch(state, :raid) do
      :error ->
        :ok

      {:ok, nil} ->
        nil

      {:ok, raid} ->
        %{r_pid: r_pid} = Autoraid.AppSupervisor.process_pids(supervisor)
        Autoraid.RaidRegistry.delete(r_pid, raid.raid_boss.name, raid)
        IO.puts("Removed #{raid.id}")
    end

    :ok
  end

  def handle_action("join", %{queue: queue}, me, supervisor) do
    IO.puts("I could join #{me.name} to #{queue}")

    %{q_pid: q_pid, s_name: s_pid, wr_name: wr_name} =
      Autoraid.AppSupervisor.process_pids(supervisor)

    wr_name
    |> Registry.register(:websocket, Autoraid.Web.Junkyard.registry_id_from_user(me))

    Autoraid.RaidQueues.put(q_pid, queue, me)
    {:ok, size} = Autoraid.RaidQueues.count(q_pid, queue)

    s_pid
    |> Registry.register(:websocket, %{})

    IO.puts("I did join #{me.name} to #{queue}, size #{size}")

    {:ok, %{me: me}, %{type: :join}}
  end

  def handle_action("boop", _data, _me, _supervisor) do
    {:ok, %{}, %{beep: :boop}}
  end

  def handle_action(
        "create",
        %{location_name: location_name, boss_name: queue} = request,
        me,
        supervisor
      ) do
    IO.puts("I could create #{location_name} to #{queue}")

    %{r_pid: r_pid, s_name: s_pid, wr_name: wr_name} =
      Autoraid.AppSupervisor.process_pids(supervisor)

    raid = Autoraid.Web.Junkyard.raid_from_request(request, me)
    Autoraid.RaidRegistry.put(r_pid, queue, raid)
    {:ok, size} = Autoraid.RaidRegistry.count(r_pid, queue)

    wr_name
    |> Registry.register(:websocket, Autoraid.Web.Junkyard.registry_id_from_user(me))

    s_pid
    |> Registry.register(:websocket, %{})

    IO.puts("I did create #{location_name} to #{queue}, id #{raid.id}, size #{size}")

    {:ok, %{raid: raid}, %{type: :create, raid: raid}}
  end
end
