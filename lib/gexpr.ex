defmodule Gexpr do
  @moduledoc """
  G-Expression System - A minimal, self-bootstrapping computational framework.
  
  G-Expressions represent the essence of computation through a minimal set of
  primitive operations that can unfurl into complex, self-hosting systems.
  
  ## Core Concepts
  
  - **Prime Mover**: The minimal interpreter that understands basic G-Expressions
  - **Genesis Context**: The foundational definitions that bootstrap the system
  - **Unfurling**: The process of evaluating G-Expressions into values
  
  ## Basic Usage
  
      # Bootstrap the system
      {:ok, context} = Gexpr.bootstrap()
      
      # Evaluate a simple expression
      Gexpr.eval({:lit, 42}, context)
      #=> {:ok, 42}
      
      # Apply a function
      Gexpr.eval({:app, {:ref, "id"}, {:lit, "hello"}}, context)
      #=> {:ok, "hello"}
  """

  alias Gexpr.{PrimeMover, Bootstrap}

  @doc """
  Bootstraps the G-Expression system and returns a complete context.
  """
  @spec bootstrap() :: {:ok, PrimeMover.context()} | {:error, String.t()}
  defdelegate bootstrap(), to: Bootstrap

  @doc """
  Evaluates a G-Expression in the given context.
  """
  @spec eval(PrimeMover.prime_gexpr(), PrimeMover.context()) :: 
    {:ok, PrimeMover.value()} | {:error, String.t()}
  defdelegate eval(gexpr, context), to: PrimeMover, as: :unfurl

  @doc """
  Creates a literal G-Expression.
  """
  @spec lit(any()) :: PrimeMover.prime_gexpr()
  def lit(value), do: {:lit, value}

  @doc """
  Creates a reference G-Expression.
  """
  @spec ref(String.t()) :: PrimeMover.prime_gexpr()
  def ref(name), do: {:ref, name}

  @doc """
  Creates an application G-Expression.
  """
  @spec app(PrimeMover.prime_gexpr(), PrimeMover.prime_gexpr()) :: PrimeMover.prime_gexpr()
  def app(fun_gexpr, arg_gexpr), do: {:app, fun_gexpr, arg_gexpr}

  @doc """
  Creates a vector G-Expression.
  """
  @spec vec(list(PrimeMover.prime_gexpr())) :: PrimeMover.prime_gexpr()
  def vec(elements), do: {:vec, elements}
end
