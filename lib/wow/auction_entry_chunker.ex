defmodule Wow.AuctionEntryChunker do
  alias Wow.AuctionEntry

  @spec chunk([%AuctionEntry{}, ...], String.t, Calendar.datetime) :: [[%AuctionEntry{}]]
  def chunk(entries, "7d", start) do
    start_date = DateTime.to_date(start)
    Enum.reduce(entries, List.duplicate([], 7), fn(e, acc) ->
      position = Date.diff(DateTime.to_date(e.dump_timestamp), start_date)
      if 0 <= position && 7 > position do
        List.update_at(acc, position, fn(list) -> List.insert_at(list, 0, e) end)
      else
        acc
      end
    end)
  end
  def chunk(_, _, _) do :err end
end
