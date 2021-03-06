defmodule Wow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Wow.Repo,
      # Start the endpoint when the application starts
      WowWeb.Endpoint,
      # Starts a worker by calling: Wow.Worker.start_link(arg)
      # {Wow.Worker, arg},
      Wow.Scheduler,
      worker(Cachex, [:wow_cache, []]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
