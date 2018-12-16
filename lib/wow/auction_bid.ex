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

  @derive {Jason.Encoder, only: [:id, :bid, :item, :owner, :owner_realm, :region, :buyout,
    :quantity, :rand, :seed, :context]}
  schema "auction_bid" do
    field :bid, :integer
    field :item, :integer
    field :owner, :string
    field :owner_realm, :string
    field :region, :string
    field :buyout, :integer
    field :quantity, :integer
    field :rand, :integer
    field :seed, :integer
    field :context, :integer
    has_one :auction_timestamp, Wow.AuctionTimestamp
  end

  @spec changeset(Wow.AuctionBid.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.AuctionBid{} = bid, params \\ %{}) do
    bid
    |> cast(params, [:id, :bid, :item, :owner, :owner_realm, :region, :buyout, :quantity,
      :rand, :seed, :context])
    |> validate_required([:id, :bid, :item, :owner, :owner_realm, :region, :buyout, :quantity,
      :rand, :seed, :context])
    |> unique_constraint(:id, name: :auction_bid_pkey)
  end

  @spec insert(Wow.AuctionBid, map) :: t
  def insert(%Wow.AuctionBid{} = bid, attrs \\ %{}) do
    bid
    |> changeset(attrs)
    |> Repo.insert()
  end

  @spec from_entries([Wow.AuctionEntry]) :: [Wow.AuctionBid]
  def from_entries(entries) do
    entries
    |> Enum.map(fn e ->
      %Wow.AuctionBid{
        id: e.auc_id,
        bid: e.bid,
        item: e.item,
        owner: e.owner,
        owner_realm: e.owner_realm,
        region: e.region,
        buyout: e.buyout,
        quantity: e.quantity,
        rand: e.rand,
        seed: e.seed,
        context: e.context,
      }
    end)
  end
end
