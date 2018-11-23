defmodule Wow.Jobs.Scheduler do
  @spec schedule() :: :ok
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

  @spec schedule_items() :: :ok
  def schedule_items(toniq \\ Toniq) do
    Wow.Item.find_missing_items
    |> Enum.each(fn(item_id) -> toniq.enqueue(Wow.Jobs.ItemFetch, item_id: item_id) end)

    :ok
  end
end
