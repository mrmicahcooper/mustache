defmodule Mustache.Utilities do
  def html_escape(string) do
    Regex.replace(~r/(\\|&|<|>|")/, string, fn(capture) ->
      %{
        "\\" => "&#40;",
        ~s(") => "&quot;",
        "&"  => "&amp;",
        "<"  => "&lt;",
        ">"  => "&gt;",
      }[capture]
    end)
  end

  def present?([]), do: false
  def present?(""), do: false
  def present?(nil), do: false
  def present?(%{}=object), do: present?(Map.keys(object))
  def present?(_), do: true

end
