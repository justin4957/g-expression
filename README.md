# G-Expression System

A minimal, self-bootstrapping computational framework implemented in Elixir.

## Overview

The G-Expression system represents computation through a minimal set of primitive operations that can "unfurl" into complex, self-hosting systems. At its core, it consists of:

- **Prime Mover**: The minimal interpreter that understands basic G-Expressions
- **Genesis Context**: Foundational definitions that bootstrap the system
- **Unfurling Process**: The evaluation mechanism that transforms G-Expressions into values

## Core Concepts

### G-Expressions

G-Expressions are the fundamental building blocks, consisting of four basic types:

- `{:lit, value}` - Literal values
- `{:ref, name}` - References to bound names
- `{:app, fun, arg}` - Function application
- `{:vec, elements}` - Vectors of G-Expressions

### The Bootstrap Process

The system bootstraps in stages:

1. **Prime Mover**: Defines minimal axioms (`cons`, `car`, `cdr`, `id`, `eq?`, `cond`)
2. **Genesis Context**: Loads foundational definitions as G-Expressions
3. **Self-Hosting**: The unfurler becomes a G-Expression evaluated by itself

## Usage

### Basic Example

```elixir
# Bootstrap the system
{:ok, context} = Gexpr.bootstrap()

# Evaluate a simple literal
Gexpr.eval({:lit, 42}, context)
#=> {:ok, 42}

# Apply the identity function
Gexpr.eval({:app, {:ref, "id"}, {:lit, "hello"}}, context)
#=> {:ok, "hello"}

# Create and manipulate lists
cons_expr = {:app, {:ref, "cons"}, {:vec, [{:lit, 1}, {:lit, 2}]}}
Gexpr.eval(cons_expr, context)
#=> {:ok, {:list, [1, 2]}}
```

### Building Complex Expressions

```elixir
# Using helper functions for cleaner syntax
import Gexpr

# Create a conditional expression
condition = app(ref("eq?"), vec([lit(1), lit(1)]))
then_branch = lit("equal")
else_branch = lit("not equal")

conditional = app(ref("cond"), vec([condition, then_branch, else_branch]))

{:ok, context} = bootstrap()
eval(conditional, context)
#=> {:ok, "equal"}
```

## Architecture

### Prime Mover (`Gexpr.PrimeMover`)

The foundational interpreter that defines:
- Basic evaluation rules for the four G-Expression types
- Primitive operations needed for self-hosting
- Context management for bindings

### Bootstrap (`Gexpr.Bootstrap`)

Manages the system initialization:
- Loads Genesis Context definitions
- Applies Prime Mover to build complete system
- Handles graceful fallbacks for missing configuration

### Genesis Context

Foundational definitions stored as data in `priv/genesis_context.exs`:
- Lambda abstraction
- Conditional logic (`if` in terms of `cond`)
- Basic list operations
- Simplified evaluator (bootstrapping towards self-hosting)

## Installation

Add `gexpr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gexpr, "~> 0.1.0"}
  ]
end
```

## Development

```bash
# Get dependencies
mix deps.get

# Run tests
mix test

# Generate documentation
mix docs

# Start interactive session
iex -S mix
```

## Testing

The project includes comprehensive tests covering:
- Prime Mover evaluation rules
- Bootstrap process
- Genesis Context loading
- Integration scenarios

Run tests with:

```bash
mix test
```

## Documentation

Generate documentation with:

```bash
mix docs
```

## The Practical Utility of G-Expressions

This isn't just theoretical elegance - G-Expressions could fundamentally change how we build, reason about, and evolve software. Here are the concrete benefits:

### 1. **AI-Native Code Generation**

Current LLMs generate text that hopefully parses as valid code. With G-Exprs, they'd generate **semantic intentions**:

```elixir
# Instead of generating brittle syntax:
"def factorial(n), do: if n <= 1, do: 1, else: n * factorial(n-1)"

# AI generates semantic structure:
%{
  "g" => "define",
  "v" => %{
    "name" => "factorial",
    "body" => %{"g" => "cond",
               "v" => [["<=", "n", 1], %{"g" => "lit", "v" => 1}],
                    ["else", %{"g" => "app", "v" => ["*", "n", %{"g" => "app", "v" => ["factorial", ["-", "n", 1]]}]}]}
  }
}
```

