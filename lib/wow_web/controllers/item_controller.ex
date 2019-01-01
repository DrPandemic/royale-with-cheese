defmodule WowWeb.ItemController do
  use WowWeb, :controller
  alias Memoize.Cache
  alias Wow.{AuctionBid, Item}

  def show(conn, _params) do
    render(conn)
  end

  def show_json(conn, %{"region" => region, "realm" => realm, "item_name" => item_name} = params) do
    duration = Map.get(params, "duration", "7d")
    response = Cache.get_or_run({__MODULE__, :show_json, {region, realm, item_name, duration}}, fn ->
      start_date = case duration do
        "1d" ->  Timex.now |> Timex.shift(hours: -24)
        "7d" ->  Timex.now |> Timex.shift(hours: -24 * 6)
        "30d" -> Timex.now |> Timex.shift(hours: -24 * 29)
      end
      item = List.first(Item.find_similar_to_name(item_name))
      entries = AuctionBid.find_by_item_id_with_sampling(item.id, region, realm, 1000, start_date)

      Phoenix.json_library().encode_to_iodata!(%{entries: entries, item: item})
    end)

    as_json(conn, response)
  end

  def find(conn, %{"item_name" => item_name}) do
    json(conn, Item.find_similar_to_name(item_name))
  end

  defp as_json(%Plug.Conn{} = conn, response) do
    conn
    |> json_resp_content_type
    |> Plug.Conn.send_resp(conn.status || 200, response)
  end

  defp json_resp_content_type(%Plug.Conn{resp_headers: resp_headers} = conn) do
    content_type = "application/json" <> "; charset=utf-8"
    %Plug.Conn{conn | resp_headers: [{"content-type", content_type}|resp_headers]}
  end
end
