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
  def new(coercer) do
    %__MODULE__{coercer: coercer}
  end
end
