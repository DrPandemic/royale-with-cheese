defmodule Wow.Migration do
  require Logger

  def migrate_to_new_tables do
    delete_and_fetch(Wow.AuctionEntry.find_firsts(500))
  end

  defp delete_and_fetch(entries) do
    if length(entries) > 0 do
      Logger.debug("Tick #{length(entries)}")
      Wow.Repo.checkout(fn ->
        Enum.each(entries, fn e ->
          realm = Wow.Realm.insert(Wow.Realm.from_entry(e))
          character = Wow.Character.insert(%Wow.Character{Wow.Character.from_entry(e) | realm_id: realm.id})
          Wow.AuctionBid.insert(
            %Wow.AuctionBid{Wow.AuctionBid.from_entry(e) | realm_id: realm.id, character_id: character.id}
          )
          Wow.AuctionTimestamp.insert(Wow.AuctionTimestamp.from_entry(e))

          Wow.AuctionEntry.delete_by_id(e.id)
        end)
      end)
      delete_and_fetch(Wow.AuctionEntry.find_firsts(500))
    end
  end
end