Benefits:
- **No syntax errors** - structure is always valid
- **Language agnostic** - same G-Expr can unfurl to Python, JS, Rust, Elixir
- **Semantic versioning** - AI can reason about meaning, not text

### 2. **Computation Archaeology & Provenance**

Every G-Expr carries its history. In production, you could trace any running code back to its origin:

```elixir
%{
  "g" => "app",
  "v" => ["process_payment", "order_123"],
  "m" => %{
    "generated_by" => "gpt-4",
    "prompt_hash" => "a3f42...",
    "timestamp" => "2024-01-03T10:23:45Z",
    "unfurled_from" => %{"g" => "ref", "v" => "payment_macro_v2"},
    "review_status" => "approved",
    "reviewer" => "alice@company.com"
  }
}
```

This enables:
- **Debugging AI-generated code** - trace back to the prompt/model
- **Compliance auditing** - prove code provenance for regulated industries
- **Performance archaeology** - "this slow query unfurled from macro X"

### 3. **Live Programming Environments**

G-Exprs are perfect for systems that modify themselves while running:

```elixir
# Runtime receives new G-Expr from network
update = receive_gexpr()

# System can inspect before unfurling
if complexity(update) < threshold && verify_signature(update) do
  # Hot-swap the running function
  Context.redefine(context, "handle_request", Gexpr.eval(update, context))
end
```

Applications:
- **Feature flags that ship actual code**, not just toggles
- **A/B testing at the semantic level** - test different algorithms
- **Self-healing systems** - receive patches as G-Exprs

### 4. **Cross-Language Compilation**

One G-Expr, multiple targets:

```elixir
%{
  "g" => "function",
  "v" => %{
    "name" => "validate_email",
    "params" => ["email"],
    "body" => %{"g" => "match_regex", "v" => ["email", "^[a-z]+@[a-z]+\\.[a-z]+$"]}
  }
}
```

Could unfurl to:
- JavaScript for frontend
- Python for API server  
- SQL CHECK constraint for database
- Regex for WAF rules

**Write once, deploy everywhere** - but at the semantic level, not source level.

### 5. **Semantic Version Control**

Git tracks text changes. G-Expr version control would track **semantic** changes:

```diff
{
  "g": "app",
  "v": {
    "fn": "calculate_tax",
-   "rate": {"g": "lit", "v": 0.08},
+   "rate": {"g": "lit", "v": 0.085},
  }
}
```

The VCS could understand:
- "This commit only changes tax rate from 8% to 8.5%"
- "These two functions are semantically identical despite different text"
- "This refactor preserves behavior exactly"

### 6. **Computational Contracts & Verification**

G-Exprs make formal verification more practical:

```elixir
%{
  "g" => "define",
  "v" => %{
    "name" => "transfer",
    "contract" => %{
      "pre" => [">=", "from.balance", "amount"],
      "post" => ["=", "from.balance", ["-", "from.balance@pre", "amount"]],
      "invariant" => ["=", "total_supply", "total_supply@pre"]
    },
    "body" => "..."
  }
}
```

The unfurler could:
- Prove contracts at compile-time using SMT solvers
- Insert runtime checks automatically
- Generate test cases from contracts

### 7. **Code as Data Warehouse**

With G-Exprs, your entire codebase becomes queryable:

```sql
-- Find all functions that call the database
SELECT * FROM gexprs 
WHERE type = 'app' 
AND json_extract(value, '$.fn') IN ('query', 'insert', 'update');

-- Find all tax calculations
SELECT * FROM gexprs
WHERE semantic_fingerprint SIMILAR TO 'calculate.*tax.*rate';
```

This enables:
- **Semantic code search** - find by meaning, not text
- **Impact analysis** - "what breaks if I change this?"
- **Compliance scanning** - "show me all PII processing"

### 8. **Gradual Typing & Progressive Enhancement**

Start with dynamic G-Exprs, gradually add types:

