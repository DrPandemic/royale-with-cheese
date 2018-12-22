defmodule Wow.Repo.Migrations.MigrateToBid2 do
  use Ecto.Migration

  def change do
    execute("
      INSERT INTO auction_bid_2 (id, bid, item_id, buyout, quantity, rand, context, realm_id, character_id, first_dump_timestamp, last_dump_timestamp, last_time_left)
      SELECT id, MAX(ts.bid), item_id, buyout, quantity, rand, context, realm_id, character_id, MIN(ts.dump_timestamp), MAX(ts.dump_timestamp), MAX(time_left)
      FROM auction_bid
      INNER JOIN auction_timestamp AS ts ON ts.auction_bid_id = auction_bid.id
      GROUP BY id, item_id, buyout, quantity, rand, context, realm_id, character_id;
    ")
    drop_if_exists table(:auction_entry)
    drop_if_exists table(:auction_timestamp)
    drop_if_exists table(:auction_bid)
    drop index("auction_bid_2", [:realm_id])
    drop index("auction_bid_2", [:item_id], name: :auction_bid_2_pet_cage_index)

    rename table(:auction_bid_2), to: table(:auction_bid)
    create index("auction_bid", [:realm_id])
    create index("auction_bid", [:item_id], where: "item_id = 82800", name: :auction_bid_pet_cage_index)
  end
end
