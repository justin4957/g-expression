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

## Philosophy

This system explores fundamental questions about computation:

- **Where does meaning come from?** The meaning emerges through unfurling
- **What is the minimal computational foundation?** The Prime Mover axioms
- **Can systems be self-describing?** The Genesis Context defines itself

The G-Expression framework pushes homoiconicity to its logical extreme, where code becomes a program that generates data, enabling unprecedented levels of abstraction and self-modification.

## License

MIT License - see LICENSE file for details.

