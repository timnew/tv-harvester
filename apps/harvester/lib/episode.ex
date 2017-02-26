defmodule Episode do
  defstruct [:show, :title, :season, :episode, :download_url]

  @type t :: %Episode {
    show: Show.t,
    title: String.t,
    season: pos_integer,
    episode: pos_integer,
    download_url: String.t
  }
end
