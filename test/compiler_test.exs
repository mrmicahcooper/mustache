defmodule Mustache.CompilerTest do
  use ExUnit.Case, async: true

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
        "age"    => 29,
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

end
