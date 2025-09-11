# G-Expression Expansion CLI Guide

This guide walks you through the new expansion CLI functionality, which implements the generative computation concepts from the expansion notes. The CLI lets you plant "seeds" of computation that grow into complex structures through controlled expansion processes.

## Overview: From Static Code to Living Systems

Traditional programming creates static artifacts. The expansion CLI creates **living computational seeds** that grow, adapt, and evolve:

- **🌱 Plant**: Create seed expressions with different growth strategies
- **🌿 Grow**: Expand expressions through controlled transformations  
- **👁️ Peek**: Observe growth potential without executing
- **📊 Show**: Inspect current state and transformation history
- **🎛️ Context**: Control the expansion environment

## Installation and Setup

```bash
# Install dependencies
mix deps.get

# Compile the system
mix compile

# Verify installation
mix gx --help
```

## Core Concepts

### Generator Types

Each seed has a **generator** that determines how it expands:

- **`lazy`**: Sequences that unfold incrementally (Fibonacci, infinite lists)
- **`adaptive`**: Algorithms that choose implementations based on context
- **`lsystem`**: Recursive structures that generate complex patterns
- **`spec`**: High-level specifications that synthesize into implementations
- **`genetic`**: Multiple variants that compete for selection
- **`fixed`**: Terminal expressions that don't expand further

### Expansion Context

The environment that controls growth:

- **Rules**: Transformation patterns and constraints
- **Limits**: Resource bounds (depth, iterations, time)
- **World Model**: Runtime conditions that influence decisions
- **Observation Points**: Hooks for inspection during expansion

## Basic Usage Walkthrough

### 1. Planting Your First Seed

```bash
# Create a lazy Fibonacci sequence
mix gx plant fib lazy

# Create an adaptive sorting algorithm
mix gx plant sort adaptive '{"hint": "size<50?insertion:quick"}'

# Create an L-system tree
mix gx plant tree lsystem '{"axiom": "A", "rules": {"A": "B[+A][-A]", "B": "BB"}}'

# Create a specification seed
mix gx plant validator spec '{"type": "function", "constraints": ["validate_email"]}'
```

**What just happened?** You planted computational seeds - compact representations that contain growth potential. Each seed "knows" how to unfold into more complex structures.

### 2. Growing Seeds (The Magic Moment)

```bash
# Grow Fibonacci sequence one step
mix gx grow fib
# ✓ Expanded: fib
#    Generated: 1

# Grow it multiple steps
mix gx grow fib -n 5
# ✓ Expanded: fib  
#    Generated: 8
```

**🧠 Philosophical Significance**: You're not running pre-written code - you're **cultivating computation**. The Fibonacci seed doesn't contain the sequence; it contains the *pattern* that generates it.

### 3. Observing Growth (Peek Without Side Effects)

```bash
# Preview what would happen next without actually growing
mix gx peek fib --depth 2
# fib (peek at depth 2):
#   Current generator: lazy
#   Rule: fibonacci
#   Current state: [8, 13]
#   Next would generate: 13
```

**Key Insight**: Peek lets you explore possibility spaces without commitment. You can inspect potential futures before making them real.

### 4. Examining the Results

```bash
# Show current state with history
mix gx show fib
# fib:
#   Generator: lazy
#   State: %{depth: 6, iterations: 6, ...}
#   Value: %{state: [8, 13], rule: "fibonacci"}
#   History:
#     lazy: %{state: [5, 8], rule: "fibonacci"} → %{state: [8, 13], rule: "fibonacci"}
#     lazy: %{state: [3, 5], rule: "fibonacci"} → %{state: [5, 8], rule: "fibonacci"}
#     ...

# Export as JSON for analysis
mix gx show fib --as json > fib-state.json
```

**Computational Archaeology**: Every transformation is recorded. You can trace any result back to its origins, understanding not just *what* was computed, but *how* it evolved.

## Advanced Examples

### Adaptive Algorithm Selection

This demonstrates **context-sensitive computation** - the same seed produces different implementations based on runtime conditions.

