defmodule Wow.Repo.Migrations.AddUserAndRealmTable do
  use Ecto.Migration

  def change do
    create table(:realm) do
      add :name, :string, null: false
      add :region, :string, null: false
    end
    create unique_index("realm", [:name, :region])

    create table(:character) do
      add :name, :string, null: false
      add :realm_id, references(:realm)
    end
    create unique_index("character", [:name, :realm_id])

    alter table("auction_bid") do
      remove :owner
      remove :owner_realm
      remove :region
      add :realm_id, references(:realm)
      add :character_id, references(:character)
    end
  end
end
