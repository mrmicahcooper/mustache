defmodule Mustache.Tokenizer do

  def parse(text) when is_binary(text), do: parse String.to_charlist(text)
  def parse(text) when is_list(text),   do: parse(text, [], [], :text)

  def parse('{{{' ++ tail, buf, acc, state) do
     parse(tail, [], acc ++ token(buf, state), :raw_tag)
  end

  def parse('}}}' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ token(buf, state), nil)
  end

  def parse('{{#if' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ token(buf, state), :start_if)
  end

  def parse('{{/if' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ token(buf, state), :end_if)
  end

  def parse('{{else' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ token(buf, state), :else)
  end

  def parse('{{' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ token(buf, state), :escaped_tag)
  end

  def parse('}}' ++ tail, buf, acc, :else=state) do
    parse(tail, [], acc ++ token(buf, state), nil)
  end

  def parse('}}' ++ tail, buf, acc, state) do
    parse(tail, [], acc ++ token(buf, state), nil)
  end

  def parse([], [], acc, _state),          do: acc
  def parse([], buf, acc, state),          do: acc ++ token(buf, state)
  def parse([head|tail], buf, acc, nil),   do: parse(tail, buf ++ [head], acc, :text)
  def parse([head|tail], buf, acc, state), do: parse(tail, buf ++ [head], acc, state)

  defp token([], :text),     do: []
  defp token(buf, :text),    do: [{:text, to_string(buf)}]
  defp token(_buf, :end_if), do: [{:end_if, nil}]
  defp token(_buf, :else),   do: [{:else, nil}]
  defp token([], _state),    do: []

  defp token(buf, state) when state in [:escaped_tag, :raw_tag, :start_if] do
    access = buf |> to_string |> String.trim() |>  String.split([".", "/"])
    [{state, access}]
  end

end
