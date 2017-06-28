defmodule Mustache.Tokenizer do

  @empty_token_states ~w[end_if end_each else]a
  @section_states ~w[escaped_tag raw_tag start_if start_each]a

  def parse(source) when is_list(source),   do: parse(to_string(source))
  def parse(source) when is_binary(source), do: parse(source, "", [], :text)

  def parse("{{{"     <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :raw_tag)
  def parse("}}}"     <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), nil)
  def parse("{{#if"   <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :start_if)
  def parse("{{/if"   <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :end_if)
  def parse("{{else"  <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :else)
  def parse("{{#each" <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :start_each)
  def parse("{{/each" <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :end_each)
  def parse("{{"      <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), :escaped_tag)
  def parse("}}"      <> tail, buf, acc, state),       do: parse(tail, "", acc ++ token(buf, state), nil)

  def parse("|" <> tail, buf, acc, :start_each),       do: parse(tail, {buf, ""}, acc, :reference)
  def parse("|" <> tail, buf, acc , :reference),  do: parse(tail, "", acc ++ token(buf, :reference), :reference)

  def parse("", "", acc, _state), do: acc
  def parse("", buf, acc, state), do: acc ++ token(buf, state)
  def parse(<<head::binary-1, tail::binary>>, buf, acc, nil),   do: parse(tail, buf <> head, acc, :text)
  def parse(<<head::binary-1, tail::binary>>, {buf, ref}, acc, :reference), do: parse(tail, {buf, ref <> head }, acc, :reference)
  def parse(<<head::binary-1, tail::binary>>, buf, acc, state), do: parse(tail, buf <> head, acc, state)

  defp token("", :text), do: []
  defp token(buf, :text), do: [{:text, buf}]
  defp token(_buf, state) when state in @empty_token_states, do: [{state, nil}]
  defp token(buf, state)  when state in @section_states, do: [{state, access(buf)}]
  defp token({buf, ref}, :reference), do: [{:start_each, access(buf), ref}]
  defp token("", _state), do: []

  def access(string), do: string |> String.trim() |>  String.split([".", "/"])
end
