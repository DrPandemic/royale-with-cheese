defmodule Wow.Repo.Migrations.DeleteItems do
  use Ecto.Migration

  def change do
    execute "DELETE FROM item WHERE description='';"

    alter table("item") do
      modify :description, :text
    end
  end
end
