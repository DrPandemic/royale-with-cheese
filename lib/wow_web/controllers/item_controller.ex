defmodule WowWeb.ItemController do
  use WowWeb, :controller

  def show(conn, %{"region" => region, "realm" => realm, "item_name" => item_name}) do
    item = List.first(Wow.Item.find_similar_to_name(item_name))
    entries = item.id
    |> Wow.AuctionEntry.find_by_item_id(region, realm)
    |> Wow.AuctionEntryChunker.chunk("7d", ((DateTime.utc_now |> DateTime.to_unix) - 60 * 60 * 24 * 6) |> DateTime.from_unix!)
    render(conn, "show.html", entries: entries, item: item)
  end
end
