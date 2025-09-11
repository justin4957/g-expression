#!/usr/bin/env elixir

# Demo script showing G-Expression system functionality
# Run with: elixir demo.exs

defmodule GexprDemo do
  def run do
    IO.puts """
    
    🚀 G-Expression System Demo
    ===========================
    
    This demo shows the key capabilities of the G-Expression system.
    """

    demo_basic_evaluation()
    demo_lambda_calculus() 
    demo_recursion()
    demo_macro_system()
    demo_ai_integration()
    demo_provenance()

    IO.puts """
    
    ✅ Demo Complete!
    
    Next steps:
    - Run `iex -S mix` for interactive exploration
    - Check `guides/getting_started.md` for detailed tutorial
    - Run `mix test` to see all tests pass
    - Run `mix docs` to generate full documentation
    
    """
  end

  defp demo_basic_evaluation do
    IO.puts "\n📝 1. Basic G-Expression Evaluation"
    IO.puts "   ================================"

    {:ok, context} = Gexpr.bootstrap()

    # Literals
    {:ok, result} = Gexpr.eval({:lit, 42}, context)
    IO.puts "   {:lit, 42} → #{result}"

    # Arithmetic
    add_expr = {:app, {:ref, "+"}, {:vec, [{:lit, 20}, {:lit, 22}]}}
    {:ok, result} = Gexpr.eval(add_expr, context)
    IO.puts "   add(20, 22) → #{result}"

    # Function application
    {:ok, result} = Gexpr.eval({:app, {:ref, "id"}, {:lit, "hello"}}, context)
    IO.puts "   id(\"hello\") → \"#{result}\""
  end

  defp demo_lambda_calculus do
    IO.puts "\n🧮 2. Lambda Calculus"
    IO.puts "   =================="

    {:ok, context} = Gexpr.bootstrap()

    # Create and apply lambda
    double_lambda = {:lam, %{
      params: ["x"],
      body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}
    }}

    app_expr = {:app, double_lambda, {:vec, [{:lit, 21}]}}
    {:ok, result} = Gexpr.eval(app_expr, context)
    IO.puts "   (λx. x * 2)(21) → #{result}"

    # Curried function
    curried_add = {:lam, %{
      params: ["x"],
      body: {:lam, %{params: ["y"], body: {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:ref, "y"}]}}}}
    }}

    add_10 = {:app, curried_add, {:vec, [{:lit, 10}]}}
    final_result = {:app, add_10, {:vec, [{:lit, 32}]}}
    {:ok, result} = Gexpr.eval(final_result, context)
    IO.puts "   ((λx.λy. x + y) 10) 32 → #{result}"
  end

  defp demo_recursion do
    IO.puts "\n🔄 3. Y-Combinator (Recursion)"
    IO.puts "   ============================="

    {:ok, context} = Gexpr.bootstrap()

    # Simple factorial test (just for n=3 to avoid timeout)
    factorial_body = {:lam, %{
      params: ["n"],
      body: {:match, {:app, {:ref, "<="}, {:vec, [{:ref, "n"}, {:lit, 1}]}}, [
        {{:lit_pattern, true}, {:lit, 1}},
        {:else_pattern, {:app, {:ref, "*"}, {:vec, [
          {:ref, "n"},
          {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}]}}
        ]}}}
      ]}
    }}

    factorial_gen = {:lam, %{params: ["f"], body: factorial_body}}
    factorial = {:fix, factorial_gen}

    fact_3 = {:app, factorial, {:vec, [{:lit, 3}]}}
    {:ok, result} = Gexpr.eval(fact_3, context)
    IO.puts "   factorial(3) via Y-combinator → #{result}"
  end

  defp demo_macro_system do
    IO.puts "\n🔧 4. Pure G-Expression Macros"
    IO.puts "   ============================="

    {:ok, macro_context} = Gexpr.bootstrap_with_macros()

    # Test increment macro
    {:ok, result} = Gexpr.eval({:app, {:ref, "inc"}, {:vec, [{:lit, 41}]}}, macro_context)
    IO.puts "   inc(41) → #{result}"

    # Test function composition
    compose_expr = {:app,
      {:app, {:ref, "compose"}, {:vec, [{:ref, "square"}, {:ref, "inc"}]}},
      {:vec, [{:lit, 5}]}
    }
    {:ok, result} = Gexpr.eval(compose_expr, macro_context)
    IO.puts "   compose(square, inc)(5) → #{result}"

    # Test conditional macro
    when_expr = {:app, {:ref, "when"}, {:vec, [{:lit, true}, {:lit, "condition true!"}]}}
    {:ok, result} = Gexpr.eval(when_expr, macro_context)
    IO.puts "   when(true, \"condition true!\") → \"#{result}\""
  end

  defp demo_ai_integration do
    IO.puts "\n🤖 5. AI Code Generation"
    IO.puts "   ======================"

    case Gexpr.generate_from_ai_prompt("add 20 and 22") do
      {:ok, ai_result} ->
        IO.puts "   Prompt: \"add 20 and 22\""
        IO.puts "   Generated: #{ai_result["g"]} expression"
        IO.puts "   Confidence: #{ai_result["m"]["confidence"]}"
        
        case Gexpr.to_ai_json(ai_result) do
          {:ok, json} ->
            json_preview = String.slice(json, 0, 60) <> "..."
            IO.puts "   JSON: #{json_preview}"
          _ ->
            IO.puts "   JSON generation failed"
        end

      {:error, reason} ->
        IO.puts "   Generation failed: #{reason}"
    end

    # Show training examples
    examples = Gexpr.ai_training_examples()
    IO.puts "   Training examples available: #{length(examples)}"
  end

  defp demo_provenance do
    IO.puts "\n📊 6. Computational Archaeology"
    IO.puts "   ==============================="

    # Create G-Expression with metadata
    gexpr = %{"g" => "lit", "v" => 42}
    
    with_metadata = Gexpr.add_ai_metadata(
      gexpr,
      "demo-ai-v1.0",
      "the answer to everything",
      0.99
    )

    enhanced = Gexpr.Metadata.add_performance_data(with_metadata, 1500, 2048)
    
    approved = Gexpr.Metadata.approve(
      enhanced,
      "demo-reviewer",
      "Approved for demonstration"
    )

    # Generate reports
    audit = Gexpr.Metadata.create_audit_trail(approved)
    IO.puts "   Generated audit trail with #{map_size(audit)} fields"
    IO.puts "   Security score: #{audit["security_score"]}"
    IO.puts "   Compliance: #{audit["compliance_status"]}"
    
    report_lines = Gexpr.provenance_report(approved) |> String.split("\n")
    IO.puts "   Provenance report: #{length(report_lines)} lines"
  end
end

# Run the demo
GexprDemo.run()