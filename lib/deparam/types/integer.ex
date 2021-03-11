defmodule Deparam.Types.Integer do
  @behaviour Deparam.Type

  @impl true
  def coerce(value, _context) when is_integer(value) do
    {:ok, value}
  end

  def coerce(value, _context) when is_float(value) do
    {:ok, trunc(value)}
  end

  def coerce(value, _context) when is_binary(value) do
    case Integer.parse(value) do
      {num, ""} -> {:ok, num}
      _ -> :error
    end
  end

  def coerce(_value, _context), do: :error
end
