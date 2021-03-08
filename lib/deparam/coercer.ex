defmodule Deparam.Coercer do
  @moduledoc """
  A behavior that can be used to implement a custom coercer.
  """

  @callback coerce(value :: any) :: {:ok, any} | :error

  @doc false
  @spec coerce(any, atom | tuple | (any -> {:ok, any} | :error)) ::
          {:ok, any} | :error
  def coerce(value, {:non_nil, inner_type}) do
    with {:ok, nil} <- coerce(value, inner_type) do
      :error
    end
  end

  def coerce(nil, {:non_empty, _}), do: :error

  def coerce(nil, _), do: {:ok, nil}

  def coerce(value, type) when is_nil(type) when type == :any, do: {:ok, value}

  # Function

  def coerce(value, coercer) when is_function(coercer) do
    coercer.(value)
  end

  # Boolean

  def coerce(value, :boolean) when is_boolean(value) do
    {:ok, value}
  end

  def coerce(value, :boolean) when is_binary(value) do
    {:ok, value in ["true", "1"]}
  end

  # Float

  def coerce(value, :float) when is_float(value) do
    {:ok, value}
  end

  def coerce(value, :float) when is_integer(value) do
    {:ok, value / 1}
  end

  def coerce(value, :float) when is_binary(value) do
    case Float.parse(value) do
      {num, ""} -> {:ok, num}
      _ -> :error
    end
  end

  # Integer

  def coerce(value, :integer) when is_integer(value) do
    {:ok, value}
  end

  def coerce(value, :integer) when is_float(value) do
    {:ok, trunc(value)}
  end

  def coerce(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {num, ""} -> {:ok, num}
      _ -> :error
    end
  end

  # String

  def coerce("", {:non_empty, :string}), do: :error

  def coerce(value, {:non_empty, :string}) when is_binary(value) do
    coerce(value, :string)
  end

  def coerce(value, :string) when is_binary(value) do
    {:ok, value}
  end

  def coerce(value, :string)
      when is_atom(value)
      when is_number(value) do
    value
    |> to_string()
    |> coerce(:string)
  end

  # URL

  def coerce("", {:non_empty, :url}), do: :error

  def coerce(value, {:non_empty, :url}) when is_binary(value) do
    coerce(value, :url)
  end

  def coerce("", :url), do: {:ok, nil}

  def coerce(value, :url) when is_binary(value) do
    case URI.parse(value) do
      %URI{scheme: scheme} when scheme not in ["http", "https"] -> :error
      %URI{host: nil} -> :error
      _ -> {:ok, value}
    end
  end

  # Map

  def coerce(map, {:non_empty, {:map, _, _}}) when map_size(map) == 0 do
    :error
  end

  def coerce(map, {:non_empty, {:map, _, _} = type}) when is_map(map) do
    coerce(map, type)
  end

  def coerce(map, {:map, key_type, value_type}) when is_map(map) do
    Enum.reduce_while(map, {:ok, %{}}, fn
      {key, value}, {:ok, coerced_map} ->
        with {:ok, coerced_key} <- coerce(key, key_type),
             {:ok, coerced_value} <- coerce(value, value_type) do
          {:cont, {:ok, Map.put(coerced_map, coerced_key, coerced_value)}}
        else
          _ -> {:halt, :error}
        end

      _, _ ->
        {:halt, :error}
    end)
  end

  # List

  def coerce([], {:non_empty, {:array, _}}), do: :error

  def coerce(list, {:non_empty, {:array, _} = type}) when is_list(list) do
    coerce(list, type)
  end

  def coerce(list, {:array, inner_type}) when is_list(list) do
    list
    |> Enum.reduce_while({:ok, []}, fn item, {:ok, coerced_list} ->
      case coerce(item, inner_type) do
        {:ok, coerced_item} -> {:cont, {:ok, [coerced_item | coerced_list]}}
        error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, coerced_list} -> {:ok, Enum.reverse(coerced_list)}
      error -> error
    end
  end

  def coerce(value, {:array, _} = type) do
    value |> List.wrap() |> coerce(type)
  end

  # Word List

  def coerce(value, {:non_empty, {:word_list, inner_type}})
      when is_list(value) do
    coerce(value, {:non_empty, {:array, inner_type}})
  end

  def coerce(value, {:non_empty, {:word_list, _}} = type)
      when is_binary(value) do
    value |> String.split() |> coerce(type)
  end

  def coerce(value, {:non_empty, :word_list}) when is_binary(value) do
    coerce(value, {:non_empty, {:word_list, :string}})
  end

  def coerce(value, {:word_list, inner_type}) when is_list(value) do
    coerce(value, {:array, inner_type})
  end

  def coerce(value, {:word_list, _} = type) when is_binary(value) do
    value |> String.split() |> coerce(type)
  end

  def coerce(value, :word_list) do
    coerce(value, {:word_list, :string})
  end

  if Code.ensure_loaded?(Plug.Upload) do
    # Upload
    def coerce(%Plug.Upload{path: path}, :upload) do
      {:ok, path}
    end
  end

  # Enum

  def coerce(value, {:enum, values}) do
    if value in values do
      {:ok, value}
    else
      :error
    end
  end

  # Rest

  def coerce(value, {:non_empty, inner_type}) do
    coerce(value, {:non_nil, inner_type})
  end

  def coerce(value, type) when is_atom(type) do
    if Code.ensure_loaded?(type) && function_exported?(type, :coerce, 1) do
      type.coerce(value)
    else
      :error
    end
  end

  def coerce(_value, _type), do: :error
end
