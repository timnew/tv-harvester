defmodule Downloader do
  use GenServer

  def start_link do
    import Supervisor.Spec, warn: false
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    [:ok, nil]
  end

  @@doc """
  """
  def add_task(task)

  def add_task(name) when is_atom(name) do
    {:ok, url} = get_url(name)
    GenServer.cask(__MODULE__, {:download, name, url})
  end

  defp get_url(name) do
    raise "Not implement yet"
  end

  def add_task((name, url) = explict_task) when is_tuple(explict_task) and is_atom(name) do
    GenServer.cask(__MODULE__, {:download, name, url})
  end

  def handle_cast({:download, name, url}, _) do
    # Stream to Parser.Base 
    HTTPoison.get! url, %{}, stream_to: name

    {:noreply, nil}
  end


end
