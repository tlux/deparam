defmodule Deparam do
  @moduledoc """
  A generic parameter parser and coercer.
  """

  alias Deparam.DeepMapGet
  alias Deparam.InvalidParamError
  alias Deparam.Type

  @typedoc """
  A type describing a parameter collection.
  """
  @type params :: %{optional(String.t()) => any}

  @typedoc """
  A type describing a param key.
  """
  @type key :: atom | String.t()

  @typedoc """
  A type describing a keypath.
  """
  @type path :: nonempty_list(key)

  @typedoc """
  A type describing a param key path.
  """
  @type key_or_path :: key | path

  @typedoc """
  A type representing a the primitive data type for a parameter key or value.
  """
  @type primitive ::
          :any | :boolean | :float | :integer | :string | :upload | :url

  @typedoc """
  A type describing possible values for coersion types.
  """
  @type type ::
          primitive
          | {:array, type}
          | {:enum, [String.t()]}
          | {:map, type, type}
          | {:non_nil, type}
          | {:non_empty, type}
          | :word_list
          | {:word_list, type}
          | (any -> {:ok, any} | :error)

  @doc """
  Cast a keyword list or map to a params map.
  """
  @spec normalize(Keyword.t() | %{optional(atom | String.t()) => any}) ::
          params
  def normalize(params) when is_map(params) when is_list(params) do
    Map.new(params, fn
      {key, value} when is_atom(key) when is_binary(key) ->
        {to_string(key), do_normalize(value)}

      _ ->
        raise ArgumentError,
              "value must be a map with string or atom keys or a keyword list"
    end)
  end

  defp do_normalize(%_{} = struct), do: struct

  defp do_normalize(map) when is_map(map) do
    normalize(map)
  end

  defp do_normalize(term), do: term

  @doc """
  Gets a param identified by a key or path from the given params map. Returns
  `nil` or the value defined by the `:default` option rather than an error when
  coersion fails or the param is missing.

  ## Options

  * `:default` - Indicates that the requested param is optional and additionally
    provides a default value when the value is `nil`.
  """
  @spec get(params, key_or_path, type, Keyword.t()) :: any
  def get(params, key_or_path, type \\ :any, opts \\ []) do
    case fetch(params, key_or_path, type, opts) do
      {:ok, auth_token} -> auth_token
      _ -> opts[:default]
    end
  end

  @doc """
  Fetches a param identified by a key or path from the given params map.

  ## Options

  * `:default` - Indicates that the requested param is optional and additionally
    provides a default value when the value is `nil`.

  ## Examples

      iex> Deparam.fetch(%{"foo" => "bar"}, :foo)
      {:ok, "bar"}

      iex> Deparam.fetch(%{"foo" => "bar"}, "foo", :string)
      {:ok, "bar"}

      iex> Deparam.fetch(%{"foo" => %{"bar" => "123"}}, [:foo, "bar"], :integer)
      {:ok, 123}

      iex> Deparam.fetch(%{"foo" => "bar"}, :baz, {:non_nil, :any})
      {:error, %InvalidParamError{path: ["baz"], value: nil, type: {:non_nil, :any}}}
  """
  @spec fetch(params, key_or_path, type, Keyword.t()) ::
          {:ok, any} | {:error, InvalidParamError.t()}
  def fetch(params, key_or_path, type \\ :any, opts \\ []) do
    path = resolve_path(key_or_path)
    value = DeepMapGet.deep_map_get(params, path)

    case Type.coerce(value, type) do
      {:ok, nil} ->
        {:ok, opts[:default]}

      {:ok, value} ->
        {:ok, value}

      :error ->
        {:error, %InvalidParamError{path: path, value: value, type: type}}
    end
  end

  defp resolve_path(key_or_path) do
    key_or_path |> List.wrap() |> Enum.map(&to_string/1)
  end
end
