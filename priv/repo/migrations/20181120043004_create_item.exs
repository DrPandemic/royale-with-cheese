defmodule Wow.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION pg_trgm")

    create table(:item) do
      add :name, :string, null: false
      add :icon, :string, null: false
      add :buy_price, :integer, null: false
      add :sell_price, :integer, null: false
      add :is_auctionable, :boolean, null: false
      add :blob, :map, null: false

      timestamps()
    end

    create index("item", ["(to_tsvector('english', name))"], name: :name_text_gin_index, using: "GIN")
  end
end
