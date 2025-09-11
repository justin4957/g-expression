defmodule Gexpr.PrimeMover do
  @moduledoc """
  The Prime Mover - the minimal interpreter that bootstraps the G-Expression system.
  
  This module defines the core types and evaluation logic that can unfurl
  G-Expressions into a self-hosting computational system.
  """

  # ------ THE MINIMAL TYPES THE PRIME MOVER UNDERSTANDS ------
  @type prime_gexpr ::
          {:lit, value}
          | {:ref, String.t()}
          | {:app, prime_gexpr, prime_gexpr}
          | {:vec, list(prime_gexpr)}
          | {:lam, %{params: list(String.t()), body: prime_gexpr}}
          | {:fix, prime_gexpr}
          | {:match, prime_gexpr, list({pattern, prime_gexpr})}

  @type pattern :: 
          {:lit_pattern, any()}
          | {:ref_pattern, String.t()}
          | :else_pattern

  @type value ::
          number()
          | atom()
          | String.t()
          | boolean()
          | {:symbol, String.t()}
          | {:list, list(value)}
          | {:closure, list(String.t()), prime_gexpr, context()}
          | {:builtin, String.t(), (list(value) -> {:ok, value} | {:error, String.t()})}

  # ------ THE PRIME MOVER'S CONTEXT ------
  @type context :: %{String.t() => value}

  @doc """
  Creates the Genesis Context with the fundamental axioms.
  
  These are the minimal operations needed to bootstrap a self-hosting system:
  - cons/car/cdr for list manipulation
  - id for identity
  - eq? for equality testing
  - cond for conditional logic
  """
  @spec create_genesis_context() :: context
  def create_genesis_context do
    %{
      # The most fundamental axiom: construction
      "cons" => {:builtin, "cons", fn
                 [a, b] -> {:ok, {:list, [a, b]}}
                 _ -> {:error, "cons requires exactly 2 arguments"}
               end},
      # The other half: deconstruction
      "car" => {:builtin, "car", fn
                [{:list, [head | _]}] -> {:ok, head}
                _ -> {:error, "car requires a non-empty list"}
              end},
      "cdr" => {:builtin, "cdr", fn
                [{:list, [_ | tail]}] -> {:ok, {:list, tail}}
                _ -> {:error, "cdr requires a non-empty list"}
              end},
      # Identity function - critical for bootstrapping lambda
      "id" => {:builtin, "id", fn
                [x] -> {:ok, x}
                _ -> {:error, "id requires 1 argument"}
              end},
      # Equality predicate
      "eq?" => {:builtin, "eq?", fn
                 [a, a] -> {:ok, true}
                 [_a, _b] -> {:ok, false}
                 _ -> {:error, "eq? requires 2 arguments"}
               end},
      # The fundamental conditional (our 'prime-if')
      "cond" => {:builtin, "cond", fn
                  [true, then_val, _else_val] -> {:ok, then_val}
                  [false, _then_val, else_val] -> {:ok, else_val}
                  _ -> {:error, "cond requires 3 arguments [bool, then, else]"}
                end},

      # Arithmetic operations for testing
      "+" => {:builtin, "+", fn
               [a, b] when is_number(a) and is_number(b) -> {:ok, a + b}
               _ -> {:error, "+ requires 2 numbers"}
             end},
      
      "-" => {:builtin, "-", fn
               [a, b] when is_number(a) and is_number(b) -> {:ok, a - b}
               _ -> {:error, "- requires 2 numbers"}  
             end},
             
      "*" => {:builtin, "*", fn
               [a, b] when is_number(a) and is_number(b) -> {:ok, a * b}
               _ -> {:error, "* requires 2 numbers"}
             end},

      # Comparison operations
      "<=" => {:builtin, "<=", fn
                [a, b] when is_number(a) and is_number(b) -> {:ok, a <= b}
                _ -> {:error, "<= requires 2 numbers"}
              end}
    }
  end

  @doc """
  The Prime Mover unfurling function.
  
  Takes a G-Expression and context, and evaluates it according to the
  fundamental rules of computation.
  """
  @spec unfurl(prime_gexpr, context) :: {:ok, value} | {:error, String.t()}
  def unfurl(gexpr, context)

  # Rule 1: Literal - just return the value
  def unfurl({:lit, value}, _context), do: {:ok, value}

  # Rule 2: Reference - look it up in the context
  def unfurl({:ref, name}, context) do
    case Map.get(context, name) do
      nil -> {:error, "Undefined reference: #{name}"}
      value -> {:ok, value}
    end
  end

  # Rule 3: Application - evaluate function and argument, then apply
  def unfurl({:app, fun_gexpr, arg_gexpr}, context) do
    with {:ok, fun_val} <- unfurl(fun_gexpr, context),
         {:ok, arg_val} <- unfurl(arg_gexpr, context) do
      # If arg_val is a list, spread it as arguments, otherwise use as single arg
      args = case arg_val do
        {:list, elements} -> elements
        single_arg -> [single_arg]
      end
      apply_value(fun_val, args)
    end
  end

  # Rule 4: Vector - evaluate each element
  def unfurl({:vec, elements}, context) do
    results = Enum.map(elements, &unfurl(&1, context))
    # Check if any evaluation failed
    if Enum.any?(results, &match?({:error, _}, &1)) do
      # Find the first error
      error = Enum.find(results, &match?({:error, _}, &1))
      error
    else
      {:ok, {:list, Enum.map(results, fn {:ok, val} -> val end)}}
    end
  end

  # Rule 5: Lambda abstraction (closure creation)
  def unfurl({:lam, %{params: params, body: body}}, context) do
    {:ok, {:closure, params, body, context}}
  end

  # Rule 6: Fixed point combinator (Y-combinator)
  def unfurl({:fix, f}, context) do
    # Create the fixed point by applying f to (fix f)
    fixed_point_app = {:app, f, {:fix, f}}
    unfurl(fixed_point_app, context)
  end

  # Rule 7: Pattern matching
  def unfurl({:match, expr, branches}, context) do
    with {:ok, value} <- unfurl(expr, context) do
      case select_matching_branch(value, branches, context) do
        {:ok, selected_expr} -> unfurl(selected_expr, context)
        error -> error
      end
    end
  end

  @doc """
  Applies a value as a function to a list of arguments.
  """
  @spec apply_value(value, list(value)) :: {:ok, value} | {:error, String.t()}
  def apply_value({:builtin, _name, func}, args), do: func.(args)
  
  # Apply closure (lambda)
  def apply_value({:closure, params, body, closure_context}, args) do
    if length(params) != length(args) do
      {:error, "Arity mismatch: expected #{length(params)}, got #{length(args)}"}
    else
      # Create new context with parameters bound to arguments
      param_bindings = Enum.zip(params, args) |> Map.new()
      new_context = Map.merge(closure_context, param_bindings)
      unfurl(body, new_context)
    end
  end
  
  def apply_value(other, _args), do: {:error, "Not a function: #{inspect(other)}"}

  @doc """
  Select the appropriate branch in pattern matching.
  """
  @spec select_matching_branch(value, list({pattern, prime_gexpr}), context) :: {:ok, prime_gexpr} | {:error, String.t()}
  def select_matching_branch(value, branches, _context) do
    case find_matching_pattern(value, branches) do
      nil -> {:error, "No matching pattern for value: #{inspect(value)}"}
      {_pattern, expr} -> {:ok, expr}
    end
  end

  defp find_matching_pattern(_value, []), do: nil
  
  defp find_matching_pattern(value, [{{:lit_pattern, pattern_val}, expr} | rest]) do
    if value == pattern_val do
      {{:lit_pattern, pattern_val}, expr}
    else
      find_matching_pattern(value, rest)
    end
  end
  
  defp find_matching_pattern(_value, [{{:ref_pattern, _name}, expr} | _rest]) do
    # Reference patterns always match and bind the value
    {{:ref_pattern, _name}, expr}
  end
  
  defp find_matching_pattern(_value, [{:else_pattern, expr} | _rest]) do
    # Else patterns always match
    {:else_pattern, expr}
  end

  defp find_matching_pattern(value, [_head | tail]) do
    find_matching_pattern(value, tail)
  end
end