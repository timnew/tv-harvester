defmodule SiteParser do
  defstruct [:module, :method]

  @type t :: %SiteParser{ module: module, method: atom }

  @type host :: %{ host: String.t }
              | %{ host: String.t, path: String.t }

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
  @spec parse_host(String.t) :: {:ok, host} | :error
  def parse_host(url) when is_bitstring(url) do
    case URI.parse(url) do
      %{host: host} when is_bitstring(host) -> {:ok, host}
      %{host: host, path: path } when is_nil(host) and is_bitstring(path) -> {:ok, path}
      _ -> :error
    end
  end

  @doc """
    iex> get_parser("http://www.kmeiju.net/archives/4998.html")
    {:ok, %SiteParser{module: SiteParser.BuiltIn, method: :parse_keiju}}

    iex> get_parser("www.kmeiju.net")
    {:ok, %SiteParser{module: SiteParser.BuiltIn, method: :parse_keiju}}

    iex> get_parser("http://site_not_exists")
    :error

    iex> get_parser(%Show{id: :legion, name: "Legion", url: "http://www.kmeiju.net/archives/4998.html"})
    {:ok, %SiteParser{module: SiteParser.BuiltIn, method: :parse_keiju}}
  """
  @spec get_parser(Show.t | String.t) :: {:ok, t} | :error
  def get_parser(show_or_url_or_host)

  @spec get_parser(Show.t) :: {:ok, t} | :error
  def get_parser(%{url: url}) do
    get_parser(url)
  end

  @spec get_parser(String.t) :: {:ok, t} | :error
  def get_parser(url) when is_bitstring(url) do
    with {:ok, host} <- parse_host(url),
         {:ok, info} <- Map.fetch(site_parsers(), host),
      do: {:ok, build_struct(info)}
  end

  @spec site_parsers() :: map
  defp site_parsers do
    Application.get_env(:harvester, :site_parsers)
  end

  @spec build_struct({ module, atom }) :: t
  defp build_struct({ module, method }) do
    %SiteParser{module: module, method: method}
  end

  @spec parse(PageData.t) :: list(Episode.t)
  def parse(page_data) do
    with {:ok, parser} <- get_parser(page_data.show),
     do: invoke_parser(parser, page_data)
  end

  @spec invoke_parser(t, PageData.t) :: list(Episode.t)
  defp invoke_parser(parser, page_data) do
    apply(parser.module, parser.method, page_data)
  end
end
