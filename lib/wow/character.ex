defmodule Wow.Character do
  alias Wow.Repo
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type t :: Ecto.Schema.t
  @primary_key {:id, :id, autogenerate: true}

  @derive {Jason.Encoder, only: [:id, :name, :bids, :realm, :realm_id]}
  schema "character" do
    field :name, :string
    has_many :bids, Wow.AuctionBid
    belongs_to :realm, Wow.Realm
  end

  @spec changeset(Wow.Character.t, map) :: Ecto.Changeset.t
  def changeset(%Wow.Character{} = character, params \\ %{}) do
    character
    |> cast(params, [:id, :name, :realm_id])
    |> validate_required([:name, :realm_id])
    |> unique_constraint(:name_realm_id)
  end

  @spec insert(Wow.AuctionBid, map) :: t
  def insert(%Wow.Character{} = character, attrs \\ %{}) do
    {:ok, result} = character
    |> changeset(attrs)
    |> Repo.insert(returning: true, on_conflict: :replace_all_except_primary_key, conflict_target: [:name, :realm_id])

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
end
