defmodule Wow.Repo.Migrations.AddAucitonIndex do
  use Ecto.Migration

  def change do
    create index("auction_entry", [:item, :owner_realm, :region, :dump_timestamp])
  end
end