```bash
# Plant an adaptive sorting algorithm
mix gx plant sort adaptive '{"hint": "size<50?insertion:quick"}'

# Set context for small data
mix gx context set input_size 10
mix gx grow sort

# Check what it chose
mix gx show sort
# Shows: {:app, {:ref, "insertion"}, ...} - chose insertion sort

# Change context to large data
mix gx context set input_size 10000  
mix gx plant sort2 adaptive '{"hint": "size<50?insertion:quick"}'
mix gx grow sort2

# Check what it chose now  
mix gx show sort2  
# Shows: {:app, {:ref, "quick"}, ...} - chose quicksort
```

**Revolutionary Implication**: Write algorithms once at a high level. The system automatically specializes them for performance based on data size, hardware, or other constraints.

### L-System Recursive Growth

This demonstrates **emergent complexity** - simple rules generating intricate structures.

```bash
# Plant a tree-growing L-system
mix gx plant tree lsystem '{
  "axiom": "A", 
  "rules": {"A": "B[+A][-A]", "B": "BB"}
}'

# Watch it grow step by step
mix gx show tree
# Axiom: A

mix gx grow tree  
mix gx show tree
# Axiom: B[+A][-A]

mix gx grow tree
mix gx show tree  
# Axiom: BB[+B[+A][-A]][-B[+A][-A]]

# Save the growth history
mix gx save tree tree-generation.gx
```

**Biological Computing**: Like DNA encoding growth patterns, L-systems encode structural development. You're literally growing computational structures from genetic-like rules.

### Specification to Implementation

This demonstrates **intent-based programming** - describing what you want and letting the system synthesize how to achieve it.

```bash
# Plant a specification seed
mix gx plant email_check spec

# Grow it into actual implementation
mix gx grow email_check

# See what was synthesized
mix gx show email_check --as json
# Shows synthesized regex and validation logic
```

**AI-Native Development**: Instead of writing implementation details, you describe intent. The system (potentially with AI assistance) generates the actual code.

## Interactive Mode (REPL)

For rapid experimentation:

```bash
mix gx repl
# G-Expression REPL v0.1.0
# Type 'help' for commands, 'exit' to quit

gx> plant counter lazy
✓ Planted: counter

gx> grow counter -n 3  
✓ Expanded: counter
   Generated: 3

gx> peek counter
counter (peek at depth 1):
  Current generator: lazy
  Rule: fibonacci  
  Current state: [2, 3]
  Next would generate: 3

gx> list
Planted seeds:
  counter
  fib
  sort  
  tree

gx> exit
Goodbye!
```

## Context Management

The expansion context is like DNA - it determines how seeds develop:

```bash
# View current context
mix gx context show
# Current context:
#   input_size: 10

# Set expansion parameters
mix gx context set max_depth 20
mix gx context set expansion_strategy "performance"
mix gx context set memory_limit 1000000

# Context affects all future expansions
mix gx grow some_seed  # Will use new context
```

**Environmental Programming**: The same seed produces different results in different environments, just like biological organisms adapt to their surroundings.

## Persistence and Sharing

```bash
# Save a seed's current state
mix gx save fib fibonacci-state.gx

# Load it later or on another machine
mix gx load fibonacci-state.gx
# ✓ Loaded fib from fibonacci-state.gx

# The loaded seed continues where it left off
mix gx grow fib
```

**Computation as Data**: Seeds can be stored, transmitted, and resumed anywhere. Your computational processes become portable and persistent.

## Understanding the Philosophy

### Traditional Programming vs. Generative Computing

**Traditional Approach:**
```javascript
// Write explicit code
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n-1) + fibonacci(n-2);
}

const result = fibonacci(10); // Get answer: 55
```

**Generative Approach:**
```bash
# Plant a growth pattern  
mix gx plant fib lazy

# Cultivate it gradually
mix gx grow fib -n 10

# The sequence grows organically: [0,1,1,2,3,5,8,13,21,34,55]
# But you can observe and modify the growth process itself
```

### Key Philosophical Shifts

1. **From Instructions to Seeds**: Code becomes growth patterns rather than step-by-step instructions

2. **From Execution to Cultivation**: You don't run programs; you grow computational organisms

3. **From Static to Living**: Programs evolve, adapt, and optimize themselves based on context

4. **From Black Boxes to Glass Houses**: Every transformation is observable and traceable

5. **From Implementation to Intent**: Focus on what you want, not how to achieve it

## Advanced Patterns

### Evolutionary Programming

