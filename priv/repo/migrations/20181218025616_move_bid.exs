defmodule Wow.Repo.Migrations.MoveBid do
  use Ecto.Migration

  def change do
    alter table("auction_bid") do
      remove :bid
    end

    alter table("auction_timestamp") do
      add :bid, :bigint, null: false, default: 0
    end
  end
end
