# G-Expression Expansion CLI Guide

This guide walks you through the revolutionary expansion CLI functionality, which implements generative computation concepts where **code grows like living organisms**. The CLI transforms programming from writing static instructions to **cultivating computational seeds** that evolve into complex, adaptive systems.

## 🚀 The 30-Second Wow Moment

**Ready to have your mind blown?** Start here:

```bash
# Install and compile
mix deps.get && mix compile

# The showcase demo (30 seconds to enlightenment)
mix gx plant fractal fractal
mix gx grow fractal --visual -n 5
# Watch a fractal tree grow in beautiful ASCII art

mix gx show fractal --visual  
# Opens interactive browser visualization with expansion history
```

**What just happened?** You didn't run pre-written code - you **cultivated a computational organism** from a simple growth pattern, watched it evolve in real-time, and explored its complete genealogy.

## Overview: From Static Code to Living Systems

Traditional programming creates static artifacts. The expansion CLI creates **living computational seeds** that grow, adapt, and evolve:

- **🌱 Plant**: Create seed expressions with different growth strategies
- **🌿 Grow**: Expand expressions through controlled transformations  
- **👁️ Peek**: Observe growth potential without executing
- **📊 Show**: Inspect current state and transformation history
- **🎛️ Context**: Control the expansion environment
- **🎬 Visual**: Watch growth happen in real-time with stunning visualizations

## Installation and Setup

```bash
# Install dependencies
mix deps.get

# Compile the system
mix compile

# Verify installation with help
mix gx --help

# Start the interactive experience
mix gx repl
```

## Core Concepts

### Generator Types

Each seed has a **generator** that determines how it grows - like DNA for computational organisms:

- **`lazy`**: Infinite sequences that unfold incrementally (Fibonacci, primes, π digits)
- **`adaptive`**: Smart algorithms that choose strategies based on runtime conditions
- **`lsystem`**: Fractal generators creating complex patterns from simple rules  
- **`spec`**: Intent-based generators that synthesize implementations from descriptions
- **`genetic`**: Evolutionary generators where variants compete for survival
- **`fractal`**: Specialized beautiful fractal trees (the showcase demo generator)
- **`primes`**: Prime number generators using advanced sieves
- **`collatz`**: The mysterious 3n+1 sequence generators
- **`pi`**: π calculation generators using infinite series
- **`fixed`**: Terminal expressions that have finished growing

### The Seed Library - Pre-Built Computational Organisms

Instead of writing generators from scratch, use the **curated seed library** - a collection of mind-blowing examples:

```bash
# Browse the catalog
mix gx repl
gx> catalog

# Plant library seeds
mix gx plant amazing fractal '{"seed": "fractal_tree"}'
mix gx plant smart adaptive '{"seed": "smart_cache"}'  
mix gx plant mystery lazy '{"seed": "collatz", "start": 27}'
```

### Expansion Context

The environment that controls growth:

- **Rules**: Transformation patterns and constraints
- **Limits**: Resource bounds (depth, iterations, time)
- **World Model**: Runtime conditions that influence decisions
- **Observation Points**: Hooks for inspection during expansion

## Basic Usage Walkthrough

### 1. Planting Your First Seeds

```bash
# Quick generators (basic types)
mix gx plant fib lazy                    # Classic Fibonacci
mix gx plant primes primes              # Prime number sequence  
mix gx plant mystery collatz            # The 3n+1 mystery
mix gx plant pi_calc pi                 # Calculate π infinitely

# Beautiful fractals (the wow factor)
mix gx plant tree fractal              # Stunning fractal tree
mix gx plant triangle lsystem '{"axiom": "F-G-G", "rules": {"F": "F-G+F+G-F", "G": "GG"}}'

# Library seeds (curated masterpieces)
mix gx plant amazing fractal '{"seed": "fractal_tree"}'
mix gx plant smart_ai adaptive '{"seed": "smart_cache"}'
```

**What just happened?** You planted computational seeds - compact genetic codes that contain infinite growth potential. Each seed "knows" how to unfold into complex structures, adapt to environments, and evolve over time.

### 2. Growing Seeds (The Magic Moment)

```bash
# Traditional growth (behind the scenes)
mix gx grow fib -n 5
# ✓ Expanded: fib  
#    Generated: 8

# VISUAL GROWTH (the mind-blowing experience)
mix gx grow fib --visual -n 10
# Watch numbers appear in real-time with ASCII bar charts!

mix gx grow tree --visual -n 4  
# Watch fractal trees grow branch by branch in ASCII art!

mix gx grow primes --visual -n 15
# See prime numbers discovered live with visual patterns!
```

**🧠 Philosophical Breakthrough**: You're not running pre-written code - you're **cultivating living computation**. The Fibonacci seed doesn't contain the sequence; it contains the *genetic pattern* that grows it organically.

### 3. Visual Exploration (Mind = Blown)

