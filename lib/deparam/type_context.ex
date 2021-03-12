defmodule Deparam.TypeContext do
  defstruct [:mod, modifier: nil, args: []]

  @type t :: %__MODULE__{
          mod: module,
          modifier: nil | :non_nil | :non_empty,
          args: [any]
        }
end
