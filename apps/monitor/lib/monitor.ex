defmodule Monitor do
  @moduledoc """
  Documentation for Monitor.
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end
end
