defmodule Autoraid.Web.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @tag :oops
  describe "with application" do
    setup [:with_application, :with_websocket]
    @tag :oops

    test "it responds to heartbeats", %{conn: conn, ws_pid: ws_pid} do
      :gun.ws_send(conn, {:text, %{action: "boop"} |> Jason.encode!})
      {:ws, {:text, "{\"beep\":\"boop\"}"}} = :gun.await(conn, ws_pid)


      :ok = :gun.cancel(conn, ws_pid)
      :ok = :gun.shutdown(conn)
      Process.sleep(10)

     :ok
    end

    @tag :oops
    test "it joins", %{conn: conn, ws_pid: ws_pid, q_pid: q_pid} do
      assert {:ok, 0} == Autoraid.RaidQueues.count(q_pid, "Vaporeon")

      :gun.ws_send(conn, {:text, %{action: "join", me: %{name: "test", level: "1", fc: "1111"}, data: %{queue: "Vaporeon"}} |> Jason.encode!})
      {:ws, {:text, "{\"type\":\"join\"}"}} = :gun.await(conn, ws_pid)

      assert {:ok, 1} == Autoraid.RaidQueues.count(q_pid, "Vaporeon")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(10)
     end

     test "it creates", %{conn: conn, ws_pid: ws_pid, r_pid: r_pid} do
      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Vaporeon")

      :gun.ws_send(conn, {:text, %{action: "create", me: %{name: "test", level: "1", fc: "1111"}, data: %{boss_name: "Vaporeon", location_name: "Anonymous", max_invites: 5}} |> Jason.encode!})
      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)

      %{"raid" => %{"raid_boss" => %{"name" => "Vaporeon"}}} = payload |> Jason.decode!

      assert {:ok, 1} == Autoraid.RaidRegistry.count(r_pid, "Vaporeon")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(10)
     end


     test "empties after creates", %{conn: conn, ws_pid: ws_pid, r_pid: r_pid} do
      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Vaporeon")

      :gun.ws_send(conn, {:text, %{action: "create", me: %{name: "test", level: "1", fc: "1111"}, data: %{boss_name: "Vaporeon", location_name: "Anonymous", max_invites: 5}} |> Jason.encode!})
      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)

      %{"raid" => %{"raid_boss" => %{"name" => "Vaporeon"}}} = payload |> Jason.decode!

      assert {:ok, 1} == Autoraid.RaidRegistry.count(r_pid, "Vaporeon")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(100)

      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Vaporeon")

     end

     test "empties after joins", %{conn: conn, ws_pid: ws_pid, q_pid: q_pid} do
      assert {:ok, 0} == Autoraid.RaidQueues.count(q_pid, "Vaporeon")

      :gun.ws_send(conn, {:text, %{action: "join", me: %{name: "test", level: "1", fc: "1111"}, data: %{queue: "Vaporeon"}} |> Jason.encode!})
      {:ws, {:text, "{\"type\":\"join\"}"}} = :gun.await(conn, ws_pid)

      assert {:ok, 1} == Autoraid.RaidQueues.count(q_pid, "Vaporeon")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(100)

      assert {:ok, 0} == Autoraid.RaidQueues.count(q_pid, "Vaporeon")
     end
  end

  def with_websocket(%{port: port}) do
    {:ok, conn} = :gun.open('localhost', port)
    {:ok, :http} = :gun.await_up(conn)
    ws_ref = :gun.ws_upgrade(conn, '/ws/queues')
    {:upgrade, _, _} = :gun.await(conn, ws_ref)

    %{conn: conn, ws_pid: ws_ref}
  end

  def with_application(%{}) do
    Application.ensure_all_started(:gun)
    Application.ensure_all_started(:cowboy)
    Application.ensure_all_started(:telemetry)

    port = Enum.random(10000..30000)
    a_pid = start_supervised!({Autoraid.AppSupervisor, %{port: port}}, shutdown: 1000)

    Autoraid.AppSupervisor.process_pids(a_pid)
    |> Map.merge(%{a_pid: a_pid, port: port})
  end
end
