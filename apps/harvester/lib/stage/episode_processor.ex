defmodule Stage.EpisodeProcessor do
  use GenStage.ConsumerSupervisor

  def start_link() do
    GenStage.ConsumerSupervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    children = [
      worker(__MODULE__, [], restart: :temporary, function: :process_episode)
    ]

    {:ok, children, strategy: :one_for_one, subscribe_to: [{Stage.EpisodeBuffer, max_demand: 20, min_demand: 10}]}
  end

  def process_episode(episode) do
    Task.start_link(__MODULE__, :do_process_episode, episode)
  end

  def do_process_episode(episode) do
    Episode.visit(episode)
  end
end
