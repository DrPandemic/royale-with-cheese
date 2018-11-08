defmodule Wow.Repo.Migrations.CreateAuctionEntry do
  use Ecto.Migration

  def change do
    create table(:auction_entry) do
      add :auc_id, :string, null: false
      add :bid, :integer, null: false
      add :item, :integer, null: false
      add :owner, :string, null: false
      add :owner_realm, :string, null: false
      add :buyout, :integer, null: false
      add :quantity, :integer, null: false
      add :time_left, :string, null: false
      add :rand, :integer, null: false
      add :seed, :integer, null: false
      add :context, :integer, null: false
      add :dump_timestamp, :utc_datetime, null: false

      timestamps()
    end

    create unique_index("auction_entry", [:auc_id, :dump_timestamp])
  end
end
