defmodule Wow.BoxplotTest do
  use ExUnit.Case, async: true

  alias Wow.{AuctionEntry, Wow.Boxplot}

  @even_valid [
    %AuctionEntry{id: 1,  buyout: 20,    quantity: 10}, # 2
    %AuctionEntry{id: 2,  buyout: 200,   quantity: 1},  # 200
    %AuctionEntry{id: 3,  buyout: 1,     quantity: 1},  # 1
    %AuctionEntry{id: 4,  buyout: 177,   quantity: 13}, # 13.615384615
    %AuctionEntry{id: 5,  buyout: 202,   quantity: 10}, # 20.2
    %AuctionEntry{id: 6,  buyout: 99,    quantity: 20}, # 4.95
    %AuctionEntry{id: 7,  buyout: 12,    quantity: 10}, # 1.2
    %AuctionEntry{id: 8,  buyout: 20,    quantity: 20}, # 1
    %AuctionEntry{id: 9,  buyout: 544,   quantity: 200},# 2.72
    %AuctionEntry{id: 10, buyout: 65765, quantity: 20}, # 3288.25
    %AuctionEntry{id: 11, buyout: 44,    quantity: 4},  # 11
    %AuctionEntry{id: 12, buyout: 20234, quantity: 54}, # 374.703703704
    %AuctionEntry{id: 13, buyout: 2453,  quantity: 11}, # 223
    %AuctionEntry{id: 14, buyout: 875,   quantity: 17}, # 51.470588235
    %AuctionEntry{id: 15, buyout: 123,   quantity: 12}, # 10.25
    %AuctionEntry{id: 16, buyout: 7878,  quantity: 12}, # 656.5
  ]

  test "boxplot extracts the right values for an even number of elements" do
    result = Wow.Boxplot.boxplot(@even_valid, fn(%{buyout: b, quantity: q}) -> Kernel.trunc(b / q) end)

    assert result.min == 1
    assert Kernel.trunc(result.max) == 3288
    assert result.median == 12
    assert result.lower_quartile == 2
    assert Kernel.trunc(result.upper_quartile) == 211
  end

  test "boxplot extracts the right values for an odd number of elements" do
    result = Wow.Boxplot.boxplot(@even_valid |> List.pop_at(-1) |> elem(1), fn(%{buyout: b, quantity: q}) -> Kernel.trunc(b / q) end)

    assert result.min == 1
    assert Kernel.trunc(result.max) == 3288
    assert result.median == 11
    assert result.lower_quartile == 2
    assert result.upper_quartile == 223
  end

  test "boxplot extracts the right values for one element" do
    result = Wow.Boxplot.boxplot([%AuctionEntry{id: 1, buyout: 40, quantity: 2}], fn(%{buyout: b, quantity: q}) -> Kernel.trunc(b / q) end)

    assert result.min == 20
    assert result.max == 20
    assert result.median == 20
    assert result.lower_quartile == 20
    assert result.upper_quartile == 20
  end
end
