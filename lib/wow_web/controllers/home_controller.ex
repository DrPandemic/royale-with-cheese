defmodule WowWeb.HomeController do
  use WowWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def expensive(conn, _params) do
    json(conn, Wow.AuctionBid.most_expensive_items)
  end

  def present(conn, _params) do
    json(conn, Wow.AuctionBid.most_present_items)
  end
end
