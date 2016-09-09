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
    else_tail   = skip_to_else(tail)
    end_if_tail = skip_to_end_if(tail)

    buffer = quote do
      if present?(get_in(var!(data), unquote(access))) do
        unquote(compile(tail, buf)) |> String.trim()
      else
        unquote(compile(else_tail, buf))
      end
    end

    compile(end_if_tail, buffer)
  end

  def compile([{:end_if, nil}|_tail], buf) do
    quote do: unquote(buf) |> String.trim()
  end

  def compile([{:else, nil}|_tail], buf) do
    quote do: unquote(buf) |> String.trim()
  end

  def compile([], buf), do: buf

  defp skip_to_end_if([{:end_if, _}|tail]), do: tail
  defp skip_to_end_if([]), do: []
  defp skip_to_end_if([_head|tail]), do: skip_to_end_if(tail)

  defp skip_to_else([{:else, _}|tail]), do: tail
  defp skip_to_else([{:end_if, _}|tail]), do: []
  defp skip_to_else([]), do: []
  defp skip_to_else([_head|tail]), do: skip_to_else(tail)
end
