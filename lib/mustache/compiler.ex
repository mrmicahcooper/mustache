defmodule Mustache.Compiler do
  import Mustache.Utilities, only: [html_escape: 1]

  def compile_string(source, data) do
    tokens = Mustache.Tokenizer.parse(source)
    compile(tokens, "", data)
  end

  def eval_string(source, data) do
    source
    |> compile_string(data)
    |> Code.eval_quoted(file: __ENV__.file, line: __ENV__.line)
    |> elem(0)
  end

  def compile([token|tail], buf, data) do
    buffer = add_token_to_buffer(token, buf, data)
    compile(tail, buffer, data)
  end
  def compile([], buf, _data), do: buf

  defp add_token_to_buffer({:text, text}, buf, _data) do
    quote do: unquote(buf) <> unquote(text)
  end

  defp add_token_to_buffer({:escaped_tag, access}, buf, data) do
    quote do
      unquote(buf) <> unquote(data |> get_in(access) |> to_string |> html_escape)
    end
  end

  defp add_token_to_buffer({:raw_tag, access}, buf, data) do
    quote do
      unquote(buf) <> unquote(data |> get_in(access) |> to_string)
    end
  end

end
