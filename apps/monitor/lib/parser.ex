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

    iex> Parser.extract_episode_info("S03.HR-HDTV.AC3.1024X576.x264.mkv")
    nil
  """
  def extract_episode_info(text) do
    matched = Regex.run(~r/(s(?<season>\d+))?e(?<episode>\d+)/ui, text, capture: :all_names)
    # with capture: all_names
    # matches are sorted by name in alphabetic order instead of capture order
    # so captured pattern is [episode, season] instead of [season, episode]

    case matched do
      [episode, season] when season == "" -> [episode: String.to_integer(episode)]
      [episode, season] when season != "" and episode != "" -> [season: String.to_integer(season), episode: String.to_integer(episode)]
      _ -> nil
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
