defmodule Deparam.Types.String do
  @behaviour Deparam.Type

  @impl true
  def coerce("", %{modifier: :non_empty}), do: :error

  def coerce(value, %{modifier: :non_empty} = context) when is_binary(value) do
    coerce(value, %{context | modifier: nil})
  end

  def coerce(value, _context) when is_binary(value) do
    {:ok, value}
  end

  def coerce(value, context)
      when is_atom(value)
      when is_number(value) do
    value
    |> to_string()
    |> coerce(context)
  end

  def coerce(_value, _context), do: :error
end
