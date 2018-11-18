defmodule Wow.Jobs.Scheduler do

  @spec schedule() :: :ok
  def schedule(toniq \\ Toniq) do
    [
      [region: "eu", realm: "kazzak"],
      [region: "us", realm: "medivh"],
    ]
    |> Enum.each(fn (info) -> toniq.enqueue(Wow.Jobs.Crawler, info) end)

    :ok
  end
end
