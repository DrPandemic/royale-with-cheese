defmodule Wow.AuctionEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "auction_entry" do
    field :auc_id, :integer
    field :bid, :integer
    field :item, :integer
    field :owner, :string
    field :owner_realm, :string
    field :buyout, :integer
    field :quantity, :integer
    field :time_left, :string
    field :rand, :integer
    field :seed, :integer
    field :context, :integer
    field :dump_timestamp, :utc_datetime

    timestamps()
  end

  def changeset(entry, params \\ %{}) do
    entry
    |> cast(params, [:auc_id, :bid, :item, :owner, :owner_realm, :buyout, :quantity, :time_left, :rand, :seed, :context,
                    :dump_timestamp]
    )
    |> validate_required([:auc_id, :bid, :item, :owner, :owner_realm, :buyout, :quantity, :time_left, :rand, :seed,
                         :context, :dump_timestamp]
    )
    |> unique_constraint(:auc_id_dump_timestamp)
  end
end
