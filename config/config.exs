# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :wow,
  ecto_repos: [Wow.Repo]

# Configures the endpoint
config :wow, WowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WaBt9EuHBtPYSt/1vNGqf8msGO/aYFs0gwHyX/fQXpxjXPcB4YHXtkTtEDVKhRuW",
  render_errors: [view: WowWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Wow.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# Tesla
config :tesla, :adapter, Tesla.Adapter.Ibrowse

# Quantum
config :wow, Wow.Scheduler,
  jobs: [
    # Every minute
    {"0 * * * *",      fn -> Wow.Jobs.Scheduler.schedule() end},
  ]
