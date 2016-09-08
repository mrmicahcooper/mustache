defmodule Mustache.TokenizerTest do
  use ExUnit.Case, async: true

  test "returns tokens for passed in binary" do
    text = "Hello there {{name}}. I live in {{state.city}}"
    tokens = Mustache.Tokenizer.tokenize(text)
    assert tokens == [
      {:text, "Hello there "},
      {:get_in, ["name"]},
      {:text, ". I live in "},
      {:get_in, ["state", "city"]},
    ]
  end
end
