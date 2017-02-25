defmodule Show do
  @enforce_keys [:id, :name, :url]
  defstruct [:id, :name, :url]

  def get_show(id) when is_atom(id) do
    ConfigManager.get_struct([:show, id], Show)
    |> ConfigManager.atomify_field(:id) 
  end

  def get_all_shows() do
    # ConfigManager.get_all_hash(:show)
    # |> Enum.map()
  end
end
