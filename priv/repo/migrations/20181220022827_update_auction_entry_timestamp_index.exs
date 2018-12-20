defmodule Wow.Repo.Migrations.UpdateAuctionEntryTimestampIndex do
  use Ecto.Migration

  def change do
    drop_if_exists index("auction_timestamp", [:auction_bid_id, :dump_timestamp])
    create unique_index("auction_timestamp", [:auction_bid_id, "dump_timestamp DESC"])
  end
end
