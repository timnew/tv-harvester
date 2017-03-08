defmodule EpisodeTest do
  use ExUnit.Case
  import Episode

  setup_all do
    show = %Show{name: "Flash", url: "https://coolsite"}

    episode = %Episode{
      show: show,
      title: "Flash-S2E1",
      season: 2,
      episode: 1,
      download_url: "magnet://fdafdafdsa"
    }

    %{show: show, episode: episode}
  end

  setup do
    ConfigManager.start_link("redis://localshot:6379/15")

    on_exit fn ->
      ConfigManager.command!(:flushdb)
    end
  end

  doctest Episode, import: true

  test "new?", %{episode: episode} do
    assert new?(episode) == true

    store_episode(episode)

    assert new?(episode) == false
  end

  test "store_episode/2", %{episode: episode} do
    assert store_episode(episode, meta: "cool") == :ok

    assert ConfigManager.get_keyword(Episode.episode_key(episode)) == [meta: "cool"]
  end

  test "store_episode/1", %{episode: episode} do
    assert store_episode(episode) == :ok

    assert ConfigManager.get_hash(Episode.episode_key(episode)) == %{
      show: "Flash",
      title: "Flash-S2E1",
      season: "2",
      episode: "1",
      page: "https://coolsite",
      download_url: "magnet://fdafdafdsa"
    }
  end

  @tag wip: true
  test "enqueue_daily_task", %{episode: episode} do
    now = Timex.now("Australia/Melbourne")
    date = now |> Timex.to_date() |> Date.to_string()

    assert enqueue_daily_task(episode, now, :test_queue, [days: 3]) == 1

    assert ConfigManager.command!(:lrange, ~w(test_queue:#{date} 0 -1)) == ["Episode:Flash:2:1"]
    # expire_at will aligned to end of the day
    assert ConfigManager.command!(:ttl, ~w(test_queue:#{date})) > 3 * 24 * 60 * 60 # > 3 days
    assert ConfigManager.command!(:ttl, ~w(test_queue:#{date})) < 4 * 24 * 60 * 60 # < 4 days

    assert ConfigManager.get_keyword("Episode:Flash:2:1") == [enqueued_at: now |> Timex.format!("{ISO:Extended}")]
  end

  test "visit", %{episode: episode} do
    now = Timex.now("Australia/Melbourne")
    date = now |> Timex.to_date() |> Date.to_string()

    assert visit(episode) == 1

    assert ConfigManager.command!(:lrange, ~w(episode:new:#{date} 0 -1)) == ["Episode:Flash:2:1"]
    assert new?(episode) == false

    assert visit(episode) == :noop
    assert ConfigManager.command!(:lrange, ~w(episode:new:#{date} 0 -1)) == ["Episode:Flash:2:1"]
  end
end