```bash
# Plant competing variants
mix gx plant optimizer genetic '{
  "variants": [
    {"implementation": "brute_force", "meta": {"speed": "slow", "memory": "minimal"}},
    {"implementation": "hash_table", "meta": {"speed": "fast", "memory": "high"}}, 
    {"implementation": "bloom_filter", "meta": {"speed": "fastest", "memory": "moderate"}}
  ],
  "goal": ["maximize", "speed"]
}'

# Let evolution choose the best
mix gx grow optimizer
mix gx show optimizer
# Selected: bloom_filter (fastest for current context)
```

### Progressive Enhancement

```bash
# Start simple
mix gx plant api spec '{"endpoint": "/users", "methods": ["GET"]}'

# Grow incrementally  
mix gx context set auth_required true
mix gx grow api

mix gx context set rate_limiting "100/minute" 
mix gx grow api

# Each growth adds capabilities while preserving existing functionality
```

### Computational Archaeology

```bash
# Examine the genealogy of any computation
mix gx show api --history
# Shows complete transformation tree from spec to implementation

# Debug by replaying growth history
mix gx peek api --at-step 3
# Shows state at any point in evolution
```

## Error Handling and Debugging

### Common Issues

```bash
# Resource limits exceeded
mix gx grow runaway_seed
# ❌ Error: Maximum depth exceeded

# Fix by adjusting limits
mix gx context set max_depth 50
mix gx grow runaway_seed  # Now succeeds

# Unknown generator type
mix gx plant bad_seed quantum  
# ❌ Error: Unknown generator type: quantum
```

### Debugging Techniques

```bash
# Inspect intermediate states
mix gx peek problematic_seed --depth 5

# Check expansion rules
mix gx context show

# Trace growth step-by-step
mix gx grow seed -n 1  # Grow one step at a time
mix gx show seed       # Examine after each step
```

## Integration with Existing Code

### Using Seeds in Regular Elixir

```elixir
# In your regular Elixir code:
{:ok, seed} = Gexpr.Expansion.create_seed(:fibonacci, %{})
context = Gexpr.Expansion.create_context(%{})

# Grow programmatically
{:ok, expanded} = Gexpr.Expansion.gexpand(seed, context)

# Extract results
final_value = expanded.value
growth_history = expanded.expansion_state.history
```

### API Integration

Seeds can be exposed through web APIs, allowing distributed computational cultivation:

```elixir
# REST API endpoint that grows seeds
def grow_seed(conn, %{"name" => name, "iterations" => n}) do
  case load_seed(name) do
    {:ok, seed} -> 
      context = create_api_context(conn)
      grown_seed = grow_iterations(seed, context, n)
      json(conn, serialize_seed(grown_seed))
    {:error, reason} ->
      json(conn, %{error: reason})
  end
end
```

## The Future: Self-Improving Systems

The ultimate vision is software that genuinely improves itself:

```bash
# Plant a self-improvement seed
mix gx plant self_optimizer meta '{
  "target": "current_implementation", 
  "metrics": ["performance", "correctness"],
  "method": "genetic_programming"
}'

# Let it evolve  
mix gx grow self_optimizer -n 100

# The system literally rewrites itself for better performance
mix gx show self_optimizer
# New optimized implementation with performance improvements
```

**This isn't science fiction** - it's the logical endpoint of generative computing. Seeds that improve their own growth patterns, creating genuinely autonomous, evolving software systems.

## Conclusion

The expansion CLI transforms programming from writing static instructions to cultivating living computational processes. You're not just a programmer anymore - you're a **computational gardener**, planting seeds of intention and nurturing them into full-featured systems.

### Key Takeaways

1. **Seeds > Scripts**: Plant growth patterns instead of writing explicit code
2. **Context is King**: The environment shapes how computation develops  
3. **Growth is Observable**: Every transformation can be inspected and understood
4. **Evolution is Controllable**: Guide development through context manipulation
5. **Intent > Implementation**: Focus on what you want, not how to achieve it

### Next Steps

- Experiment with different generator types
- Create your own custom expansion rules
- Build domain-specific growth patterns  
- Integrate seeds into larger systems
- Explore the philosophical implications of generative computing

**Welcome to the future of programming** - where code grows, adapts, and evolves like living systems, bridging the gap between human intention and machine execution through the power of controlled computational cultivation.