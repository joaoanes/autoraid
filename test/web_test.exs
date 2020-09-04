defmodule Autoraid.Web.EndpointTest do
  use ExUnit.Case
  use Plug.Test


  # test "it returns pong" do
  #   # Create a test connection
  #   conn = conn(:get, "/ping")

  #   # Invoke the plug
  #   conn = WebhookProcessor.Endpoint.call(conn, @opts)

  #   # Assert the response and status
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "pong!"
  # end

  # test "it returns 200 with a valid payload" do
  #   # Create a test connection
  #   conn = conn(:post, "/events", %{events: [%{}]})

  #   # Invoke the plug
  #   conn = WebhookProcessor.Endpoint.call(conn, @opts)

  #   # Assert the response
  #   assert conn.status == 200
  # end

  # test "it returns 422 with an invalid payload" do
  #   # Create a test connection
  #   conn = conn(:post, "/events", %{})

  #   # Invoke the plug
  #   conn = WebhookProcessor.Endpoint.call(conn, @opts)

  #   # Assert the response
  #   assert conn.status == 422
  # end

  # test "it returns 404 when no route matches" do
  #   # Create a test connection
  #   conn = conn(:get, "/fail")

  #   # Invoke the plug
  #   conn = WebhookProcessor.Endpoint.call(conn, @opts)

  #   # Assert the response
  #   assert conn.status == 404
  # end

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

      :ok = :gun.cancel(conn, ws_pid)
      :ok = :gun.shutdown(conn)

      Process.sleep(10)
     end

  end

  def with_websocket(%{port: port}) do
    {:ok, conn} = :gun.open('localhost', port)
    {:ok, :http} = :gun.await_up(conn)
    ws_ref = :gun.ws_upgrade(conn, '/ws/queues')
    {:upgrade, _, _} = :gun.await(conn, ws_ref)

    %{conn: conn, ws_pid: ws_ref}
  end

  def with_application(%{a_pid: old_pid}) do
    IO.puts "uhhhhh"
    stop_supervised!(old_pid)
    with_application(%{})
  end

  def with_application(%{}) do
    IO.puts "setting up"
    Application.ensure_all_started(:gun)
    Application.ensure_all_started(:cowboy)
    Application.ensure_all_started(:telemetry)

    port = Enum.random(10000..30000)
    a_pid = start_supervised!({Autoraid.AppSupervisor, %{port: port}}, shutdown: 1000)

    Autoraid.AppSupervisor.process_pids(a_pid)
    |> Map.merge(%{a_pid: a_pid, port: port})
  end
end
