defmodule WowWeb.HomeController do
  use WowWeb, :controller

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      most_expensive_items: Wow.AuctionBid.most_expensive_items,
      most_present_items: Wow.AuctionBid.most_present_items
    )
  end
end
