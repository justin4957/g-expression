defmodule Gexpr.Semantics do
  @moduledoc """
  Formal semantics and reduction rules for G-Expressions.
  
  This module defines the precise unfurling rules that transform
  G-Expressions into values according to a deterministic semantics.
  
  ## Formal Semantics
  
  The unfurling rules are defined as:
  
      unfurl(lit v, ctx) → v
      unfurl(ref x, ctx) → unfurl(ctx[x], ctx)
      unfurl(app f args, ctx) → apply(unfurl(f, ctx), unfurl(args, ctx), ctx)
      unfurl(vec elements, ctx) → [unfurl(e, ctx) for e in elements]
      unfurl(lam {params, body}, ctx) → Closure(params, body, ctx)
      unfurl(fix f, ctx) → unfurl(app(f, fix(f)), ctx)
      unfurl(match expr branches, ctx) → unfurl(select_branch(unfurl(expr, ctx), branches), ctx)
  
  ## Value Types
  
  Values in the G-Expression system include:
  - Primitives: numbers, atoms, strings, booleans
  - Collections: lists (from vec unfurling)
  - Functions: closures and builtins
  - Symbols: semantic markers
  """

  alias Gexpr.PrimeMover

  @type gexpr ::
          {:lit, any()}
          | {:ref, String.t()}
          | {:app, gexpr, gexpr}
          | {:vec, list(gexpr)}
          | {:lam, %{params: list(String.t()), body: gexpr}}
          | {:fix, gexpr}
          | {:match, gexpr, list({pattern, gexpr})}

  @type pattern :: 
          {:lit_pattern, any()}
          | {:ref_pattern, String.t()}
          | :else_pattern

  @type value ::
          any()
          | {:list, list(value)}
          | {:closure, list(String.t()), gexpr, PrimeMover.context()}
          | {:builtin, String.t(), (list(value) -> {:ok, value} | {:error, String.t()})}
          | {:symbol, String.t()}

  @type context :: %{String.t() => value}

  @doc """
  Formal unfurling function implementing the reduction rules.
  
  This is the mathematical definition of G-Expression evaluation.
  """
  @spec unfurl(gexpr, context) :: {:ok, value} | {:error, String.t()}
  def unfurl(gexpr, context)

  # Rule 1: Literal evaluation
  # unfurl(lit v, ctx) → v
  def unfurl({:lit, value}, _context), do: {:ok, value}

  # Rule 2: Reference lookup and recursive unfurling
  # unfurl(ref x, ctx) → unfurl(ctx[x], ctx)  
  def unfurl({:ref, name}, context) do
    case Map.get(context, name) do
      nil -> {:error, "Undefined reference: #{name}"}
      {:builtin, _, _} = builtin -> {:ok, builtin}
      value -> {:ok, value}
    end
  end

  # Rule 3: Function application
  # unfurl(app f args, ctx) → apply(unfurl(f, ctx), unfurl(args, ctx), ctx)
  def unfurl({:app, fun_gexpr, arg_gexpr}, context) do
    with {:ok, fun_val} <- unfurl(fun_gexpr, context),
         {:ok, arg_val} <- unfurl(arg_gexpr, context) do
      apply_function(fun_val, arg_val, context)
    end
  end

  # Rule 4: Vector evaluation
  # unfurl(vec elements, ctx) → [unfurl(e, ctx) for e in elements]
  def unfurl({:vec, elements}, context) do
    results = Enum.map(elements, &unfurl(&1, context))
    
    case Enum.find(results, &match?({:error, _}, &1)) do
      nil -> {:ok, {:list, Enum.map(results, fn {:ok, val} -> val end)}}
      error -> error
    end
  end

  # Rule 5: Lambda abstraction (closure creation)
  # unfurl(lam {params, body}, ctx) → Closure(params, body, ctx)
  def unfurl({:lam, %{params: params, body: body}}, context) do
    {:ok, {:closure, params, body, context}}
  end

  # Rule 6: Fixed point combinator (Y-combinator)
  # unfurl(fix f, ctx) → unfurl(app(f, fix(f)), ctx)
  def unfurl({:fix, f}, context) do
    # Create the fixed point by applying f to (fix f)
    fixed_point_app = {:app, f, {:fix, f}}
    unfurl(fixed_point_app, context)
  end

  # Rule 7: Pattern matching
  # unfurl(match expr branches, ctx) → unfurl(select_branch(unfurl(expr, ctx), branches), ctx)
  def unfurl({:match, expr, branches}, context) do
    with {:ok, value} <- unfurl(expr, context) do
      case select_branch(value, branches) do
        {:ok, selected_expr} -> unfurl(selected_expr, context)
        error -> error
      end
    end
  end

  @doc """
  Apply a function value to arguments.
  """
  @spec apply_function(value, value, context) :: {:ok, value} | {:error, String.t()}
  def apply_function(fun_val, arg_val, context)

  # Apply builtin function
  def apply_function({:builtin, _name, func}, arg_val, _context) do
    args = case arg_val do
      {:list, elements} -> elements
      single_arg -> [single_arg]
    end
    func.(args)
  end

  # Apply closure (lambda)
  def apply_function({:closure, params, body, closure_context}, arg_val, _outer_context) do
    args = case arg_val do
      {:list, elements} -> elements
      single_arg -> [single_arg]
    end

    if length(params) != length(args) do
      {:error, "Arity mismatch: expected #{length(params)}, got #{length(args)}"}
    else
      # Create new context with parameters bound to arguments
      param_bindings = Enum.zip(params, args) |> Map.new()
      new_context = Map.merge(closure_context, param_bindings)
      unfurl(body, new_context)
    end
  end

  def apply_function(other, _arg_val, _context) do
    {:error, "Not a function: #{inspect(other)}"}
  end

  @doc """
  Select the appropriate branch in pattern matching.
  """
  @spec select_branch(value, list({pattern, gexpr})) :: {:ok, gexpr} | {:error, String.t()}
  def select_branch(value, branches) do
    case find_matching_branch(value, branches) do
      nil -> {:error, "No matching pattern for value: #{inspect(value)}"}
      {_pattern, expr} -> {:ok, expr}
    end
  end

  defp find_matching_branch(_value, []), do: nil
  
  defp find_matching_branch(value, [{:lit_pattern, pattern_val}, expr] = branch) do
    if value == pattern_val do
      {elem(branch, 0), expr}
    else
      find_matching_branch(value, [])
    end
  end
  
  defp find_matching_branch(_value, [{:ref_pattern, _name}, expr] = branch) do
    # Reference patterns always match and bind the value
    {elem(branch, 0), expr}
  end
  
  defp find_matching_branch(_value, [:else_pattern, expr] = branch) do
    # Else patterns always match
    {elem(branch, 0), expr}
  end

  defp find_matching_branch(value, [_head | tail]) do
    find_matching_branch(value, tail)
  end

  @doc """
  Create a G-Expression from Elixir data structures.
  """
  @spec from_elixir(any()) :: gexpr
  def from_elixir(data) when is_number(data) or is_atom(data) or is_binary(data), do: {:lit, data}
  def from_elixir(data) when is_list(data), do: {:vec, Enum.map(data, &from_elixir/1)}
  def from_elixir(%{g: type, v: value}), do: parse_gexpr_map(type, value)
  def from_elixir(data), do: {:lit, data}

  defp parse_gexpr_map("lit", value), do: {:lit, value}
  defp parse_gexpr_map("ref", name), do: {:ref, name}
  defp parse_gexpr_map("vec", elements), do: {:vec, Enum.map(elements, &from_elixir/1)}
  defp parse_gexpr_map("app", %{fn: fn_expr, args: args_expr}) do
    {:app, from_elixir(fn_expr), from_elixir(args_expr)}
  end
  defp parse_gexpr_map("lam", %{params: params, body: body}) do
    {:lam, %{params: params, body: from_elixir(body)}}
  end
  defp parse_gexpr_map("fix", f), do: {:fix, from_elixir(f)}
  defp parse_gexpr_map("match", %{expr: expr, branches: branches}) do
    parsed_branches = Enum.map(branches, fn {pattern, branch_expr} ->
      {parse_pattern(pattern), from_elixir(branch_expr)}
    end)
    {:match, from_elixir(expr), parsed_branches}
  end

  defp parse_pattern("else"), do: :else_pattern
  defp parse_pattern(%{lit: value}), do: {:lit_pattern, value}  
  defp parse_pattern(%{ref: name}), do: {:ref_pattern, name}
  defp parse_pattern(value), do: {:lit_pattern, value}
end