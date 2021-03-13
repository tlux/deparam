defmodule Deparam.Types.WordList do
  @behaviour Deparam.Type

  alias Deparam.Type

  @impl true
  def coerce(list, %{modifier: modifier, args: []}) when is_list(list) do
    do_coerce(list, modifier, :string)
  end

  def coerce(list, %{modifier: modifier, args: [element_type]})
      when is_list(list) do
    do_coerce(list, modifier, element_type)
  end

  def coerce(words, %{args: []} = context) when is_binary(words) do
    coerce(words, %{context | args: [:string]})
  end

  def coerce(words, %{modifier: modifier, args: [element_type]})
      when is_binary(words) do
    words
    |> String.split(" ", trim: true)
    |> do_coerce(modifier, element_type)
  end

  def coerce(_value, _context), do: :error

  defp do_coerce([], :non_empty, _element_type), do: :error

  defp do_coerce([], _modifier, _element_type), do: {:ok, []}

  defp do_coerce(values, _modifier, element_type) do
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
end
