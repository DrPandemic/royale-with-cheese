defmodule Wow.Jobs.Scheduler do
  @spec schedule :: :ok
  def schedule(toniq \\ Toniq) do
    [
      [region: "eu", realm: "kazzak"],
      [region: "eu", realm: "medivh"],
      [region: "us", realm: "medivh"],
    ]
    |> Enum.each(fn(info) -> toniq.enqueue(Wow.Jobs.Crawler, info) end)

    schedule_items()

    :ok
  end

  @spec schedule_items :: :ok
  def schedule_items(toniq \\ Toniq) do
    Wow.Item.find_missing_items
    |> Enum.each(fn(item_id) -> toniq.enqueue(Wow.Jobs.ItemFetch, item_id: item_id) end)

    :ok
  end

  @spec schedule_item_icons(String.t) :: :ok | :err
  def schedule_item_icons(size) do
    if size == "36" || size == "56" do
      result = Wow.Item.find_distinct_icons
      result |> Enum.each(fn(name) -> Toniq.enqueue(Wow.Jobs.IconCrawler, name: name, size: size) end)

      :ok
    else
      :err
    end
  end
end