```bash
# Browser-based visualization (interactive exploration)
mix gx show tree --visual
# Opens HTML page with D3.js expansion tree, full history, Matrix aesthetics

# Terminal ASCII art (immediate gratification)  
mix gx show tree
# Beautiful ASCII tree with growth statistics

# JSON export (for analysis)
mix gx show fib --as json > fibonacci_evolution.json
```

### 4. Observing Growth (Peek Without Side Effects)

```bash
# Preview what would happen next without actually growing
mix gx peek fib --depth 2
# fib (peek at depth 2):
#   Current generator: lazy
#   Rule: fibonacci
#   Current state: [8, 13]
#   Next would generate: 13
```

**Key Insight**: Peek lets you explore possibility spaces without commitment. You can inspect potential futures before making them real - like seeing through time itself.

## The Interactive Experience (REPL Magic)

The most powerful way to experience generative computing:

```bash
mix gx repl
# G-Expression REPL v0.1.0
# Type 'help' for commands, 'exit' to quit

gx> demo                                    # Instant showcase demo
# 🎬 Running showcase demo sequence...
# Watch fractal tree grow in real-time!

gx> catalog                                 # Browse seed library
# 📚 Seed Library Catalog
# ======================= 
# LAZY GENERATORS:
#   fibonacci - Classic Fibonacci sequence...
#   primes - Infinite sequence of prime numbers...

gx> plant amazing fractal '{"seed": "fractal_tree"}'
# ✓ Planted: amazing

gx> grow amazing --visual -n 6
# 🌱 Growing amazing in real-time...
# Watch beautiful ASCII fractal unfold!

gx> show amazing --visual
# Opens browser with interactive D3.js visualization

gx> list                                    # Show all planted seeds
# Planted seeds:
#   amazing
#   demo_tree
```

**Revolutionary Experience**: This isn't a command-line tool - it's a **computational terrarium** where you cultivate living programs.

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
# Plant competing algorithm variants (from the seed library)
mix gx plant smart genetic '{"seed": "pathfinder"}'

# Watch evolution in action  
mix gx context set terrain_type "mountainous"
mix gx grow smart --visual
# Algorithm evolves to use A* for mountainous terrain

mix gx context set terrain_type "grid"  
mix gx grow smart --visual
# Now evolves to use jump point search for grid terrain

# See the evolutionary process
mix gx show smart --visual
# Browser shows decision tree of algorithmic evolution
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

## The Stunning Seed Library - Curated Mind-Blowers

Instead of building from scratch, explore these jaw-dropping pre-built examples:

### **Visual Spectacles** 🎨
```bash
# Fractal trees (the ultimate showcase)
mix gx plant tree fractal '{"seed": "fractal_tree"}'
mix gx grow tree --visual -n 5      # ASCII art masterpiece

# Sierpinski triangle (mathematical beauty)
mix gx plant sierpinski lsystem '{"seed": "sierpinski_triangle"}'  
mix gx grow sierpinski --visual -n 4

# Dragon curve (space-filling elegance)
mix gx plant dragon lsystem '{"seed": "dragon_curve"}'
mix gx grow dragon --visual -n 8
```

### **Mathematical Mysteries** 🔢
```bash
# The 3n+1 Collatz conjecture
mix gx plant mystery lazy '{"seed": "collatz", "start": 27}'
mix gx grow mystery --visual -n 50  # Watch the chaos

# Prime number discovery  
mix gx plant primes lazy '{"seed": "primes"}'
mix gx grow primes --visual -n 20   # Sieve in action

# π calculation (infinite precision)
mix gx plant pi lazy '{"seed": "pi_digits"}'  
mix gx grow pi --visual -n 100     # Watch π converge
```

### **AI-Like Intelligence** 🧠
```bash
# Adaptive caching that learns
mix gx plant smart adaptive '{"seed": "smart_cache"}'
mix gx context set access_pattern "random"
mix gx grow smart --visual         # Chooses optimal strategy

# Self-optimizing neural networks  
mix gx plant brain genetic '{"seed": "neural_network"}'
mix gx grow brain --visual -n 10   # Watch architecture evolve
```

### **Intent-Based Programming** 💡
```bash  
# REST API from description
mix gx plant api spec '{"seed": "rest_api"}'
mix gx grow api --visual           # Watch implementation synthesize

# Security from requirements
mix gx plant crypto spec '{"seed": "crypto_hasher"}'  
mix gx grow crypto --visual        # See secure code generation
```

## The Future: Self-Improving Systems

**This is real, happening now** - software that genuinely improves itself:

```bash
# The ultimate demonstration 
mix gx plant evolving genetic '{"seed": "algorithm_optimizer"}'

# Watch algorithms compete and evolve
mix gx grow evolving --visual -n 20
# Quicksort vs Heapsort vs Timsort - may the best algorithm win!

# See the evolutionary arms race
mix gx show evolving --visual
# Interactive browser view of algorithmic natural selection
```

**This isn't science fiction** - it's generative computing in action. Seeds that improve their own growth patterns, creating genuinely autonomous, evolving software systems.

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