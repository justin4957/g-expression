defmodule Gexpr.Bootstrap do
  @moduledoc """
  The Bootstrap module that uses the Prime Mover to build a self-hosting system.
  
  This module loads the Genesis Context definitions and uses the Prime Mover
  to unfurl them into a complete computational environment.
  """

  alias Gexpr.PrimeMover

  @genesis_path "priv/genesis_context.exs"

  @doc """
  Bootstraps the G-Expression system from the Genesis Context.
  
  Returns a fully bootstrapped context containing all the fundamental
  operations needed for self-hosting computation.
  """
  @spec bootstrap() :: {:ok, PrimeMover.context()} | {:error, String.t()}
  def bootstrap do
    # Start with the absolute minimal context (axioms)
    prime_context = PrimeMover.create_genesis_context()

    # Load the Genesis G-Expressions (Layer 1)
    case load_genesis_gexprs() do
      {:ok, genesis_gexprs} ->
        # Evaluate each definition in the genesis context to build the full context
        Enum.reduce_while(genesis_gexprs, {:ok, prime_context}, fn
          {:def, name, definition_gexpr}, {:ok, acc_context} ->
            case PrimeMover.unfurl(definition_gexpr, acc_context) do
              {:ok, value} ->
                new_context = Map.put(acc_context, name, value)
                {:cont, {:ok, new_context}}

              {:error, reason} ->
                {:halt, {:error, "Failed to define #{name}: #{reason}"}}
            end
        end)
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Loads the genesis G-expressions from the configuration file.
  """
  @spec load_genesis_gexprs() :: {:ok, list()} | {:error, String.t()}
  def load_genesis_gexprs do
    # Try multiple possible paths
    possible_paths = [
      Application.app_dir(:gexpr, @genesis_path),
      Path.join([File.cwd!(), @genesis_path]),
      @genesis_path
    ]
    
    genesis_file = Enum.find(possible_paths, &File.exists?/1)
    
    case genesis_file do
      nil ->
        # Return a minimal genesis context if file doesn't exist
        {:ok, create_minimal_genesis()}
      
      file_path ->
        try do
          {genesis_data, _} = Code.eval_file(file_path)
          {:ok, genesis_data}
        rescue
          e -> {:error, "Failed to load genesis file: #{Exception.message(e)}"}
        end
    end
  end

  defp create_minimal_genesis do
    [
      # Define a simple lambda constructor
      {:def, "lambda",
       {:vec, [
         {:lit, {:symbol, "lam"}},
         {:vec, [
           {:lit, {:symbol, "params"}},
           {:lit, {:symbol, "body"}}
         ]},
         {:app, {:ref, "cons"}, {:vec, [
           {:lit, {:symbol, "closure"}},
           {:app, {:ref, "cons"}, {:vec, [
             {:ref, "params"},
             {:ref, "body"}
           ]}}
         ]}}
       ]}},

      # Define if in terms of cond
      {:def, "if",
       {:vec, [
         {:lit, {:symbol, "lam"}},
         {:vec, [
           {:lit, {:symbol, "condition"}},
           {:lit, {:symbol, "then"}},
           {:lit, {:symbol, "else"}}
         ]},
         {:app, {:ref, "cond"}, {:vec, [
           {:ref, "condition"},
           {:ref, "then"},
           {:ref, "else"}
         ]}}
       ]}}
    ]
  end
end