defmodule Gexpr.SemanticsTest do
  use ExUnit.Case
  alias Gexpr.{PrimeMover, Semantics}

  doctest Semantics

  describe "formal semantics - Stage 1: Basic unfurling" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "unfurl(lit v, ctx) → v", %{context: context} do
      # Test literal numbers
      assert {:ok, 42} = Semantics.unfurl({:lit, 42}, context)
      assert {:ok, 3.14} = Semantics.unfurl({:lit, 3.14}, context)
      
      # Test literal strings
      assert {:ok, "hello"} = Semantics.unfurl({:lit, "hello"}, context)
      
      # Test literal atoms
      assert {:ok, :atom} = Semantics.unfurl({:lit, :atom}, context)
      
      # Test literal booleans
      assert {:ok, true} = Semantics.unfurl({:lit, true}, context)
      assert {:ok, false} = Semantics.unfurl({:lit, false}, context)
    end

    test "unfurl(ref x, ctx) → unfurl(ctx[x], ctx)", %{context: context} do
      # Test valid reference
      assert {:ok, {:builtin, "id", _}} = Semantics.unfurl({:ref, "id"}, context)
      
      # Test undefined reference
      assert {:error, "Undefined reference: nonexistent"} = 
        Semantics.unfurl({:ref, "nonexistent"}, context)
    end

    test "unfurl(vec elements, ctx) → [unfurl(e, ctx) for e in elements]", %{context: context} do
      # Test empty vector
      assert {:ok, {:list, []}} = Semantics.unfurl({:vec, []}, context)
      
      # Test vector with literals
      vec_expr = {:vec, [{:lit, 1}, {:lit, 2}, {:lit, 3}]}
      assert {:ok, {:list, [1, 2, 3]}} = Semantics.unfurl(vec_expr, context)
      
      # Test vector with mixed types
      mixed_vec = {:vec, [{:lit, 42}, {:lit, "hello"}, {:lit, :atom}]}
      assert {:ok, {:list, [42, "hello", :atom]}} = Semantics.unfurl(mixed_vec, context)
      
      # Test vector with error (undefined reference)
      error_vec = {:vec, [{:lit, 1}, {:ref, "nonexistent"}]}
      assert {:error, "Undefined reference: nonexistent"} = 
        Semantics.unfurl(error_vec, context)
    end
  end

  describe "formal semantics - Stage 2: Lambda calculus" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "unfurl(lam {params, body}, ctx) → Closure(params, body, ctx)", %{context: context} do
      # Test identity function
      id_lambda = {:lam, %{params: ["x"], body: {:ref, "x"}}}
      assert {:ok, {:closure, ["x"], {:ref, "x"}, ^context}} = 
        Semantics.unfurl(id_lambda, context)
      
      # Test constant function
      const_lambda = {:lam, %{params: ["x"], body: {:lit, 42}}}
      assert {:ok, {:closure, ["x"], {:lit, 42}, ^context}} = 
        Semantics.unfurl(const_lambda, context)
    end

    test "apply_function with closures", %{context: context} do
      # Test identity function application
      id_closure = {:closure, ["x"], {:ref, "x"}, context}
      assert {:ok, 42} = Semantics.apply_function(id_closure, 42, context)
      
      # Test function with computation
      add_one_body = {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:lit, 1}]}}
      add_one_closure = {:closure, ["x"], add_one_body, context}
      assert {:ok, 43} = Semantics.apply_function(add_one_closure, 42, context)
      
      # Test arity mismatch
      binary_closure = {:closure, ["x", "y"], {:ref, "x"}, context}
      assert {:error, "Arity mismatch: expected 2, got 1"} = 
        Semantics.apply_function(binary_closure, 42, context)
    end

    test "lambda application through unfurl", %{context: context} do
      # Create lambda and apply it
      id_lambda = {:lam, %{params: ["x"], body: {:ref, "x"}}}
      app_expr = {:app, id_lambda, {:lit, 42}}
      
      assert {:ok, 42} = Semantics.unfurl(app_expr, context)
      
      # Test more complex lambda
      add_lambda = {:lam, %{params: ["x", "y"], body: {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:ref, "y"}]}}}}
      add_app = {:app, add_lambda, {:vec, [{:lit, 10}, {:lit, 20}]}}
      
      assert {:ok, 30} = Semantics.unfurl(add_app, context)
    end
  end

  describe "formal semantics - Stage 3: Fixed point combinator" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "unfurl(fix f, ctx) → unfurl(app(f, fix(f)), ctx)" do
      context = PrimeMover.create_genesis_context()
      
      # Test simple fixed point - factorial
      # fact = fix(λf.λn. if n <= 1 then 1 else n * f(n-1))
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
      
      # Test factorial of 5
      fact_5 = {:app, factorial_fixed, {:vec, [{:lit, 5}]}}
      assert {:ok, 120} = Semantics.unfurl(fact_5, context)
      
      # Test factorial of 0 (base case)
      fact_0 = {:app, factorial_fixed, {:vec, [{:lit, 0}]}}
      assert {:ok, 1} = Semantics.unfurl(fact_0, context)
    end
  end

  describe "formal semantics - Stage 4: Pattern matching" do
    setup do
      context = PrimeMover.create_genesis_context()
      {:ok, context: context}
    end

    test "pattern matching with literals" do
      context = PrimeMover.create_genesis_context()
      
      # Test literal pattern matching
      match_expr = {:match, {:lit, 42}, [
        {:lit_pattern, 41}, {:lit, "not this"},
        {:lit_pattern, 42}, {:lit, "found it"},
        [:else_pattern, {:lit, "default"}]
      ]}
      
      assert {:ok, "found it"} = Semantics.unfurl(match_expr, context)
      
      # Test else pattern
      match_else = {:match, {:lit, 999}, [
        {:lit_pattern, 42}, {:lit, "not this"},
        [:else_pattern, {:lit, "default"}]
      ]}
      
      assert {:ok, "default"} = Semantics.unfurl(match_else, context)
    end

    test "no matching pattern error" do
      context = PrimeMover.create_genesis_context()
      
      # Test no match error
      no_match = {:match, {:lit, 999}, [
        {:lit_pattern, 42}, {:lit, "not this"},
        {:lit_pattern, 43}, {:lit, "also not this"}
      ]}
      
      assert {:error, "No matching pattern for value: 999"} = 
        Semantics.unfurl(no_match, context)
    end
  end

  describe "from_elixir conversion" do
    test "converts basic Elixir data to G-Expressions" do
      assert {:lit, 42} = Semantics.from_elixir(42)
      assert {:lit, "hello"} = Semantics.from_elixir("hello")
      assert {:lit, :atom} = Semantics.from_elixir(:atom)
      assert {:vec, [{:lit, 1}, {:lit, 2}]} = Semantics.from_elixir([1, 2])
    end

    test "converts G-Expression maps" do
      gexpr_map = %{g: "lit", v: 42}
      assert {:lit, 42} = Semantics.from_elixir(gexpr_map)
      
      ref_map = %{g: "ref", v: "x"}
      assert {:ref, "x"} = Semantics.from_elixir(ref_map)
      
      lam_map = %{g: "lam", v: %{params: ["x"], body: %{g: "ref", v: "x"}}}
      assert {:lam, %{params: ["x"], body: {:ref, "x"}}} = Semantics.from_elixir(lam_map)
    end
  end

  describe "integration tests - complete unfurling pipeline" do
    test "end-to-end: AI-style JSON to running code" do
      context = PrimeMover.create_genesis_context()
      
      # Simulate AI-generated G-Expression for add function
      ai_generated = %{
        "g" => "lam",
        "v" => %{
          "params" => ["x", "y"],
          "body" => %{
            "g" => "app",
            "v" => %{
              "fn" => %{"g" => "ref", "v" => "+"},
              "args" => %{
                "g" => "vec", 
                "v" => [
                  %{"g" => "ref", "v" => "x"},
                  %{"g" => "ref", "v" => "y"}
                ]
              }
            }
          }
        }
      }
      
      # Convert to G-Expression and unfurl
      gexpr = Semantics.from_elixir(ai_generated)
      {:ok, add_func} = Semantics.unfurl(gexpr, context)
      
      # Apply the function
      assert {:ok, 42} = Semantics.apply_function(add_func, {:list, [20, 22]}, context)
    end
  end
end