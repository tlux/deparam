defmodule Deparam.Types.WordList do
  @behaviour Deparam.Type

  alias Deparam.Types.Array, as: ArrayType

  @impl true
  def coerce(list, context) when is_list(list) do
    ArrayType.coerce(list, context)
  end

  def coerce(words, %{args: []} = context) when is_binary(words) do
    coerce(words, %{context | args: [:string]})
  end

  def coerce(words, context) when is_binary(words) do
    words
    |> String.split(" ", trim: true)
    |> coerce(context)
  end

  def coerce(_value, _context), do: :error
end
