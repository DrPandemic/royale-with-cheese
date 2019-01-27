defmodule Wow.AuctionBid do
  @moduledoc """
  Represent an item sold on the auction house. It doesn't contain when the item was added to the
  auction house. This information is present in auction_timestamp.
  """

  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type raw_entry :: %{optional(String.t) => String.t}
  @type t :: Ecto.Schema.t
  @bid_ttl_in_days 32

  @derive {Jason.Encoder, only: [:id, :item_id, :buyout, :quantity, :rand, :context,
    :timestamps, :realm, :character, :realm_id, :character_id]}
  schema "auction_bid" do
    field :bid, :integer
    field :buyout, :integer
    field :quantity, :integer
    field :rand, :integer
    field :context, :integer
    field :first_dump_timestamp, :utc_datetime
    field :last_dump_timestamp, :utc_datetime
    field :last_time_left, :string
    belongs_to :realm, Wow.Realm
    belongs_to :character, Wow.Character
    belongs_to :item, Wow.Item
  end

  @spec changeset(Wow.AuctionBid.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.AuctionBid{} = bid, params \\ %{}) do
    bid
    |> cast(params, [:id, :item_id, :buyout, :quantity, :rand, :context, :realm_id, :character_id, :first_dump_timestamp, :last_dump_timestamp, :last_time_left])
    |> validate_required([:item_id, :buyout, :quantity, :rand, :context, :realm_id, :character_id, :first_dump_timestamp, :last_dump_timestamp, :last_time_left])
    |> unique_constraint(:id, name: :auction_bid_pkey)
  end

  @spec insert(Wow.AuctionBid.t, map) :: t
  def insert(%Wow.AuctionBid{} = bid, attrs \\ %{}) do
    {:ok, result} = bid
    |> changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: {:replace, [:last_dump_timestamp, :last_time_left, :bid, :character_id]}, conflict_target: :id)

    result
  end

  @spec from_entries([Wow.AuctionEntry.t]) :: [Wow.AuctionBid.t]
  def from_entries(entries) do
    entries
    |> Enum.map(&Wow.AuctionBid.from_entry/1)
  end

  @spec from_entry(Wow.AuctionEntry.t) :: Wow.AuctionBid.t
  def from_entry(e) do
    %Wow.AuctionBid{
      id: e.auc_id,
      bid: e.bid,
      item_id: e.item,
      buyout: e.buyout,
      quantity: e.quantity,
      rand: e.rand,
      context: e.context,
      first_dump_timestamp: e.dump_timestamp,
      last_dump_timestamp: e.dump_timestamp,
      last_time_left: e.time_left,
    }
  end

  @spec find_by_item_id(non_neg_integer, String.t, String.t, DateTime.t) :: [Wow.AuctionEntry.Subset.t]
  defp find_by_item_id(item_id, region, realm, start_date) do
    query = from entry in Wow.AuctionBid,
      inner_join: r in assoc(entry, :realm),
      inner_join: c in assoc(entry, :character),
      where: entry.item_id == ^item_id
        and r.name == ^realm
        and r.region == ^region
        and entry.first_dump_timestamp > ^start_date
        and not is_nil(c.faction),
      select: {entry.first_dump_timestamp, entry.buyout, entry.quantity, c.faction}

    query
    |> Repo.all
    |> Wow.AuctionEntry.Subset.tuple_to_subset
  end

  @spec find_by_item_id_with_sampling(non_neg_integer, String.t, String.t, non_neg_integer, DateTime.t) :: %{data: [t], initial_count: non_neg_integer}
  def find_by_item_id_with_sampling(item_id, region, realm, max, start_date) do
    result = find_by_item_id(item_id, region, realm, start_date)
    :rand.seed(:exsplus, {1, 2, 3})
    %{
      initial_count: length(result),
      data: result |> Enum.take_random(max)
    }
  end

  @spec most_expensive_items :: [Wow.Item.ItemWithCount]
  def most_expensive_items do
    key = "model.auction_bid.most_expensive"
    case Cachex.get(:wow_cache, key) do
      {:ok, nil} ->
        lower = Timex.now |> Timex.shift(hours: -24)
        upper = Timex.now
        query = from entry in Wow.AuctionBid,
          inner_join: item in assoc(entry, :item),
          where: entry.first_dump_timestamp > ^lower
            and entry.first_dump_timestamp <= ^upper,
          having: count(entry.item_id) > 50,
          limit: 3,
          order_by: [desc: fragment("median(buyout / quantity)::bigint")],
          group_by: [item.id, item.name, item.icon],
          select: {
            item.id,
            item.name,
            item.icon,
            fragment("median(buyout / quantity)::bigint"),
            item.sell_price,
            item.item_level,
            item.required_level,
            item.quality,
            item.description,
            item.stats,
            count(item.id)
          }

        response = query
        |> Repo.all
        |> Enum.map(&Wow.Item.ItemWithCount.tuple_to_subset/1)
        Cachex.put(:wow_cache, key, response, ttl: :timer.minutes(30))
        response
      {:ok, response} -> response
    end
  end

  @spec most_present_items :: [Wow.Item.ItemWithCount]
  def most_present_items do
    key = "model.auction_bid.most_present_item"
    case Cachex.get(:wow_cache, key) do
      {:ok, nil} ->
        lower = Timex.now |> Timex.shift(hours: -24)
        upper = Timex.now
        query = from entry in Wow.AuctionBid,
          inner_join: item in assoc(entry, :item),
          where: entry.first_dump_timestamp > ^lower
        and entry.first_dump_timestamp <= ^upper,
          limit: 3,
          order_by: [desc: count(item.id)],
          group_by: [item.id, item.name, item.icon],
          select: {
            item.id,
            item.name,
            item.icon,
            fragment("median(buyout / quantity)::bigint"),
            item.sell_price,
            item.item_level,
            item.required_level,
            item.quality,
            item.description,
            item.stats,
            count(item.id)
          }

        response = query
        |> Repo.all
        |> Enum.map(&Wow.Item.ItemWithCount.tuple_to_subset/1)
        Cachex.put(:wow_cache, key, response, ttl: :timer.minutes(30))
        response
      {:ok, response} -> response
    end
  end

  @spec delete_old :: {integer(), nil | [term()]}
  def delete_old do
    limit = Timex.now |> Timex.shift(hours: -24 * @bid_ttl_in_days)
    (from bid in Wow.AuctionBid,
      where: bid.last_dump_timestamp < ^limit)
    |> Repo.delete_all
  end
end
