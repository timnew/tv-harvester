defmodule Stage.EpisodeExtractor do
  use ConsumerSupervisor

  def start_link() do
    ConsumerSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    children = [
      worker(__MODULE__, [], restart: :temporary, function: :extract_episodes)
    ]

    {:ok, children, strategy: :one_for_one, subscribe_to: [{Stage.ShowProvider, max_demand: 2, min_demand: 1}]}
  end

  def extract_episodes(site) do
    Task.start_link(__MODULE__, :do_extract_episode, site)
  end

  def do_extract_episode(site) do
    site
    |> PageData.fetch()
    |> SiteParser.parse()
    |> Enum.each(&Stage.EpisodeBuffer.put(&1))
  end
end
