defmodule Wow.AuctionEntry do
  defmodule Subset do
    @derive {Jason.Encoder, only: [:dump_timestamp, :quantity, :buyout]}
    defstruct dump_timestamp: nil, quantity: 0, buyout: 0

    @spec tuple_to_subset([[]]) :: [%Wow.AuctionEntry.Subset{}]
    def list_to_subset(result) do
      Enum.map(result, fn([dump, buyout, quantity]) ->
        %Wow.AuctionEntry.Subset{dump_timestamp: dump, buyout: buyout, quantity: quantity}
      end)
    end

    @spec tuple_to_subset([[]]) :: [%Wow.AuctionEntry.Subset{}]
    def tuple_to_subset(result) do
      Enum.map(result, fn(e) -> %Wow.AuctionEntry.Subset{dump_timestamp: elem(e, 0), buyout: elem(e, 1), quantity: elem(e, 2)} end)
    end
  end

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

  @spec find_by_item_id(integer, String.t, String.t, NaiveDateTime.t) :: [Wow.AuctionEntry.Subset]
  defp find_by_item_id(item_id, region, realm, start_date) do
    query = from entry in Wow.AuctionEntry,
      where: entry.item == ^item_id
    and entry.owner_realm == ^realm
    and entry.region == ^region
    and entry.dump_timestamp > ^start_date,
      select: {min(entry.dump_timestamp), entry.buyout, entry.quantity},
      group_by: [:buyout, :quantity]

    query
    |> Repo.all
    |> Wow.AuctionEntry.Subset.tuple_to_subset
  end

  @spec find_by_item_id_with_sampling(integer, String.t, String.t, integer, NaiveDateTime.t) :: [t]
  def find_by_item_id_with_sampling(item_id, region, realm, max, start_date) do
    result = find_by_item_id(item_id, region, realm, start_date)
    :rand.seed(:exsplus, {1, 2, 3})
    %{
      initial_count: length(result),
      data: result |> Enum.take_random(max)
    }
  end
end
