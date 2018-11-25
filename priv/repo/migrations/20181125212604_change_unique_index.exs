defmodule Wow.Repo.Migrations.ChangeUniqueIndex do
  use Ecto.Migration

  def change do
    drop index("auction_entry", [:auc_id_dump_timestamp])

    create unique_index("auction_entry", [:auc_id, :dump_timestamp, :owner_realm, :region])
  end
end
