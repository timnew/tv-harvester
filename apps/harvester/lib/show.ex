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

  @spec create_show(String.t, String.test) :: :ok
  def create_show(name, url) do
    ConfigManager.put_hash([Show, name], [name: name, url: url])
  end

  @spec create_show(t) :: :ok
  def create_show(%Show{name: name, url: url}) do
    create_show(name, url)
  end

  @spec delete_all_shows :: non_neg_integer
  def delete_all_shows do
    [Show, "*"]
    |> ConfigManager.keys()
    |> ConfigManager.delete_all()
  end
end
