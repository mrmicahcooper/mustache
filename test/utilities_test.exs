defmodule Mustache.UtilitiesTest do
  use ExUnit.Case, async: true

  test ".html_escape" do
    text   = ~s(" \\ < > &)
    result = Mustache.Utilities.html_escape(text)
    assert result == "&quot; &#40; &lt; &gt; &amp;"
  end

end
