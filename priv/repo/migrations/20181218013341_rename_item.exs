defmodule Wow.Repo.Migrations.RenameItem do
  use Ecto.Migration

  def change do
    rename table(:auction_bid), :item, to: :item_id
  end
end
