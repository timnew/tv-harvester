defmodule SiteParser do
  defstruct [:module, :method]

  @doc """
    iex> parse_host("http://google.com/")
    {:ok, "google.com"}

    iex> parse_host("https://www.google.com/")
    {:ok, "www.google.com"}

    iex> parse_host("http://192.168.1.2:8080/")
    {:ok, "192.168.1.2"}

    iex> parse_host(~s(http://google.com/path?query=yes#hash/a/b/c))
    {:ok, "google.com"}

    iex> parse_host("google.com")
    {:ok, "google.com"}

    iex> parse_host("")
    :error
  """
  def parse_host(url) when is_bitstring(url) do
    case URI.parse(url) do
      %{host: host} when is_bitstring(host) -> {:ok, host}
      %{host: host, path: path } when is_nil(host) and is_bitstring(path) -> {:ok, path}
      _ -> :error
    end
  end

  @doc """
    iex> get_parser("http://www.kmeiju.net/archives/4998.html")
    {:ok, %SiteParser{module: SiteParser, method: :parse_keiju}}

    iex> get_parser("www.kmeiju.net")
    {:ok, %SiteParser{module: SiteParser, method: :parse_keiju}}

    iex> get_parser("http://site_not_exists")
    :error

    iex> get_parser(%Show{id: :legion, name: "Legion", url: "http://www.kmeiju.net/archives/4998.html"})
    {:ok, %SiteParser{module: SiteParser, method: :parse_keiju}}
  """
  def get_parser(show_or_url_or_host)

  def get_parser(%{url: url}) do
    get_parser(url)
  end

  def get_parser(url) when is_bitstring(url) do
    with {:ok, host} <- parse_host(url),
         {:ok, info} <- Map.fetch(site_parsers(), host),
      do: {:ok, build_struct(info)}
  end

  defp site_parsers do
    Application.get_env(:harvester, :site_parsers)
  end

  defp build_struct({ module, method }) do
    %SiteParser{module: module, method: method}
  end
end
