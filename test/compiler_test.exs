defmodule Mustache.CompilerTest do
  use ExUnit.Case, async: true

  test ".compile_string" do
    text = "Hello there"
    result = Mustache.Compiler.compile_string(text)
    assert result == {:<>, [context: Mustache.Compiler, import: Kernel], ["", "Hello there"]}

  end

  test "Returns an evaled string with no data" do
    text = "Hello there"
    result = Mustache.Compiler.eval_string(text, %{})
    assert result == "Hello there"
  end

  test "compiling returns an Elixir AST" do
    text = """
    Hello there {{name}}. I am {{person.age}} years old.
    I am {{{ person/height }}} and {{person.weight}}
    """
    object = %{
      "name" => "Micah",
      "person" => %{
        "age"    => "29",
        "height" => "<99 feet tall>",
        "weight" => "<25 pounds>",
      }
    }
    result = Mustache.Compiler.eval_string(text, object)
    assert result == """
    Hello there Micah. I am 29 years old.
    I am <99 feet tall> and &lt;25 pounds&gt;
    """
  end

  test "handling conditionals" do
    text = """
    Is the name there?
    {{#if name}}
    YES! it's {{name}}!
    {{else}}
    NOPE!
    {{/if}}
    Is the other name there?
    {{#if other_name}}
    YES! it's {{other_name}}!
    {{/if}}
    """
    object = %{ "name" => "", "other_name" => "Bob"}
    result = Mustache.Compiler.eval_string(text, object)
    assert result == """
    Is the name there?

    NOPE!
    Is the other name there?

    YES! it's Bob!
    """
  end

end
