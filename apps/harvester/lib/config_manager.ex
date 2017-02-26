defmodule ConfigManager do
  @type key :: atom | String.t | key_list
  @type key_list :: nonempty_list(key)

  @spec start_link(String.t) :: GenServer.on_start
  def start_link(connection_string) do
    Redix.start_link(connection_string, name: __MODULE__)
  end

  @spec command!(atom) :: Redix.Protocol.redis_value | no_return
  @spec command!(atom, list(String.t)) :: Redix.Protocol.redis_value | no_return
  def command!(command, args \\ []) do
    Redix.command!(__MODULE__, [Atom.to_string(command) | args])
  end

  @spec get_keyword(key) :: Keyword.t
  def get_keyword(key) do
    command!(:hgetall, [normalize_key(key)])
    |> Enum.chunk(2)
    |> Enum.map(fn [key, value] -> {String.to_atom(key), value} end)
  end

  @spec get_hash(atom, Collectable.t) :: Collectable.t
  def get_hash(key, container \\ %{}), do: get_keyword(key) |> Enum.into(container)

  @spec get_struct(key, struct | module) :: struct
  def get_struct(key, struct_def), do: struct(struct_def, get_keyword(key))

  @spec keys(key) :: list(String.t)
  def keys(key_pattern) do
    command!(:keys, [normalize_key(key_pattern)])
  end

  @doc """
    iex> atomify_field(%{a: "x", b: "y"}, :a)
    %{a: :x, b: "y"}
  """
  @spec atomify_field(map, atom) :: map
  def atomify_field(map, key) when is_map(map) and is_atom(key)  do
    Map.update!(map, key, &String.to_atom(&1))
  end

  @doc """
    iex> normalize_key(A.B.C)
    "A:B:C"

    iex> normalize_key("A:B:C")
    "A:B:C"

    iex> normalize_key([:a, :b, :c])
    "a:b:c"

    iex> normalize_key([ConfigManager, :property])
    "ConfigManager:property"
  """
  @spec normalize_key(key) :: String.t
  def normalize_key(key)

  @spec normalize_key(String.t) :: String.t
  def normalize_key(key) when is_bitstring(key), do: key

  @spec normalize_key(atom) :: String.t
  def normalize_key(key) when is_atom(key) do
    key
    |> Atom.to_string()
    |> String.replace_prefix("Elixir." ,"")
    |> String.replace(".", ":")
  end

  @spec normalize_key(key_list) :: String.t
  def normalize_key(key) when is_list(key) do
    key
    |> Stream.map(&normalize_key(&1))
    |> Enum.join(":")
  end
end
