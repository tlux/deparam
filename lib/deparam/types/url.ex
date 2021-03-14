defmodule Deparam.Types.URL do
  @behaviour Deparam.Type

  alias Deparam.Types.String, as: StringType

  @allowed_schemes ~w(http https)

  @impl true
  def coerce(value, context) do
    with {:ok, url} <- StringType.coerce(value, context) do
      do_coerce(url, context)
    end
  end

  defp do_coerce("", %{modifier: :non_nil}), do: :error

  defp do_coerce("", _context), do: {:ok, nil}

  defp do_coerce(url, _context) do
    uri = URI.parse(url)

    if valid_uri?(uri) do
      {:ok, url}
    else
      :error
    end
  end

  defp valid_uri?(uri) do
    absolute_url?(uri) && allowed_scheme?(uri)
  end

  defp absolute_url?(uri) do
    uri.host && uri.scheme
  end

  defp allowed_scheme?(uri) do
    uri.scheme in @allowed_schemes
  end
end
