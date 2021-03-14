defmodule Deparam.Types.Enum do
  @behaviour Deparam.Type

  @impl true
  def coerce(value, %{args: [values]}) when is_list(values) do
    if value in values do
      {:ok, value}
    else
      :error
    end
  end

  def coerce(_value, _context), do: :error
end
