defmodule Deparam.Types.Boolean do
  @behaviour Deparam.Type

  @impl true
  def coerce(value, _context) when is_boolean(value) do
    {:ok, value}
  end

  def coerce(value, _context) when is_binary(value) do
    {:ok, String.downcase(value) in ["true", "t", "1"]}
  end

  def coerce(_value, _context), do: :error
end
