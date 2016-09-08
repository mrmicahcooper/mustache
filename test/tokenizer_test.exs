defmodule Mustache.TokenizerTest do
  use ExUnit.Case, async: true

  test "returns tokens for passed in binary" do
    text = """
    Hello there {{name}}. I am {{person.age}} years old.
    I am {{{ person/height }}} tall
    """
    tokens = Mustache.Tokenizer.tokenize(text)
    assert tokens == [
      {:text, "Hello there "},
      {:get_in, ["name"], :escaped},
      {:text, ". I am "},
      {:get_in, ["person", "age"], :escaped},
      {:text, " years old.\nI am "},
      {:get_in, ["person", "height"], :raw},
      {:text, " tall\n"},
    ]
  end
end
