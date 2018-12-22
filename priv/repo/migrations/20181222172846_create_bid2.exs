defmodule Wow.Repo.Migrations.CreateBid2 do
  use Ecto.Migration

  def change do
    create table(:auction_bid_2) do
      add :bid, :bigint, null: false
      add :item_id, :bigint, null: false
      add :buyout, :bigint, null: false
      add :quantity, :bigint, null: false
      add :rand, :bigint, null: false
      add :context, :bigint, null: false
      add :realm_id, references(:realm)
      add :character_id, references(:character)
      add :first_dump_timestamp, :utc_datetime, null: false
      add :last_dump_timestamp, :utc_datetime, null: false
      add :last_time_left, :string, null: false
    end

    create index("auction_bid_2", [:realm_id])
    create index("auction_bid_2", [:item_id], where: "item_id = 82800", name: :auction_bid_2_pet_cage_index)
  end
end
