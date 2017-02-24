defmodule Parser do
  require Logger

  def start_link do
    Task.Supervisor.start_link(name: __MODULE__, restart: :transient)
  end

  @doc """
    iex> Parser.extract_episode_info("S01E02.HR-HDTV.AC3.1024X576.x264.mkv")
    %{season: 1, episode: 2}

    iex> Parser.extract_episode_info("E03.HR-HDTV.AC3.1024X576.x264.mkv")
    %{episode: 3}

    iex> Parser.extract_episode_info("HR-HDTV.AC3.1024X576.x264.mkv")
    %{}

    iex> Parser.extract_episode_info("S03.HR-HDTV.AC3.1024X576.x264.mkv")
    %{}
  """
  def extract_episode_info(text) do
    Logger.debug("Extract episode info: #{text}")
    matched = Regex.run(~r/(s(?<season>\d+))?e(?<episode>\d+)/ui, text, capture: :all_names)
    # with capture: all_names
    # matches are sorted by name in alphabetic order instead of capture order
    # so captured pattern is [episode, season] instead of [season, episode]

    case matched do
      [episode, season] when season == "" -> tap(%{episode: String.to_integer(episode)})
      [episode, season] when season != "" and episode != "" -> tap(%{season: String.to_integer(season), episode: String.to_integer(episode)})
      _ -> tap(%{})
    end
  end

  def parse(name, dom) do
    method_name = List.to_existing_atom('parse_' ++ Atom.to_charlist(name))
    Logger.debug("Invoke #{method_name}...")
    Task.Supervisor.start_child(__MODULE__, __MODULE__, method_name, [dom])
  end

  defp generate_entry(element, show) do
    Logger.debug("Generate Entry from #{inspect element}")
    tap(%{show: show, title: hd(Floki.attribute(element, "title")), href: hd(Floki.attribute(element, "href"))})
  end

  defp tap(data) do
    Logger.debug("Tap: #{inspect data}")
    data
  end

  def parse_legion(dom) do
    Logger.debug("Parsing Legion DOM")
    Floki.find(dom, ~s(table#table tr td a))
    |> Stream.map(&generate_entry(&1, "Flash"))
    |> Stream.map(&Map.merge(&1, extract_episode_info(Map.fetch!(&1, :title))))
    |> Enum.into([])
    |> tap()
  end
end
