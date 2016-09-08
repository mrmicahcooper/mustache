defmodule Mustache.Tokenizer do

  @empty_token_states ~w[end_if end_each else]a
  @section_states ~w[escaped_tag raw_tag start_if start_each]a

  def parse(source) when is_binary(source), do: parse String.to_charlist(source)
  def parse(source) when is_list(source),   do: parse(source, [], [], :text)

  def parse('{{{' ++ tail, buf, acc, state),     do: parse(tail, [], acc ++ token(buf, state), :raw_tag)
  def parse('}}}' ++ tail, buf, acc, state),     do: parse(tail, [], acc ++ token(buf, state), nil)

  def parse('{{#if' ++ tail, buf, acc, state),   do: parse(tail, [], acc ++ token(buf, state), :start_if)
  def parse('{{/if' ++ tail, buf, acc, state),   do: parse(tail, [], acc ++ token(buf, state), :end_if)
  def parse('{{else' ++ tail, buf, acc, state),  do: parse(tail, [], acc ++ token(buf, state), :else)
  def parse('{{#each' ++ tail, buf, acc, state),  do: parse(tail, [], acc ++ token(buf, state), :start_each)
  def parse('{{/each' ++ tail, buf, acc, state),  do: parse(tail, [], acc ++ token(buf, state), :end_each)
  def parse('{{' ++ tail, buf, acc, state),      do: parse(tail, [], acc ++ token(buf, state), :escaped_tag)

  def parse('}}' ++ tail, buf, acc, :else=state),do: parse(tail, [], acc ++ token(buf, state), nil)
  def parse('}}' ++ tail, buf, acc, state),      do: parse(tail, [], acc ++ token(buf, state), nil)

  def parse([], [], acc, _state),          do: acc
  def parse([], buf, acc, state),          do: acc ++ token(buf, state)
  def parse([head|tail], buf, acc, nil),   do: parse(tail, buf ++ [head], acc, :text)
  def parse([head|tail], buf, acc, state), do: parse(tail, buf ++ [head], acc, state)

  defp token([], :text),     do: []
  defp token(buf, :text),    do: [{:text, to_string(buf)}]

  defp token(_buf, state) when state in @empty_token_states do
    [{state, nil}]
  end

  defp token(buf, state) when state in @section_states do
    access = buf |> to_string |> String.trim() |>  String.split([".", "/"])
    [{state, access}]
  end

  defp token([], _state),    do: []

end
