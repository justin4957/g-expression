# Advanced G-Expression Examples

This guide showcases advanced uses of the G-Expression system, demonstrating its power for AI-native computing, self-modification, and computational archaeology.

## Table of Contents

1. [Recursive Algorithms](#recursive-algorithms)
2. [Higher-Order Functions](#higher-order-functions)
3. [AI Code Generation Pipeline](#ai-code-generation-pipeline)
4. [Self-Modifying Programs](#self-modifying-programs)
5. [Computational Archaeology](#computational-archaeology)
6. [Church Encodings](#church-encodings)
7. [Custom Macro Development](#custom-macro-development)
8. [Performance Optimization](#performance-optimization)

## Recursive Algorithms

**🧠 PHILOSOPHICAL SIGNIFICANCE:** These examples demonstrate how infinite recursive definitions become finite through the Y-combinator, solving the fundamental paradox of self-reference in computation.

### Fibonacci with Y-Combinator

**🧠 COMPUTATIONAL ARCHAEOLOGY:** This shows the mathematical DNA of recursion - how infinite sequences emerge from finite descriptions through fixed-point theory.

```elixir
{:ok, context} = Gexpr.bootstrap()

# fib = fix(λf.λn. if n <= 1 then n else f(n-1) + f(n-2))
# MATHEMATICAL BEAUTY: Infinite recursion from finite definition
fib_body = {:lam, %{
  params: ["n"],
  body: {:match, {:app, {:ref, "<="}, {:vec, [{:ref, "n"}, {:lit, 1}]}}, [
    {{:lit_pattern, true}, {:ref, "n"}},
    {:else_pattern, {:app, {:ref, "+"}, {:vec, [
      {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}]}},
      {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 2}]}}]}}
    ]}}}
  ]}
}}

fib_generator = {:lam, %{params: ["f"], body: fib_body}}
fibonacci = {:fix, fib_generator}  # FIXED-POINT MAGIC: Y-combinator solution

# Test fibonacci sequence - EMERGENT MATHEMATICS
for n <- 0..6 do
  fib_n = {:app, fibonacci, {:vec, [{:lit, n}]}}
  {:ok, result} = Gexpr.eval(fib_n, context)
  IO.puts("fib(#{n}) = #{result}")
end
# fib(0) = 0
# fib(1) = 1
# fib(2) = 1
# fib(3) = 2
# fib(4) = 3
# fib(5) = 5
# fib(6) = 8
```

### List Processing with Recursion

**🧠 STRUCTURAL RECURSION:** This demonstrates how data structure traversal becomes computation - the shape of data determines the shape of the algorithm, showing the deep connection between form and function.

```elixir
# sum_list = fix(λf.λlist. if empty?(list) then 0 else car(list) + f(cdr(list)))
# STRUCTURAL INDUCTION: Algorithm follows data structure
sum_list_body = {:lam, %{
  params: ["list"],
  body: {:match, {:app, {:ref, "eq?"}, {:vec, [{:ref, "list"}, {:lit, {:list, []}}]}}, [
    {{:lit_pattern, true}, {:lit, 0}},  # BASE CASE: Empty structure
    {:else_pattern, {:app, {:ref, "+"}, {:vec, [
      {:app, {:ref, "car"}, {:vec, [{:ref, "list"}]}},  # DECONSTRUCTION
      {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "cdr"}, {:vec, [{:ref, "list"}]}}]}}  # RECURSION
    ]}}}
  ]}
}}

sum_generator = {:lam, %{params: ["f"], body: sum_list_body}}
sum_list = {:fix, sum_generator}  # MATHEMATICAL INDUCTION AS COMPUTATION

# Test with a list [1, 2, 3, 4, 5] - DATA DRIVES COMPUTATION
test_list = {:list, [1, 2, 3, 4, 5]}
sum_expr = {:app, sum_list, {:vec, [test_list]}}
{:ok, result} = Gexpr.eval(sum_expr, context)
IO.puts("Sum of [1,2,3,4,5] = #{result}")  # 15
```

## Higher-Order Functions

**🧠 PHILOSOPHICAL SIGNIFICANCE:** Higher-order functions prove that functions are first-class mathematical objects - demonstrating the unity between data and computation that enables self-modifying and self-reasoning systems.

### Function Composition Chain

**🧠 COMPOSITIONAL REASONING:** This shows how complex transformations emerge from simple function composition - the mathematical foundation of modular programming and separation of concerns.

```elixir
{:ok, macro_context} = Gexpr.bootstrap_with_macros()

# Create a chain: compose(inc, compose(square, inc))
# This computes: inc(square(inc(x))) - COMPOSITIONAL SEMANTICS
compose_chain = {:app, {:ref, "compose"}, {:vec, [
  {:ref, "inc"},  # OUTER TRANSFORMATION
  {:app, {:ref, "compose"}, {:vec, [{:ref, "square"}, {:ref, "inc"}]}}  # INNER PIPELINE
]}}

# Apply to 5: inc(square(inc(5))) = inc(square(6)) = inc(36) = 37
# TRANSFORMATION CHAIN: 5 → 6 → 36 → 37
chain_expr = {:app, compose_chain, {:vec, [{:lit, 5}]}}
{:ok, result} = Gexpr.eval(chain_expr, macro_context)
IO.puts("inc(square(inc(5))) = #{result}")  # 37
```

### Currying and Partial Application

```elixir
# Create curried multiply function
multiply = {:lam, %{
  params: ["x", "y"],
  body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:ref, "y"}]}}
}}

curried_multiply = {:app, {:ref, "curry"}, {:vec, [multiply]}}

# Create multiply_by_3 function
multiply_by_3 = {:app, curried_multiply, {:vec, [{:lit, 3}]}}

# Use it: multiply_by_3(14) = 42
result_expr = {:app, multiply_by_3, {:vec, [{:lit, 14}]}}
{:ok, result} = Gexpr.eval(result_expr, macro_context)
IO.puts("multiply_by_3(14) = #{result}")  # 42
```

### Higher-Order Map Function

```elixir
# map_simple = λf.λlist. if empty?(list) then [] else cons(f(car(list)), map(f, cdr(list)))
map_body = {:lam, %{
  params: ["list"],
  body: {:match, {:app, {:ref, "eq?"}, {:vec, [{:ref, "list"}, {:lit, {:list, []}}]}}, [
    {{:lit_pattern, true}, {:lit, {:list, []}}},
    {:else_pattern, {:app, {:ref, "cons"}, {:vec, [
      {:app, {:ref, "f_param"}, {:vec, [{:app, {:ref, "car"}, {:vec, [{:ref, "list"}]}}]}},
      {:app, {:ref, "map_f"}, {:vec, [{:app, {:ref, "cdr"}, {:vec, [{:ref, "list"}]}}]}}
    ]}}}
  ]}
}}

map_generator = {:lam, %{
  params: ["map_f"],
  body: {:lam, %{params: ["f_param"], body: map_body}}
}}

map_func = {:fix, map_generator}

# Test: map(square, [1, 2, 3]) = [1, 4, 9]
test_list = {:list, [1, 2, 3]}
map_expr = {:app, {:app, map_func, {:vec, [{:ref, "square"}]}}, {:vec, [test_list]}}
{:ok, result} = Gexpr.eval(map_expr, macro_context)
IO.inspect(result)  # {:list, [1, 4, 9]}
```

## AI Code Generation Pipeline

### Complete AI → G-Expression → Execution Pipeline

```elixir
# Step 1: AI generates G-Expression from prompt
{:ok, ai_gexpr} = Gexpr.generate_from_ai_prompt("create a function that doubles a number")

# Step 2: Convert to JSON (simulate sending to AI service)
{:ok, json_payload} = Gexpr.to_ai_json(ai_gexpr)
IO.puts("JSON payload for AI:")
IO.puts(json_payload)

# Step 3: Parse response from AI service
{:ok, parsed_gexpr} = Gexpr.parse_ai_json(json_payload)

# Step 4: Add additional metadata
enhanced_gexpr = Gexpr.Metadata.add_performance_data(
  parsed_gexpr, 
  1500,    # execution time microseconds
  2048     # memory bytes
)

# Step 5: Execute with provenance tracking
{:ok, context} = Gexpr.bootstrap()
internal_gexpr = convert_ai_format_to_internal(parsed_gexpr)
{:ok, double_func} = Gexpr.eval(internal_gexpr, context)

# Step 6: Test the generated function
{:ok, result} = Gexpr.PrimeMover.apply_value(double_func, [21])
IO.puts("AI-generated double function: double(21) = #{result}")  # 42

# Step 7: Generate audit report
audit_report = Gexpr.Metadata.create_audit_trail(enhanced_gexpr)
IO.inspect(audit_report, pretty: true)
```

### Batch AI Code Generation

```elixir
prompts = [
  "add two numbers",
  "multiply by 3", 
  "check if number is even",
  "create increment function"
]

ai_results = Enum.map(prompts, fn prompt ->
  case Gexpr.generate_from_ai_prompt(prompt) do
    {:ok, gexpr} -> 
      %{prompt: prompt, gexpr: gexpr, status: :success}
    {:error, reason} -> 
      %{prompt: prompt, error: reason, status: :failed}
  end
end)

# Analyze generation success rate
success_count = Enum.count(ai_results, & &1.status == :success)
total = length(ai_results)
IO.puts("AI Generation Success Rate: #{success_count}/#{total} (#{trunc(success_count/total * 100)}%)")
```

## Self-Modifying Programs

### Dynamic Function Generation

```elixir
{:ok, macro_context} = Gexpr.bootstrap_with_macros()

# meta_function_creator creates functions that create functions
meta_creator = {:lam, %{
  params: ["operation"],
  body: {:lam, %{
    params: ["n"],
    body: {:lam, %{
      params: ["x"],
      body: {:app, {:ref, "operation"}, {:vec, [{:ref, "x"}, {:ref, "n"}]}}
    }}
  }}
}}

# Create an "add_n" generator
add_n_generator = {:app, meta_creator, {:vec, [{:ref, "+"}]}}

# Generate add_5 function
add_5_creator = {:app, add_n_generator, {:vec, [{:lit, 5}]}}
{:ok, add_5_func} = Gexpr.eval(add_5_creator, macro_context)

# Use the dynamically created function
{:ok, result} = Gexpr.PrimeMover.apply_value(add_5_func, [37])
IO.puts("Dynamically created add_5(37) = #{result}")  # 42
```

### Self-Optimizing Code

```elixir
# Function that optimizes itself based on usage patterns
optimizing_function = {:lam, %{
  params: ["usage_count", "current_impl"],
  body: {:match, {:app, {:ref, ">"}, {:vec, [{:ref, "usage_count"}, {:lit, 100}]}}, [
    {{:lit_pattern, true}, {:lit, "optimized_version"}},
    {:else_pattern, {:ref, "current_impl"}}
  ]}
}}

# Simulate usage tracking
usage_simulator = {:lam, %{
  params: ["count"],
  body: {:app, optimizing_function, {:vec, [{:ref, "count"}, {:lit, "basic_version"}]}}
}}

# Test optimization trigger
low_usage = {:app, usage_simulator, {:vec, [{:lit, 50}]}}
{:ok, result1} = Gexpr.eval(low_usage, macro_context)
IO.puts("Low usage result: #{result1}")  # "basic_version"

high_usage = {:app, usage_simulator, {:vec, [{:lit, 150}]}}
{:ok, result2} = Gexpr.eval(high_usage, macro_context)  
IO.puts("High usage result: #{result2}")  # "optimized_version"
```

### Code Evolution Simulator

```elixir
# Simulate genetic programming on G-Expressions
mutation_function = {:lam, %{
  params: ["original_func", "mutation_type"],
  body: {:match, {:ref, "mutation_type"}, [
    {{:lit_pattern, "optimize"}, {:app, {:ref, "compose"}, {:vec, [{:ref, "inc"}, {:ref, "original_func"}]}}},
    {{:lit_pattern, "simplify"}, {:ref, "original_func"}},
    {:else_pattern, {:ref, "original_func"}}
  ]}
}}

# Original function: square
original = {:ref, "square"}

# Mutate it
mutated = {:app, mutation_function, {:vec, [original, {:lit, "optimize"}]}}

# Test both versions
original_test = {:app, original, {:vec, [{:lit, 6}]}}
{:ok, orig_result} = Gexpr.eval(original_test, macro_context)
IO.puts("Original square(6) = #{orig_result}")  # 36

mutated_test = {:app, mutated, {:vec, [{:lit, 6}]}}
{:ok, mut_result} = Gexpr.eval(mutated_test, macro_context)
IO.puts("Mutated function(6) = #{mut_result}")  # 37 (inc(square(6)))
```

## Computational Archaeology

### Full Provenance Tracking

```elixir
# Create a G-Expression with full provenance
original_gexpr = %{
  "g" => "lam",
  "v" => %{
    "params" => ["x"],
    "body" => %{
      "g" => "app",
      "v" => %{
        "fn" => %{"g" => "ref", "v" => "*"},
        "args" => %{
          "g" => "vec",
          "v" => [
            %{"g" => "ref", "v" => "x"},
            %{"g" => "lit", "v" => 2}
          ]
        }
      }
    }
  }
}

# Add AI provenance
with_ai_meta = Gexpr.add_ai_metadata(
  original_gexpr,
  "gpt-4-turbo",
  "create a doubling function",
  0.92
)

# Add performance data
with_perf_meta = Gexpr.Metadata.add_performance_data(
  with_ai_meta,
  1200,  # execution time μs
  1536   # memory bytes
)

# Add approval
approved_gexpr = Gexpr.Metadata.approve(
  with_perf_meta,
  "senior_engineer@company.com",
  "Reviewed and approved for production use"
)

# Create mutation with full ancestry
optimized_version = Gexpr.Metadata.mutate(
  approved_gexpr,
  :optimization,
  %{
    "g" => "lam",
    "v" => %{
      "params" => ["x"],
      "body" => %{
        "g" => "app", 
        "v" => %{
          "fn" => %{"g" => "ref", "v" => "<<"},
          "args" => %{
            "g" => "vec",
            "v" => [
              %{"g" => "ref", "v" => "x"},
              %{"g" => "lit", "v" => 1}
            ]
          }
        }
      }
    }
  }
)

# Generate comprehensive audit trail
audit_trail = Gexpr.Metadata.create_audit_trail(optimized_version)
IO.puts("=== COMPUTATIONAL ARCHAEOLOGY REPORT ===")
IO.puts(Gexpr.provenance_report(optimized_version))
IO.puts("\n=== AUDIT TRAIL ===")
IO.inspect(audit_trail, pretty: true)
```

### Query-Based Code Analysis

```elixir
# Create a database of G-Expressions with metadata
code_database = [
  Gexpr.add_ai_metadata(%{"g" => "lit", "v" => 42}, "gpt-3", "answer", 0.8),
  Gexpr.add_ai_metadata(%{"g" => "app", "v" => "add"}, "claude", "math", 0.9),
  Gexpr.add_ai_metadata(%{"g" => "lam", "v" => "func"}, "gpt-4", "lambda", 0.95)
]

# Query by AI model
gpt4_code = Gexpr.Metadata.query_by_metadata(
  code_database, 
  %{"generated_by" => "gpt-4"}
)

IO.puts("Code generated by GPT-4: #{length(gpt4_code)} items")

# Query by confidence threshold
high_confidence = Enum.filter(code_database, fn gexpr ->
  meta = Gexpr.Metadata.extract_metadata(gexpr)
  meta && Map.get(meta, "confidence", 0) > 0.85
end)

IO.puts("High confidence code: #{length(high_confidence)} items")
```

## Church Encodings

### Church Numerals

```elixir
{:ok, context} = Gexpr.bootstrap()

# Church numeral generators
church_zero = {:lam, %{params: ["f", "x"], body: {:ref, "x"}}}
church_one = {:lam, %{params: ["f", "x"], body: {:app, {:ref, "f"}, {:vec, [{:ref, "x"}]}}}}
church_two = {:lam, %{params: ["f", "x"], body: {:app, {:ref, "f"}, {:vec, [
  {:app, {:ref, "f"}, {:vec, [{:ref, "x"}]}}
]}}}}

# Church successor function
church_succ = {:lam, %{
  params: ["n"],
  body: {:lam, %{
    params: ["f", "x"],
    body: {:app, {:ref, "f"}, {:vec, [
      {:app, {:app, {:ref, "n"}, {:vec, [{:ref, "f"}, {:ref, "x"}]}}, {:vec, []}]
    ]}}
  }}
}}

# Test Church numerals with increment function
inc_fn = {:lam, %{params: ["n"], body: {:app, {:ref, "+"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}}}

# church_two applied to inc and 0 should give 2
church_test = {:app, church_two, {:vec, [inc_fn, {:lit, 0}]}}
{:ok, result} = Gexpr.eval(church_test, context)
IO.puts("Church numeral two applied to inc and 0: #{result}")  # 2
```

### Church Booleans and Logic

```elixir
# Church encodings for booleans
church_true = {:lam, %{params: ["x", "y"], body: {:ref, "x"}}}
church_false = {:lam, %{params: ["x", "y"], body: {:ref, "y"}}}

# Church AND operation
church_and = {:lam, %{
  params: ["p", "q"],
  body: {:app, {:ref, "p"}, {:vec, [{:ref, "q"}, church_false]}}
}}

# Church OR operation  
church_or = {:lam, %{
  params: ["p", "q"],
  body: {:app, {:ref, "p"}, {:vec, [church_true, {:ref, "q"}]}}
}}

# Church NOT operation
church_not = {:lam, %{
  params: ["p"],
  body: {:app, {:ref, "p"}, {:vec, [church_false, church_true]}}
}}

# Test: NOT(TRUE) should be FALSE
not_true = {:app, church_not, {:vec, [church_true]}}
# Apply to two test values to see which one it selects
test_not = {:app, not_true, {:vec, [{:lit, "first"}, {:lit, "second"}]}}
{:ok, result} = Gexpr.eval(test_not, context)
IO.puts("NOT(TRUE) selects: #{result}")  # "second" (indicating FALSE)
```

## Custom Macro Development

### Creating Domain-Specific Macros

```elixir
# Define a "repeat" macro that executes an expression N times
repeat_macro = {:lam, %{
  params: ["n", "expr"],
  body: {:match, {:app, {:ref, "<="}, {:vec, [{:ref, "n"}, {:lit, 0}]}}, [
    {{:lit_pattern, true}, {:lit, nil}},
    {:else_pattern, {:app, {:ref, "cons"}, {:vec, [
      {:ref, "expr"},
      {:app, {:ref, "repeat"}, {:vec, [
        {:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 1}]}},
        {:ref, "expr"}
      ]}}
    ]}}}
  ]}
}}

# Add to macro context
extended_context = Map.put(macro_context, "repeat", {:ok, repeat_func} = Gexpr.eval(repeat_macro, macro_context))

# Use the repeat macro
repeat_expr = {:app, {:ref, "repeat"}, {:vec, [{:lit, 3}, {:lit, "hello"}]}}
{:ok, result} = Gexpr.eval(repeat_expr, extended_context)
IO.inspect(result)  # Should create a list with "hello" repeated 3 times
```

### Macro Composition

```elixir
# Create a macro that combines other macros
combined_macro = {:lam, %{
  params: ["x"],
  body: {:app, {:ref, "when"}, {:vec, [
    {:app, {:ref, ">"}, {:vec, [{:ref, "x"}, {:lit, 0}]}},
    {:app, {:ref, "inc"}, {:vec, [
      {:app, {:ref, "square"}, {:vec, [{:ref, "x"}]}}
    ]}}
  ]}}
}}

# Test: when(x > 0, inc(square(x)))
combined_test = {:app, combined_macro, {:vec, [{:lit, 5}]}}
{:ok, result} = Gexpr.eval(combined_test, macro_context)
IO.puts("Combined macro result: #{result}")  # inc(square(5)) = inc(25) = 26
```

## Performance Optimization

### Benchmarking G-Expression Evaluation

```elixir
# Benchmark different evaluation strategies
{:ok, context} = Gexpr.bootstrap()

# Simple arithmetic
simple_expr = {:app, {:ref, "+"}, {:vec, [{:lit, 1000}, {:lit, 2000}]}}

# Complex nested expression
complex_expr = {:app, {:ref, "*"}, {:vec, [
  {:app, {:ref, "+"}, {:vec, [{:lit, 10}, {:lit, 20}]}},
  {:app, {:ref, "-"}, {:vec, [{:lit, 100}, {:lit, 50}]}}
]}}

# Benchmark simple expression
{time_simple, {:ok, result_simple}} = :timer.tc(fn ->
  Gexpr.eval(simple_expr, context)
end)

IO.puts("Simple expression: #{result_simple} (#{time_simple}μs)")

# Benchmark complex expression
{time_complex, {:ok, result_complex}} = :timer.tc(fn ->
  Gexpr.eval(complex_expr, context)
end)

IO.puts("Complex expression: #{result_complex} (#{time_complex}μs)")

# Benchmark with macro context
{:ok, macro_context} = Gexpr.bootstrap_with_macros()
macro_expr = {:app, {:ref, "compose"}, {:vec, [{:ref, "inc"}, {:ref, "square"}]}}

{time_macro, {:ok, _result_macro}} = :timer.tc(fn ->
  Gexpr.eval(macro_expr, macro_context)
end)

IO.puts("Macro evaluation: (#{time_macro}μs)")
```

### Memory Usage Analysis

```elixir
# Analyze memory usage of different G-Expression patterns
defmodule MemoryProfiler do
  def profile_memory(label, fun) do
    :erlang.garbage_collect()
    mem_before = :erlang.memory(:total)
    
    result = fun.()
    
    :erlang.garbage_collect()
    mem_after = :erlang.memory(:total)
    
    IO.puts("#{label}: #{mem_after - mem_before} bytes")
    result
  end
end

# Profile different expression types
{:ok, context} = Gexpr.bootstrap()

MemoryProfiler.profile_memory("Literal evaluation", fn ->
  Gexpr.eval({:lit, 42}, context)
end)

MemoryProfiler.profile_memory("Simple function call", fn ->
  Gexpr.eval({:app, {:ref, "id"}, {:lit, 42}}, context)
end)

MemoryProfiler.profile_memory("Lambda creation", fn ->
  Gexpr.eval({:lam, %{params: ["x"], body: {:ref, "x"}}}, context)
end)

MemoryProfiler.profile_memory("Complex computation", fn ->
  factorial_expr = create_factorial_expression()  # From earlier example
  Gexpr.eval({:app, factorial_expr, {:vec, [{:lit, 5}]}}, context)
end)
```

## Conclusion

These advanced examples demonstrate the full power of the G-Expression system:

- **Recursive algorithms** showing computational completeness
- **Higher-order functions** enabling powerful abstractions
- **AI integration** for natural language code generation  
- **Self-modification** allowing programs to evolve themselves
- **Computational archaeology** providing complete provenance tracking
- **Church encodings** proving theoretical foundations
- **Custom macros** extending the language
- **Performance optimization** for production use

The G-Expression system provides a unique computational substrate that bridges theoretical computer science, practical software engineering, and AI-native programming paradigms.