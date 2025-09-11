defmodule Gexpr.AiGenerator do
  @moduledoc """
  AI-friendly G-Expression generator and parser.
  
  This module provides utilities for generating and parsing G-Expressions
  in formats that are easy for AI models to understand and generate.
  It bridges the gap between natural language prompts and executable code.
  """

  alias Gexpr.{PrimeMover, Metadata}

  @type ai_prompt :: String.t()
  @type generation_options :: %{
    model: String.t(),
    temperature: float(),
    max_tokens: integer(),
    include_metadata: boolean(),
    security_level: atom()
  }

  @doc """
  Generates a G-Expression from a natural language prompt.
  
  This simulates what an AI model might generate - in practice, this would
  interface with actual AI services like GPT-4, Claude, etc.
  """
  @spec generate_from_prompt(ai_prompt(), generation_options()) :: 
    {:ok, map()} | {:error, String.t()}
  def generate_from_prompt(prompt, options \\ %{}) do
    defaults = %{
      model: "simulated_ai_v1.0",
      temperature: 0.3,
      max_tokens: 1000,
      include_metadata: true,
      security_level: :internal
    }
    
    opts = Map.merge(defaults, options)
    
    case parse_prompt_intent(prompt) do
      {:ok, intent} ->
        gexpr = generate_gexpr_for_intent(intent)
        
        if opts.include_metadata do
          confidence = calculate_confidence(prompt, intent)
          
          result = Metadata.add_ai_provenance(
            gexpr,
            opts.model,
            prompt,
            confidence
          )
          
          {:ok, result}
        else
          {:ok, gexpr}
        end
        
      {:error, reason} ->
        {:error, "Failed to parse prompt: #{reason}"}
    end
  end

  @doc """
  Parses a JSON G-Expression string into executable form.
  """
  @spec parse_json_gexpr(String.t()) :: {:ok, map()} | {:error, String.t()}
  def parse_json_gexpr(json_string) do
    case Jason.decode(json_string) do
      {:ok, parsed} -> validate_gexpr_structure(parsed)
      {:error, error} -> {:error, "JSON parse error: #{inspect(error)}"}
    end
  end

  @doc """
  Converts a G-Expression to AI-friendly JSON format.
  """
  @spec to_ai_json(map()) :: {:ok, String.t()} | {:error, String.t()}
  def to_ai_json(gexpr) do
    case Jason.encode(gexpr, pretty: true) do
      {:ok, json} -> {:ok, json}
      {:error, error} -> {:error, "JSON encode error: #{inspect(error)}"}
    end
  end

  @doc """
  Creates example G-Expressions for AI training.
  """
  @spec generate_training_examples() :: list(map())
  def generate_training_examples do
    [
      # Arithmetic examples
      %{
        "prompt" => "add 20 and 22",
        "gexpr" => %{
          "g" => "app",
          "v" => %{
            "fn" => %{"g" => "ref", "v" => "+"},
            "args" => %{
              "g" => "vec",
              "v" => [
                %{"g" => "lit", "v" => 20},
                %{"g" => "lit", "v" => 22}
              ]
            }
          }
        },
        "expected_result" => 42
      },

      # Function definition examples
      %{
        "prompt" => "create a function that doubles a number",
        "gexpr" => %{
          "g" => "lam",
          "v" => %{
            "params" => ["x"],
            "body" => %{
              "g" => "app",
              "v" => %{
                "fn" => %{"g" => "ref", "v" => "*"},
                "args" => %{
                  "g" => "vec",
                  "v" => [
                    %{"g" => "ref", "v" => "x"},
                    %{"g" => "lit", "v" => 2}
                  ]
                }
              }
            }
          }
        },
        "test_input" => 21,
        "expected_result" => 42
      },

      # Conditional examples
      %{
        "prompt" => "if x is less than or equal to 1, return 1, otherwise return x",
        "gexpr" => %{
          "g" => "lam",
          "v" => %{
            "params" => ["x"],
            "body" => %{
              "g" => "match",
              "v" => %{
                "expr" => %{
                  "g" => "app",
                  "v" => %{
                    "fn" => %{"g" => "ref", "v" => "<="},
                    "args" => %{
                      "g" => "vec",
                      "v" => [
                        %{"g" => "ref", "v" => "x"},
                        %{"g" => "lit", "v" => 1}
                      ]
                    }
                  }
                },
                "branches" => [
                  {%{"lit" => true}, %{"g" => "lit", "v" => 1}},
                  {"else", %{"g" => "ref", "v" => "x"}}
                ]
              }
            }
          }
        }
      },

      # Recursive examples
      %{
        "prompt" => "factorial function using recursion",
        "gexpr" => %{
          "g" => "fix",
          "v" => %{
            "g" => "lam",
            "v" => %{
              "params" => ["f"],
              "body" => %{
                "g" => "lam",
                "v" => %{
                  "params" => ["n"],
                  "body" => %{
                    "g" => "match",
                    "v" => %{
                      "expr" => %{
                        "g" => "app",
                        "v" => %{
                          "fn" => %{"g" => "ref", "v" => "<="},
                          "args" => %{
                            "g" => "vec",
                            "v" => [
                              %{"g" => "ref", "v" => "n"},
                              %{"g" => "lit", "v" => 1}
                            ]
                          }
                        }
                      },
                      "branches" => [
                        {%{"lit" => true}, %{"g" => "lit", "v" => 1}},
                        {"else", %{
                          "g" => "app",
                          "v" => %{
                            "fn" => %{"g" => "ref", "v" => "*"},
                            "args" => %{
                              "g" => "vec",
                              "v" => [
                                %{"g" => "ref", "v" => "n"},
                                %{
                                  "g" => "app",
                                  "v" => %{
                                    "fn" => %{"g" => "ref", "v" => "f"},
                                    "args" => %{
                                      "g" => "vec",
                                      "v" => [%{
                                        "g" => "app",
                                        "v" => %{
                                          "fn" => %{"g" => "ref", "v" => "-"},
                                          "args" => %{
                                            "g" => "vec",
                                            "v" => [
                                              %{"g" => "ref", "v" => "n"},
                                              %{"g" => "lit", "v" => 1}
                                            ]
                                          }
                                        }
                                      }]
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        }}
                      ]
                    }
                  }
                }
              }
            }
          }
        }
      }
    ]
  end

  @doc """
  Validates and tests generated G-Expressions.
  """
  @spec validate_and_test(map(), any(), any()) :: 
    {:ok, :valid} | {:error, String.t()}
  def validate_and_test(gexpr, test_input \\ nil, expected_output \\ nil) do
    with {:ok, _} <- validate_gexpr_structure(gexpr),
         {:ok, context} <- get_test_context(),
         {:ok, result} <- test_execution(gexpr, test_input, context) do
      
      if expected_output && result != expected_output do
        {:error, "Expected #{inspect(expected_output)}, got #{inspect(result)}"}
      else
        {:ok, :valid}
      end
    end
  end

  @doc """
  Provides prompting guidelines for AI models.
  """
  @spec ai_prompting_guide() :: String.t()
  def ai_prompting_guide do
    """
    # G-Expression Generation Guide for AI Models

    When generating G-Expressions, follow these patterns:

    ## Basic Structure
    Every G-Expression has this form:
    ```json
    {
      "g": "operation_type",
      "v": "operation_data"
    }
    ```

    ## Core Operations:

    1. **Literals**: `{"g": "lit", "v": value}`
       - Numbers: `{"g": "lit", "v": 42}`
       - Strings: `{"g": "lit", "v": "hello"}`
       - Booleans: `{"g": "lit", "v": true}`

    2. **References**: `{"g": "ref", "v": "name"}`
       - Variables: `{"g": "ref", "v": "x"}`
       - Functions: `{"g": "ref", "v": "+"}`

    3. **Vectors**: `{"g": "vec", "v": [element1, element2, ...]}`

    4. **Applications**: 
       ```json
       {
         "g": "app",
         "v": {
           "fn": function_gexpr,
           "args": arguments_gexpr
         }
       }
       ```

    5. **Lambdas**:
       ```json
       {
         "g": "lam", 
         "v": {
           "params": ["param1", "param2"],
           "body": body_gexpr
         }
       }
       ```

    ## Common Patterns:

    - **Add two numbers**: Use `+` with a vector of arguments
    - **Function calls**: Always wrap arguments in vectors
    - **Conditionals**: Use pattern matching with `match`
    - **Recursion**: Use the `fix` combinator

    ## Best Practices:
    - Always validate JSON structure
    - Use descriptive parameter names
    - Keep expressions focused and modular
    - Include metadata for provenance tracking
    """
  end

  # Private helper functions

  defp parse_prompt_intent(prompt) do
    prompt_lower = String.downcase(prompt)
    
    cond do
      String.contains?(prompt_lower, ["add", "+"]) and 
      String.contains?(prompt_lower, ["and", "plus"]) ->
        {:ok, :arithmetic_add}
        
      String.contains?(prompt_lower, ["function", "create", "define"]) and
      String.contains?(prompt_lower, ["double", "times 2", "* 2"]) ->
        {:ok, :function_double}
        
      String.contains?(prompt_lower, ["factorial", "fact"]) ->
        {:ok, :factorial}
        
      String.contains?(prompt_lower, ["if", "conditional", "condition"]) ->
        {:ok, :conditional}
        
      true ->
        {:error, "Unknown intent"}
    end
  end

  defp generate_gexpr_for_intent(:arithmetic_add) do
    %{
      "g" => "app",
      "v" => %{
        "fn" => %{"g" => "ref", "v" => "+"},
        "args" => %{
          "g" => "vec",
          "v" => [
            %{"g" => "lit", "v" => 20},
            %{"g" => "lit", "v" => 22}
          ]
        }
      }
    }
  end

  defp generate_gexpr_for_intent(:function_double) do
    %{
      "g" => "lam",
      "v" => %{
        "params" => ["x"],
        "body" => %{
          "g" => "app",
          "v" => %{
            "fn" => %{"g" => "ref", "v" => "*"},
            "args" => %{
              "g" => "vec",
              "v" => [
                %{"g" => "ref", "v" => "x"},
                %{"g" => "lit", "v" => 2}
              ]
            }
          }
        }
      }
    }
  end

  defp generate_gexpr_for_intent(intent) do
    # Default fallback for unknown intents
    %{
      "g" => "lit",
      "v" => "Generated for intent: #{intent}"
    }
  end

  defp calculate_confidence(prompt, intent) do
    base_confidence = 0.7
    
    # Increase confidence for clear mathematical operations
    confidence = if intent == :arithmetic_add and String.contains?(prompt, ["add", "+"]) do
      base_confidence + 0.2
    else
      base_confidence
    end
    
    # Decrease confidence for vague prompts
    confidence = if String.length(prompt) < 10 do
      confidence - 0.1
    else
      confidence
    end
    
    max(0.1, min(1.0, confidence))
  end

  defp validate_gexpr_structure(%{"g" => _g, "v" => _v} = gexpr) do
    {:ok, gexpr}
  end

  defp validate_gexpr_structure(_invalid) do
    {:error, "Invalid G-Expression structure: must have 'g' and 'v' keys"}
  end

  defp get_test_context do
    {:ok, PrimeMover.create_genesis_context()}
  end

  defp test_execution(gexpr, test_input, context) do
    try do
      # Convert to internal format and execute
      internal_gexpr = convert_to_internal(gexpr)
      
      case test_input do
        nil ->
          PrimeMover.unfurl(internal_gexpr, context)
        input ->
          # Apply as function if test input provided
          with {:ok, func} <- PrimeMover.unfurl(internal_gexpr, context) do
            PrimeMover.apply_value(func, [input])
          end
      end
    rescue
      e -> {:error, "Execution error: #{inspect(e)}"}
    end
  end

  defp convert_to_internal(%{"g" => "lit", "v" => value}), do: {:lit, value}
  defp convert_to_internal(%{"g" => "ref", "v" => name}), do: {:ref, name}
  defp convert_to_internal(%{"g" => "vec", "v" => elements}) do
    {:vec, Enum.map(elements, &convert_to_internal/1)}
  end
  defp convert_to_internal(%{"g" => "app", "v" => %{"fn" => fn_expr, "args" => args_expr}}) do
    {:app, convert_to_internal(fn_expr), convert_to_internal(args_expr)}
  end
  defp convert_to_internal(%{"g" => "lam", "v" => %{"params" => params, "body" => body}}) do
    {:lam, %{params: params, body: convert_to_internal(body)}}
  end
  defp convert_to_internal(other), do: {:lit, other}
end