defmodule ConfigManagerTest do
  defstruct [:a, :b, :c]

  use ExUnit.Case

  import ConfigManager

  setup do
    ConfigManager.start_link("redis://localshot:6379/15")

    on_exit fn ->
      command!(:flushdb)
   end
  end

  test "get_keyword" do
    command!(:hmset, ~w{ConfigManagerTest a 1 b 2 c 3})

    assert get_keyword(ConfigManagerTest) == [a: "1", b: "2", c: "3"]
  end

  test "get_hash" do
    command!(:hmset, ~w{ConfigManagerTest a 1 b 2 c 3})

    assert get_hash(ConfigManagerTest) == %{a: "1", b: "2", c: "3"}

    assert get_hash(ConfigManagerTest, %{e: "!"}) == %{a: "1", b: "2", c: "3", e: "!"}
  end

  test "get_struct" do
    command!(:hmset, ~w{ConfigManagerTest a 1 b 2 c 3})

    assert get_struct(ConfigManagerTest, ConfigManagerTest) == %ConfigManagerTest{a: "1", b: "2", c: "3"}
  end

  test "keys" do
    key_list = ~w{ConfigManagerTest:a ConfigManagerTest:b ConfigManagerTest:c}

    for key <- key_list, do: command!(:set, [key, key])

    actual_keys = keys([ConfigManagerTest, "*"]) |> Enum.sort()

    assert actual_keys == key_list
  end

  doctest ConfigManager, import: true
end
