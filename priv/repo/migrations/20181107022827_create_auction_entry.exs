defmodule Wow.Repo.Migrations.CreateAuctionEntry do
  use Ecto.Migration

  def change do
    create table(:auction_entry) do
      add :auc_id, :bigint, null: false
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
      add :dump_timestamp, :utc_datetime, null: false

      timestamps()
    end

    create unique_index("auction_entry", [:auc_id, :dump_timestamp])
  end
end
