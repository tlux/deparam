defmodule Deparam.TypeContext do
  defstruct non_empty: false, args: []

  @type t :: %__MODULE__{non_empty: boolean, args: [any]}
end
