defmodule Mustache.Compiler do

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
    buffer = compile_token(token, buf, data)
    compile(tail, buffer, data)
  end
  def compile([], buf, _data), do: buf

  defp compile_token({:text, text}, buf, _data) do
    quote do: unquote(buf) <> unquote(text)
  end

  defp compile_token({:escaped_tag, access}, buf, data) do
    quote do: unquote(buf) <> unquote(data |> get_in(access) |> to_string)
  end

end
