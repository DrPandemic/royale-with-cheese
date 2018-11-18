defmodule Mock.Toniq do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def enqueued do
    Agent.get(__MODULE__, &(&1))
  end

  def clear do
    Agent.update(__MODULE__, fn _ -> [] end)
  end

  def enqueue(job, params) do
    Agent.update(__MODULE__, fn existing_jobs -> [{job, params} | existing_jobs] end)

    :ok
  end
end
