defmodule ShowTest do
  use ExUnit.Case

  setup do
    ConfigManager.start_link("redis://locahost:6379/15")

    on_exit fn ->
      ConfigManager.command!(:flushdb)
   end
  end

  test "get_show" do
    ConfigManager.command!(:hmset, ~w(Show:MyShow name MyShow url http://myshow.com))

    assert Show.get_show("MyShow") == %Show{name: "MyShow", url: "http://myshow.com"}
  end

  test "get_all_shows" do
    ConfigManager.command!(:hmset, ~w(Show:MyShow1 name MyShow1 url http://myshow.com))
    ConfigManager.command!(:hmset, ~w(Show:MyShow2 name MyShow2 url http://myshow.com))

    loaded_shows = Show.get_all_shows() |> Enum.sort()
    expected_shows = [
      %Show{name: "MyShow1", url: "http://myshow.com"},
      %Show{name: "MyShow2", url: "http://myshow.com"}
    ]

    assert loaded_shows == expected_shows
  end
end
