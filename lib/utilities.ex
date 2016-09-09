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
end
