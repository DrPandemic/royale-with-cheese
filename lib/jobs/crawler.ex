defmodule Jobs.Crawler do
  use Toniq.Worker

  def perform(region: region, realm: realm) do
    IO.puts "Starting #{realm}"
    id = System.get_env("BLIZZARD_CLIENT_ID")
    secret = System.get_env("BLIZZARD_CLIENT_SECRET")
    %{"access_token" => token} = Wow.Crawler.get_access_token(id, secret)
    %{"files" => [%{
      "lastModified" => last_modified,
      "url" => url
    }]} = Wow.Crawler.get_url(token, region, realm)
    %{"auctions" => auctions} = Wow.Crawler.get_dump(url)

    IO.puts "Received #{realm}"

    auctions |> Enum.map(fn e -> create_entry(e, last_modified) end) |> Enum.each(&Wow.Repo.insert/1)

    IO.puts "Done #{realm}"
  end

  def create_entry(auction, timestamp) do
    %Wow.AuctionEntry{
      auc_id: auction["auc"],
      bid: auction["bid"],
      item: auction["item"],
      owner: auction["owner"],
      owner_realm: auction["ownerRealm"],
      buyout: auction["buyout"],
      quantity: auction["quantity"],
      time_left: auction["timeLeft"],
      rand: auction["rand"],
      seed: auction["seed"],
      context: auction["context"],
      dump_timestamp: timestamp |> DateTime.from_unix!(:millisecond) |> DateTime.truncate(:second)
    } |> Wow.AuctionEntry.changeset
  end
end
