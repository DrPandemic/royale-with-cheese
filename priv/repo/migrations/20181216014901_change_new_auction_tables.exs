defmodule Wow.Repo.Migrations.ChangeNewAuctionTables do
  use Ecto.Migration

  def change do
    alter table("auction_bid") do
      remove :time_left
    end

    alter table("auction_timestamp") do
      add :time_left, :string, null: false
    end
  end
end
