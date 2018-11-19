defmodule Mock.Toniq do
  @spec start_link :: any()
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @spec enqueued :: list()
  def enqueued do
    Agent.get(__MODULE__, &(&1))
  end

  @spec clear :: any()
  def clear do
    Agent.update(__MODULE__, fn _ -> [] end)
  end

  @spec enqueue(any(), any()) :: :ok
  def enqueue(job, params) do
    Agent.update(__MODULE__, fn existing_jobs -> [{job, params} | existing_jobs] end)

    :ok
  end
end
