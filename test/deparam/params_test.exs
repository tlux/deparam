defmodule Deparam.ParamsTest do
  use ExUnit.Case, async: true

  alias Deparam.InvalidParamError
  alias Deparam.Params

  doctest Deparam.Params

  @valid_params %{
    "foo" => "bar",
    "bar" => %{"baz" => "1337"},
    "baz" => nil
  }

  describe "normalize/1" do
    test "map with string keys" do
      assert Params.normalize(@valid_params) == @valid_params
    end

    test "map with atom keys" do
      assert Params.normalize(%{
               foo: "bar",
               bar: %{baz: "1337"},
               baz: nil
             }) == @valid_params
    end

    test "keyword list" do
      assert Params.normalize(
               foo: "bar",
               bar: %{baz: "1337"},
               baz: nil
             ) == @valid_params

      assert Params.normalize(
               foo: "bar",
               bar: [baz: "1337"],
               baz: nil,
               lorem: %InvalidParamError{path: "test"}
             ) == %{
               "foo" => "bar",
               "bar" => [baz: "1337"],
               "baz" => nil,
               "lorem" => %InvalidParamError{path: "test"}
             }
    end

    test "invalid" do
      assert_raise FunctionClauseError, fn ->
        Params.normalize("1337")
      end

      assert_raise ArgumentError,
                   "value must be a map with string or atom keys or a keyword list",
                   fn ->
                     Params.normalize(%{1 => "test"})
                   end

      assert_raise ArgumentError,
                   "value must be a map with string or atom keys or a keyword list",
                   fn ->
                     Params.normalize([{"test", "test", "test"}])
                   end
    end
  end

  describe "get/4" do
    test "get value" do
      assert Params.get(@valid_params, :foo, :any, []) == "bar"

      assert Params.get(@valid_params, [:bar, "baz"], :integer, []) ==
               1337
    end

    test "default value" do
      assert Params.get(@valid_params, :foo, :integer, []) == nil

      assert Params.get(@valid_params, :foo, :integer, default: :foo) ==
               :foo
    end
  end

  describe "fetch/2" do
    test "fetch value" do
      assert Params.fetch(@valid_params, :foo) ==
               Params.fetch(@valid_params, :foo, :any, [])
    end
  end

  describe "fetch/4" do
    test "fetch value" do
      assert Params.fetch(@valid_params, :foo, :any, []) == {:ok, "bar"}

      assert Params.fetch(@valid_params, [:bar, "baz"], :any, []) ==
               {:ok, "1337"}

      assert Params.fetch(@valid_params, [:foo, "baz"], :any, []) ==
               {:ok, nil}
    end

    test "default value" do
      assert Params.fetch(@valid_params, [:bar, "baz"], :any, default: :foo) ==
               {:ok, "1337"}

      assert Params.fetch(@valid_params, [:foo, "baz"], :any, default: :foo) ==
               {:ok, :foo}
    end

    test "invalid" do
      assert Params.fetch(
               @valid_params,
               [:foo, "baz"],
               {:non_empty, :any}
             ) ==
               {:error,
                %InvalidParamError{
                  path: ["foo", "baz"],
                  value: nil,
                  type: {:non_empty, :any}
                }}
    end

    test "coerce" do
      assert Params.fetch(@valid_params, [:bar, "baz"], :integer, []) ==
               {:ok, 1337}
    end
  end
end
