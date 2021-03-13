defmodule Deparam.Type do
  @moduledoc """
  A behavior that can be used to implement a custom coercer.
  """

  alias Deparam.TypeContext
  alias Deparam.Types

  @callback coerce(value :: any, context :: TypeContext.t()) ::
              {:ok, any} | :error

  @aliases %{
    any: Types.Any,
    array: Types.Array,
    boolean: Types.Boolean,
    enum: Types.Enum,
    float: Types.Float,
    integer: Types.Integer,
    map: Types.Map,
    string: Types.String,
    word_list: Types.WordList
  }

  @modifiers [:non_empty, :non_nil]

  @type modifier :: :non_empty | :non_nil

  @type type ::
          nil
          | atom
          | module
          | TypeContext.t()
          | (any -> {:ok, any} | :error)
          | (any, TypeContext.t() -> {:ok, any} | :error)

  @doc """
  Translates the given type specification to a type context that can be passed
  as argument to a coercer.
  """
  @spec resolve(type | {modifier, type} | tuple | nonempty_list) ::
          {:ok, TypeContext.t()} | :error
  def resolve(nil), do: resolve(:any)

  def resolve(%TypeContext{} = context) do
    {:ok, context}
  end

  def resolve({modifier, context_or_fun_or_type}) when modifier in @modifiers do
    with {:ok, context} <- resolve(context_or_fun_or_type) do
      {:ok, %{context | modifier: modifier}}
    end
  end

  def resolve(definition) when tuple_size(definition) >= 2 do
    definition
    |> Tuple.to_list()
    |> resolve()
  end

  def resolve([context_or_fun_or_type | args]) do
    with {:ok, context} <- resolve(context_or_fun_or_type) do
      {:ok, %{context | args: args}}
    end
  end

  def resolve(type) when is_atom(type) do
    mod = Map.get(@aliases, type, type)

    if Code.ensure_loaded?(mod) && function_exported?(mod, :coerce, 2) do
      {:ok, TypeContext.new(&mod.coerce/2)}
    else
      :error
    end
  end

  def resolve(fun) when is_function(fun, 1) do
    resolve(fn value, _context -> fun.(value) end)
  end

  def resolve(fun) when is_function(fun, 2) do
    {:ok, TypeContext.new(fun)}
  end

  def resolve(_), do: :error

  @doc """
  Coerces the given value using the given type context or specification.
  """
  @spec coerce(any, any) :: {:ok, any} | :error
  def coerce(value, type) do
    with {:ok, context} <- resolve(type),
         {:ok, value} <- do_coerce(value, context) do
      {:ok, value}
    end
  end

  defp do_coerce(nil, %{modifier: modifier})
       when modifier in [:non_nil, :non_empty] do
    :error
  end

  defp do_coerce(nil, _), do: {:ok, nil}

  defp do_coerce(value, context) do
    context.coercer.(value, context)
  end
end
