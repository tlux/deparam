defmodule Deparam.Types.Map do
  @behaviour Deparam.Type

  alias Deparam.Type

  @impl true
  def coerce(map, %{modifier: :non_empty}) when map_size(map) == 0, do: :error

  def coerce(map, %{args: []} = context) when is_map(map) do
    coerce(map, %{context | args: [:any, :any]})
  end

  def coerce(map, %{args: [key_type, value_type]}) when is_map(map) do
    Enum.reduce_while(map, {:ok, %{}}, fn {key, value}, {:ok, new_map} ->
      with {:ok, mapped_key} <- Type.coerce(key_type, key),
           {:ok, mapped_value} <- Type.coerce(value_type, value) do
        {:cont, {:ok, Map.put(new_map, mapped_key, mapped_value)}}
      else
        _ -> {:halt, :error}
      end
    end)
  end

  def coerce(_map, _context), do: :error
end
