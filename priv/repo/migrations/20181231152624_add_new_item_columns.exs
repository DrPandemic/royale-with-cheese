defmodule Wow.Repo.Migrations.AddNewItemColumns do
  use Ecto.Migration

  def change do
    execute "TRUNCATE item;"
    alter table("item") do
      add :item_level, :smallint, null: false
      add :required_level, :smallint, null: false
      add :quality, :smallint, null: false
      add :description, :string, null: false
    end
  end
end
