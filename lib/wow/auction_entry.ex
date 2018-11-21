defmodule Wow.AuctionEntry do
  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type raw_entry :: %{optional(String.t) => String.t}
  @type t :: Ecto.Schema.t

  @primary_key {:id, :id, autogenerate: true}

  @derive {Jason.Encoder, only: [:auc_id, :bid, :item, :owner, :owner_realm, :region, :buyout,
    :quantity, :time_left, :rand, :seed, :context, :dump_timestamp]}
  schema "auction_entry" do
    field :auc_id, :integer
    field :bid, :integer
    field :item, :integer
    field :owner, :string
    field :owner_realm, :string
    field :region, :string
    field :buyout, :integer
    field :quantity, :integer
    field :time_left, :string
    field :rand, :integer
    field :seed, :integer
    field :context, :integer
    field :dump_timestamp, :utc_datetime

    timestamps()
  end

  @spec create_entry(map) :: t
  def create_entry(attrs \\ %{}) do
    %Wow.AuctionEntry{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @spec changeset(Wow.AuctionEntry.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.AuctionEntry{} = entry, params \\ %{}) do
    entry
    |> cast(params, [:auc_id, :bid, :item, :owner, :owner_realm, :region, :buyout, :quantity,
                    :time_left, :rand, :seed, :context, :dump_timestamp])
                    |> validate_required([:auc_id, :bid, :item, :owner, :owner_realm, :region, :buyout, :quantity,
                                         :time_left, :rand, :seed, :context, :dump_timestamp])
    |> validate_inclusion(:time_left, ["SHORT", "MEDIUM", "LONG", "VERY LONG"])
    |> unique_constraint(:auc_id_dump_timestamp)
  end

  @spec from_raw(raw_entry, integer, String.t) :: t
  def from_raw(auction, timestamp, region) do
    %Wow.AuctionEntry{
      auc_id: auction["auc"],
      bid: auction["bid"],
      item: auction["item"],
      owner: auction["owner"],
      owner_realm: auction["ownerRealm"],
      region: region,
      buyout: auction["buyout"],
      quantity: auction["quantity"],
      time_left: auction["timeLeft"],
      rand: auction["rand"],
      seed: auction["seed"],
      context: auction["context"],
      dump_timestamp: timestamp |> DateTime.from_unix!(:millisecond) |> DateTime.truncate(:second)
    } |> changeset
  end

  @spec find_by_item_id(integer, String.t, String.t) :: [t]
  def find_by_item_id(item_id, region, realm) do
    query = from entry in Wow.AuctionEntry,
      where: entry.item == ^item_id
        and entry.owner_realm == ^realm
        and entry.region == ^region

    Repo.all(query)
  end
end
