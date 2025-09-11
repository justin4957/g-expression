defmodule Gexpr.PrimeMoverTest do
  use ExUnit.Case
  alias Gexpr.PrimeMover
  
  doctest PrimeMover

  describe "create_genesis_context/0" do
    test "creates a context with fundamental operations" do
      context = PrimeMover.create_genesis_context()
      
      # Should contain all the basic axioms
      assert Map.has_key?(context, "cons")
      assert Map.has_key?(context, "car") 
      assert Map.has_key?(context, "cdr")
      assert Map.has_key?(context, "id")
      assert Map.has_key?(context, "eq?")
      assert Map.has_key?(context, "cond")
      
      # All values should be builtins
      Enum.each(context, fn {_name, value} ->
        assert match?({:builtin, _, _}, value)
      end)
    end
  end

  describe "unfurl/2" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "evaluates literals", %{context: context} do
      assert {:ok, 42} = PrimeMover.unfurl({:lit, 42}, context)
      assert {:ok, "hello"} = PrimeMover.unfurl({:lit, "hello"}, context)
      assert {:ok, :atom} = PrimeMover.unfurl({:lit, :atom}, context)
    end

    test "evaluates references", %{context: context} do
      # Valid reference
      assert {:ok, {:builtin, "id", _}} = PrimeMover.unfurl({:ref, "id"}, context)
      
      # Invalid reference
      assert {:error, "Undefined reference: nonexistent"} = 
        PrimeMover.unfurl({:ref, "nonexistent"}, context)
    end

    test "evaluates vectors", %{context: context} do
      vec_expr = {:vec, [{:lit, 1}, {:lit, 2}, {:lit, 3}]}
      assert {:ok, {:list, [1, 2, 3]}} = PrimeMover.unfurl(vec_expr, context)
      
      # Vector with references
      vec_with_ref = {:vec, [{:lit, 1}, {:ref, "nonexistent"}]}
      assert {:error, _} = PrimeMover.unfurl(vec_with_ref, context)
    end

    test "evaluates function applications", %{context: context} do
      # Apply id function
      app_expr = {:app, {:ref, "id"}, {:lit, 42}}
      assert {:ok, 42} = PrimeMover.unfurl(app_expr, context)
      
      # Apply cons function  
      cons_expr = {:app, {:ref, "cons"}, {:vec, [{:lit, 1}, {:lit, 2}]}}
      assert {:ok, {:list, [1, 2]}} = PrimeMover.unfurl(cons_expr, context)
    end
  end

  describe "builtin functions" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "cons creates lists", %{context: context} do
      cons_fun = Map.get(context, "cons")
      assert {:ok, {:list, [1, 2]}} = PrimeMover.apply_value(cons_fun, [1, 2])
      assert {:error, _} = PrimeMover.apply_value(cons_fun, [1])
    end

    test "car extracts first element", %{context: context} do
      car_fun = Map.get(context, "car")
      assert {:ok, 1} = PrimeMover.apply_value(car_fun, [{:list, [1, 2, 3]}])
      assert {:error, _} = PrimeMover.apply_value(car_fun, [{:list, []}])
    end

    test "cdr extracts tail", %{context: context} do
      cdr_fun = Map.get(context, "cdr")
      assert {:ok, {:list, [2, 3]}} = PrimeMover.apply_value(cdr_fun, [{:list, [1, 2, 3]}])
      assert {:ok, {:list, []}} = PrimeMover.apply_value(cdr_fun, [{:list, [1]}])
    end

    test "id returns input unchanged", %{context: context} do
      id_fun = Map.get(context, "id")
      assert {:ok, 42} = PrimeMover.apply_value(id_fun, [42])
      assert {:ok, "test"} = PrimeMover.apply_value(id_fun, ["test"])
      assert {:error, _} = PrimeMover.apply_value(id_fun, [1, 2])
    end

    test "eq? tests equality", %{context: context} do
      eq_fun = Map.get(context, "eq?")
      assert {:ok, true} = PrimeMover.apply_value(eq_fun, [42, 42])
      assert {:ok, false} = PrimeMover.apply_value(eq_fun, [42, 43])
      assert {:ok, true} = PrimeMover.apply_value(eq_fun, ["test", "test"])
    end

    test "cond provides conditional logic", %{context: context} do
      cond_fun = Map.get(context, "cond")
      assert {:ok, "then"} = PrimeMover.apply_value(cond_fun, [true, "then", "else"])
      assert {:ok, "else"} = PrimeMover.apply_value(cond_fun, [false, "then", "else"])
    end
  end
end