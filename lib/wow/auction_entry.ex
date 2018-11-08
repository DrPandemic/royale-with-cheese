defmodule Wow.AuctionEntry do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}

  schema "auction_entry" do
    field :auc_id, :string
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
end
