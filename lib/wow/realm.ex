defmodule Wow.Realm do
  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type t :: Ecto.Schema.t
  @primary_key {:id, :id, autogenerate: true}

  @derive {Jason.Encoder, only: [:id, :name, :bids]}
  schema "realm" do
    field :name, :string
    field :region, :string
    has_many :bids, Wow.AuctionBid
    has_many :characters, Wow.Character
  end

  @spec changeset(Wow.Character.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.Realm{} = realm, params \\ %{}) do
    realm
    |> cast(params, [:id, :name, :region])
    |> validate_required([:name, :region])
    |> unique_constraint(:name_region)
  end

  @spec insert(Wow.Realm, map) :: t
  def insert(%Wow.Realm{} = realm, attrs \\ %{}) do
    {:ok, result} = realm
    |> changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: :nothing, conflict_target: [:name, :region])

    find(realm.name, realm.region)
  end

  @spec from_entries([Wow.AuctionEntry]) :: [Wow.Realm]
  def from_entries(entries) do
    entries
    |> Enum.map(&Wow.Realm.from_entry/1)
  end

  @spec from_entry(Wow.AuctionEntry) :: Wow.Realm
  def from_entry(entry) do
    %Wow.Realm{
      name: entry.owner_realm,
      region: entry.region,
    }
  end

  @spec find(String.t, String.t) :: Wow.Realm
  def find(name, region) do
    query = from r in Wow.Realm,
      where: r.region == ^region
        and r.name == ^name

    Repo.one!(query)
  end
end
