defmodule Mix.Tasks.Setup.Show do
  use Mix.Task

  import Show

  @shortdoc "Setup Show"
  def run(_) do
    Mix.Task.run "run"

    create_show("Flash", "http://www.dysfz.net/movie5156.html")
    create_show("Legends of Tomorrow", "http://www.dysfz.net/movie8896.html")
    create_show("Agents of SHIELD", "http://www.dysfz.net/movie4850.html")
    create_show("Emerald City", "http://www.kmeiju.net/archives/4901.html")
    create_show("Supergirl", "http://www.kmeiju.net/archives/4543.html")
    create_show("Legion", "http://www.kmeiju.net/archives/4998.html")
  end
end
