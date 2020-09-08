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
    test "it joins and receives stats", %{conn: conn, ws_pid: ws_pid, q_pid: q_pid} do
      assert {:ok, 0} == Autoraid.RaidQueues.count(q_pid, "Mew")

      :gun.ws_send(conn, {:text, join_packet() |> Jason.encode!})
      {:ws, {:text, "{\"type\":\"join\"}"}} = :gun.await(conn, ws_pid)

      assert {:ok, 1} == Autoraid.RaidQueues.count(q_pid, "Mew")

      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)
      
      %{
        data: %{
          MISSINGNO: %{ queued: 0, rooms: 0 },
          Mew: %{ queued: 1, rooms: 0 },
        } 
      } = payload |> Jason.decode!() |> Morphix.atomorphiform!()

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(10)
     end

     test "it creates and receives stats", %{conn: conn, ws_pid: ws_pid, r_pid: r_pid} do
      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Mew")

      :gun.ws_send(conn, {:text, create_packet() |> Jason.encode!})
      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)

      %{"raid" => %{"raid_boss" => %{"name" => "Mew"}}} = payload |> Jason.decode!

      assert {:ok, 1} == Autoraid.RaidRegistry.count(r_pid, "Mew")

      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)
      
      %{
        data: %{
          MISSINGNO: %{ queued: 0, rooms: 0 },
          Mew: %{ queued: 0, rooms: 1 },
        } 
      } = payload |> Jason.decode!() |> Morphix.atomorphiform!()

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(10)
     end


     test "empties after creates", %{conn: conn, ws_pid: ws_pid, r_pid: r_pid} do
      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Mew")

      :gun.ws_send(conn, {:text, create_packet() |> Jason.encode!})
      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)

      %{"raid" => %{"raid_boss" => %{"name" => "Mew"}}} = payload |> Jason.decode!

      assert {:ok, 1} == Autoraid.RaidRegistry.count(r_pid, "Mew")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(100)

      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Mew")

     end


     test "gets stats after join", %{conn: conn, ws_pid: ws_pid, r_pid: r_pid} do
      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Mew")

      :gun.ws_send(conn, {:text, create_packet() |> Jason.encode!})
      {:ws, {:text, payload}} = :gun.await(conn, ws_pid)

      %{"raid" => %{"raid_boss" => %{"name" => "Mew"}}} = payload |> Jason.decode!

      assert {:ok, 1} == Autoraid.RaidRegistry.count(r_pid, "Mew")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(100)

      assert {:ok, 0} == Autoraid.RaidRegistry.count(r_pid, "Mew")

     end

     test "empties after joins", %{conn: conn, ws_pid: ws_pid, q_pid: q_pid} do
      assert {:ok, 0} == Autoraid.RaidQueues.count(q_pid, "Mew")

      :gun.ws_send(conn, {:text, join_packet() |> Jason.encode!})
      {:ws, {:text, "{\"type\":\"join\"}"}} = :gun.await(conn, ws_pid)

      assert {:ok, 1} == Autoraid.RaidQueues.count(q_pid, "Mew")

      :ok = :gun.shutdown(conn)
      :ok = :gun.flush(conn)

      Process.sleep(100)

      assert {:ok, 0} == Autoraid.RaidQueues.count(q_pid, "Mew")
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

    Mix.Config.persist(autoraid: [boss_provider: Autoraid.Test.BossList])

    port = Enum.random(10000..30000)
    a_pid = start_supervised!({Autoraid.AppSupervisor, %{port: port, bosses: bosses()}}, shutdown: 1000)

    Autoraid.AppSupervisor.process_pids(a_pid)
    |> Map.merge(%{a_pid: a_pid, port: port})
  end

  def bosses do
    Autoraid.Test.BossList.bosses() |> Map.keys
  end

  def create_packet do
    %{
      action: "create", 
      me: Autoraid.Test.FactoryYard.create("User"), 
      data: %{
        boss_name: "Mew", 
        location_name: "Anonymous", 
        max_invites: 5
      }
    }
  end

  def join_packet do
    %{
      action: "join", 
      me: Autoraid.Test.FactoryYard.create("User"), 
      data: %{
        queue: "Mew"
      }
    }
  end
end

defmodule Autoraid.Test.BossList do
  def bosses do
    %{
      "MISSINGNO" => %{
      "dex_number" => 000,
        "name" => "MISSINGNO",
        "form" => "Normal",
        "tier" => 5,
        "possible_shiny" => true,
        "max_boosted_cp" => 1048,
        "min_boosted_cp" => 974,
        "max_unboosted_cp" => 838,
        "min_unboosted_cp" => 779,
        "type" => [
          "Bird",
          "Normal"
        ]
      },
      "Mew" => %{
        "dex_number" => 151,
        "name" => "Mew",
        "form" => "Normal",
        "tier" => 5,
        "possible_shiny" => true,
        "max_boosted_cp" => 1048,
        "min_boosted_cp" => 974,
        "max_unboosted_cp" => 838,
        "min_unboosted_cp" => 779,
        "type" => [
          "Psychic"
        ]
      },
    }
  end
end
