defmodule Wow.AuctionTimestamp do
  @moduledoc """
  Represents when an auction bid is seen in the auction house.
  """

  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type t :: Ecto.Schema.t

  @primary_key false

  @derive {Jason.Encoder, only: [:auction_bid_id, :dump_timestamp, :time_left, :bid]}
  schema "auction_timestamp" do
    field :dump_timestamp, :utc_datetime, primary_key: true
    field :time_left, :string, primary_key: true
    field :bid, :integer
    belongs_to :auction_bid, Wow.AuctionBid
  end

  @spec changeset(Wow.AuctionTimestamp.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.AuctionTimestamp{} = timestamp, params \\ %{}) do
    timestamp
    |> cast(params, [:auction_bid_id, :dump_timestamp, :time_left, :bid])
    |> validate_required([:auction_bid_id, :dump_timestamp, :time_left, :bid])
    |> validate_inclusion(:time_left, ["SHORT", "MEDIUM", "LONG", "VERY LONG"])
    |> unique_constraint(:auciton_bid_id_dump_timestamp, name: :auction_timestamp_pkey)
  end

  @spec insert(Wow.AuctionTimestamp, map) :: t
  def insert(%Wow.AuctionTimestamp{} = timestamp, attrs \\ %{}) do
    {:ok, result} = timestamp
    |> changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: :replace_all_except_primary_key, conflict_target: [:auction_bid_id, :dump_timestamp])

    result
  end

  @spec from_entries([Wow.AuctionEntry]) :: [Wow.AuctionTimestamp]
  def from_entries(entries) do
    entries
    |> Enum.map(&Wow.AuctionTimestamp.from_entry/1)
  end

  @spec from_entry(Wow.AuctionEntry) :: Wow.AuctionTimestamp
  def from_entry(e) do
    %Wow.AuctionTimestamp{
      auction_bid_id: e.auc_id,
      dump_timestamp: e.dump_timestamp,
      time_left: e.time_left,
      bid: e.bid,
    }
  end
end
