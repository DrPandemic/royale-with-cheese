defmodule TestJob do
  use Toniq.Worker

  def perform(to: to) do
    IO.puts to
  end
end
