defmodule Wow.Boxplot do
  alias Wow.AuctionEntry

  @type boxplot_entry() :: %{
    min: integer(),
    max: integer(),
    median: integer(),
    lower_quartile: integer(),
    upper_quartile: integer(),
  }

  @spec boxplot([], (any(), any() -> integer())) :: :err
  def boxplot([], _) do
    :err
  end

  @spec boxplot([%AuctionEntry{}, ...], (any(), any() -> integer())) :: boxplot_entry()
  def boxplot(entries, sorter) do
    sorted = entries |> Enum.sort_by(sorter) |> Enum.map(sorter)
    %{
      min: sorted |> Enum.min,
      max: sorted |> Enum.max,
      median: sorted |> percentile(50),
      lower_quartile: sorted |> percentile(25),
      upper_quartile: sorted |> percentile(75)
    }
  end

  # Adapted from https://github.com/msharp/elixir-statistics/blob/a71ea4b1091dbe9a4993e0b4cbde3fbb303e0243/lib/statistics.ex#L181
  @spec percentile(list, number) :: number
  def percentile([], _), do: nil
  def percentile([x], _), do: x
  def percentile(list, 0), do: Enum.min(list)
  def percentile(list, 100), do: Enum.max(list)
  def percentile(list, n) when is_list(list) and is_number(n) do
    r = n / 100.0 * Enum.count(list)
    f = r |> Float.ceil |> Kernel.trunc
    if Kernel.trunc(r) != f do
      Enum.at(list, f)
    else
      lower = Enum.at(list, f)
      upper = Enum.at(list, f - 1)
      (lower + upper) / 2
    end
  end
end
