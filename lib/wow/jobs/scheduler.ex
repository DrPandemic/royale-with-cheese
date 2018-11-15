defmodule Wow.Jobs.Scheduler do

  @spec schedule([{:region, String.t} | {:realm, String.t}]) :: :ok
  def schedule(toniq \\ Toniq) do
    [
      [region: "eu", realm: "kazzak"],
      [region: "us", realm: "medivh"],
    ]
    |> Enum.each(fn (info) -> toniq.enqueue(Wow.Jobs.Crawler, info) end)

    :ok
  end
end
