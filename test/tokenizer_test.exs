defmodule Mustache.TokenizerTest do
  use ExUnit.Case, async: true

  test "returns tokens for passed in binary" do
    text = """
    Hello there {{name}}. I am {{person.age}} years old.
    I am {{{ person/height }}}{{person.weight}}
    """
    tokens = Mustache.Tokenizer.parse(text)
    assert tokens == [
      {:text, "Hello there "},
      {:get_in, ["name"], :escaped_tag},
      {:text, ". I am "},
      {:get_in, ["person", "age"], :escaped_tag},
      {:text, " years old.\nI am "},
      {:get_in, ["person", "height"], :raw_tag},
      {:get_in, ["person", "weight"], :escaped_tag},
      {:text, "\n"},
    ]
  end

  test "returns tokens for passed in binary of just a string" do
    text = "Hello there"
    tokens = Mustache.Tokenizer.parse(text)
    assert tokens == [
      {:text, "Hello there"},
    ]
  end
end
