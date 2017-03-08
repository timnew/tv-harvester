defmodule Stage.ShowProvider do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, reset_state()}
  end

  def refresh do
    GenStage.call(__MODULE__, :refresh)
  end

  def handle_demand(demand, {all_shows, index}) do
    shows_to_return = Enum.slice(all_shows, index, demand)
    new_index = index + demand

    {:noreply, Enum.slice(all_shows, index, demand) , {all_shows, index + demand}}
  end

  def handle_call(:refresh, _, _) do
    {:reply, :ok, [], reset_state()}
  end

  defp reset_state do
    { Show.get_all_shows(), 0 }
  end
end
