defmodule ShowTest do
  use ExUnit.Case

  import Show

  setup do
    ConfigManager.start_link("redis://locahost:6379/15")

    on_exit fn ->
      ConfigManager.command!(:flushdb)
   end
  end

  test "get_show" do
    create_show("MyShow", "http://myshow.com")

    assert get_show("MyShow") == %Show{name: "MyShow", url: "http://myshow.com"}
  end

  test "get_all_shows" do
    create_show(%Show{name: "MyShow1", url: "http://myshow.com"})
    create_show(%Show{name: "MyShow2", url: "http://myshow.com"})

    loaded_shows = get_all_shows() |> Enum.sort()
    expected_shows = [
      %Show{name: "MyShow1", url: "http://myshow.com"},
      %Show{name: "MyShow2", url: "http://myshow.com"}
    ]

    assert loaded_shows == expected_shows
  end

  test "delete all shows" do
    create_show(%Show{name: "MyShow1", url: "http://myshow.com"})
    create_show(%Show{name: "MyShow2", url: "http://myshow.com"})

    assert delete_all_shows() == 2

    assert get_all_shows() == []
  end
end
