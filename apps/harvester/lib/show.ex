defmodule Show do
  @enforce_keys [:id, :name, :url]
  defstruct [:id, :name, :url]

  @type t :: %Show{id: atom, name: String.t, url: String.t}

  @spec get_show(atom) :: t
  def get_show(id) when is_atom(id), do: do_get_show([:show, id])

  @spec do_get_show(ConfigManager.key_list) :: t
  defp do_get_show(key) do
    ConfigManager.get_struct(key, Show)
    |> ConfigManager.atomify_field(:id)
  end

  @spec get_all_shows() :: list(t)
  def get_all_shows() do
    ConfigManager.keys([:show, "*"])
    |> Enum.map(&do_get_show(&1))
  end
end
