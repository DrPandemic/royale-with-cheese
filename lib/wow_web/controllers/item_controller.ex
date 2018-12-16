defmodule WowWeb.ItemController do
  use WowWeb, :controller

  def show(conn, _params) do
    render(conn)
  end

  def show_json(conn, %{"region" => region, "realm" => realm, "item_name" => item_name} = params) do
    duration = Map.get(params, "duration", "7d")
    start_date = case duration do
      "1d" ->  Timex.now |> Timex.beginning_of_day
      "7d" ->  Timex.now |> Timex.shift(days: -6)
      "30d" -> Timex.now |> Timex.shift(days: -29)
    end
    item = List.first(Wow.Item.find_similar_to_name(item_name))
    entries = Wow.AuctionBid.find_by_item_id_with_sampling(item.id, region, realm, 1000, start_date)

    render(conn, "show.json", entries: entries, item: item)
  end

  def find(conn, %{"item_name" => item_name}) do
    render(conn, "find.json", items: Wow.Item.find_similar_to_name(item_name))
  end
end
