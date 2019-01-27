defmodule Wow.Repo.Migrations.AddsItemStats do
  use Ecto.Migration

  def change do
    execute "TRUNCATE item;"
    alter table("item") do
      add :stats, :string, null: false, default: ""
    end
  end
end
