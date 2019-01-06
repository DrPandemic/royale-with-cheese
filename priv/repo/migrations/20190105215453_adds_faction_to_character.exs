defmodule Wow.Repo.Migrations.AddsFactionToCharacter do
  use Ecto.Migration

  def change do
    alter table("character") do
      add :faction, :smallint, null: true, default: nil
    end
  end
end
