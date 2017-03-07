defmodule ConfigManager do
  @type key :: atom | String.t | key_list
  @type key_list :: nonempty_list(key)

  @type value :: atom
               | String.t
               | number
               | boolean
               | tuple
               | list
               | map
               | struct

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

  @doc """
    iex> put_hash(:test, [a: "x", b: "y"])
    :ok
    iex> get_keyword(:test)
    [a: "x", b: "y"]
  """
  @spec put_hash(key, value) :: :ok
  def put_hash(key, value) do
    "OK" = command!(:hmset, [normalize_key(key)] ++ format_value(value))
    :ok
  end

  @doc """
    iex> format_value :test
    "test"

    iex> format_value "test"
    "test"

    iex> format_value 1
    "1"

    iex> format_value 1.1
    "1.1"

    iex> format_value true
    "true"
    iex> format_value false
    "false"

    iex> format_value [1, 2, 3, 4]
    ["1", "2", "3", "4"]

    iex> format_value [a: 1, b: 2]
    ["a", "1", "b", "2"]

    iex> format_value %{a: 1, b: 2}
    ["a", "1", "b", "2"]
  """
  @spec format_value(value) :: String.t | list(String.t)
  def format_value(value)

  @spec format_value(tuple) :: list(String.t)
  def format_value(tuple) when is_tuple(tuple), do:
    tuple
    |> Tuple.to_list()
    |> Enum.map(&format_value(&1))

  @spec format_value(list | map) :: list(String.t)
  def format_value(enumerable) when is_list(enumerable) or is_map(enumerable) , do:
    enumerable
    |> Enum.map(&format_value(&1))
    |> List.flatten()

  @spec format_value(atom) :: String.t
  def format_value(atom) when is_atom(atom), do:
    atom
    |> Atom.to_string()

  @spec format_value(integer) :: String.t
  def format_value(integer) when is_integer(integer), do:
    integer
    |> Integer.to_string()

  @spec format_value(float) :: String.t
  def format_value(float) when is_float(float), do:
    float
    |> Float.to_string()

  @spec format_value(String.t) :: String.t
  def format_value(binary) when is_binary(binary), do:
    binary

  @doc """
    iex> exists?(:test)
    false
    iex> command!(:set, ~w(test value))
    "OK"
    iex> exists?(:test)
    true
  """
  @spec exists?(key) :: boolean
  def exists?(key) do
    command!(:exists, [normalize_key(key)])
    |> Kernel.>(0)
  end

  @spec keys(key) :: list(String.t)
  def keys(key_pattern) do
    command!(:keys, [normalize_key(key_pattern)])
  end

  @spec delete(key) :: boolean
  def delete(key) do
    command!(:del, [normalize_key(key)]) == 1
  end

  @spec delete_all(list(String.t)) :: non_neg_integer
  def delete_all(keys) do
    command!(:del, keys)
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
  def normalize_key(key) when is_binary(key), do: key

  @spec normalize_key(atom) :: String.t
  def normalize_key(key) when is_atom(key) do
    key
    |> Atom.to_string()
    |> String.replace_prefix("Elixir." ,"")
    |> String.replace(".", ":")
  end

  @spec normalize_key(integer) :: String.t
  def normalize_key(key) when is_integer(key) do
    key
    |> Integer.to_string()
  end

  @spec normalize_key(key_list) :: String.t
  def normalize_key(key) when is_list(key) do
    key
    |> Stream.map(&normalize_key(&1))
    |> Enum.join(":")
  end

  @spec enqueue(key, value) :: non_neg_integer
  def enqueue(queue_name, value) do
    command!(:lpush, [normalize_key(queue_name), format_value(value)])
  end

  @spec expire_at(key, Timex.datetime) :: :ok | :error
  def expire_at(key, datetime) do
    case command!(:expireat, [normalize_key(key), datetime |> Timex.to_unix() |> format_value()]) do
      1 -> :ok
      0 -> :error
    end
  end
end
