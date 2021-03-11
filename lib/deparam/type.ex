defmodule Deparam.Type do
  @moduledoc """
  A behavior that can be used to implement a custom coercer.
  """

  alias Deparam.TypeContext
  alias Deparam.Types

  @callback coerce(value :: any, context :: Deparam.TypeContext.t()) ::
              {:ok, any} | :error

  @aliases %{
    array: Types.Array,
    boolean: Types.Boolean,
    enum: Types.Enum,
    float: Types.Float,
    integer: Types.Integer,
    map: Types.Map,
    string: Types.String
  }

  @doc false
  @spec resolve(atom | module | tuple) ::
          {:ok, module, TypeContext.t()} | :error
  def resolve({:non_empty, type}) do
    resolve()
  end

  # def resolve(type) when is_tuple(type) do

  # end

  def resolve(type) do
    type = Map.get(@aliases, type, type)

    if Code.ensure_loaded?(type) && function_exported?(type, :coerce, 2) do
      {:ok, type, %TypeContext{}}
    else
      :error
    end
  end
end
