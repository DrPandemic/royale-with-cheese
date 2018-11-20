defmodule Wow.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item) do
      add :name, :string, null: false
      add :icon, :string, null: false
      add :buy_price, :integer, null: false
      add :sell_price, :integer, null: false
      add :is_auctionable, :boolean, null: false
      add :blob, :map, null: false

      timestamps()
    end

    create index("item", ["name text_pattern_ops"], name: :name_text_pattern_index)
  end
end
