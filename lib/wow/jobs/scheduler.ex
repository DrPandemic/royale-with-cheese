defmodule Wow.Jobs.Scheduler do
  @spec schedule :: :ok
  def schedule(toniq \\ Toniq) do
    [
      [region: "eu", realm: "kazzak"],
      [region: "eu", realm: "medivh"],
      [region: "us", realm: "medivh"],
      [region: "us", realm: "illidan"],
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
      new_icons = Wow.Item.find_distinct_icons
      new_icons -- downloaded_icons(size) |> Enum.each(fn(name) -> Toniq.enqueue(Wow.Jobs.IconCrawler, name: name, size: size) end)

      :ok
    else
      :err
    end
  end

  @spec downloaded_icons(String.t) :: [String.t]
  defp downloaded_icons(size) do
    Path.wildcard("./assets/static/images/blizzard/icons/#{size}/*.jpg")
    |> Enum.map(fn name -> Regex.run(~r/.*\/(.*).jpg$/, name) |> List.last end)
  end
end
