defmodule Deparam.Types.Array do
  @behaviour Deparam.Type

  alias Deparam.Type

  @impl true
  def coerce([], %{modifier: :non_empty}), do: :error

  def coerce(values, %{args: []} = context) when is_list(values) do
    coerce(values, %{context | args: [:any]})
  end

  def coerce(values, %{args: [element_type]}) when is_list(values) do
    values
    |> Enum.reverse()
    |> Enum.reduce_while({:ok, []}, fn value, {:ok, mapped_values} ->
      case Type.coerce(element_type, value) do
        {:ok, mapped_value} ->
          {:cont, {:ok, [mapped_value | mapped_values]}}

        :error ->
          {:halt, :error}
      end
    end)
  end

  def coerce(_values, _context), do: :error
end
