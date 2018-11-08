defmodule Wow.Repo do
  use Ecto.Repo,
    otp_app: :wow,
    adapter: Ecto.Adapters.Postgres
end
