defmodule Wow.Jobs.Crawler do
  import Wow.Helpers, only: [with_logs: 1]
  use Toniq.Worker, max_concurrency: 1

  @spec perform([{:region, String.t} | {:realm, String.t}]) :: :ok
  def perform(region: region, realm: realm) do
    with_logs(fn ->
      IO.puts "Starting #{region} - #{realm}"
      id = System.get_env("BLIZZARD_CLIENT_ID")
      secret = System.get_env("BLIZZARD_CLIENT_SECRET")
      token = Wow.Crawler.get_access_token(id, secret)
      %{
        lastModified: last_modified,
        url: url
      } = Wow.Crawler.get_url(token, region, realm)
      auctions = Wow.Crawler.get_dump(url)

      IO.puts "Received #{realm}"

      auctions
      |> Enum.map(fn e -> Wow.AuctionEntry.from_raw(e, last_modified, region) end)
      |> Enum.chunk_every(500)
      |> Enum.each(&insert/1)

      IO.puts "Done #{realm}"

      :ok
    end)
  end

  @spec insert(entries: [Wow.AuctionEntry]) :: any()
  defp insert(entries) do
    Wow.Repo.checkout(fn ->
      IO.puts("Tick")
      Enum.each(entries, fn e ->
        realm = Wow.Realm.insert(Wow.Realm.from_entry(e))
        character = Wow.Character.insert(%Wow.Character{Wow.Character.from_entry(e) | realm_id: realm.id})
        Wow.AuctionBid.insert(
          %Wow.AuctionBid{Wow.AuctionBid.from_entry(e) | realm_id: realm.id, character_id: character.id}
        )
      end)
    end)
  end
end
