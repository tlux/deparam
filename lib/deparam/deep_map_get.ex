defmodule Deparam.DeepMapGet do
  @moduledoc false

  @spec deep_map_get(map, Deparam.path()) :: map
  def deep_map_get(value, []), do: value

  def deep_map_get(map, [key | rest_path]) when is_map(map) do
    map
    |> Map.get(key)
    |> deep_map_get(rest_path)
  end

  def deep_map_get(_value, _path), do: nil
end
