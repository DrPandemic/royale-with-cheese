defmodule Wow.Jobs.ItemFetch do
  alias Wow.Crawler
  alias Wow.Item
  alias Wow.Repo
  import Wow.Helpers, only: [with_logs: 1]
  use Toniq.Worker, max_concurrency: 10

  @spec perform([{:item_id, integer}]) :: :ok
  def perform(item_id: item_id) do
    with_logs(fn ->
      IO.puts "Starting item sync for #{item_id}"
      id = System.get_env("BLIZZARD_CLIENT_ID")
      secret = System.get_env("BLIZZARD_CLIENT_SECRET")

      case Crawler.get_access_token(id, secret) |> Crawler.get_item(item_id) do
        :not_found ->
          IO.puts "Skipped #{item_id}"
          :ok
        raw ->
          raw |> Item.from_raw |> Repo.insert
          IO.puts "Done with #{item_id}"
          :ok
      end
    end)
  end
end
