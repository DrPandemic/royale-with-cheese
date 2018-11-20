defmodule Wow.Item do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type raw_entry :: %{optional(String.t) => String.t}
  @type t :: Ecto.Schema.t

  @derive {Jason.Encoder, only: []}
  schema "item" do
    field :name, :string
    field :icon, :string
    field :buy_price, :integer
    field :sell_price, :integer
    field :is_auctionable, :boolean
    field :blob, :map

    timestamps()
  end

  @spec create_item(map) :: t
  def create_item(attrs \\ %{}) do
    %Wow.Item{}
    |> changeset(attrs)
    |> Wow.Repo.insert()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(%Wow.Item{} = entry, params \\ %{}) do
    entry
    |> cast(params, [:id, :name, :icon, :buy_price, :sell_price, :is_auctionable, :blob])
    |> validate_required([:id, :name, :icon, :buy_price, :sell_price, :is_auctionable, :blob])
    |> unique_constraint(:item_name_index)
  end

  @spec from_raw(raw_entry) :: t
  def from_raw(item) do
    %Wow.Item{
      id: item["id"],
      name: item["name"],
      icon: item["icon"],
      buy_price: item["buyPrice"],
      sell_price: item["sellPrice"],
      is_auctionable: item["isAuctionable"],
      blob: item
    } |> changeset
  end

  @spec find(integer) :: t
  def find(item_id) do
    query = from entry in Wow.Item,
      where: entry.item == ^item_id

    Wow.Repo.one(query)
  end
end
