defmodule Wow.Migration do
  require Logger

  def migrate_to_new_tables do
    delete_and_fetch(Wow.AuctionEntry.find_firsts(500))
  end

  defp delete_and_fetch(entries) do
    if length(entries) > 0 do
      bids = Wow.AuctionBid.from_entries(entries)
      timestamps = Wow.AuctionTimestamp.from_entries(entries)
      Logger.info("Tick #{length(entries)}")
      Wow.Repo.checkout(fn ->
        bids |> Enum.each(&Wow.AuctionBid.insert/1)
        timestamps |> Enum.each(&Wow.AuctionTimestamp.insert/1)
        entries |> Enum.map(fn e -> e.id end) |> Wow.AuctionEntry.delete_by_ids
      end)
      delete_and_fetch(Wow.AuctionEntry.find_firsts(1000))
    end
  end
end
