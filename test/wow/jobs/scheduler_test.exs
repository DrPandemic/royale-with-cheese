defmodule Wow.Jobs.SchedulerTest do
  use ExUnit.Case, async: true

  setup do
    Mock.Toniq.clear
    :ok
  end

  test "schedule/0 enqueues 2 jobs" do
    Wow.Jobs.Scheduler.schedule(Mock.Toniq)

    assert Enum.count(Mock.Toniq.enqueued) == 2
  end
end
