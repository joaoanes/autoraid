defmodule Cyndaquil.Web.SocketHandlers.Queue do
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
      |> Morphix.atomorphiform!

    %{action: action} = payload
    me = Map.get(payload, :me, nil)
    data = Map.get(payload, :data, nil)
    {:ok, new_state, ret} = handle_action(action, data, me, supervisor)

    {:reply, {:text, ret |> Jason.encode!()}, Map.merge(new_state |> Morphix.atomorphiform!, Map.merge(state, %{me: me}))}
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
        %{q_pid: q_pid} = Cyndaquil.AppSupervisor.process_pids(supervisor)
        Cyndaquil.RaidQueues.remove_from_all(q_pid, me)
        Cyndaquil.Logging.log("ws_conn", "remove_from_queues", %{me: me})
    end

    case Map.fetch(state, :raid) do
      :error ->
        :ok

      {:ok, nil} ->
        nil

      {:ok, raid} ->
        %{r_pid: r_pid} = Cyndaquil.AppSupervisor.process_pids(supervisor)
        Cyndaquil.RaidRegistry.delete(r_pid, raid.raid_boss.name, raid)
        Cyndaquil.Logging.log("ws_conn", "remove_from_raids", %{raid: raid})
    end

    :ok
  end

  def handle_action("join", %{queue: queue}, me, supervisor) do
    %{q_pid: q_pid, s_name: s_pid, wr_name: wr_name} =
      Cyndaquil.AppSupervisor.process_pids(supervisor)

    wr_name
    |> Registry.register(:websocket, Cyndaquil.Web.Junkyard.registry_id_from_user(me))

    Cyndaquil.RaidQueues.put(q_pid, queue, me)

    s_pid
    |> Registry.register(:websocket, %{})

    Cyndaquil.Logging.log("ws_conn", "join", %{me: me, queue: queue})

    {:ok, %{me: me}, %{type: :join}}
  end

  def handle_action("boop", _data, _me, _supervisor) do
    {:ok, %{}, %{beep: :boop}}
  end

  def handle_action(
        "create",
        %{location_name: _location_name, boss_name: queue} = request,
        me,
        supervisor
      ) do

    %{r_pid: r_pid, s_name: s_pid, wr_name: wr_name} =
      Cyndaquil.AppSupervisor.process_pids(supervisor)

    raid = Cyndaquil.Web.Junkyard.raid_from_request(request, me)
    Cyndaquil.RaidRegistry.put(r_pid, queue, raid)

    wr_name
    |> Registry.register(:websocket, Cyndaquil.Web.Junkyard.registry_id_from_user(me))

    s_pid
    |> Registry.register(:websocket, %{})

    Cyndaquil.Logging.log("ws_conn", "create", raid)

    {:ok, %{raid: raid}, %{type: :create, raid: raid}}
  end
end
