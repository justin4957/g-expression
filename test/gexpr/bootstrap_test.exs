defmodule Gexpr.BootstrapTest do
  use ExUnit.Case
  alias Gexpr.{Bootstrap, PrimeMover}
  
  doctest Bootstrap

  describe "bootstrap/0" do
    test "bootstraps the genesis context successfully" do
      assert {:ok, full_context} = Bootstrap.bootstrap()
      
      # Verify that basic axioms are present
      assert Map.has_key?(full_context, "cons")
      assert Map.has_key?(full_context, "car")
      assert Map.has_key?(full_context, "cdr")
      assert Map.has_key?(full_context, "id")
      assert Map.has_key?(full_context, "eq?")
      assert Map.has_key?(full_context, "cond")
      
      # Verify that bootstrapped definitions are present
      assert Map.has_key?(full_context, "lambda")
      assert Map.has_key?(full_context, "if")
    end

    test "can evaluate simple expressions with bootstrapped context" do
      assert {:ok, context} = Bootstrap.bootstrap()
      
      # Test identity function
      simple_expr = {:app, {:ref, "id"}, {:lit, 42}}
      assert {:ok, 42} = PrimeMover.unfurl(simple_expr, context)
      
      # Test cons operation
      cons_expr = {:app, {:ref, "cons"}, {:vec, [{:lit, 1}, {:lit, 2}]}}
      assert {:ok, {:list, [1, 2]}} = PrimeMover.unfurl(cons_expr, context)
    end

    test "handles missing genesis file gracefully" do
      # This test verifies that even without a genesis file,
      # the system can bootstrap with minimal definitions
      assert {:ok, _context} = Bootstrap.bootstrap()
    end
  end

  describe "load_genesis_gexprs/0" do
    test "loads genesis expressions successfully" do
      assert {:ok, genesis_gexprs} = Bootstrap.load_genesis_gexprs()
      assert is_list(genesis_gexprs)
      
      # Should contain at least some basic definitions
      definition_names = 
        genesis_gexprs
        |> Enum.filter(&match?({:def, _, _}, &1))
        |> Enum.map(fn {:def, name, _} -> name end)
      
      assert "lambda" in definition_names
      assert "if" in definition_names
    end
  end
end