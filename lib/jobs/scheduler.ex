defmodule Jobs.Scheduler do
  use Toniq.Worker, max_concurrency: 1

  @spec perform([{:region, String.t} | {:realm, String.t}]) :: :ok
  def perform(toniq \\ Toniq) do
    [
      [region: "eu", realm: "kazzak"],
      [region: "us", realm: "medivh"],
    ]
    |> Enum.each(fn (info) -> toniq.enqueue(Jobs.Crawler, info) end)

    :ok
  end
end
