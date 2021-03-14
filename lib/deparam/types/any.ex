defmodule Deparam.Types.Any do
  @behaviour Deparam.Type

  @impl true
  def coerce(value, _context) do
    {:ok, value}
  end
end
