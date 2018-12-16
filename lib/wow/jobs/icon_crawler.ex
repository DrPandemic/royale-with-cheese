defmodule Wow.Jobs.IconCrawler do
  use Toniq.Worker, max_concurrency: 10
  import Wow.Helpers, only: [with_logs: 1]

  @base_url "https://render-us.worldofwarcraft.com/icons"
  @extension ".jpg"

  @spec perform([{:name, String.t} | {:size, String.t}]) :: :ok
  def perform(name: name, size: size) do
    with_logs(fn ->
      Application.ensure_all_started :inets

      client = Tesla.client([Tesla.Middleware.Compression])

      case Tesla.get(
            client,
            "#{@base_url}/#{size}/#{name}#{@extension}"
          ) do
        {:ok, %Tesla.Env{status: 200, body: body}} ->
          File.write!("./assets/static/images/blizzard/icons/#{size}/#{name}#{@extension}", body)
        something ->
          IO.inspect(something)
      end

      IO.puts("Fetched #{size} #{name}")

      :ok
    end)
  end
end
