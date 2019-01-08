defmodule Wow.Character do
  @moduledoc """
  Represents a character.

  faction:
  0 = Alliance
  1 = Horde
  """

  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type t :: Ecto.Schema.t
  @primary_key {:id, :id, autogenerate: true}

  @derive {Jason.Encoder, only: [:id, :name, :faction, :bids, :realm, :realm_id]}
  schema "character" do
    field :name, :string
    field :faction, :integer
    field :not_found, :boolean
    has_many :bids, Wow.AuctionBid
    belongs_to :realm, Wow.Realm
  end

  @spec changeset(Wow.Character.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.Character{} = character, params \\ %{}) do
    character
    |> cast(params, [:id, :name, :faction, :realm_id])
    |> validate_required([:name, :realm_id])
    |> unique_constraint(:name_realm_id)
  end

  @spec insert(Wow.AuctionBid, map) :: t
  def insert(%Wow.Character{} = character, attrs \\ %{}) do
    {:ok, result} = character
    |> changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: :nothing, conflict_target: [:name, :realm_id])

    result
  end

  @spec from_entries([Wow.AuctionEntry]) :: [Wow.Character]
  def from_entries(entries) do
    entries
    |> Enum.map(&Wow.Character.from_entry/1)
  end

  @spec from_entry(Wow.AuctionEntry) :: Wow.Character
  def from_entry(entry) do
    %Wow.Character{
      name: entry.owner,
    }
  end

  @spec find_by_name_realm(String.t, String.t, String.t) :: Wow.Character
  def find_by_name_realm(name, realm, region) do
    query = from c in Wow.Character,
      left_join: r in Wow.Realm,
      on: c.realm_id == r.id,
      where: r.name == ^realm
        and r.region == ^region
        and c.name == ^name

    Repo.one!(query)
  end

  @spec find_no_faction :: [Wow.Character]
  def find_no_faction do
    query = from c in Wow.Character,
      left_join: r in Wow.Realm,
      on: c.realm_id == r.id,
      where: is_nil(c.faction)
        and c.not_found == false,
      preload: [:realm]

    query
    |> Repo.all
  end
end
