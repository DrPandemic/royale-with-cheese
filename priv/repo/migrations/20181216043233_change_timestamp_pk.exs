defmodule Wow.Repo.Migrations.ChangeTimestampPk do
  use Ecto.Migration

  def change do
    drop table("auction_timestamp")

    create table(:auction_timestamp, primary_key: false) do
      add :auction_bid_id, references(:auction_bid), primary_key: true
      add :dump_timestamp, :utc_datetime, null: false, primary_key: true
      add :time_left, :string, null: false
    end

    alter table("auction_bid") do
      remove :seed
    end
  end
end
