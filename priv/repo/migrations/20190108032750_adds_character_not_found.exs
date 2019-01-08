defmodule Wow.Repo.Migrations.AddsCharacterNotFound do
  use Ecto.Migration

  def change do
    alter table("character") do
      add :not_found, :boolean, null: false, default: false
    end
  end
end
