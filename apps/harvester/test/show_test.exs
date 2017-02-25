defmodule ShowTest do
  use ExUnit.Case

  setup do
    ConfigManager.start_link("redis://locahost:6379/15")

    on_exit fn ->
      ConfigManager.command!(:flushdb)
   end
  end

  test "get_show" do
    ConfigManager.command!(:hmset, ~w(show:my_show id my_show name MyShow url http://myshow.com))

    assert Show.get_show(:my_show) == %Show{id: :my_show, name: "MyShow", url: "http://myshow.com"}
  end
end
