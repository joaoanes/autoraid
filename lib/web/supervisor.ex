defmodule Cyndaquil.Web.Supervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg, opts \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, opts)
  end

  defp dispatch(supervisor_pid) do
    [
      {:_,
        [
          {"/ws/queues", Cyndaquil.Web.SocketHandlers.Queue, [%{supervisor: supervisor_pid}]},
          {"/ws/[...]", Cyndaquil.Web.SocketHandlers.Chat, [%{supervisor: supervisor_pid}]},
          {:_, Plug.Cowboy.Handler, {Cyndaquil.Web.Router, []}}
        ]
      }
    ]
  end

  def process_pids(supervisor) do
    Supervisor.which_children(supervisor)
    |> Enum.reduce(%{}, fn {module, pid, _, _}, acc ->
      case module do
        Registry.Cyndaquil -> (
          [{:registered_name, name} | _rest] = Process.info(pid)
          Map.merge(acc, %{wr_pid: pid, wr_name: name})
        )
        Registry.Cyndaquil.Stats -> (
          [{:registered_name, name }| _rest] = Process.info(pid)
          Map.merge(acc, %{s_pid: pid, s_name: name})
        )
        {:ranch_listener_sup, Cyndaquil.Web.Router.HTTP} -> Map.merge(acc, %{w_pid: pid})
        _ -> acc
      end
    end)
  end

  @impl true
  def init(opts) do
    %{supervisor: supervisor, port: port} = opts

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Cyndaquil.Web.Router,
        options: [
          dispatch: dispatch(supervisor),
          port: port,
          protocol_options: [
            request_timeout: 1000,
            shutdown_timeout: 1,
          ],
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: String.to_atom("registry_#{System.os_time}")
      )
      |> Supervisor.child_spec(id: Registry.Cyndaquil),
      Registry.child_spec(
        keys: :duplicate,
        name: String.to_atom("registry_stats_#{System.os_time}")
      )
      |> Supervisor.child_spec(id: Registry.Cyndaquil.Stats),
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
