use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wow, WowWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :wow, Wow.Repo,
  username: "postgres",
  password: "password",
  database: "wow_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Toniq
config :toniq, redis_url: "redis://redis:6379/1"
