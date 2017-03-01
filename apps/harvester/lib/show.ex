defmodule Show do
  defstruct [:name, :url]

  @type t :: %Show{name: String.t, url: String.t}

  @spec get_show(String.t) :: t
  def get_show(name) when is_binary(name) or is_atom(name) do
     ConfigManager.get_struct([Show, name], Show)
   end

  @spec get_all_shows() :: list(t)
  def get_all_shows() do
    ConfigManager.keys([Show, "*"])
    |> Enum.map(&ConfigManager.get_struct(&1, Show))
  end
end
