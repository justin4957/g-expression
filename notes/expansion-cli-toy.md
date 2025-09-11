## G-Expression Playground: Minimal CLI Specification

Here's a bare-minimum CLI that lets you experiment with the generative aspects of G-Expressions:

```bash
# gx - The G-Expression CLI
```

### Core Commands (The Absolute Minimum)

```bash
# 1. PLANT - Create a seed expression
gx plant <name> <generator-type> [inline-spec]
gx plant fib lazy '{"init": [0,1], "rule": "a,b -> b,a+b"}'
gx plant sort adaptive '{"hint": "size<10?insertion:quick"}'
gx plant tree lsystem '{"axiom": "A", "A": "B[+A][-A]", "B": "BB"}'

# 2. GROW - Expand an expression (the heart of the system)
gx grow <name> [options]
gx grow fib                    # Expand once with default context
gx grow fib -n 5                # Expand 5 iterations
gx grow fib --until "length>10" # Expand until condition met
gx grow sort --with input.json  # Expand with specific context

# 3. PEEK - Observe without full expansion
gx peek <name>                  # Show current state
gx peek fib --depth 2           # Show 2 levels deep without expanding
gx peek sort --structure        # Show structure only, hide values

# 4. SHOW - Display expressions
gx show <name>                  # Pretty-print current state
gx show <name> --history        # Show expansion history
gx show <name> --as json        # Output as JSON
gx show <name> --as lisp        # Render as s-expression
gx show <name> --as python      # Render as Python code
```

### Interactive Mode (REPL)

```bash
gx repl

gx> plant counter lit 0
✓ Planted: counter

gx> grow counter with rule="n -> n+1"
✓ Expanded: counter = 1

gx> grow counter
✓ Expanded: counter = 2

gx> peek counter --history
Expansion history for 'counter':
  Step 0: {"g": "lit", "v": 0}
  Step 1: {"g": "lit", "v": 1} [rule: n -> n+1]
  Step 2: {"g": "lit", "v": 2} [rule: n -> n+1]

gx> .context set max_depth 100
✓ Context updated

gx> .watch counter
✓ Watching 'counter' (will show after each command)
```

### Context Control

```bash
# Set expansion context/environment
gx context set <key> <value>
gx context set max_depth 10
gx context set memory_limit 1000000
gx context set strategy "performance"

# Load context from file
gx context load production.ctx

# Show current context
gx context show
```

### The Minimum File Format

```bash
# Save/load expressions
gx save <name> [filename]
gx load <filename>

# Minimal file format (counter.gx):
---
name: counter
generator: increment
value: 42
meta:
  created: 2024-01-15
rules:
  increment: "n -> n+1"
---
```

### Practical Examples

#### Example 1: Growing Fibonacci
```bash
# Create a lazy sequence
gx plant fib lazy
gx context set rule "a,b -> b,a+b"
gx context set init "[0,1]"

# Grow it step by step
gx grow fib        # [0,1,1]
gx grow fib        # [0,1,1,2]
gx grow fib -n 5   # [0,1,1,2,3,5,8,13]

# Peek without expanding
gx peek fib --next 3  # Preview: would produce [21,34,55]
```

#### Example 2: Adaptive Algorithm
```bash
# Plant adaptive sort
gx plant sort adaptive '{
  "small": "insertion",
  "large": "quick", 
  "threshold": 50
}'

# Test with different inputs
echo "[3,1,2]" | gx grow sort --pipe
# → Expanded to: insertion_sort([3,1,2])

echo "[1..1000]" | gx grow sort --pipe  
# → Expanded to: quick_sort([1..1000])
```

#### Example 3: L-System Tree
```bash
# Plant L-system
gx plant tree lsystem
gx context set axiom "A"
gx context set rules.A "B[+A][-A]"
gx context set rules.B "BB"

# Watch it grow
gx grow tree            # B[+A][-A]
gx grow tree            # BB[+B[+A][-A]][-B[+A][-A]]
gx show tree --as ascii # Renders ASCII art tree
```

#### Example 4: Specification to Code
```bash
# Plant a specification
gx plant api spec '{
  "endpoint": "/users",
  "methods": ["GET", "POST"],
  "auth": true
}'

# Grow with different contexts
gx context set target "express"
gx grow api > express-api.js

gx context set target "fastapi" 
gx grow api > fastapi-api.py
```

### Debug/Inspection Commands

```bash
# Step through expansion
gx step <name>                  # Interactive stepping
> [ENTER]                       # Expand one step
> context set <key> <value>     # Modify context mid-expansion
> rollback                      # Undo last expansion
> continue                      # Expand to completion

# Trace expansion decisions
gx trace <name>
# Shows each decision point and why specific expansion was chosen

# Compare different expansion strategies
gx battle <name> <context1> <context2>
gx battle sort size=10 size=10000
# Shows side-by-side expansion for different contexts
```

### Pipe-Friendly Operations

```bash
# Unix philosophy: compose with other tools
echo '{"g":"lit","v":0}' | gx grow - | jq .value

# Chain expansions
gx show fib --raw | gx grow - --as tree | gx grow - --as image > tree.png

# Use as a filter
cat data.json | gx grow sort --pipe | gx grow optimize --pipe > sorted-optimized.json
```

### Minimal Configuration File

```bash
# ~/.gxrc
default_context:
  max_depth: 100
  max_time_ms: 5000
  expansion_strategy: "lazy"

aliases:
  l: "show --list"
  g: "grow"
  p: "peek"
  
render_formats:
  python: "python3 -m gx.renderers.python"
  lisp: "gx-to-lisp"
```

### Error Messages (Clear and Helpful)

```bash
gx grow undefined-expr
❌ Error: No expression named 'undefined-expr'
   Hint: Use 'gx list' to see available expressions
   
gx grow fib --depth 1000000
❌ Error: Expansion limit exceeded (max_depth: 100)
   Hint: Increase limit with 'gx context set max_depth <value>'
   
gx plant bad syntax error
❌ Error: Invalid generator specification
   Expected: gx plant <name> <generator> [spec]
   Example: gx plant counter lit 0
```

### The Absolute Core (If Even More Minimal)

If you want the *absolute* bare minimum to start playing:

```bash
# Just three commands:
gx eval <gexpr>           # Evaluate a G-expression
gx expand <gexpr>         # Expand one level
gx unfurl <gexpr>         # Fully expand

# Everything as pipes:
echo '{"g":"lazy","v":"fib"}' | gx expand | gx expand | gx expand

# One-liner experiments:
gx eval '{"g":"app","v":{"fn":"grow","args":"seed"}}'
```

### Implementation Priority

For the very first version, implement just:

1. `plant` - Create expressions
2. `grow` - Expand them  
3. `show` - See what happened
4. `repl` - Interactive exploration

Everything else can be added incrementally. The key is making the grow/expand cycle **visceral and immediate** - you type, it grows, you see the transformation instantly.

This CLI makes G-Expressions **tangible** - you're literally planting seeds and watching them grow. The metaphor guides the interface and makes the abstract concept of "generative computation" concrete and playful.