defmodule WowWeb.ItemController do
  use WowWeb, :controller

  def show(conn, _params) do
    render(conn)
  end

  def show_json(conn, %{"region" => region, "realm" => realm, "item_name" => item_name} = params) do
    duration = Map.get(params, "duration", "7d")
    start_date = case duration do
                   "1d" ->  NaiveDateTime.utc_now |> NaiveDateTime.add(-1 * 60 * 60 * 24)
                   "7d" ->  NaiveDateTime.utc_now |> NaiveDateTime.add(-7 * 60 * 60 * 24)
                   "30d" -> NaiveDateTime.utc_now |> NaiveDateTime.add(-30 * 60 * 60 * 24)
                 end
    item = List.first(Wow.Item.find_similar_to_name(item_name))
    entries = Wow.AuctionEntry.find_by_item_id_with_sampling(item.id, region, realm, 1000, start_date)

    render(conn, "show.json", entries: entries, item: item)
  end
end
