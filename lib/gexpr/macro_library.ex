defmodule Gexpr.MacroLibrary do
  @moduledoc """
  A library of common macros implemented as pure G-Expressions.
  
  This demonstrates how complex language constructs can be built up from
  the minimal G-Expression primitives, creating a self-hosting macro system.
  """

  alias Gexpr.PrimeMover

  @doc """
  Returns the complete macro library as G-Expression definitions.
  """
  @spec get_macro_library() :: list({String.t(), PrimeMover.prime_gexpr()})
  def get_macro_library do
    [
      # Basic control flow
      {"when", when_macro()},
      {"unless", unless_macro()},
      {"let", let_macro()},
      
      # List operations  
      {"map", map_macro()},
      {"filter", filter_macro()},
      {"reduce", reduce_macro()},
      
      # Arithmetic conveniences
      {"inc", inc_macro()},
      {"dec", dec_macro()},
      {"square", square_macro()},
      
      # Logical operations
      {"and", and_macro()},
      {"or", or_macro()},
      {"not", not_macro()},
      
      # Comparison operations
      {"=", eq_macro()},
      {"!=", ne_macro()},
      {">", gt_macro()},
      {"<", lt_macro()},
      {">=", ge_macro()},
      
      # Higher-order functions
      {"compose", compose_macro()},
      {"partial", partial_macro()},
      {"curry", curry_macro()},
      
      # Advanced control flow
      {"try", try_macro()},
      {"case", case_macro()}
    ]
  end

  @doc """
  Loads the macro library into a context.
  """
  @spec load_macros_into_context(PrimeMover.context()) :: PrimeMover.context()
  def load_macros_into_context(context) do
    get_macro_library()
    |> Enum.reduce(context, fn {name, macro_gexpr}, acc_context ->
      case PrimeMover.unfurl(macro_gexpr, acc_context) do
        {:ok, macro_value} -> Map.put(acc_context, name, macro_value)
        {:error, _} -> acc_context  # Skip failed macros
      end
    end)
  end

  # ===== BASIC CONTROL FLOW MACROS =====

  defp when_macro do
    # when(condition, body) → if condition then body else nil
    {:lam, %{
      params: ["condition", "body"],
      body: {:app, {:ref, "cond"}, {:vec, [
        {:ref, "condition"},
        {:ref, "body"},
        {:lit, nil}
      ]}}
    }}
  end

  defp unless_macro do
    # unless(condition, body) → if condition then nil else body
    {:lam, %{
      params: ["condition", "body"],
      body: {:app, {:ref, "cond"}, {:vec, [
        {:ref, "condition"},
        {:lit, nil},
        {:ref, "body"}
      ]}}
    }}
  end

  defp let_macro do
    # let(bindings, body) - simplified version for single binding
    # let([x, 42], body) → ((λx. body) 42)
    {:lam, %{
      params: ["binding", "body"],
      body: {:app, 
        {:lam, %{
          params: ["x"],
          body: {:ref, "body"}
        }},
        {:vec, [{:app, {:ref, "cdr"}, {:vec, [{:ref, "binding"}]}}]}
      }
    }}
  end

  # ===== LIST OPERATIONS =====

  defp map_macro do
    # map(f, list) - simplified single-element version
    {:lam, %{
      params: ["f", "x"],
      body: {:app, {:ref, "f"}, {:vec, [{:ref, "x"}]}}
    }}
  end

  defp filter_macro do
    # filter(predicate, list) - simplified version
    {:lam, %{
      params: ["pred", "x"],
      body: {:app, {:ref, "cond"}, {:vec, [
        {:app, {:ref, "pred"}, {:vec, [{:ref, "x"}]}},
        {:ref, "x"},
        {:lit, nil}
      ]}}
    }}
  end

  defp reduce_macro do
    # reduce(f, acc, list) - simplified version  
    {:lam, %{
      params: ["f", "acc", "x"],
      body: {:app, {:ref, "f"}, {:vec, [{:ref, "acc"}, {:ref, "x"}]}}
    }}
  end

  # ===== ARITHMETIC CONVENIENCES =====

  defp inc_macro do
    # inc(x) → x + 1
    {:lam, %{
      params: ["x"],
      body: {:app, {:ref, "+"}, {:vec, [{:ref, "x"}, {:lit, 1}]}}
    }}
  end

  defp dec_macro do
    # dec(x) → x - 1
    {:lam, %{
      params: ["x"],
      body: {:app, {:ref, "-"}, {:vec, [{:ref, "x"}, {:lit, 1}]}}
    }}
  end

  defp square_macro do
    # square(x) → x * x
    {:lam, %{
      params: ["x"],
      body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:ref, "x"}]}}
    }}
  end

  # ===== LOGICAL OPERATIONS =====

  defp and_macro do
    # and(a, b) → if a then b else false
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "cond"}, {:vec, [
        {:ref, "a"},
        {:ref, "b"},
        {:lit, false}
      ]}}
    }}
  end

  defp or_macro do
    # or(a, b) → if a then true else b
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "cond"}, {:vec, [
        {:ref, "a"},
        {:lit, true},
        {:ref, "b"}
      ]}}
    }}
  end

  defp not_macro do
    # not(x) → if x then false else true
    {:lam, %{
      params: ["x"],
      body: {:app, {:ref, "cond"}, {:vec, [
        {:ref, "x"},
        {:lit, false},
        {:lit, true}
      ]}}
    }}
  end

  # ===== COMPARISON OPERATIONS =====

  defp eq_macro do
    # =(a, b) → eq?(a, b)
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "eq?"}, {:vec, [{:ref, "a"}, {:ref, "b"}]}}
    }}
  end

  defp ne_macro do
    # !=(a, b) → not(eq?(a, b))
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "not"}, {:vec, [
        {:app, {:ref, "eq?"}, {:vec, [{:ref, "a"}, {:ref, "b"}]}}
      ]}}
    }}
  end

  defp gt_macro do
    # >(a, b) → not(<=(a, b))
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "not"}, {:vec, [
        {:app, {:ref, "<="}, {:vec, [{:ref, "a"}, {:ref, "b"}]}}
      ]}}
    }}
  end

  defp lt_macro do
    # <(a, b) → <=(a, b) and not(eq?(a, b))
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "and"}, {:vec, [
        {:app, {:ref, "<="}, {:vec, [{:ref, "a"}, {:ref, "b"}]}},
        {:app, {:ref, "not"}, {:vec, [
          {:app, {:ref, "eq?"}, {:vec, [{:ref, "a"}, {:ref, "b"}]}}
        ]}}
      ]}}
    }}
  end

  defp ge_macro do
    # >=(a, b) → eq?(a, b) or not(<=(a, b))
    {:lam, %{
      params: ["a", "b"],
      body: {:app, {:ref, "or"}, {:vec, [
        {:app, {:ref, "eq?"}, {:vec, [{:ref, "a"}, {:ref, "b"}]}},
        {:app, {:ref, "not"}, {:vec, [
          {:app, {:ref, "<="}, {:vec, [{:ref, "a"}, {:ref, "b"}]}}
        ]}}
      ]}}
    }}
  end

  # ===== HIGHER-ORDER FUNCTIONS =====

  defp compose_macro do
    # compose(f, g) → λx. f(g(x))
    {:lam, %{
      params: ["f", "g"],
      body: {:lam, %{
        params: ["x"],
        body: {:app, {:ref, "f"}, {:vec, [
          {:app, {:ref, "g"}, {:vec, [{:ref, "x"}]}}
        ]}}
      }}
    }}
  end

  defp partial_macro do
    # partial(f, a) → λx. f(a, x)
    {:lam, %{
      params: ["f", "a"],
      body: {:lam, %{
        params: ["x"],
        body: {:app, {:ref, "f"}, {:vec, [{:ref, "a"}, {:ref, "x"}]}}
      }}
    }}
  end

  defp curry_macro do
    # curry(f) → λa.λb. f(a, b) - transforms binary function to curried form
    {:lam, %{
      params: ["f"],
      body: {:lam, %{
        params: ["a"],
        body: {:lam, %{
          params: ["b"],
          body: {:app, {:ref, "f"}, {:vec, [{:ref, "a"}, {:ref, "b"}]}}
        }}
      }}
    }}
  end

  # ===== ADVANCED CONTROL FLOW =====

  defp try_macro do
    # try(expr, handler) - simplified error handling
    {:lam, %{
      params: ["expr", "handler"],
      body: {:ref, "expr"}  # Simplified - would need error handling in real implementation
    }}
  end

  defp case_macro do
    # case(expr, branches) - pattern matching (simplified)
    {:lam, %{
      params: ["expr", "branches"],
      body: {:match, {:ref, "expr"}, [
        :else_pattern, {:ref, "branches"}
      ]}
    }}
  end

  @doc """
  Returns example usage of macros as G-Expressions.
  """
  @spec macro_examples() :: list({String.t(), map()})
  def macro_examples do
    [
      {
        "when example",
        %{
          "description" => "Execute body only when condition is true",
          "gexpr" => %{
            "g" => "app",
            "v" => %{
              "fn" => %{"g" => "ref", "v" => "when"},
              "args" => %{
                "g" => "vec",
                "v" => [
                  %{
                    "g" => "app",
                    "v" => %{
                      "fn" => %{"g" => "ref", "v" => ">"},
                      "args" => %{
                        "g" => "vec", 
                        "v" => [
                          %{"g" => "lit", "v" => 10},
                          %{"g" => "lit", "v" => 5}
                        ]
                      }
                    }
                  },
                  %{"g" => "lit", "v" => "condition was true!"}
                ]
              }
            }
          }
        }
      },
      
      {
        "compose example",
        %{
          "description" => "Compose increment and square functions",
          "gexpr" => %{
            "g" => "app",
            "v" => %{
              "fn" => %{
                "g" => "app",
                "v" => %{
                  "fn" => %{"g" => "ref", "v" => "compose"},
                  "args" => %{
                    "g" => "vec",
                    "v" => [
                      %{"g" => "ref", "v" => "square"},
                      %{"g" => "ref", "v" => "inc"}
                    ]
                  }
                }
              },
              "args" => %{
                "g" => "vec",
                "v" => [%{"g" => "lit", "v" => 5}]
              }
            }
          },
          "description_note" => "This computes square(inc(5)) = square(6) = 36"
        }
      }
    ]
  end

  @doc """
  Creates a complete G-Expression environment with macros loaded.
  """
  @spec create_macro_environment() :: {:ok, PrimeMover.context()} | {:error, String.t()}
  def create_macro_environment do
    base_context = PrimeMover.create_genesis_context()
    macro_context = load_macros_into_context(base_context)
    
    # Verify essential macros loaded
    essential_macros = ["when", "inc", "square", "compose"]
    missing = Enum.filter(essential_macros, &(!Map.has_key?(macro_context, &1)))
    
    if Enum.empty?(missing) do
      {:ok, macro_context}
    else
      {:error, "Failed to load essential macros: #{inspect(missing)}"}
    end
  end
end