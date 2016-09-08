defmodule Mustache.Tokenizer do

  def tokenize(text) when is_binary(text) do
    tokenize String.to_charlist(text)
  end

  def tokenize(text) when is_list(text) do
    tokenize(text, [], [], :text)
  end

  def tokenize('{{' ++ tail, buffer, acc, :text) do
    tokenize(tail, [], acc ++ text(buffer), :tag)
  end

  def tokenize('}}' ++ tail, buffer, acc, :tag) do
    tokenize(tail, [], acc ++ tag(buffer), :text)
  end

  def tokenize([head|tail], buffer, acc, :tag) do
    tokenize(tail, buffer ++ [head], acc, :tag)
  end

  def tokenize([head|tail], buffer, acc, :text) do
    tokenize(tail, buffer ++ [head], acc, :text)
  end

  def tokenize([], [], acc, _state) do
    acc
  end

  def tokenize([], buffer, acc, _state) do
    acc ++ [{:text, to_string(buffer)}]
  end

  defp tag(buffer) do
    access = buffer |> to_string |> String.split([".", "/"])
    [{:get_in, access}]
  end

  defp text(buffer) do
    [{:text, to_string(buffer)}]
  end

end
