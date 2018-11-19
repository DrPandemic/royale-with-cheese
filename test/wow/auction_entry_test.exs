defmodule Wow.AuctionEntryTest do
  use Wow.DataCase

  describe "auction entry" do
    alias Wow.AuctionEntry

    @valid_attrs %{auc_id: 1, bid: 10, item: 11, owner: "foo", owner_realm: "medivh", region: "us",
      buyout: 20, quantity: 1, time_left: "VERY LONG", rand: 0, seed: 0, context: 0,
      dump_timestamp: DateTime.from_unix!(1542513262) |> DateTime.truncate(:second)}
    @invalid_attrs %{auc_id: nil, bid: nil, item: nil, owner: nil, owner_realm: nil, region: nil,
      buyout: nil, quantity: nil, time_left: nil, rand: nil, seed: nil, context: nil, dump_timestamp: nil}
    @valid_raw %{"auc" => 1, "bid" => 2, "item" => 3, "owner" => "foo", "ownerRealm" => "bar",
      "buyout" => 4, "quantity" => 5, "timeLeft" => "LONG", "rand" => 6, "seed" => 7, "context" => 8}

    test "create_entry/1 with valid data creates an entry" do
      assert {:ok, %AuctionEntry{} = entry} = AuctionEntry.create_entry(@valid_attrs)
      assert entry.auc_id == 1
    end

    test "create_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AuctionEntry.create_entry(@invalid_attrs)
    end

    test "from_raw/3 builds an entry" do
      assert entry = AuctionEntry.from_raw(@valid_raw, 1542513262, "us")
      assert entry.valid?
    end

    test "from_raw/3 validates values" do
      assert entry = AuctionEntry.from_raw(Map.delete(@valid_raw, "auc"), 1542513262, "us")
      refute entry.valid?
    end

    test "changeset/2 validates time_left" do
      ["SHORT", "MEDIUM", "LONG", "VERY LONG"]
      |> Enum.each(fn(duration) ->
        assert AuctionEntry.changeset(
          %AuctionEntry{},
          Map.put(@valid_attrs, :time_left, duration)
        ).valid?
      end)

      refute AuctionEntry.changeset(
        %AuctionEntry{},
        Map.put(@valid_attrs, :time_left, "foo")
      ).valid?
    end
  end
end
