
## GExpr Formal Syntax (BNF)

### 1. Core Expression Grammar (Abstract Syntax Tree - AST)

This defines the structure of a valid GExpr after parsing.

```
<gexpr>    ::= <literal>           ; A literal value
            |  <reference>         ; A symbolic reference
            |  <application>       ; Function/Macro application
            |  <abstraction>       ; Lambda abstraction
            |  <quotation>         ; Quoting (suspends evaluation)
            |  <vector>            ; Ordered collection
            |  <conditional>       ; Conditional logic
            |  <definition>        ; Define a new symbol
            |  <meta-expr>         ; Expression with metadata

<literal>  ::= <number> | <string> | <boolean> | <symbol> | nil
<number>   ::= [0-9]+ ( "." [0-9]+ )?   ; e.g., 42, 3.14
<string>   ::= '"' ( .* ) '"'           ; e.g., "hello"
<boolean>  ::= true | false
<symbol>   ::= [a-zA-Z_+*\-/?<>!=][a-zA-Z0-9_+*\-/?<>!=]* ; e.g., x, my-func?, +
<reference> ::= "@" <symbol>             ; e.g., @cons, @main

<application> ::= "(" <gexpr> <gexpr>* ")"  ; e.g., (@cons @x @y), (@f a b)
<abstraction> ::= "λ" "(" <symbol>* ")" <gexpr> ; e.g., λ (x y) (@+ x y)
<quotation>   ::= "'" <gexpr>                 ; e.g., 'x, '(@cons a b)
<vector>      ::= "[" <gexpr>* "]"            ; e.g, [a b c], [@x 42]
<conditional> ::= "if" <gexpr> <gexpr> <gexpr> ; e.g., (if @condition @then @else)
<definition>  ::= "def" <symbol> <gexpr>      ; e.g., (def my-constant 42)

<meta-expr>   ::= "{" <gexpr> "|" <metadata> "}" ; e.g., { @x | src: "test.gexpr" }
<metadata>    ::= <key-value> ( "," <key-value> )*
<key-value>   ::= <symbol> ":" <literal>
```

### 2. Concrete Syntax (Textual Representation)

This defines a possible surface syntax for writing GExprs in a text file. It's designed to be easily parsable and reasonably human-friendly.

```
<program>    ::= <form>*
<form>       ::= <gexpr> | <definition>

; The core grammar remains the same, but written for text
<gexpr>      ::= <atom>
            |    "(" <gexpr>+ ")"     ; Application
            |    "λ" <binding> <gexpr> ; Abstraction
            |    "'" <gexpr>           ; Quotation
            |    "[" <gexpr>* "]"      ; Vector
            |    "#{" <metadata> "}" <gexpr> ; Meta-expr (prefix notation)

<atom>       ::= <number> | <string> | <boolean> | <symbol> | nil
<binding>    ::= "(" <symbol>* ")" | <symbol>
<metadata>   ::= <pair> ( "," <pair> )*
<pair>       ::= <key> ":" <value>
<key>        ::= <symbol>
<value>      ::= <atom>
```

### 3. Genesis Context Grammar (Initial Environment)

This defines the structure of the initial environment that bootstraps the language. It's a list of foundational definitions.

```
<genesis-context> ::= "{" <definition>+ "}"

<definition> ::= <symbol> ":" <primitive>  ; Prime Mover built-in
              |  <symbol> ":" <gexpr>      ; Bootstrapped definition

<primitive>  ::= "«primitive:" <name> "»"  ; e.g., «primitive:cons»
```

### 4. Formal Semantics (Evaluation Rules - Operational Semantics)

BNF defines syntax. To define meaning, we use operational semantics, showing how an expression evaluates in an environment `env`.

```
env ⊢ <gexpr> ⇓ <value>   ; Expression <gexpr> evaluates to <value> in environment env

------------ [Lit]
env ⊢ ⟨lit, v⟩ ⇓ v

env(x) = v
------------ [Ref]
env ⊢ ⟨ref, x⟩ ⇓ v

env ⊢ e1 ⇓ ⟨λ, params, body⟩    env ⊢ e2 ⇓ arg    env[params → arg] ⊢ body ⇓ result
----------------------------------------------------------------------------- [App]
env ⊢ ⟨app, e1, e2⟩ ⇓ result

env[params → arg] ⊢ body ⇓ result    ; where arg is the evaluated argument
----------------------------------- [App-Lam]
env ⊢ ⟨app, ⟨lam, params, body⟩, arg⟩ ⇓ result

env ⊢ e ⇓ v
----------------------- [Quote]
env ⊢ ⟨quote, e⟩ ⇓ ⟨ast, e⟩   ; Note: Returns its own AST, unevaluated.

env ⊢ e1 ⇓ true    env ⊢ e2 ⇓ v
-------------------------------- [If-True]
env ⊢ ⟨if, e1, e2, _⟩ ⇓ v

env ⊢ e1 ⇓ false    env ⊢ e3 ⇓ v
---------------------------------- [If-False]
env ⊢ ⟨if, e1, _, e3⟩ ⇓ v
```

### Example: Factorial in Concrete Syntax

This shows how the familiar factorial function would be expressed.

```lisp
; Definition in the Genesis Context to bootstrap recursion
def Y (λ (f) ((λ (x) (f (λ (y) ((@ x x) y)))) (λ (x) (f (λ (y) ((@ x x) y))))))

; User-defined factorial
def factorial (λ (n)
  (if (@eq? n 0)
      1
      (@* n (@ factorial (@- n 1)))))
```

### Example: The Big Bang (`main`)

This is the minimal seed that starts the unfurling process.

```lisp
; The entire program can be a single reference
@main

; Which relies on the genesis context defining `main`:
; genesis-context = {
;   main: (@process @input)  ; 'main' is defined as applying a process to an input
;   process: «primitive:eval» ; which is a built-in primitive evaluator
;   input: "(+ 1 2)"        ; the input to evaluate
; }
```

This BNF specification provides a rigorous, formal foundation for the GExpr language, defining both its structure and its meaning. It serves as the ultimate reference for implementers and a guarantee of the language's consistency.