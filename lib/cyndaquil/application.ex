defmodule Cyndaquil.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    children = [
      Cyndaquil.AppSupervisor.child_spec(%{port: 4000})
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]

    Cyndaquil.Logging.log("start", __MODULE__, %{running: true})
    Supervisor.start_link(children, opts)
  end



end
