defmodule Deparam.TestCoercer do
  @behaviour Deparam.Coercer

  @impl true
  def coerce("foo") do
    {:ok, "FOO"}
  end

  def coerce(_) do
    :error
  end
end
