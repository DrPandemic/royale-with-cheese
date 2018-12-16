defmodule Wow.Repo.Migrations.CreateNewAuctionTables do
  use Ecto.Migration

  def change do
    create table(:auction_bid) do
      add :bid, :bigint, null: false
      add :item, :bigint, null: false
      add :owner, :string, null: false
      add :owner_realm, :string, null: false
      add :buyout, :bigint, null: false
      add :quantity, :bigint, null: false
      add :time_left, :string, null: false
      add :rand, :bigint, null: false
      add :seed, :bigint, null: false
      add :context, :bigint, null: false
      add :region, :string, null: false
    end

    create table(:auction_timestamp) do
      add :auction_bid_id, references(:auction_bid)
      add :dump_timestamp, :utc_datetime, null: false
    end
    create unique_index("auction_timestamp", [:auction_bid_id, :dump_timestamp])
  end
end
