defmodule Wow.Jobs.Migration do
  import Wow.Helpers, only: [with_logs: 1]
  use Toniq.Worker, max_concurrency: 1

  @spec perform() :: :ok
  def perform do
    with_logs(fn ->
      Wow.Migration.migrate_to_new_tables
    end)
  end
end
