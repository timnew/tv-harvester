defmodule SiteParser.BuiltIn do
  def build_entry(a) do
    title = Floki.text(a)
    link = Floki.attribute(a, "href")

    %Episode{title: title, download_url: link}
  end

  def filter_attr(element, attr, filter) do
    element
    |> Floki.attribute(attr)
    |> filter.()
  end

  def stream_filter_attr(elements, attr, filter) do
    elements
    |> Stream.filter(&filter_attr(&1, attr, filter))
  end

  def filter_text(element, filter) do
    element
    |> Floki.text()
    |> filter.()
  end

  def stream_filter_text(elements, filter) do
    elements
    |> Stream.filter(&filter_text(&1, filter))
  end

  def not_blank(text) when is_binary(text) do
    text
    |> String.trim()
    |> String.length() > 0
  end

  def parse_keiju(%{show: show, content: dom}) do
    dom
    |> Floki.find(~s(table#table tr td a))
    |> Stream.map(&build_entry(&1))
    |> Stream.map(&Map.put(&1, :show, show))
    |> Stream.map(&Episode.parse_episode_title(&1))
    |> Enum.to_list()
  end

  @p2p_schemes ~w(ed2k: magnet:)
  def parse_dysfz(%{show: show, content: dom}) do
    dom
    |> Floki.find(".detail p a[href]")
    |> stream_filter_attr("href", &String.starts_with?(&1, @p2p_schemes))
    |> stream_filter_text(&not_blank(&1))
    |> Stream.map(&build_entry(&1))
    |> Stream.map(&Map.put(&1, :show, show))
    |> Stream.map(&Episode.parse_episode_title(&1))
    |> Enum.to_list()
  end




end
