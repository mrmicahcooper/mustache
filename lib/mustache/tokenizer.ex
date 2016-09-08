defmodule Mustache.Tokenizer do

  def parse(text) when is_binary(text), do: parse String.to_charlist(text)
  def parse(text) when is_list(text),   do: parse(text, [], [], :text)

  def parse('{{{' ++ tail, buf, acc, state) do
     parse(tail, [], acc ++ tokenize(buf, state), :raw_tag)
  end

  def parse('}}}' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ tokenize(buf, state), nil)
  end

  def parse('{{' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ tokenize(buf, state), :escaped_tag)
  end

  def parse('}}' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ tokenize(buf, state), nil)
  end

  def parse([], [], acc, _state),          do: acc
  def parse([], buf, acc, state),          do: acc ++ tokenize(buf, state)
  def parse([head|tail], buf, acc, nil),   do: parse(tail, buf ++ [head], acc, :text)
  def parse([head|tail], buf, acc, state), do: parse(tail, buf ++ [head], acc, state)

  defp tokenize(buf, :text) do
    [{:text, to_string(buf)}]
  end

  defp tokenize(buf, state) when state in [:escaped_tag, :raw_tag] do
    access = buf |> to_string |> String.trim() |>  String.split([".", "/"])
    [{:get_in, access, state}]
  end

  defp tokenize(buf, state) do
    []
  end

end
