defmodule Harvester do
  use Application

  require Logger

  def start(_type, :setup) do
    Logger.info("App started in Setup mode...")

    import Supervisor.Spec, warn: false

    HTTPoison.start

    children = [
      worker(ConfigManager, [Application.get_env(:harvester, :redis)])
    ]

    opts = [strategy: :one_for_one, name: Harvester.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def start(_type, _args) do
    Logger.info("App start in executing mode...")

    import Supervisor.Spec, warn: false

    HTTPoison.start

    children = [
      worker(ConfigManager, [Application.get_env(:harvester, :redis)]),

      worker(Stage.ShowProvider, []),
      worker(Stage.EpisodeExtractor, []),
      worker(Stage.EpisodeBuffer, []),
      worker(Stage.EpisodeProcessor, [])
    ]

    opts = [strategy: :one_for_one, name: Harvester.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
