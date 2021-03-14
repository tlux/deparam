defmodule Deparam.TypeContext do
  @moduledoc """
  A context struct that is passed to a module implementing the `Deparam.Type`
  behavior.
  """

  defstruct [:coercer, modifier: nil, args: []]

  @type coercer :: (any, t -> {:ok, any} | :error)

  @type t :: %__MODULE__{
          coercer: coercer,
          modifier: Deparam.Type.modifier(),
          args: [any]
        }

  @doc false
  @spec new(coercer) :: t
  def new(coercer) when is_function(coercer, 2) do
    %__MODULE__{coercer: coercer}
  end
end
