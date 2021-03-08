defmodule Deparam.CoercerTest do
  use ExUnit.Case, async: true

  alias Deparam.Coercer

  describe "coerce/2" do
    test "typeless" do
      for value <- [nil, "foo", 1337, 133.7, :foo, [], %{}] do
        assert Coercer.coerce(value, nil) == {:ok, value}
        assert Coercer.coerce(value, :any) == {:ok, value}
      end
    end

    test "string" do
      assert Coercer.coerce(nil, :string) == {:ok, nil}
      assert Coercer.coerce("", :string) == {:ok, ""}
      assert Coercer.coerce("foo", :string) == {:ok, "foo"}
      assert Coercer.coerce("1337", :string) == {:ok, "1337"}
      assert Coercer.coerce("133.7", :string) == {:ok, "133.7"}
      assert Coercer.coerce(1337, :string) == {:ok, "1337"}
      assert Coercer.coerce(133.7, :string) == {:ok, "133.7"}
      assert Coercer.coerce(:foo, :string) == {:ok, "foo"}
      assert Coercer.coerce([], :string) == :error
      assert Coercer.coerce(%{}, :string) == :error
      assert Coercer.coerce("foo", {:non_nil, :string}) == {:ok, "foo"}
      assert Coercer.coerce("foo", {:non_empty, :string}) == {:ok, "foo"}
      assert Coercer.coerce(nil, {:non_nil, :string}) == :error
      assert Coercer.coerce(nil, {:non_empty, :string}) == :error
      assert Coercer.coerce("", {:non_empty, :string}) == :error
    end

    test "URL" do
      assert Coercer.coerce(nil, :url) == {:ok, nil}
      assert Coercer.coerce(nil, {:non_nil, :url}) == :error
      assert Coercer.coerce("", :url) == {:ok, nil}
      assert Coercer.coerce("", {:non_nil, :url}) == :error
      assert Coercer.coerce("", {:non_empty, :url}) == :error
      assert Coercer.coerce("foo", :url) == :error

      assert Coercer.coerce("http://test.com", :url) ==
               {:ok, "http://test.com"}

      assert Coercer.coerce("https://test.com", :url) ==
               {:ok, "https://test.com"}

      assert Coercer.coerce("ftp://test.com", :url) == :error
    end

    test "integer" do
      assert Coercer.coerce(nil, :integer) == {:ok, nil}
      assert Coercer.coerce("", :integer) == :error
      assert Coercer.coerce("foo", :integer) == :error
      assert Coercer.coerce("1337", :integer) == {:ok, 1337}
      assert Coercer.coerce("133.7", :integer) == :error
      assert Coercer.coerce(1337, :integer) == {:ok, 1337}
      assert Coercer.coerce(133.7, :integer) == {:ok, 133}
      assert Coercer.coerce(:foo, :integer) == :error
      assert Coercer.coerce([], :integer) == :error
      assert Coercer.coerce(%{}, :integer) == :error
      assert Coercer.coerce("1337", {:non_nil, :integer}) == {:ok, 1337}
      assert Coercer.coerce("1337", {:non_empty, :integer}) == {:ok, 1337}
      assert Coercer.coerce(nil, {:non_nil, :integer}) == :error
      assert Coercer.coerce(nil, {:non_empty, :integer}) == :error
      assert Coercer.coerce("", {:non_empty, :integer}) == :error
    end

    test "float" do
      assert Coercer.coerce(nil, :float) == {:ok, nil}
      assert Coercer.coerce("", :float) == :error
      assert Coercer.coerce("foo", :float) == :error
      assert Coercer.coerce("1337", :float) == {:ok, 1337.0}
      assert Coercer.coerce("133.7", :float) == {:ok, 133.7}
      assert Coercer.coerce(1337, :float) == {:ok, 1337.0}
      assert Coercer.coerce(133.7, :float) == {:ok, 133.7}
      assert Coercer.coerce(:foo, :float) == :error
      assert Coercer.coerce([], :float) == :error
      assert Coercer.coerce(%{}, :float) == :error
      assert Coercer.coerce("133.7", {:non_nil, :float}) == {:ok, 133.7}
      assert Coercer.coerce("133.7", {:non_empty, :float}) == {:ok, 133.7}
      assert Coercer.coerce(nil, {:non_nil, :float}) == :error
      assert Coercer.coerce(nil, {:non_empty, :float}) == :error
      assert Coercer.coerce("", {:non_empty, :float}) == :error
    end

    test "boolean" do
      assert Coercer.coerce(nil, :boolean) == {:ok, nil}
      assert Coercer.coerce(false, :boolean) == {:ok, false}
      assert Coercer.coerce(true, :boolean) == {:ok, true}
      assert Coercer.coerce("", :boolean) == {:ok, false}
      assert Coercer.coerce("foo", :boolean) == {:ok, false}
      assert Coercer.coerce("true", :boolean) == {:ok, true}
      assert Coercer.coerce("0", :boolean) == {:ok, false}
      assert Coercer.coerce("1", :boolean) == {:ok, true}
      assert Coercer.coerce(1337, :boolean) == :error
      assert Coercer.coerce(133.7, :boolean) == :error
      assert Coercer.coerce(:foo, :boolean) == :error
      assert Coercer.coerce([], :boolean) == :error
      assert Coercer.coerce(%{}, :boolean) == :error
    end

    test "map" do
      assert Coercer.coerce(
               %{
                 :foo => 666,
                 "bar" => "1337",
                 "baz" => nil
               },
               {:map, :string, :string}
             ) == {:ok, %{"foo" => "666", "bar" => "1337", "baz" => nil}}

      assert Coercer.coerce(
               %{
                 :foo => 666,
                 "bar" => "1337",
                 "baz" => nil
               },
               {:map, :string, :integer}
             ) == {:ok, %{"foo" => 666, "bar" => 1337, "baz" => nil}}

      assert Coercer.coerce(
               %{
                 "1" => 666,
                 "2" => "foo",
                 3 => :bar
               },
               {:map, :integer, :any}
             ) == {:ok, %{1 => 666, 2 => "foo", 3 => :bar}}

      assert Coercer.coerce(
               %{
                 :foo => 666,
                 "bar" => "foo",
                 "baz" => nil
               },
               {:map, :string, :integer}
             ) == :error

      assert Coercer.coerce(%{}, {:map, :string, :integer}) == {:ok, %{}}

      assert Coercer.coerce(%{}, {:non_nil, {:map, :string, :integer}}) ==
               {:ok, %{}}

      assert Coercer.coerce(nil, {:non_nil, {:map, :string, :integer}}) ==
               :error

      assert Coercer.coerce(
               %{"foo" => "bar", "" => "baz"},
               {:non_nil, {:map, :string, :string}}
             ) == {:ok, %{"foo" => "bar", "" => "baz"}}

      assert Coercer.coerce(
               %{"foo" => "bar", "" => "baz"},
               {:non_nil, {:map, {:non_empty, :string}, :string}}
             ) == :error

      assert Coercer.coerce(
               %{"foo" => "bar"},
               {:non_empty, {:map, :string, :string}}
             ) == {:ok, %{"foo" => "bar"}}

      assert Coercer.coerce(%{}, {:non_empty, {:map, :string, :integer}}) ==
               :error

      assert Coercer.coerce("foo", {:map, :string, :string}) == :error
      assert Coercer.coerce(1337, {:map, :string, :string}) == :error
      assert Coercer.coerce([1337, "goo"], {:map, :string, :string}) == :error
    end

    test "list" do
      assert Coercer.coerce([666, "foo", nil], {:array, :string}) ==
               {:ok, ["666", "foo", nil]}

      assert Coercer.coerce([666, "foo", nil], {:array, {:non_nil, :string}}) ==
               :error

      assert Coercer.coerce([666, "foo"], {:array, {:non_nil, :string}}) ==
               {:ok, ["666", "foo"]}

      assert Coercer.coerce([], {:array, :string}) == {:ok, []}
      assert Coercer.coerce([], {:array, {:non_nil, :string}}) == {:ok, []}

      assert Coercer.coerce(nil, {:array, {:non_nil, :string}}) == {:ok, nil}

      assert Coercer.coerce(nil, {:non_nil, {:array, {:non_nil, :string}}}) ==
               :error

      assert Coercer.coerce([], {:non_empty, {:array, {:non_nil, :string}}}) ==
               :error

      assert Coercer.coerce(
               ["foo"],
               {:non_empty, {:array, {:non_nil, :string}}}
             ) == {:ok, ["foo"]}

      assert Coercer.coerce(
               ["foo", nil],
               {:non_empty, {:array, {:non_nil, :string}}}
             ) == :error

      assert Coercer.coerce(
               ["foo", ""],
               {:non_empty, {:array, {:non_empty, :string}}}
             ) == :error

      assert Coercer.coerce(
               nil,
               {:array, {:non_empty, :string}}
             ) == {:ok, nil}

      assert Coercer.coerce(
               "foo",
               {:array, {:non_empty, :string}}
             ) == {:ok, ["foo"]}
    end

    test "word list" do
      assert Coercer.coerce("foo bar", :word_list) == {:ok, ["foo", "bar"]}

      assert Coercer.coerce("  foo    bar ", :word_list) ==
               {:ok, ["foo", "bar"]}

      assert Coercer.coerce("foo bar", {:word_list, :string}) ==
               {:ok, ["foo", "bar"]}

      assert Coercer.coerce(" 1337 666", {:word_list, :integer}) ==
               {:ok, [1337, 666]}

      assert Coercer.coerce("", :word_list) == {:ok, []}
      assert Coercer.coerce("  ", :word_list) == {:ok, []}
      assert Coercer.coerce("", {:word_list, :string}) == {:ok, []}
      assert Coercer.coerce("  ", {:word_list, :string}) == {:ok, []}
      assert Coercer.coerce(nil, :word_list) == {:ok, nil}
      assert Coercer.coerce(nil, {:word_list, :string}) == {:ok, nil}

      assert Coercer.coerce("foo bar", {:non_empty, :word_list}) ==
               {:ok, ["foo", "bar"]}

      assert Coercer.coerce("", {:non_nil, :word_list}) == {:ok, []}
      assert Coercer.coerce(nil, {:non_nil, :word_list}) == :error
      assert Coercer.coerce("", {:non_empty, :word_list}) == :error
      assert Coercer.coerce("  ", {:non_empty, :word_list}) == :error
      assert Coercer.coerce("", {:non_empty, {:word_list, :string}}) == :error
      assert Coercer.coerce("  ", {:non_empty, {:word_list, :string}}) == :error

      assert Coercer.coerce(["foo", "bar"], {:non_empty, :word_list}) ==
               {:ok, ["foo", "bar"]}

      assert Coercer.coerce(["foo", ""], {:word_list, {:non_empty, :string}}) ==
               :error
    end

    test "upload" do
      path = "tmp/#{System.system_time()}.dat"

      assert Coercer.coerce(%Plug.Upload{path: path}, :upload) == {:ok, path}
      assert Coercer.coerce(%{path: path}, :upload) == :error
    end

    test "enum" do
      assert Coercer.coerce("ipsum", {:enum, ["lorem", "ipsum"]}) ==
               {:ok, "ipsum"}

      assert Coercer.coerce("dolor", {:enum, ["lorem", "ipsum"]}) ==
               :error
    end

    test "function" do
      coercer = fn
        "0" -> {:ok, nil}
        "1" -> {:ok, true}
        "2" -> {:ok, false}
        _ -> :error
      end

      assert Coercer.coerce(nil, coercer) == {:ok, nil}
      assert Coercer.coerce("0", coercer) == {:ok, nil}
      assert Coercer.coerce("1", coercer) == {:ok, true}
      assert Coercer.coerce("2", coercer) == {:ok, false}
      assert Coercer.coerce("3", coercer) == :error
      assert Coercer.coerce([], coercer) == :error
    end
  end
end
