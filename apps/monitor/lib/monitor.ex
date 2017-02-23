defmodule Monitor do
  require Logger

  @moduledoc """
  Documentation for Monitor.
  """
  def scrape(site) do
    Scraper.scrape(site)
  end

  def scrape_failed(name, error) do
    Logger.error("Error [#{name}]: #{error}")
  end

  def parse(name, dom) do
    Parser.parse(name, dom)
  end
end
