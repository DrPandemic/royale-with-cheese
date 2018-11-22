defmodule Wow.AuctionEntryChunkerTest do
  use ExUnit.Case, async: true

  alias Wow.{AuctionEntry, AuctionEntryChunker}

  describe "chunk 7d" do
    test "creates different chunks for every day" do
      start_unix = Enum.random(1514764800..1522454400)
      chunks = AuctionEntryChunker.chunk(create_random_entries(200, start_unix), "7d", DateTime.from_unix!(start_unix))

      for entries <- chunks do
        zipped = Enum.zip(entries, List.delete_at(entries, 0))
        assert Enum.all?(zipped, fn({a, b}) -> Date.diff(DateTime.to_date(a.dump_timestamp), DateTime.to_date(b.dump_timestamp)) == 0 end)
      end
    end
  end

  defp create_random_entries(count, start_unix) do
    (1..count) |> Enum.map(fn(i) ->
      %AuctionEntry{
        id: i,
        buyout: Enum.random(100..1000),
        quantity: Enum.random(1..100),
        dump_timestamp: DateTime.from_unix!(Enum.random((start_unix..start_unix + 604_800)))
      } end
    )
  end
end
