if Code.ensure_loaded?(Plug.Upload) do
  defmodule Deparam.Types.Upload do
    @behaviour Deparam.Type

    @impl true
    def coerce(%Plug.Upload{} = upload, _context) do
      {:ok, upload.path}
    end

    def coerce(_value, _context), do: :error
  end
end
