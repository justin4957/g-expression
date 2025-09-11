defmodule Gexpr.MacroLibraryTest do
  use ExUnit.Case
  alias Gexpr.{MacroLibrary, PrimeMover}

  describe "macro library loading" do
    test "loads essential macros into context" do
      {:ok, macro_context} = MacroLibrary.create_macro_environment()
      
      # Test that essential macros are present
      essential_macros = ["when", "inc", "square", "compose"]
      Enum.each(essential_macros, fn macro_name ->
        assert Map.has_key?(macro_context, macro_name), "Missing macro: #{macro_name}"
      end)
    end

    test "macro context includes base operations" do
      {:ok, macro_context} = MacroLibrary.create_macro_environment()
      
      # Test that base operations are still present
      base_ops = ["cons", "car", "cdr", "id", "+", "-", "*"]
      Enum.each(base_ops, fn op ->
        assert Map.has_key?(macro_context, op), "Missing base operation: #{op}"
      end)
    end
  end

  describe "arithmetic macros" do
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "inc macro adds 1", %{context: context} do
      inc_expr = {:app, {:ref, "inc"}, {:vec, [{:lit, 41}]}}
      assert {:ok, 42} = PrimeMover.unfurl(inc_expr, context)
    end

    test "dec macro subtracts 1", %{context: context} do
      dec_expr = {:app, {:ref, "dec"}, {:vec, [{:lit, 43}]}}
      assert {:ok, 42} = PrimeMover.unfurl(dec_expr, context)
    end

    test "square macro multiplies by itself", %{context: context} do
      square_expr = {:app, {:ref, "square"}, {:vec, [{:lit, 6}]}}
      assert {:ok, 36} = PrimeMover.unfurl(square_expr, context)
    end
  end

  describe "logical macros" do  
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "and macro with both true", %{context: context} do
      and_expr = {:app, {:ref, "and"}, {:vec, [{:lit, true}, {:lit, true}]}}
      assert {:ok, true} = PrimeMover.unfurl(and_expr, context)
    end

    test "and macro with first false", %{context: context} do
      and_expr = {:app, {:ref, "and"}, {:vec, [{:lit, false}, {:lit, true}]}}
      assert {:ok, false} = PrimeMover.unfurl(and_expr, context)
    end

    test "or macro with first true", %{context: context} do
      or_expr = {:app, {:ref, "or"}, {:vec, [{:lit, true}, {:lit, false}]}}
      assert {:ok, true} = PrimeMover.unfurl(or_expr, context)
    end

    test "or macro with both false", %{context: context} do
      or_expr = {:app, {:ref, "or"}, {:vec, [{:lit, false}, {:lit, false}]}}
      assert {:ok, false} = PrimeMover.unfurl(or_expr, context)
    end

    test "not macro inverts boolean", %{context: context} do
      not_true = {:app, {:ref, "not"}, {:vec, [{:lit, true}]}}
      assert {:ok, false} = PrimeMover.unfurl(not_true, context)
      
      not_false = {:app, {:ref, "not"}, {:vec, [{:lit, false}]}}
      assert {:ok, true} = PrimeMover.unfurl(not_false, context)
    end
  end

  describe "control flow macros" do
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "when macro executes on true condition", %{context: context} do
      when_expr = {:app, {:ref, "when"}, {:vec, [{:lit, true}, {:lit, "executed"}]}}
      assert {:ok, "executed"} = PrimeMover.unfurl(when_expr, context)
    end

    test "when macro returns nil on false condition", %{context: context} do
      when_expr = {:app, {:ref, "when"}, {:vec, [{:lit, false}, {:lit, "not executed"}]}}
      assert {:ok, nil} = PrimeMover.unfurl(when_expr, context)
    end

    test "unless macro returns nil on true condition", %{context: context} do
      unless_expr = {:app, {:ref, "unless"}, {:vec, [{:lit, true}, {:lit, "not executed"}]}}
      assert {:ok, nil} = PrimeMover.unfurl(unless_expr, context)
    end

    test "unless macro executes on false condition", %{context: context} do
      unless_expr = {:app, {:ref, "unless"}, {:vec, [{:lit, false}, {:lit, "executed"}]}}
      assert {:ok, "executed"} = PrimeMover.unfurl(unless_expr, context)
    end
  end

  describe "higher-order function macros" do
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "compose macro creates function composition", %{context: context} do
      # compose(square, inc) applied to 5 should give square(inc(5)) = square(6) = 36
      compose_expr = {:app, 
        {:app, {:ref, "compose"}, {:vec, [{:ref, "square"}, {:ref, "inc"}]}},
        {:vec, [{:lit, 5}]}
      }
      assert {:ok, 36} = PrimeMover.unfurl(compose_expr, context)
    end

    test "partial application", %{context: context} do
      # partial(+, 10) creates add_ten function
      add_ten = {:app, {:ref, "partial"}, {:vec, [{:ref, "+"}, {:lit, 10}]}}
      add_ten_to_32 = {:app, add_ten, {:vec, [{:lit, 32}]}}
      
      assert {:ok, 42} = PrimeMover.unfurl(add_ten_to_32, context)
    end

    test "currying transforms binary function", %{context: context} do
      # curry(+) transforms + into curried form
      curried_add = {:app, {:ref, "curry"}, {:vec, [{:ref, "+"}]}}
      add_10 = {:app, curried_add, {:vec, [{:lit, 10}]}}
      result = {:app, add_10, {:vec, [{:lit, 32}]}}
      
      assert {:ok, 42} = PrimeMover.unfurl(result, context)
    end
  end

  describe "comparison macros" do
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "equality macro", %{context: context} do
      eq_true = {:app, {:ref, "="}, {:vec, [{:lit, 42}, {:lit, 42}]}}
      assert {:ok, true} = PrimeMover.unfurl(eq_true, context)
      
      eq_false = {:app, {:ref, "="}, {:vec, [{:lit, 42}, {:lit, 43}]}}
      assert {:ok, false} = PrimeMover.unfurl(eq_false, context)
    end

    test "inequality macro", %{context: context} do
      ne_true = {:app, {:ref, "!="}, {:vec, [{:lit, 42}, {:lit, 43}]}}
      assert {:ok, true} = PrimeMover.unfurl(ne_true, context)
      
      ne_false = {:app, {:ref, "!="}, {:vec, [{:lit, 42}, {:lit, 42}]}}
      assert {:ok, false} = PrimeMover.unfurl(ne_false, context)
    end

    test "greater than macro", %{context: context} do
      gt_true = {:app, {:ref, ">"}, {:vec, [{:lit, 10}, {:lit, 5}]}}
      assert {:ok, true} = PrimeMover.unfurl(gt_true, context)
      
      gt_false = {:app, {:ref, ">"}, {:vec, [{:lit, 5}, {:lit, 10}]}}
      assert {:ok, false} = PrimeMover.unfurl(gt_false, context)
    end
  end

  describe "macro composition and complex expressions" do
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "chaining multiple macros", %{context: context} do
      # when(>(square(5), 20), inc(10)) 
      # Should compute: when(>(25, 20), 11) = when(true, 11) = 11
      
      complex_expr = {:app, {:ref, "when"}, {:vec, [
        {:app, {:ref, ">"}, {:vec, [
          {:app, {:ref, "square"}, {:vec, [{:lit, 5}]}},
          {:lit, 20}
        ]}},
        {:app, {:ref, "inc"}, {:vec, [{:lit, 10}]}}
      ]}}
      
      assert {:ok, 11} = PrimeMover.unfurl(complex_expr, context)
    end

    test "nested function applications with macros", %{context: context} do
      # compose(inc, square)(6) = inc(square(6)) = inc(36) = 37
      nested_expr = {:app,
        {:app, {:ref, "compose"}, {:vec, [{:ref, "inc"}, {:ref, "square"}]}},
        {:vec, [{:lit, 6}]}
      }
      
      assert {:ok, 37} = PrimeMover.unfurl(nested_expr, context)
    end
  end

  describe "macro examples validation" do
    test "all provided examples are syntactically valid" do
      examples = MacroLibrary.macro_examples()
      
      Enum.each(examples, fn {name, example} ->
        gexpr = Map.get(example, "gexpr")
        assert is_map(gexpr), "Example '#{name}' should have valid gexpr structure"
        assert Map.has_key?(gexpr, "g"), "Example '#{name}' missing 'g' key"
        assert Map.has_key?(gexpr, "v"), "Example '#{name}' missing 'v' key"
      end)
    end
  end

  describe "error handling" do
    setup do
      {:ok, context} = MacroLibrary.create_macro_environment()
      {:ok, context: context}
    end

    test "undefined macro reference produces error", %{context: context} do
      undefined_expr = {:app, {:ref, "nonexistent_macro"}, {:vec, [{:lit, 42}]}}
      assert {:error, "Undefined reference: nonexistent_macro"} = 
        PrimeMover.unfurl(undefined_expr, context)
    end

    test "arity mismatch in macro application", %{context: context} do
      # inc expects 1 argument, give it 2
      arity_error = {:app, {:ref, "inc"}, {:vec, [{:lit, 1}, {:lit, 2}]}}
      assert {:error, "Arity mismatch: expected 1, got 2"} = 
        PrimeMover.unfurl(arity_error, context)
    end
  end
end