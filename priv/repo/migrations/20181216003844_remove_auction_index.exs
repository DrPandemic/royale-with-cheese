defmodule Wow.Repo.Migrations.RemoveAuctionIndex do
  use Ecto.Migration

  def change do
    drop index("auction_entry", [:item, :owner_realm, :region, :dump_timestamp])
  end
end
