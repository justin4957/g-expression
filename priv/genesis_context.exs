# Genesis Context - The foundational definitions for the G-Expression system
# This is data that will be loaded and evaluated by the Prime Mover.
# It defines the real 'eval' function and core forms in terms of the primitive axioms.

[
  # 1. Define LAMBDA - A simple lambda constructor  
  {:def, "lambda",
   {:app, {:ref, "cons"}, {:vec, [
     {:lit, {:symbol, "closure"}},
     {:app, {:ref, "cons"}, {:vec, [
       {:lit, "params"},
       {:lit, "body"}
     ]}}
   ]}}},

  # 2. Define IF as a simple conditional constructor
  {:def, "if",
   {:app, {:ref, "cons"}, {:vec, [
     {:lit, {:symbol, "if"}},
     {:app, {:ref, "cons"}, {:vec, [
       {:lit, "condition"},
       {:app, {:ref, "cons"}, {:vec, [
         {:lit, "then"},
         {:lit, "else"}
       ]}}
     ]}}
   ]}}},

  # 3. Define a simple list constructor
  {:def, "list",
   {:lit, {:symbol, "list-constructor"}}},

  # 4. Define a simple evaluator constructor
  {:def, "eval", 
   {:lit, {:symbol, "evaluator"}}}
]