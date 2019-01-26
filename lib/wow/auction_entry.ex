defmodule Wow.AuctionEntry do
  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Changeset

  defmodule Subset do
    @moduledoc """
    Used to carry the smallest usable subset of an entry.
    """
    @type t :: %__MODULE__{
      dump_timestamp: DateTime.t,
      quantity: non_neg_integer,
      buyout: non_neg_integer,
      faction: 0 | 1
    }

    @derive {Jason.Encoder, only: [:dump_timestamp, :quantity, :buyout, :faction]}
    defstruct dump_timestamp: nil, quantity: 0, buyout: 0, faction: nil

    @spec list_to_subset([[]]) :: [%Wow.AuctionEntry.Subset{}]
    def list_to_subset(result) do
      Enum.map(result, fn([dump, buyout, quantity, faction]) ->
        %Wow.AuctionEntry.Subset{dump_timestamp: dump, buyout: buyout, quantity: quantity, faction: faction}
      end)
    end

    @spec tuple_to_subset([[]]) :: [%Wow.AuctionEntry.Subset{}]
    def tuple_to_subset(result) do
      Enum.map(result, fn(e) -> %Wow.AuctionEntry.Subset{dump_timestamp: elem(e, 0), buyout: elem(e, 1), quantity: elem(e, 2), faction: elem(e, 3)} end)
    end
  end

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
    |> unique_constraint(:auc_id_dump_timestamp_owner_realm_region)
  end

  @spec from_raw(raw_entry, non_neg_integer, String.t) :: t
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
    }
  end
end
