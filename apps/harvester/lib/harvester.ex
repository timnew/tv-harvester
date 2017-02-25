defmodule Harvester do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    HTTPoison.start

    children = [
      worker(ConfigManager, [Application.get_env(:harvester, :redis)])
    ]

    opts = [strategy: :one_for_one, name: Harvester.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
