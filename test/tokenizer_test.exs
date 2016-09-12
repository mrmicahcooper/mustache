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
      {:escaped_tag, ["name"]},
      {:text, ". I am "},
      {:escaped_tag, ["person", "age"]},
      {:text, " years old.\nI am "},
      {:raw_tag, ["person", "height"]},
      {:escaped_tag, ["person", "weight"]},
      {:text, "\n"},
    ]
  end

  test "conditionals" do
    text = """
    {{#if person.alive }}
     I'm alive!!
    {{else}}
     I'm dead :(
    {{/if }}
    """
    tokens = Mustache.Tokenizer.parse(text)
    assert tokens == [
      {:start_if, ["person","alive"]},
      {:text, "\n I'm alive!!\n"},
      {:else, nil},
      {:text, "\n I'm dead :(\n"},
      {:end_if, nil},
      {:text, "\n"},
    ]
  end

  test "each" do
    text = """
    {{#each person.hobbies }}
    My hobby is {{name}} {{description.text}}
    {{/each }}
    """
    tokens = Mustache.Tokenizer.parse(text)
    assert tokens == [
      {:start_each, ["person","hobbies"]},
      {:text, "\nMy hobby is "},
      {:escaped_tag, ["name"]},
      {:text, " "},
      {:escaped_tag, ["description", "text"]},
      {:text, "\n"},
      {:end_each, nil},
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
