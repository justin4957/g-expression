defmodule GexprTest do
  use ExUnit.Case
  doctest Gexpr

  test "can bootstrap the system" do
    assert {:ok, _context} = Gexpr.bootstrap()
  end
end
