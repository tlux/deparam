defmodule Deparam.TypeContext do
  defstruct [:coercer, modifier: nil, args: []]

  @type coercer :: (any, t -> {:ok, any} | :error)

  @type t :: %__MODULE__{
          coercer: coercer,
          modifier: nil | :non_nil | :non_empty,
          args: [any]
        }

  @doc false
  @spec new(coercer) :: t
  def new(coercer) when is_function(coercer, 2) do
    %__MODULE__{coercer: coercer}
  end
end
