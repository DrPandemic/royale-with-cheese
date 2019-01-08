defmodule Wow.Item do
  @moduledoc """
  Represent an item. They can by searched by id or by name.
  """

  alias Wow.Repo
  use Ecto.Schema
  use Memoize
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type raw_entry :: %{optional(String.t) => String.t}
  @type t :: Ecto.Schema.t

  @derive {Jason.Encoder, only: [:id, :name, :icon, :buy_price, :sell_price,
    :is_auctionable, :item_level, :required_level, :quality, :description]}
  schema "item" do
    field :name, :string
    field :icon, :string
    field :buy_price, :integer
    field :sell_price, :integer
    field :is_auctionable, :boolean
    field :item_level, :integer
    field :required_level, :integer
    field :quality, :integer
    field :description, :string
    field :blob, :map

    timestamps()
  end

  defp validate_not_nil(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      if get_field(changeset, field) == nil do
        add_error(changeset, field, "nil")
      else
        changeset
      end
    end)
  end

  @spec create_item(map) :: t
  def create_item(attrs \\ %{}) do
    %Wow.Item{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(%Wow.Item{} = entry, params \\ %{}) do
    entry
    |> cast(params, [:id, :name, :icon, :buy_price, :sell_price, :is_auctionable,
      :item_level, :required_level, :quality, :description, :blob])
    |> validate_required([:id, :name, :icon, :buy_price, :sell_price, :is_auctionable,
      :item_level, :required_level, :quality, :blob])
    |> validate_not_nil([:description])
    |> unique_constraint(:name)
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
      item_level: item["itemLevel"],
      required_level: item["requiredLevel"],
      quality: item["quality"],
      description: get_description(item),
      blob: item
    } |> changeset
  end

  @spec get_description(raw_entry) :: String.t
  defp get_description(item) do
    if item["description"] != "" || (item |> Map.get("itemSpells", []) |> length) == 0 do
      item["description"]
    else
      item["itemSpells"] |> hd |> Map.get("scaledDescription", "")
    end
  end

  @spec find(integer) :: t
  def find(item_id) do
    query = from entry in Wow.Item,
      where: entry.item == ^item_id

    Repo.one(query)
  end

  @spec find_missing_items() :: [integer]
  def find_missing_items do
    query = from e in Wow.AuctionBid,
      distinct: e.item_id,
      left_join: i in Wow.Item,
      on: i.id == e.item_id,
      where: is_nil(i.id),
      select: {e.item_id}

    query
    |> Repo.all
    |> Enum.map(fn({id}) -> id end)
  end

  @spec find_similar_to_name(String.t) :: [t]
  defmemo find_similar_to_name(item_name), expires_in: 60 * 60 * 1000 do
    query = from i in Wow.Item,
      order_by: fragment("similarity(name, ?) DESC", ^String.downcase(item_name)),
      limit: 10

    Repo.all(query)
  end

  @spec find_distinct_icons :: [String.t]
  def find_distinct_icons do
    query = from i in Wow.Item,
      distinct: i.icon,
      select: i.icon

    query
    |> Repo.all
  end
end
