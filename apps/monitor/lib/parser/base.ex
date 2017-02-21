defmodule Parser.Base do
  defmacro __using__ do
    quote do
      use GenServer

      # %HTTPoison.AsyncResponse{id: #Reference<0.0.0.1654>}iex> flush
      # %HTTPoison.AsyncStatus{code: 200, id: #Reference<0.0.0.1654>}
      # %HTTPoison.AsyncHeaders{headers: %{"Connection" => "keep-alive", ...}, id: #Reference<0.0.0.1654>}
      # %HTTPoison.AsyncChunk{chunk: "<!DOCTYPE html>...", id: #Reference<0.0.0.1654>}
      # %HTTPoison.AsyncEnd{id: #Reference<0.0.0.1654>}

    end
  end
end
