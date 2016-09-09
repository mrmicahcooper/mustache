defmodule Mustache.Compiler do

  alias Mustache.Utilities

  import Mustache.Utilities, only: [html_escape: 1]

  def eval_string(source, data) do
    source
    |> compile_string()
    |> Code.eval_quoted([data: data], __ENV__)
    |> elem(0)
  end

  def compile_string(source) do
    tokens = Mustache.Tokenizer.parse(source)
    compile(tokens, "")
  end

  def compile([{:text, text}|tail], buf) do
    buffer = quote do
      unquote(buf) <> unquote(text)
    end
    compile(tail, buffer)
  end

  def compile([{:escaped_tag, access}|tail], buf) do
    buffer = quote do
     unquote(buf) <> (var!(data) |> get_in(unquote(access)) |> to_string() |> html_escape())
    end
    compile(tail, buffer)
  end

  def compile([{:raw_tag, access }|tail], buf) do
    buffer = quote do
     unquote(buf) <> get_in(var!(data), unquote(access))
    end
    compile(tail, buffer)
  end

  def compile([], buf), do: buf
end
