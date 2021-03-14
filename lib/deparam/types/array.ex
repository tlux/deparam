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
    |> Enum.reduce_while({:ok, []}, fn element, {:ok, values} ->
      case Type.coerce(element, element_type) do
        {:ok, element} ->
          {:cont, {:ok, [element | values]}}

        :error ->
          {:halt, :error}
      end
    end)
  end

  def coerce(value, context) do
    value
    |> List.wrap()
    |> coerce(context)
  end
end
