defmodule Episode do
  defstruct [:show, :title, :season, :episode, :download_url]

  @type t :: %Episode {
    show: Show.t,
    title: String.t,
    season: pos_integer,
    episode: pos_integer,
    download_url: String.t
  }

  @doc """
    iex> parse_title("S01E02.HR-HDTV.AC3.1024X576.x264.mkv")
    [season: 1, episode: 2]

    iex> parse_title("E03.HR-HDTV.AC3.1024X576.x264.mkv")
    [episode: 3]

    iex> parse_title("HR-HDTV.AC3.1024X576.x264.mkv")
    []

    iex> parse_title("S03.HR-HDTV.AC3.1024X576.x264.mkv")
    []
  """
  @spec parse_title(String.t) :: keyword
  def parse_title(title) do
    matched = Regex.run(~r/(s(?<season>\d+))?e(?<episode>\d+)/ui, title, capture: :all_names)
    # with capture: all_names
    # matches are sorted by name in alphabetic order instead of capture order
    # so captured pattern is [episode, season] instead of [season, episode]

    case matched do
      [episode, season] when season == "" ->
        [episode: String.to_integer(episode)]
      [episode, season] when season != "" and episode != "" ->
        [season: String.to_integer(season), episode: String.to_integer(episode)]
      _ ->
        []
    end
  end

  @doc """
    iex> parse_episode_title(%Episode{title: "S01E02.HR-HDTV.AC3.1024X576.x264.mkv"})
    %Episode{title: "S01E02.HR-HDTV.AC3.1024X576.x264.mkv", season: 1, episode: 2}

    iex> parse_episode_title(%Episode{title: "E03.HR-HDTV.AC3.1024X576.x264.mkv"})
    %Episode{title: "E03.HR-HDTV.AC3.1024X576.x264.mkv", episode: 3}

    iex> parse_episode_title(%Episode{title: "HR-HDTV.AC3.1024X576.x264.mkv"})
    %Episode{title: "HR-HDTV.AC3.1024X576.x264.mkv"}
  """
  @spec parse_episode_title(t) :: t
  def parse_episode_title(%Episode{title: title} = episode) do
    struct(episode, parse_title(title))
  end
end