defmodule Stage.EpisodeBuffer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init do
    {:producer_consumer, nil}
  end

  def put(episodes) do
    GenStage.cast(__MODULE__, {:put, episodes})
  end

  def handle_cast({:put, episodes}, queue) do
    {:noreply, [episodes], nil}
  end

  def handle_events(episodes, _from, _state) do
    {:noreply, [episodes], nil}
  end
end
