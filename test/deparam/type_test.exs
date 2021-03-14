defmodule Deparam.CoercerTest do
  use ExUnit.Case, async: true

  alias Deparam.Type

  describe "coerce/2" do
    test "typeless" do
      for value <- [nil, "foo", 1337, 133.7, :foo, [], %{}] do
        assert Type.coerce(value, nil) == {:ok, value}
        assert Type.coerce(value, :any) == {:ok, value}
      end
    end

    test "string" do
      assert Type.coerce(nil, :string) == {:ok, nil}
      assert Type.coerce("", :string) == {:ok, ""}
      assert Type.coerce("foo", :string) == {:ok, "foo"}
      assert Type.coerce("1337", :string) == {:ok, "1337"}
      assert Type.coerce("133.7", :string) == {:ok, "133.7"}
      assert Type.coerce(1337, :string) == {:ok, "1337"}
      assert Type.coerce(133.7, :string) == {:ok, "133.7"}
      assert Type.coerce(:foo, :string) == {:ok, "foo"}
      assert Type.coerce([], :string) == :error
      assert Type.coerce(%{}, :string) == :error
      assert Type.coerce("foo", {:non_nil, :string}) == {:ok, "foo"}
      assert Type.coerce("foo", {:non_empty, :string}) == {:ok, "foo"}
      assert Type.coerce(nil, {:non_nil, :string}) == :error
      assert Type.coerce(nil, {:non_empty, :string}) == :error
      assert Type.coerce("", {:non_empty, :string}) == :error
    end

    test "URL" do
      assert Type.coerce(nil, :url) == {:ok, nil}
      assert Type.coerce(nil, {:non_nil, :url}) == :error
      assert Type.coerce("", :url) == {:ok, nil}
      assert Type.coerce("", {:non_nil, :url}) == :error
      assert Type.coerce("", {:non_empty, :url}) == :error
      assert Type.coerce("foo", :url) == :error

      assert Type.coerce("http://test.com", :url) ==
               {:ok, "http://test.com"}

      assert Type.coerce("https://test.com", :url) ==
               {:ok, "https://test.com"}

      assert Type.coerce("https://test.com", {:non_empty, :url}) ==
               {:ok, "https://test.com"}

      assert Type.coerce("ftp://test.com", :url) == :error
    end

    test "integer" do
      assert Type.coerce(nil, :integer) == {:ok, nil}
      assert Type.coerce("", :integer) == :error
      assert Type.coerce("foo", :integer) == :error
      assert Type.coerce("1337", :integer) == {:ok, 1337}
      assert Type.coerce("133.7", :integer) == :error
      assert Type.coerce(1337, :integer) == {:ok, 1337}
      assert Type.coerce(133.7, :integer) == {:ok, 133}
      assert Type.coerce(:foo, :integer) == :error
      assert Type.coerce([], :integer) == :error
      assert Type.coerce(%{}, :integer) == :error
      assert Type.coerce("1337", {:non_nil, :integer}) == {:ok, 1337}
      assert Type.coerce("1337", {:non_empty, :integer}) == {:ok, 1337}
      assert Type.coerce(nil, {:non_nil, :integer}) == :error
      assert Type.coerce(nil, {:non_empty, :integer}) == :error
      assert Type.coerce("", {:non_empty, :integer}) == :error
    end

    test "float" do
      assert Type.coerce(nil, :float) == {:ok, nil}
      assert Type.coerce("", :float) == :error
      assert Type.coerce("foo", :float) == :error
      assert Type.coerce("1337", :float) == {:ok, 1337.0}
      assert Type.coerce("133.7", :float) == {:ok, 133.7}
      assert Type.coerce(1337, :float) == {:ok, 1337.0}
      assert Type.coerce(133.7, :float) == {:ok, 133.7}
      assert Type.coerce(:foo, :float) == :error
      assert Type.coerce([], :float) == :error
      assert Type.coerce(%{}, :float) == :error
      assert Type.coerce("133.7", {:non_nil, :float}) == {:ok, 133.7}
      assert Type.coerce("133.7", {:non_empty, :float}) == {:ok, 133.7}
      assert Type.coerce(nil, {:non_nil, :float}) == :error
      assert Type.coerce(nil, {:non_empty, :float}) == :error
      assert Type.coerce("", {:non_empty, :float}) == :error
    end

    test "boolean" do
      assert Type.coerce(nil, :boolean) == {:ok, nil}
      assert Type.coerce(false, :boolean) == {:ok, false}
      assert Type.coerce(true, :boolean) == {:ok, true}
      assert Type.coerce("", :boolean) == {:ok, false}
      assert Type.coerce("foo", :boolean) == {:ok, false}
      assert Type.coerce("true", :boolean) == {:ok, true}
      assert Type.coerce("0", :boolean) == {:ok, false}
      assert Type.coerce("1", :boolean) == {:ok, true}
      assert Type.coerce(1337, :boolean) == :error
      assert Type.coerce(133.7, :boolean) == :error
      assert Type.coerce(:foo, :boolean) == :error
      assert Type.coerce([], :boolean) == :error
      assert Type.coerce(%{}, :boolean) == :error
    end

    test "map" do
      assert Type.coerce(
               %{:foo => 666, "bar" => "1337", "baz" => nil},
               :map
             ) == {:ok, %{:foo => 666, "bar" => "1337", "baz" => nil}}

      assert Type.coerce(
               %{:foo => 666, "bar" => "1337", "baz" => nil},
               {:map, :string}
             ) == :error

      assert Type.coerce(
               %{:foo => 666, "bar" => "1337", "baz" => nil},
               {:map, :string, :string}
             ) == {:ok, %{"foo" => "666", "bar" => "1337", "baz" => nil}}

      assert Type.coerce(
               %{:foo => 666, "bar" => "1337", "baz" => nil},
               {:map, :string, :integer}
             ) == {:ok, %{"foo" => 666, "bar" => 1337, "baz" => nil}}

      assert Type.coerce(
               %{"1" => 666, "2" => "foo", 3 => :bar},
               {:map, :integer, :any}
             ) == {:ok, %{1 => 666, 2 => "foo", 3 => :bar}}

      assert Type.coerce(
               %{:foo => 666, "bar" => "foo", "baz" => nil},
               {:map, :string, :integer}
             ) == :error

      assert Type.coerce(%{}, {:map, :string, :integer}) == {:ok, %{}}

      assert Type.coerce(%{}, {:non_nil, {:map, :string, :integer}}) ==
               {:ok, %{}}

      assert Type.coerce(nil, {:non_nil, {:map, :string, :integer}}) ==
               :error

      assert Type.coerce(
               %{"foo" => "bar", "" => "baz"},
               {:non_nil, {:map, :string, :string}}
             ) == {:ok, %{"foo" => "bar", "" => "baz"}}

      assert Type.coerce(
               %{"foo" => "bar", "" => "baz"},
               {:non_nil, {:map, {:non_empty, :string}, :string}}
             ) == :error

      assert Type.coerce(
               %{"foo" => "bar"},
               {:non_empty, {:map, :string, :string}}
             ) == {:ok, %{"foo" => "bar"}}

      assert Type.coerce(%{}, {:non_empty, {:map, :string, :integer}}) ==
               :error

      assert Type.coerce("foo", {:map, :string, :string}) == :error
      assert Type.coerce(1337, {:map, :string, :string}) == :error
      assert Type.coerce([1337, "goo"], {:map, :string, :string}) == :error
    end

    test "list" do
      assert Type.coerce([666, "foo", nil], :array) ==
               {:ok, [666, "foo", nil]}

      assert Type.coerce([666, "foo", nil], {:array, :string}) ==
               {:ok, ["666", "foo", nil]}

      assert Type.coerce([666, "foo", nil], {:array, {:non_nil, :string}}) ==
               :error

      assert Type.coerce([666, "foo"], {:array, {:non_nil, :string}}) ==
               {:ok, ["666", "foo"]}

      assert Type.coerce([], {:array, :string}) == {:ok, []}
      assert Type.coerce([], {:array, {:non_nil, :string}}) == {:ok, []}

      assert Type.coerce(nil, {:array, {:non_nil, :string}}) == {:ok, nil}

      assert Type.coerce(nil, {:non_nil, {:array, {:non_nil, :string}}}) ==
               :error

      assert Type.coerce([], {:non_empty, {:array, {:non_nil, :string}}}) ==
               :error

      assert Type.coerce(
               ["foo"],
               {:non_empty, {:array, {:non_nil, :string}}}
             ) == {:ok, ["foo"]}

      assert Type.coerce(
               ["foo", nil],
               {:non_empty, {:array, {:non_nil, :string}}}
             ) == :error

      assert Type.coerce(
               ["foo", ""],
               {:non_empty, {:array, {:non_empty, :string}}}
             ) == :error

      assert Type.coerce(
               nil,
               {:array, {:non_empty, :string}}
             ) == {:ok, nil}

      assert Type.coerce("foo", :array) == {:ok, ["foo"]}

      assert Type.coerce("foo", {:array, {:non_empty, :string}}) ==
               {:ok, ["foo"]}
    end

    test "word list" do
      assert Type.coerce("foo bar", :word_list) == {:ok, ["foo", "bar"]}

      assert Type.coerce("  foo    bar ", :word_list) ==
               {:ok, ["foo", "bar"]}

      assert Type.coerce("foo bar", {:word_list, :string}) ==
               {:ok, ["foo", "bar"]}

      assert Type.coerce(" 1337 666", {:word_list, :integer}) ==
               {:ok, [1337, 666]}

      assert Type.coerce("", :word_list) == {:ok, []}
      assert Type.coerce("  ", :word_list) == {:ok, []}
      assert Type.coerce("", {:word_list, :string}) == {:ok, []}
      assert Type.coerce("  ", {:word_list, :string}) == {:ok, []}
      assert Type.coerce(nil, :word_list) == {:ok, nil}
      assert Type.coerce(nil, {:word_list, :string}) == {:ok, nil}

      assert Type.coerce("foo bar", {:non_empty, :word_list}) ==
               {:ok, ["foo", "bar"]}

      assert Type.coerce("", {:non_nil, :word_list}) == {:ok, []}
      assert Type.coerce(nil, {:non_nil, :word_list}) == :error
      assert Type.coerce("", {:non_empty, :word_list}) == :error
      assert Type.coerce("  ", {:non_empty, :word_list}) == :error
      assert Type.coerce("", {:non_empty, {:word_list, :string}}) == :error
      assert Type.coerce("  ", {:non_empty, {:word_list, :string}}) == :error

      assert Type.coerce(["foo", "bar"], {:non_empty, :word_list}) ==
               {:ok, ["foo", "bar"]}

      assert Type.coerce(["foo", ""], {:word_list, {:non_empty, :string}}) ==
               :error
    end

    test "upload" do
      path = "tmp/#{System.system_time()}.dat"

      assert Type.coerce(%Plug.Upload{path: path}, :upload) == {:ok, path}
      assert Type.coerce(%{path: path}, :upload) == :error
    end

    test "enum" do
      assert Type.coerce("ipsum", {:enum, ["lorem", "ipsum"]}) ==
               {:ok, "ipsum"}

      assert Type.coerce("dolor", {:enum, ["lorem", "ipsum"]}) ==
               :error
    end

    test "arity-1 function" do
      coercer = fn
        "0" -> {:ok, nil}
        "1" -> {:ok, true}
        "2" -> {:ok, false}
        _ -> :error
      end

      assert Type.coerce(nil, coercer) == {:ok, nil}
      assert Type.coerce("0", coercer) == {:ok, nil}
      assert Type.coerce("1", coercer) == {:ok, true}
      assert Type.coerce("2", coercer) == {:ok, false}
      assert Type.coerce("3", coercer) == :error
      assert Type.coerce([], coercer) == :error
    end

    test "arity-2 function" do
      coercer = fn
        "blank", %{modifier: :non_empty} -> :error
        str, _ when is_binary(str) -> {:ok, str}
        _, _ -> :error
      end

      assert Type.coerce(nil, coercer) == {:ok, nil}
      assert Type.coerce("blank", coercer) == {:ok, "blank"}
      assert Type.coerce("blank", {:non_empty, coercer}) == :error
      assert Type.coerce("present", coercer) == {:ok, "present"}
      assert Type.coerce("present", {:non_empty, coercer}) == {:ok, "present"}
      assert Type.coerce(:invalid, coercer) == :error
    end

    test "custom coercer" do
      assert Type.coerce("foo", Deparam.TestType) == {:ok, "FOO"}
      assert Type.coerce("bar", Deparam.TestType) == :error
    end
  end
end
