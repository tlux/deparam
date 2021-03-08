defmodule Deparam.InvalidParamErrorTest do
  use ExUnit.Case, async: true

  alias Deparam.InvalidParamError

  describe "message/1" do
    test "get message with parameter name and type" do
      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type: :string
             }) == "Invalid parameter: foo.bar (expected string)"

      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type: {:array, :string}
             }) == "Invalid parameter: foo.bar (expected array<string>)"

      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type: {:non_nil, {:array, :string}}
             }) ==
               "Invalid parameter: foo.bar (expected array<string>!)"

      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type: {:array, {:non_empty, :string}}
             }) ==
               "Invalid parameter: foo.bar (expected array<string!!>)"

      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type:
                 {:array, {:non_empty, {:map, {:non_empty, :string}, :integer}}}
             }) ==
               "Invalid parameter: foo.bar " <>
                 "(expected array<map<string!!,integer>!!>)"

      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type: {:enum, ["lorem", "ipsum"]},
               value: "baz"
             }) ==
               "Invalid parameter: foo.bar (expected enum[lorem,ipsum])"

      assert Exception.message(%InvalidParamError{
               path: ["foo", "bar"],
               type: {:non_empty, {:enum, ["lorem", "ipsum"]}},
               value: "baz"
             }) ==
               "Invalid parameter: foo.bar (expected enum[lorem,ipsum]!!)"
    end
  end
end
