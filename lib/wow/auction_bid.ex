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

  @derive {Jason.Encoder, only: [:id, :item_id, :buyout, :quantity, :rand, :context,
    :timestamps, :realm, :character, :realm_id, :character_id]}
  schema "auction_bid" do
    field :item_id, :integer
    field :buyout, :integer
    field :quantity, :integer
    field :rand, :integer
    field :context, :integer
    has_many :timestamps, Wow.AuctionTimestamp
    belongs_to :realm, Wow.Realm
    belongs_to :character, Wow.Character
  end

  @spec changeset(Wow.AuctionBid.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.AuctionBid{} = bid, params \\ %{}) do
    bid
    |> cast(params, [:id, :item_id, :buyout, :quantity, :rand, :context, :realm_id, :character_id])
    |> validate_required([:item_id, :buyout, :quantity, :rand, :context, :realm_id, :character_id])
    |> unique_constraint(:id, name: :auction_bid_pkey)
  end

  @spec insert(Wow.AuctionBid, map) :: t
  def insert(%Wow.AuctionBid{} = bid, attrs \\ %{}) do
    {:ok, result} = bid
    |> changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: :replace_all_except_primary_key, conflict_target: [:id])

    result
  end

  @spec from_entries([Wow.AuctionEntry]) :: [Wow.AuctionBid]
  def from_entries(entries) do
    entries
    |> Enum.map(&Wow.AuctionBid.from_entry/1)
  end

  @spec from_entry(Wow.AuctionEntry) :: Wow.AuctionBid
  def from_entry(e) do
    %Wow.AuctionBid{
      id: e.auc_id,
      item_id: e.item,
      buyout: e.buyout,
      quantity: e.quantity,
      rand: e.rand,
      context: e.context,
    }
  end

  @spec find_by_item_id(integer, String.t, String.t, DateTime.t) :: [Wow.AuctionEntry.Subset]
  defp find_by_item_id(item_id, region, realm, start_date) do
    query = from entry in Wow.AuctionBid,
      inner_join: t in assoc(entry, :timestamps),
      inner_join: r in assoc(entry, :realm),
      where: entry.item_id == ^item_id
        and r.name == ^realm
        and r.region == ^region
        and t.dump_timestamp > ^start_date,
      select: {min(t.dump_timestamp), entry.buyout, entry.quantity},
      group_by: [:buyout, :quantity]

    query
    |> Repo.all
    |> Wow.AuctionEntry.Subset.tuple_to_subset
  end

  @spec find_by_item_id_with_sampling(integer, String.t, String.t, integer, DateTime.t) :: [t]
  def find_by_item_id_with_sampling(item_id, region, realm, max, start_date) do
    result = find_by_item_id(item_id, region, realm, start_date)
    :rand.seed(:exsplus, {1, 2, 3})
    %{
      initial_count: length(result),
      data: result |> Enum.take_random(max)
    }
  end
end
