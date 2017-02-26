defmodule PageData do
  @enforce_keys [:show, :type, :content]
  defstruct [:show, :type, :content]

  @type content_type :: Poison.Parser.t
                      | Floki.html_tree

  @type t :: %PageData{show: Show.t, type: mime_type, content: content_type}

  @typep mime_type :: :json | :html
  @type http_error :: {:error, :http_error, integer}
  @type mime_error :: {:error, :unknown_mime, String.t}
  @type general_error :: {:error, term}
  @type poison_error :: {:error, :invalid} | {:error, {:invalid, String.t, integer}}

  @doc """
    iex> parse_content(%{}, :json, ~s({ "data": "cool" }))
    %PageData{show: %{}, type: :json, content: %{"data" => "cool"}}

    iex> parse_content(%{}, :json, "invalid json")
    {:error, {:invalid, "i", 0}}

    iex> parse_content(%{}, :html, "<div></div>")
    %PageData{show: %{}, type: :html, content: {"div", [], []}}
  """
  @spec parse_content(Show.t, mime_type, Strin.t) :: {:ok, t} |  poison_error
  def parse_content(show, mime_type, content)

  @spec parse_content(Show.t, :json, Strin.t) :: {:ok, t} |  poison_error
  def parse_content(show, :json, content) do
    with {:ok, json} <- Poison.Parser.parse(content),
     do: %PageData{
           show: show,
           type: :json,
           content: json
         }
  end

  @spec parse_content(Show.t, :html, Strin.t) :: {:ok, t}
  def parse_content(show, :html, content) do
    %PageData{
      show: show,
      type: :html,
      content: Floki.parse(content)
    }
  end

  @type fetch_response :: {:ok, t}
                        | http_error
                        | mime_error
                        | poison_error
                        | general_error

  @spec fetch(Show.t) :: fetch_response
  def fetch(%{url: url} = show) do
    with {:ok, type, raw_body} <- do_fetch(url),
     do: parse_content(show, type, raw_body)
  end

  defp content_type_filter({ header, _value }), do: header == "Content-Type"

  @typep do_fetch_result :: {:ok, mime_type, String.t}
                          | http_error
                          | mime_error
                          | general_error

  @spec do_fetch(String.t) :: do_fetch_result
  defp do_fetch(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body, headers: headers}} ->
        with {_header_name, raw_mime} <- Enum.find(headers, &content_type_filter(&1)),
             {:ok, type} <- parse_mime(raw_mime),
         do: {:ok, type, body}
      {:ok, %{status_code: status_code}} -> {:error, :http_error, status_code}
      error -> {:error, error}
    end
  end

  @doc """
    iex> parse_mime("application/json")
    {:ok, :json}

    iex> parse_mime("application/json; charset=utf-8")
    {:ok, :json}

    iex> parse_mime("text/html")
    {:ok, :html}

    iex> parse_mime("text/html; charset=utf-8")
    {:ok, :html}

    iex> parse_mime("multipart/form-data; boundary=something")
    {:error, :unknown_mime, "multipart/form-data; boundary=something"}
  """
  @spec parse_mime(String.t) :: {:ok, mime_type} | mime_error
  def parse_mime(mime) do
    case mime do
      "application/json" <> _ -> {:ok, :json}
      "text/html" <>  _ -> {:ok, :html}
      _ -> {:error, :unknown_mime, mime}
    end
  end
end
