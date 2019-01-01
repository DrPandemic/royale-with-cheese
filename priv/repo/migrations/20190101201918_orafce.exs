defmodule Wow.Repo.Migrations.Orafce do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION orafce")
  end
end
