defmodule Scraper do
  require  Logger

  def start_link do
    Task.Supervisor.start_link(name: __MODULE__, restart: :transient)
  end

  def scrape(name) when is_atom(name) do
    Logger.debug("Scrape #{name}")
    {:ok, url} = get_url(name)

    scrape({name, url})
  end

  defp get_url(name) do
    Logger.debug("Parse url for #{name}")
    raise "Not implement yet"
  end

  def scrape({name, url}) when is_atom(name) do
    Logger.debug("Scrape #{name} at #{url}")
    run(:download, {name, url})
  end

  defp run(method, args) do
    Logger.debug("Run #{method} with #{inspect args}")
    {:ok, pid} = Task.Supervisor.start_child(__MODULE__, __MODULE__, method, [args])

    Logger.debug("Pid: #{inspect pid}")
    {:ok, pid}
  end

  def download({name, url}) do
    Logger.info("Download #{name} at #{url}")
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body}} ->
        Logger.debug("Server respond 200")
        run(:parse_html, {name, body})

      {:ok, %HTTPoison.Response{status_code: code, headers: _headers, body: _body}} ->
        Logger.debug("Server respond #{code}")
        Monitor.scrape_failed(name, code)
        exit(:http_error)

      {:error, ex} ->
        Logger.debug("Unexpected Error:")
        message = Exception.format(:error, ex)
        Logger.debug(message)
        Monitor.scrape_failed(name, message)
        exit(:http_error)

      _ ->
        Logger.error("Unexpected path reached")
        exit(:error)
    end
  end

  def parse_html({name, html}) do
    Logger.info("Parse site: #{name}")
    dom = Floki.parse(html)
    Monitor.parse(name, dom)
  end
end
