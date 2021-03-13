defmodule Deparam.Types.Map do
  @behaviour Deparam.Type

  alias Deparam.Type

  @impl true
  def coerce(map, %{modifier: :non_empty}) when map_size(map) == 0, do: :error

  def coerce(map, %{args: []} = context) when is_map(map) do
    coerce(map, %{context | args: [:any, :any]})
  end

  def coerce(map, %{args: [key_type, value_type]}) when is_map(map) do
    Enum.reduce_while(map, {:ok, %{}}, fn {key, value}, {:ok, map} ->
      with {:ok, key} <- Type.coerce(key, key_type),
           {:ok, value} <- Type.coerce(value, value_type) do
        {:cont, {:ok, Map.put(map, key, value)}}
      else
        _ -> {:halt, :error}
      end
    end)
  end

  def coerce(_map, _context), do: :error
end