```elixir
# Version 1: Untyped
%{"g" => "ref", "v" => "user_id"}

# Version 2: Add type annotation
%{"g" => "ref", "v" => "user_id", "m" => %{"type" => "uuid"}}

# Version 3: Add constraints
%{"g" => "ref", "v" => "user_id", "m" => %{"type" => "uuid", "not_null" => true, "format" => "v4"}}
```

The same code gets progressively more verified without rewriting.

### 9. **Distributed Computation Orchestration**

G-Exprs are naturally serializable and portable:

```elixir
%{
  "g" => "distributed",
  "v" => %{
    "map" => %{"g" => "lam", "params" => ["x"], "body" => ["*", "x", 2]},
    "data" => %{"g" => "ref", "v" => "dataset"},
    "reduce" => %{"g" => "ref", "v" => "+"},
    "nodes" => ["worker-1", "worker-2", "worker-3"]
  }
}
```

The orchestrator can:
- Ship G-Exprs to workers
- Optimize execution plans
- Cache unfurled results
- Move computation to data

### 10. **Time-Travel Debugging**

Since G-Exprs separate description from execution:

```elixir
defmodule Debugger do
  defstruct history: []

  def step_back(%Debugger{history: []} = debugger), do: debugger
  def step_back(%Debugger{history: [{gexpr, context, _result} | rest]} = debugger) do
    # Re-unfurl with inspection
    new_result = Gexpr.eval_with_breakpoint(gexpr, context)
    %{debugger | history: rest}
  end
end
```

You can:
- Replay any computation step-by-step
- Modify G-Exprs and re-run from any point
- Compare different unfurling strategies

### 11. **Economic Models for Computation**

G-Exprs could enable "computation markets":

```elixir
%{
  "g" => "app",
  "v" => ["complex_analysis", "dataset"],
  "m" => %{
    "max_cost" => 0.01,  # USD
    "max_time" => 5000,  # ms
    "required_accuracy" => 0.99,
    "bidding" => "open"
  }
}
```

Compute providers could:
- Bid on unfurling jobs
- Prove execution correctly
- Optimize for cost/performance
- Trade partially-unfurled results

### 12. **Legal Smart Contracts**

Unlike current smart contracts, G-Exprs could bridge legal text and code:

```elixir
%{
  "g" => "contract",
  "v" => %{
    "parties" => ["alice", "bob"],
    "terms" => %{
      "g" => "if",
      "condition" => %{"g" => "delivered_by", "date" => "2024-12-31"},
      "then" => %{"g" => "transfer", "from" => "bob", "to" => "alice", "amount" => 1000},
      "else" => %{"g" => "refund", "to" => "bob"}
    }
  },
  "m" => %{
    "legal_prose" => "Upon delivery by December 31, 2024...",
    "jurisdiction" => "Delaware",
    "hash" => "sha256:..."
  }
}
```

## The Killer App: **Self-Improving Software**

The ultimate utility: software that genuinely improves itself:

```elixir
%{
  "g" => "improve",
  "v" => %{
    "target" => %{"g" => "ref", "v" => "current_implementation"},
    "metrics" => ["performance", "readability", "correctness"],
    "constraints" => ["maintain_api", "pass_tests"],
    "method" => "genetic_programming"
  }
}
```

The system could:
1. Generate variations of its own G-Exprs
2. Unfurl and test them
3. Select the best performers
4. Replace its own implementation
5. All while running

This isn't just optimization - it's evolution. Software that gets better at getting better.

---

The core insight: **G-Expressions aren't just a better syntax - they're a computational substrate that makes previously impossible things tractable.** They're the difference between software as static artifacts and software as living, evolving processes.

## Philosophy

This system explores fundamental questions about computation:

- **Where does meaning come from?** The meaning emerges through unfurling
- **What is the minimal computational foundation?** The Prime Mover axioms
- **Can systems be self-describing?** The Genesis Context defines itself

The G-Expression framework pushes homoiconicity to its logical extreme, where code becomes a program that generates data, enabling unprecedented levels of abstraction and self-modification.

## License

MIT License - see LICENSE file for details.

