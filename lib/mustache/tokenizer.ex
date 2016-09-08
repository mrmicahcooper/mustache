defmodule Mustache.Tokenizer do

  def tokenize(text) when is_binary(text) do
    tokenize String.to_charlist(text)
  end

  def tokenize(text) when is_list(text) do
    tokenize(text, [], [], :text)
  end

  def tokenize('{{{' ++ tail, buf, acc, :text) do
    tokenize(tail, [], acc ++ text(buf), :tag)
  end

  def tokenize('}}}' ++ tail, buf, acc, :tag) do
    tokenize(tail, [], acc ++ tag(buf, :raw), :text)
  end

  def tokenize('{{' ++ tail, buf, acc, :text) do
    tokenize(tail, [], acc ++ text(buf), :tag)
  end

  def tokenize('}}' ++ tail, buf, acc, :tag) do
    tokenize(tail, [], acc ++ tag(buf), :text)
  end

  def tokenize([head|tail], buf, acc, state) do
    tokenize(tail, buf ++ [head], acc, state)
  end

  def tokenize([], [], acc, _state) do
    acc
  end

  def tokenize([], buf, acc, _state) do
    acc ++ [{:text, to_string(buf)}]
  end

  defp tag(buf, escape\\:escaped) do
    access = buf |> to_string |> String.trim() |>  String.split([".", "/"])
    [{:get_in, access, escape}]
  end

  defp text(buf) do
    [{:text, to_string(buf)}]
  end

end
