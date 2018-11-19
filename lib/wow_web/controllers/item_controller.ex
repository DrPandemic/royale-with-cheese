defmodule WowWeb.ItemController do
  use WowWeb, :controller

  def show(conn, %{"region" => region, "realm" => realm, "item_id" => item_id}) do
    items = Wow.AuctionEntry.find_by_item_id(item_id, region, realm)
    render(conn, "show.html", items: items)
  end
end
