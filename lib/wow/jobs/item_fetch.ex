defmodule Wow.Jobs.ItemFetch do
  alias Wow.Crawler
  alias Wow.Item
  alias Wow.Repo
  use Toniq.Worker, max_concurrency: 10

  @spec perform([{:item_id, integer}]) :: :ok
  def perform(item_id: item_id) do
    IO.puts "Starting item sync for #{item_id}"
    id = System.get_env("BLIZZARD_CLIENT_ID")
    secret = System.get_env("BLIZZARD_CLIENT_SECRET")

    Crawler.get_access_token(id, secret)
    |> Crawler.get_item(item_id)
    |> Item.from_raw
    |> Repo.insert

    IO.puts "Done with #{item_id}"
    :ok
  end
end
