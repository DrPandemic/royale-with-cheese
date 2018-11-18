defmodule Wow.Jobs.Crawler do
  use Toniq.Worker, max_concurrency: 1

  @spec perform([{:region, String.t} | {:realm, String.t}]) :: :ok
  def perform(region: region, realm: realm) do
    IO.puts "Starting #{realm}"
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
    |> Enum.map(fn e -> Wow.AuctionEntry.from_raw(e, last_modified) end)
    |> Enum.chunk_every(500)
    |> Enum.each(&insert/1)

    IO.puts "Done #{realm}"

    :ok
  end

  @spec insert(auctions: [Wow.AuctionEntry]) :: any()
  defp insert(auctions) do
    Wow.Repo.checkout(fn ->
      IO.puts("Tick")
      auctions |> Enum.each(&Wow.Repo.insert/1)
    end)
  end
end
