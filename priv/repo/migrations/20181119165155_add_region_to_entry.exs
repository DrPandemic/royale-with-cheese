defmodule Wow.Repo.Migrations.AddRegionToEntry do
  use Ecto.Migration

  def change do
    alter table("auction_entry") do
      add :region, :string, null: false
    end

    create index("auction_entry", [:item, :region, :owner_realm])
  end
end
