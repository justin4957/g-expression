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

  alias Gexpr.{PrimeMover, Bootstrap, Semantics, MacroLibrary, AiGenerator, Metadata, JsCompiler}

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

  @doc """
  Creates a lambda G-Expression.
  """
  @spec lam(list(String.t()), PrimeMover.prime_gexpr()) :: PrimeMover.prime_gexpr()
  def lam(params, body), do: {:lam, %{params: params, body: body}}

  @doc """
  Creates a fixed-point G-Expression (Y-combinator).
  """
  @spec fix(PrimeMover.prime_gexpr()) :: PrimeMover.prime_gexpr()
  def fix(f), do: {:fix, f}

  @doc """
  Creates a match G-Expression for pattern matching.
  """
  @spec match(PrimeMover.prime_gexpr(), list()) :: PrimeMover.prime_gexpr()
  def match(expr, branches), do: {:match, expr, branches}

  # ===== ADVANCED FUNCTIONALITY =====

  @doc """
  Creates a macro-enabled environment with extended functionality.
  """
  @spec bootstrap_with_macros() :: {:ok, PrimeMover.context()} | {:error, String.t()}
  defdelegate bootstrap_with_macros(), to: MacroLibrary, as: :create_macro_environment

  @doc """
  Evaluates G-Expressions using the formal semantics engine.
  """
  @spec eval_with_semantics(Semantics.gexpr(), PrimeMover.context()) :: 
    {:ok, Semantics.value()} | {:error, String.t()}
  defdelegate eval_with_semantics(gexpr, context), to: Semantics, as: :unfurl

  @doc """
  Generates a G-Expression from a natural language prompt (AI-friendly).
  """
  @spec generate_from_ai_prompt(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  defdelegate generate_from_ai_prompt(prompt, options \\ %{}), to: AiGenerator, as: :generate_from_prompt

  @doc """
  Adds AI provenance metadata to a G-Expression.
  """
  @spec add_ai_metadata(map(), String.t(), String.t(), float()) :: map()
  defdelegate add_ai_metadata(gexpr, model, prompt, confidence), to: Metadata, as: :add_ai_provenance

  @doc """
  Creates a provenance report for a G-Expression.
  """
  @spec provenance_report(map()) :: String.t()
  defdelegate provenance_report(gexpr), to: Metadata

  @doc """
  Converts a G-Expression to AI-friendly JSON format.
  """
  @spec to_ai_json(map()) :: {:ok, String.t()} | {:error, String.t()}
  defdelegate to_ai_json(gexpr), to: AiGenerator

  @doc """
  Parses a JSON G-Expression string.
  """
  @spec parse_ai_json(String.t()) :: {:ok, map()} | {:error, String.t()}
  defdelegate parse_ai_json(json), to: AiGenerator, as: :parse_json_gexpr

  @doc """
  Returns example G-Expressions for training AI models.
  """
  @spec ai_training_examples() :: list(map())
  defdelegate ai_training_examples(), to: AiGenerator, as: :generate_training_examples

  @doc """
  Gets the AI prompting guide for G-Expression generation.
  """
  @spec ai_guide() :: String.t()
  defdelegate ai_guide(), to: AiGenerator, as: :ai_prompting_guide

  # ===== JAVASCRIPT COMPILATION =====

  @doc """
  Compiles a G-Expression to JavaScript code.
  
  This is the killer feature that proves G-Expressions are a universal substrate.
  """
  @spec compile_to_js(PrimeMover.prime_gexpr()) :: {:ok, String.t()} | {:error, String.t()}
  defdelegate compile_to_js(gexpr), to: JsCompiler

  @doc """
  Compiles a G-Expression to a complete JavaScript function.
  """
  @spec compile_to_js_function(PrimeMover.prime_gexpr(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defdelegate compile_to_js_function(gexpr, function_name \\ "gexpr_func"), to: JsCompiler

  @doc """
  Compiles a lambda G-Expression to a JavaScript function with parameters.
  """
  @spec compile_lambda_to_js_function(PrimeMover.prime_gexpr(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defdelegate compile_lambda_to_js_function(lambda_gexpr, function_name \\ "gexpr_func"), to: JsCompiler

  @doc """
  End-to-end: compiles G-Expression to JavaScript and runs it with Node.js.
  """
  @spec compile_and_run(PrimeMover.prime_gexpr(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defdelegate compile_and_run(gexpr, function_name \\ "gexpr_func"), to: JsCompiler
end
