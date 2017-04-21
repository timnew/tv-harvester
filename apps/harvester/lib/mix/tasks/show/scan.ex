defmodule Mix.Tasks.Show.Scan do
  use Mix.Task

  import Show
  require PageData
  require SiteParser
  require Episode

  @shortdoc "Scan Show"
  def run(_) do
    Mix.Task.run "run"

    get_all_shows()
    |> Stream.map(&PageData.fetch/1)
    |> Stream.map(&SiteParser.parse/1)
    |> Stream.flat_map(fn x -> x end)
    |> Stream.map(&Episode.visit/1)
    |> Enum.each(&IO.puts/1)
  end
end
