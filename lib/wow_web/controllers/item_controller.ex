defmodule WowWeb.ItemController do
  use WowWeb, :controller

  def show(conn, %{"region" => region, "realm" => realm, "item_name" => item_name}) do
    item = List.first(Wow.Item.find_similar_to_name(item_name))
    entries = Wow.AuctionEntry.find_by_item_id(item.id, region, realm)
    render(conn, "show.html", entries: entries, item: item)
  end
end
