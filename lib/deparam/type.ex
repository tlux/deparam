defmodule Deparam.Type do
  @moduledoc """
  A behavior that can be used to implement a custom coercer.
  """

  @callback coerce(value :: any, context :: Deparam.TypeContext.t()) ::
              {:ok, any} | :error
end
