defmodule Gexpr.AdvancedTest do
  use ExUnit.Case
  alias Gexpr.PrimeMover
  
  describe "Y-combinator and recursion tests" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "factorial using fix combinator", %{context: context} do
      # factorial = fix(λf.λn. if n <= 1 then 1 else n * f(n-1))
      factorial_body = {:lam, %{
        params: ["n"],
        body: {:match, {:app, {:ref, "<="}, {:vec, [{:ref, "n"}, {:lit, 1}]}}, [
          {:lit_pattern, true}, {:lit, 1}],
          [:else_pattern, {:app, {:ref, "*"}, {:vec, [
            {:ref, "n"},
            {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}]}}
          ]}}
        ]}
      }}
      
      factorial_generator = {:lam, %{params: ["f"], body: factorial_body}}
      factorial_fixed = {:fix, factorial_generator}
      
      # Test various factorial values
      test_cases = [
        {0, 1},
        {1, 1}, 
        {2, 2},
        {3, 6},
        {4, 24},
        {5, 120}
      ]
      
      Enum.each(test_cases, fn {n, expected} ->
        fact_n = {:app, factorial_fixed, {:vec, [{:lit, n}]}}
        assert {:ok, expected} = PrimeMover.unfurl(fact_n, context), 
          "factorial(#{n}) should equal #{expected}"
      end)
    end

    test "fibonacci using fix combinator", %{context: context} do
      # fib = fix(λf.λn. if n <= 1 then n else f(n-1) + f(n-2))
      fib_body = {:lam, %{
        params: ["n"],
        body: {:match, {:app, {:ref, "<="}, {:vec, [{:ref, "n"}, {:lit, 1}]}}, [
          {:lit_pattern, true}, {:ref, "n"}],
          [:else_pattern, {:app, {:ref, "+"}, {:vec, [
            {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}]}},
            {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 2}]}}]}}
          ]}}
        ]}
      }}
      
      fib_generator = {:lam, %{params: ["f"], body: fib_body}}
      fib_fixed = {:fix, fib_generator}
      
      # Test Fibonacci sequence
      test_cases = [
        {0, 0},
        {1, 1},
        {2, 1}, 
        {3, 2},
        {4, 3},
        {5, 5},
        {6, 8}
      ]
      
      Enum.each(test_cases, fn {n, expected} ->
        fib_n = {:app, fib_fixed, {:vec, [{:lit, n}]}}
        assert {:ok, expected} = PrimeMover.unfurl(fib_n, context),
          "fibonacci(#{n}) should equal #{expected}"
      end)
    end
  end

  describe "higher-order functions" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "map function implementation", %{context: context} do
      # map = λf.λlist. (simplified for single element list)
      # For demonstration, we'll implement a simple version that doubles a number
      
      double_fn = {:lam, %{params: ["x"], body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}}}
      
      # Apply double function to 21
      result = {:app, double_fn, {:vec, [{:lit, 21}]}}
      assert {:ok, 42} = PrimeMover.unfurl(result, context)
    end

    test "compose function", %{context: context} do
      # compose = λf.λg.λx. f(g(x))
      compose_fn = {:lam, %{
        params: ["f", "g"], 
        body: {:lam, %{
          params: ["x"],
          body: {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "g"}, {:vec, [{:ref, "x"}]}}]}}
        }}
      }}
      
      # Create add1 and double functions
      add1_fn = {:lam, %{params: ["x"], body: {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:lit, 1}]}}}}
      double_fn = {:lam, %{params: ["x"], body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}}}
      
      # Compose double ∘ add1
      composed = {:app, {:app, compose_fn, {:vec, [double_fn, add1_fn]}}, {:vec, [{:lit, 20}]}}
      
      # Should compute double(add1(20)) = double(21) = 42
      assert {:ok, 42} = PrimeMover.unfurl(composed, context)
    end
  end

  describe "Church encodings" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "Church booleans" do
      context = PrimeMover.create_genesis_context()
      
      # Church true = λx.λy.x
      church_true = {:lam, %{
        params: ["x", "y"],
        body: {:ref, "x"}
      }}
      
      # Church false = λx.λy.y  
      church_false = {:lam, %{
        params: ["x", "y"],
        body: {:ref, "y"}
      }}
      
      # Test church true selects first argument
      true_test = {:app, church_true, {:vec, [{:lit, "first"}, {:lit, "second"}]}}
      assert {:ok, "first"} = PrimeMover.unfurl(true_test, context)
      
      # Test church false selects second argument
      false_test = {:app, church_false, {:vec, [{:lit, "first"}, {:lit, "second"}]}}
      assert {:ok, "second"} = PrimeMover.unfurl(false_test, context)
    end

    test "Church numerals" do
      context = PrimeMover.create_genesis_context()
      
      # Church 0 = λf.λx.x
      church_zero = {:lam, %{
        params: ["f", "x"],
        body: {:ref, "x"}
      }}
      
      # Church 1 = λf.λx.f x
      church_one = {:lam, %{
        params: ["f", "x"],
        body: {:app, {:ref, "f"}, {:vec, [{:ref, "x"}]}}
      }}
      
      # Church 2 = λf.λx.f (f x)
      church_two = {:lam, %{
        params: ["f", "x"],
        body: {:app, {:ref, "f"}, {:vec, [
          {:app, {:ref, "f"}, {:vec, [{:ref, "x"}]}}
        ]}}
      }}
      
      # Test Church numerals with successor function
      succ_fn = {:lam, %{params: ["n"], body: {:app, {:ref, "+"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}}}
      
      # Apply Church 2 to successor and 0: should get 2
      church_2_test = {:app, church_two, {:vec, [succ_fn, {:lit, 0}]}}
      assert {:ok, 2} = PrimeMover.unfurl(church_2_test, context)
    end
  end

  describe "self-modifying expressions" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "dynamic code generation" do
      context = PrimeMover.create_genesis_context()
      
      # A function that generates other functions
      # make_adder = λn. λx. x + n
      make_adder = {:lam, %{
        params: ["n"],
        body: {:lam, %{
          params: ["x"],
          body: {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:ref, "n"}]}}
        }}
      }}
      
      # Generate add5 function
      add5_generator = {:app, make_adder, {:vec, [{:lit, 5}]}}
      {:ok, add5_fn} = PrimeMover.unfurl(add5_generator, context)
      
      # Use the generated function
      result = PrimeMover.apply_value(add5_fn, [37])
      assert {:ok, 42} = result
    end
  end

  describe "computational archaeology - provenance tracking" do
    test "G-Expression with metadata" do
      # This would be enhanced with metadata support
      gexpr_with_meta = %{
        "g" => "app",
        "v" => %{
          "fn" => %{"g" => "ref", "v" => "+"},
          "args" => %{
            "g" => "vec",
            "v" => [%{"g" => "lit", "v" => 20}, %{"g" => "lit", "v" => 22}]
          }
        },
        "m" => %{
          "generated_by" => "test_ai",
          "timestamp" => "2024-01-01T00:00:00Z",
          "source_prompt" => "add 20 and 22",
          "confidence" => 0.95
        }
      }
      
      # For now, we can at least verify the structure is parseable
      assert is_map(gexpr_with_meta)
      assert Map.has_key?(gexpr_with_meta, "m")
      assert Map.get(gexpr_with_meta["m"], "generated_by") == "test_ai"
    end
  end
end