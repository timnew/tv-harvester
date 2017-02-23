defmodule Parser do
  def start_link do
    Task.Supervisor.start_link(name: __MODULE__, restart: :transient)
  end

  @doc """
    iex> Parser.extract_episode_info("S01E02.HR-HDTV.AC3.1024X576.x264.mkv")
    [season: 1, episode: 2]

    iex> Parser.extract_episode_info("E03.HR-HDTV.AC3.1024X576.x264.mkv")
    [episode: 3]

    iex> Parser.extract_episode_info("HR-HDTV.AC3.1024X576.x264.mkv")
    nil
  """
  def extract_episode_info(text) do
    season_info = case Regex.run(~r/s(\d+)/ui, text) do
                    [_, season] -> [season: String.to_integer(season)]
                    _ -> []
                  end

    episode_info = case Regex.run(~r/e(\d+)/ui, text) do
                     [_, episode] -> [episode: String.to_integer(episode)]
                     _ -> []
                   end

    case season_info ++ episode_info do
      [] -> nil
      result -> result
    end
  end

  def parse(name, dom) do
    method_name = List.to_existing_atom('parse_' ++ Atom.to_charlist(name))
    Task.Supervisor.start_child(__MODULE__, __MODULE__, method_name, [dom])
  end

  def parse_flash(dom) do
    dom
  end
end
