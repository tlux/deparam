defmodule Deparam.InvalidParamError do
  @moduledoc """
  An error that is returned or raised when a fetch adapter is invoked with an
  invalid parameter value.
  """

  defexception [:path, :value, :type]

  @type t :: %__MODULE__{path: [String.t()], value: any, type: term}

  @impl true
  def message(exception) do
    path = Enum.join(exception.path, ".")
    "Invalid parameter: #{path} (expected #{humanize_type(exception.type)})"
  end

  defp humanize_type(nil), do: "any"

  defp humanize_type({:enum, values}) do
    value_list = Enum.join(values, ",")
    "enum[#{value_list}]"
  end

  defp humanize_type({:non_nil, inner_type}) do
    humanize_type(inner_type) <> "!"
  end

  defp humanize_type({:non_empty, inner_type}) do
    humanize_type(inner_type) <> "!!"
  end

  defp humanize_type(type_tuple) when tuple_size(type_tuple) > 1 do
    [outer_type | inner_types] = Tuple.to_list(type_tuple)

    humanized_inner_types =
      inner_types
      |> Enum.map(&humanize_type/1)
      |> Enum.join(",")

    "#{outer_type}<#{humanized_inner_types}>"
  end

  defp humanize_type(type), do: to_string(type)
end
