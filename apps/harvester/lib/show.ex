defmodule Show do
  @enforce_keys [:id, :name, :url]
  defstruct [:id, :name, :url]

  def get_show(id) when is_atom(id), do: do_get_show([:show, id])

  defp do_get_show(key) do
    ConfigManager.get_struct(key, Show)
    |> ConfigManager.atomify_field(:id)
  end

  def get_all_shows() do
    ConfigManager.keys([:show, "*"])
    |> Enum.map(&do_get_show(&1))
  end
end
