# G-Expression to JavaScript Compiler

This guide demonstrates the **killer feature** that proves G-Expressions work as a universal computational substrate: compiling G-Expressions to JavaScript and executing them with Node.js.

## Overview

The JavaScript compiler transforms G-Expressions into executable JavaScript code, proving that G-Expressions can serve as an intermediate representation (IR) for any target language. This closes the loop between theoretical elegance and practical utility.

## Table of Contents

1. [Basic Compilation](#basic-compilation)
2. [Lambda Functions](#lambda-functions)
3. [Arithmetic and Logic](#arithmetic-and-logic)
4. [Complex Expressions](#complex-expressions)
5. [End-to-End Pipeline](#end-to-end-pipeline)
6. [The Killer Test](#the-killer-test)
7. [Practical Applications](#practical-applications)
8. [Extending to Other Languages](#extending-to-other-languages)

## Basic Compilation

Start by testing the basic compilation functionality:

```elixir
# Start an IEx session
iex -S mix

# Compile simple literals
{:ok, js} = Gexpr.compile_to_js({:lit, 42})
IO.puts(js)  # "42"

{:ok, js} = Gexpr.compile_to_js({:lit, true})
IO.puts(js)  # "true"

{:ok, js} = Gexpr.compile_to_js({:lit, "hello"})
IO.puts(js)  # "\"hello\""

# Compile references
{:ok, js} = Gexpr.compile_to_js({:ref, "myVariable"})
IO.puts(js)  # "myVariable"

# Compile vectors to arrays
{:ok, js} = Gexpr.compile_to_js({:vec, [{:lit, 1}, {:lit, 2}, {:lit, 3}]})
IO.puts(js)  # "[1, 2, 3]"
```

## Lambda Functions

G-Expression lambdas compile to JavaScript arrow functions:

```elixir
# Identity function: λx.x
id_lambda = {:lam, %{params: ["x"], body: {:ref, "x"}}}
{:ok, js} = Gexpr.compile_to_js(id_lambda)
IO.puts(js)  # "(x) => { return x; }"

# Double function: λx.(x * 2)
double_lambda = {:lam, %{
  params: ["x"],
  body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}
}}
{:ok, js} = Gexpr.compile_to_js(double_lambda)
IO.puts(js)  # "(x) => { return (x * 2); }"

# Multi-parameter function: λx,y.(x + y)
add_lambda = {:lam, %{
  params: ["x", "y"],
  body: {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:ref, "y"}]}}
}}
{:ok, js} = Gexpr.compile_to_js(add_lambda)
IO.puts(js)  # "(x, y) => { return (x + y); }"
```

## Arithmetic and Logic

Arithmetic operations map directly to JavaScript operators:

```elixir
# Addition
add_expr = {:app, {:ref, "+"}, {:vec, [{:lit, 20}, {:lit, 22}]}}
{:ok, js} = Gexpr.compile_to_js(add_expr)
IO.puts(js)  # "(20 + 22)"

# Comparison
eq_expr = {:app, {:ref, "eq?"}, {:vec, [{:lit, 42}, {:lit, 42}]}}
{:ok, js} = Gexpr.compile_to_js(eq_expr)
IO.puts(js)  # "(42 === 42)"

# Conditional (ternary operator)
cond_expr = {:app, {:ref, "cond"}, {:vec, [{:lit, true}, {:lit, "yes"}, {:lit, "no"}]}}
{:ok, js} = Gexpr.compile_to_js(cond_expr)
IO.puts(js)  # "(true ? \"yes\" : \"no\")"

# Less than or equal
le_expr = {:app, {:ref, "<="}, {:vec, [{:lit, 5}, {:lit, 10}]}}
{:ok, js} = Gexpr.compile_to_js(le_expr)
IO.puts(js)  # "(5 <= 10)"
```

## Complex Expressions

The compiler handles nested expressions and function applications:

```elixir
# Nested arithmetic: (2 * 3) + (4 * 5)
nested_expr = {:app, {:ref, "+"}, {:vec, [
  {:app, {:ref, "*"}, {:vec, [{:lit, 2}, {:lit, 3}]}},
  {:app, {:ref, "*"}, {:vec, [{:lit, 4}, {:lit, 5}]}}
]}}
{:ok, js} = Gexpr.compile_to_js(nested_expr)
IO.puts(js)  # "((2 * 3) + (4 * 5))"

# Function application: (λx.(x * 2))(21)
double_lambda = {:lam, %{
  params: ["x"],
  body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}
}}
app_expr = {:app, double_lambda, {:vec, [{:lit, 21}]}}
{:ok, js} = Gexpr.compile_to_js(app_expr)
IO.puts(js)  # "((x) => { return (x * 2); })(21)"

# Higher-order functions: compose(f, g)
compose_lambda = {:lam, %{
  params: ["f", "g"],
  body: {:lam, %{
    params: ["x"],
    body: {:app, {:ref, "f"}, {:vec, [
      {:app, {:ref, "g"}, {:vec, [{:ref, "x"}]}}
    ]}}
  }}
}}
{:ok, js} = Gexpr.compile_to_js(compose_lambda)
# Generates nested arrow functions
```

## End-to-End Pipeline

### Complete JavaScript Function Generation

```elixir
# Create a complete JavaScript function
triple_lambda = {:lam, %{
  params: ["x"],
  body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 3}]}}
}}

{:ok, js_function} = Gexpr.compile_lambda_to_js_function(triple_lambda, "triple")
IO.puts(js_function)
```

Output:
```javascript
function triple(x) {
  return (x * 3);
}
```

### Write and Execute JavaScript

```elixir
# Write JavaScript to file
test_js = js_function <> "\nconsole.log('triple(14) =', triple(14));"
File.write!("/tmp/gexpr_test.js", test_js)

# Execute with Node.js (if available)
case System.cmd("node", ["/tmp/gexpr_test.js"]) do
  {output, 0} -> 
    IO.puts("Result: #{String.trim(output)}")  # "triple(14) = 42"
  {error, _} -> 
    IO.puts("Node.js error: #{error}")
end
```

### HTML Test Generation

```elixir
# Create interactive HTML demo
html_content = Gexpr.JsCompiler.create_test_html(
  js_function <> "\nconsole.log('Result:', gexpr_func(14));", 
  "Triple Function Demo"
)
File.write!("/tmp/gexpr_demo.html", html_content)
IO.puts("Open /tmp/gexpr_demo.html in your browser!")
```

## The Killer Test

This is the test that proves the entire G-Expression vision:

### Factorial with Y-Combinator

```elixir
# Define factorial using Y-combinator (simplified for compilation)
factorial_body = {:lam, %{
  params: ["n"],
  body: {:app, {:ref, "cond"}, {:vec, [
    {:app, {:ref, "<="}, {:vec, [{:ref, "n"}, {:lit, 1}]}},
    {:lit, 1},
    {:app, {:ref, "*"}, {:vec, [
      {:ref, "n"},
      {:app, {:ref, "f"}, {:vec, [{:app, {:ref, "-"}, {:vec, [{:ref, "n"}, {:lit, 1}]}}]}}
    ]}}
  ]}}
}}

factorial_generator = {:lam, %{params: ["f"], body: factorial_body}}
factorial_fixed = {:fix, factorial_generator}

# Compile factorial for n=5
factorial_5 = {:app, factorial_fixed, {:vec, [{:lit, 5}]}}
{:ok, js_code} = Gexpr.compile_to_js(factorial_5)

# The output contains Y-combinator JavaScript!
IO.puts("Y-combinator in JavaScript:")
IO.puts(js_code)
```

### Complete AI → G-Expression → JavaScript Pipeline

```elixir
# Step 1: AI generates G-Expression (simulated)
ai_prompt = "create a function that doubles a number"
double_gexpr = {:lam, %{
  params: ["x"],
  body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}
}}

# Step 2: Add AI metadata
gexpr_with_meta = Gexpr.add_ai_metadata(
  %{"g" => "lam", "v" => %{"params" => ["x"], "body" => %{...}}},
  "gpt-4",
  ai_prompt,
  0.95
)

# Step 3: Compile to JavaScript
{:ok, js_function} = Gexpr.compile_lambda_to_js_function(double_gexpr, "double")

# Step 4: Execute and verify
test_js = js_function <> "\nconsole.log('double(21) =', double(21));"
File.write!("/tmp/ai_generated.js", test_js)

# Step 5: Run with Node.js
{output, 0} = System.cmd("node", ["/tmp/ai_generated.js"])
IO.puts("AI → G-Expr → JS → Result: #{String.trim(output)}")
# Output: "double(21) = 42"
```

## Running the Comprehensive Demo

Use the included demo script to see everything in action:

```bash
# Run the complete demonstration
elixir -S mix run js_demo.exs
```

This will show:
1. ✅ Basic compilation of all G-Expression types
2. ✅ Lambda calculus → Arrow functions
3. ✅ Arithmetic → Native JavaScript operators  
4. ✅ Complex nesting → Proper JavaScript structure
5. ✅ End-to-end pipeline with file generation and execution

## Running the Test Suite

```bash
# Run JavaScript compiler tests
mix test test/gexpr/js_compiler_test.exs

# Run with Node.js execution tests (if Node.js is available)
mix test test/gexpr/js_compiler_test.exs --include requires_node
```

Key tests include:
- **Basic compilation**: All G-Expression types → JavaScript
- **Lambda compilation**: Closures → Arrow functions
- **Arithmetic compilation**: Operators → Native JS
- **Complex expressions**: Nested structures
- **🎯 The Killer Test**: Factorial via Y-combinator
- **Integration test**: Complete AI → G-Expr → JS pipeline

## Practical Applications

### 1. **AI Code Generation Backend**

```elixir
# AI service generates G-Expressions
def handle_ai_request(prompt) do
  {:ok, gexpr} = AI.generate_gexpr(prompt)
  {:ok, js_code} = Gexpr.compile_to_js(gexpr)
  {:ok, html} = create_runnable_demo(js_code)
  
  %{
    gexpr: gexpr,
    javascript: js_code,
    demo_url: upload_demo(html)
  }
end
```

### 2. **Cross-Platform Function Deployment**

```elixir
# One G-Expression, multiple targets
def deploy_function(gexpr, targets) do
  Enum.map(targets, fn
    :javascript -> Gexpr.compile_to_js(gexpr)
    :python -> Gexpr.compile_to_py(gexpr)     # Future
    :rust -> Gexpr.compile_to_rust(gexpr)     # Future
    :sql -> Gexpr.compile_to_sql(gexpr)       # Future
  end)
end
```

### 3. **Interactive Code Playground**

```elixir
# Real-time G-Expression → JavaScript compilation
def live_compiler_endpoint(conn, %{"gexpr" => gexpr_json}) do
  with {:ok, gexpr} <- parse_gexpr(gexpr_json),
       {:ok, js_code} <- Gexpr.compile_to_js(gexpr),
       {:ok, result} <- execute_safely(js_code) do
    
    json(conn, %{
      success: true,
      javascript: js_code,
      result: result
    })
  end
end
```

## Extending to Other Languages

The JavaScript compiler serves as a template for additional target languages:

### Python Compiler (Future)

```elixir
defmodule Gexpr.PyCompiler do
  def compile_to_py({:lit, value}), do: "#{value}"
  def compile_to_py({:lam, %{params: params, body: body}}) do
    "lambda #{Enum.join(params, ", ")}: #{compile_to_py(body)}"
  end
  def compile_to_py({:app, {:ref, "+"}, {:vec, [a, b]}}) do
    "(#{compile_to_py(a)} + #{compile_to_py(b)})"
  end
  # ... more compilation rules
end
```

### SQL Compiler (Future)

```elixir
defmodule Gexpr.SqlCompiler do
  def compile_to_sql({:app, {:ref, "select"}, {:vec, [table, condition]}}) do
    "SELECT * FROM #{compile_to_sql(table)} WHERE #{compile_to_sql(condition)}"
  end
  # ... SQL-specific compilation rules
end
```

### WebAssembly Compiler (Future)

```elixir
defmodule Gexpr.WasmCompiler do
  def compile_to_wast({:lam, %{params: params, body: body}}) do
    "(func #{format_params(params)} #{compile_to_wast(body)})"
  end
  # ... WASM-specific compilation rules
end
```

## Performance Considerations

### Compilation Speed

```elixir
# Benchmark compilation performance
{time_us, {:ok, js_code}} = :timer.tc(fn ->
  Gexpr.compile_to_js(complex_gexpr)
end)

IO.puts("Compilation took #{time_us}μs")
IO.puts("Generated #{String.length(js_code)} characters of JavaScript")
```

### Optimization Opportunities

```elixir
# Future optimizations could include:
# 1. Constant folding: (2 + 3) → 5
# 2. Dead code elimination
# 3. Tail call optimization
# 4. Inline expansion of simple functions

def optimize_gexpr(gexpr) do
  gexpr
  |> fold_constants()
  |> eliminate_dead_code()
  |> optimize_tail_calls()
end
```

## Error Handling and Debugging

### Compilation Errors

```elixir
# Handle unsupported G-Expressions gracefully
case Gexpr.compile_to_js(unknown_gexpr) do
  {:ok, js_code} -> 
    IO.puts("Success: #{js_code}")
    
  {:error, reason} -> 
    IO.puts("Compilation failed: #{reason}")
    # Log for debugging, provide helpful error message
end
```

### JavaScript Runtime Errors

```elixir
# Test compiled JavaScript for runtime errors
defmodule JsValidator do
  def validate_js(js_code) do
    with :ok <- syntax_check(js_code),
         {:ok, result} <- safe_execute(js_code) do
      {:ok, result}
    else
      {:error, :syntax_error} -> {:error, "Invalid JavaScript syntax"}
      {:error, :runtime_error} -> {:error, "JavaScript runtime error"}
    end
  end
end
```

## Conclusion

The G-Expression to JavaScript compiler proves that G-Expressions work as a **universal computational substrate**. Key achievements:

1. ✅ **Lossless compilation** from G-Expressions to executable JavaScript
2. ✅ **Complete coverage** of all G-Expression types and operations  
3. ✅ **Real execution** with Node.js producing correct results
4. ✅ **End-to-end pipeline** from AI prompts to running code
5. ✅ **Extensible framework** ready for additional target languages

This demonstrates the core value proposition: **G-Expressions bridge the gap between AI-generated semantic intentions and practical, executable code in any target language.**

The next step is extending this pattern to Python, Rust, SQL, and other languages, proving G-Expressions as the ultimate universal intermediate representation for AI-native computing.