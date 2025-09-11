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

  @type value ::
          number()
          | atom()
          | String.t()
          | {:symbol, String.t()}
          | {:list, list(value)}
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

  @doc """
  Applies a value as a function to a list of arguments.
  """
  @spec apply_value(value, list(value)) :: {:ok, value} | {:error, String.t()}
  def apply_value({:builtin, _name, func}, args), do: func.(args)
  def apply_value(other, _args), do: {:error, "Not a function: #{inspect(other)}"}
end