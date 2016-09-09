defmodule Mustache.Compiler do

  import Mustache.Utilities, only: [ present?: 1]

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
    buffer = quote do: unquote(buf) <> unquote(text)
    compile(tail, buffer)
  end

  def compile([{:escaped_tag, access}|tail], buf) do
    buffer = quote do
     import Mustache.Utilities, only: [html_escape: 1]
     unquote(buf) <> (var!(data) |> get_in(unquote(access)) |> to_string() |> html_escape())
    end
    compile(tail, buffer)
  end

  def compile([{:raw_tag, access }|tail], buf) do
    buffer = quote do: unquote(buf) <> get_in(var!(data), unquote(access))
    compile(tail, buffer)
  end

  def compile([{:start_if, access }|tail], buf) do
    buffer = quote do
      if present?(get_in(var!(data), unquote(access))) do
        unquote(compile(tail, buf))
      else
        unquote(buf)
      end
    end

    new_tail = skip_to_end_if(tail)
    compile(new_tail, buffer)
  end

  def compile([{:end_if, nil}|_tail], buf) do
    quote do: unquote(buf) |> String.trim()
  end

  def compile([], buf), do: buf

  defp skip_to_end_if([{:end_if, _}|tail]), do: tail
  defp skip_to_end_if([_head|tail]), do: skip_to_end_if(tail)
end
