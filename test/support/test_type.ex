defmodule Deparam.TestType do
  @behaviour Deparam.Type

  @impl true
  def coerce("foo", _context) do
    {:ok, "FOO"}
  end

  def coerce(_value, _context) do
    :error
  end
end
