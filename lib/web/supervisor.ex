defmodule Autoraid.Web.Supervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  defp dispatch(supervisor_pid) do
    [
      {:_,
        [
          {"/ws/[...]", Autoraid.Web.SocketHandler, [%{supervisor: supervisor_pid}]},
          {:_, Plug.Cowboy.Handler, {Autoraid.Web.Router, []}}
        ]
      }
    ]
  end

  def process_pids(supervisor) do
    Supervisor.which_children(supervisor)
    |> Enum.reduce(%{}, fn {module, pid, _, _}, acc ->
      case module do
        Registry.Autoraid -> Map.merge(acc, %{wr_pid: pid})
        Registry.Autoraid.Stats -> Map.merge(acc, %{s_pid: pid})
        {:ranch_listener_sup, Autoraid.Web.Router.HTTP} -> Map.merge(acc, %{w_pid: pid})
        _ -> acc
      end
    end)
  end

  @impl true
  def init(opts) do
    [supervisor: supervisor] = opts

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Autoraid.Web.Router,
        options: [
          dispatch: dispatch(supervisor),
          port: 4000,

        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Autoraid
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Autoraid.Stats
      ),
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
