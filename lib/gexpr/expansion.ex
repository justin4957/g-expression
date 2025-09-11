defmodule Gexpr.Expansion do
  @moduledoc """
  Generative expansion system for G-expressions.
  
  This module implements the core expansion mechanics from expansion.md,
  allowing G-expressions to unfold into more complex structures through
  controlled transformation processes.
  """

  alias Gexpr.PrimeMover

  @typedoc "Generator types for different expansion strategies"
  @type generator :: :lazy | :adaptive | :genetic | :lsystem | :spec | :fixed

  @typedoc "Expansion state tracking depth, iterations, and constraints"
  @type expansion_state :: %{
          depth: non_neg_integer(),
          iterations: non_neg_integer(),
          resources_used: map(),
          history: [transformation_step()],
          constraints: map()
        }

  @typedoc "A single transformation in the expansion history"
  @type transformation_step :: %{
          from: gexpr(),
          to: gexpr(),
          rule: String.t(),
          timestamp: integer()
        }

  @typedoc "Expanded G-expression with generation metadata"
  @type expandable_gexpr :: %{
          generator: generator(),
          value: any(),
          meta: map(),
          expansion_state: expansion_state()
        }

  @typedoc "Standard G-expression format"
  @type gexpr :: PrimeMover.gexpr()

  @typedoc "Expansion context with rules and limits"
  @type expansion_context :: %{
          rules: map(),
          limits: %{
            max_depth: pos_integer(),
            max_iterations: pos_integer(),
            max_time_ms: pos_integer()
          },
          world_model: map(),
          observation_points: [map()]
        }

  @doc """
  Creates a new expandable G-expression with generator metadata.
  """
  @spec create_expandable(generator(), any(), map()) :: expandable_gexpr()
  def create_expandable(generator, value, meta \\ %{}) do
    %{
      generator: generator,
      value: value,
      meta: meta,
      expansion_state: %{
        depth: 0,
        iterations: 0,
        resources_used: %{},
        history: [],
        constraints: %{}
      }
    }
  end

  @doc """
  Creates a default expansion context.
  """
  @spec create_context(map()) :: expansion_context()
  def create_context(overrides \\ %{}) do
    default = %{
      rules: %{},
      limits: %{
        max_depth: 10,
        max_iterations: 100,
        max_time_ms: 5000
      },
      world_model: %{},
      observation_points: []
    }

    Map.merge(default, overrides)
  end

  @doc """
  Expands a G-expression according to its generator type and expansion context.
  """
  @spec gexpand(expandable_gexpr(), expansion_context()) ::
          {:ok, expandable_gexpr()} | {:error, String.t()}
  def gexpand(expr, ctx) do
    with :ok <- check_limits(expr, ctx),
         {:ok, expanded} <- apply_expansion(expr, ctx) do
      {:ok, record_transformation(expr, expanded)}
    end
  end

  defp check_limits(%{expansion_state: state}, %{limits: limits}) do
    cond do
      state.depth >= limits.max_depth ->
        {:error, "Maximum depth exceeded"}

      state.iterations >= limits.max_iterations ->
        {:error, "Maximum iterations exceeded"}

      true ->
        :ok
    end
  end

  defp apply_expansion(%{generator: :lazy} = expr, ctx) do
    expand_lazy(expr, ctx)
  end

  defp apply_expansion(%{generator: :adaptive} = expr, ctx) do
    expand_adaptive(expr, ctx)
  end

  defp apply_expansion(%{generator: :lsystem} = expr, ctx) do
    expand_lsystem(expr, ctx)
  end

  defp apply_expansion(%{generator: :spec} = expr, ctx) do
    expand_spec(expr, ctx)
  end

  defp apply_expansion(%{generator: :genetic} = expr, ctx) do
    expand_genetic(expr, ctx)
  end

  defp apply_expansion(%{generator: :fixed} = expr, _ctx) do
    # Terminal - no expansion
    {:ok, expr}
  end

  # Lazy sequence expansion (like Fibonacci)
  defp expand_lazy(%{value: %{rule: rule, state: state}} = expr, _ctx) do
    case apply_lazy_rule(rule, state) do
      {:ok, new_state, next_value} ->
        updated_expr = %{
          expr
          | value: %{expr.value | state: new_state},
            expansion_state: increment_state(expr.expansion_state)
        }

        {:ok, put_in(updated_expr.meta[:last_generated], next_value)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Adaptive algorithm selection
  defp expand_adaptive(%{value: %{strategy: strategy, hint: hint}} = expr, ctx) do
    case evaluate_adaptive_hint(hint, ctx.world_model) do
      {:ok, chosen_impl} ->
        updated_expr = %{
          expr
          | generator: :fixed,
            value: {:app, {:ref, chosen_impl}, expr.value[:input] || {:lit, nil}},
            expansion_state: increment_state(expr.expansion_state),
            meta: Map.put(expr.meta, :chosen_implementation, chosen_impl)
        }

        {:ok, updated_expr}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # L-System expansion for recursive structures
  defp expand_lsystem(%{value: %{axiom: current, rules: rules}} = expr, _ctx) do
    max_iterations = Map.get(expr.meta, :max_iterations, 8)
    
    if expr.expansion_state.iterations >= max_iterations do
      {:ok, expr}
    else
      expanded_string = expand_lsystem_string(current, rules)

      updated_expr = %{
        expr
        | value: %{expr.value | axiom: expanded_string},
          expansion_state: increment_state(expr.expansion_state)
      }

      {:ok, updated_expr}
    end
  end

  # Specification to implementation
  defp expand_spec(%{value: spec} = expr, ctx) do
    case synthesize_from_spec(spec, ctx) do
      {:ok, implementation} ->
        updated_expr = %{
          expr
          | generator: :fixed,
            value: implementation,
            expansion_state: finalize_state(expr.expansion_state),
            meta: Map.put(expr.meta, :synthesized_from, spec)
        }

        {:ok, updated_expr}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Genetic/evolutionary selection
  defp expand_genetic(%{value: %{variants: variants, goal: goal}} = expr, ctx) do
    case select_best_variant(variants, goal, ctx) do
      {:ok, best_variant} ->
        updated_expr = %{
          expr
          | generator: :fixed,
            value: best_variant,
            expansion_state: finalize_state(expr.expansion_state),
            meta: Map.put(expr.meta, :selected_variant, best_variant)
        }

        {:ok, updated_expr}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Helper functions
  @doc """
  Public function to apply lazy rules for preview/testing.
  """
  def apply_lazy_rule("fibonacci", [a, b]) do
    {:ok, [b, a + b], b}
  end

  def apply_lazy_rule("sequence", [current, step]) do
    {:ok, [current + step, step], current}
  end

  def apply_lazy_rule("sieve_primes", [current, sieve]) do
    next_prime = next_prime_number(current + 1, sieve)
    new_sieve = add_to_sieve(next_prime, sieve)
    {:ok, [next_prime, new_sieve], next_prime}
  end

  def apply_lazy_rule("collatz", [n, step_count]) do
    next_n = if rem(n, 2) == 0, do: div(n, 2), else: 3 * n + 1
    {:ok, [next_n, step_count + 1], next_n}
  end

  def apply_lazy_rule("pi_leibniz", [approximation, term, iteration]) do
    # π/4 = 1 - 1/3 + 1/5 - 1/7 + ...
    sign = if rem(iteration, 2) == 0, do: 1, else: -1
    term_value = sign / (2 * iteration + 1)
    new_approximation = approximation + term_value
    pi_estimate = new_approximation * 4
    {:ok, [pi_estimate, term_value, iteration + 1], pi_estimate}
  end

  def apply_lazy_rule(rule, _state) do
    {:error, "Unknown lazy rule: #{rule}"}
  end

  # Helper functions for prime sieve
  defp next_prime_number(n, sieve) when n < 2, do: 2
  defp next_prime_number(n, sieve) do
    if is_prime?(n, sieve) do
      n
    else
      next_prime_number(n + 1, sieve)
    end
  end

  defp is_prime?(n, sieve) do
    not Enum.any?(sieve, fn p -> rem(n, p) == 0 end)
  end

  defp add_to_sieve(prime, sieve) do
    [prime | sieve] |> Enum.take(100)  # Keep sieve manageable
  end

  defp evaluate_adaptive_hint(hint, world_model) do
    # Simple pattern matching for hints like "size<10?insertion:quick"
    case Regex.run(~r/size<(\d+)\?(\w+):(\w+)/, hint) do
      [_, threshold_str, small_impl, large_impl] ->
        threshold = String.to_integer(threshold_str)
        input_size = Map.get(world_model, :input_size, 0)

        if input_size < threshold do
          {:ok, small_impl}
        else
          {:ok, large_impl}
        end

      _ ->
        {:error, "Cannot parse adaptive hint: #{hint}"}
    end
  end

  defp expand_lsystem_string(current, rules) do
    current
    |> String.graphemes()
    |> Enum.map(fn symbol ->
      Map.get(rules, symbol, symbol)
    end)
    |> Enum.join()
  end

  defp synthesize_from_spec(%{type: "function", constraints: constraints}, _ctx) do
    # Simple synthesis - this could be much more sophisticated
    case constraints do
      ["validate_email"] ->
        {:ok,
         {:app, {:ref, "match_regex"},
          {:vec, [{:ref, "input"}, {:lit, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"}]}}}

      ["calculate_tax", rate] ->
        {:ok,
         {:app, {:ref, "*"},
          {:vec, [{:ref, "amount"}, {:lit, rate}]}}}

      _ ->
        {:error, "Cannot synthesize from constraints: #{inspect(constraints)}"}
    end
  end

  defp synthesize_from_spec(spec, _ctx) do
    {:error, "Unknown spec format: #{inspect(spec)}"}
  end

  defp select_best_variant(variants, goal, _ctx) do
    # Simple selection based on goal
    case goal do
      ["maximize", "speed"] ->
        # Select fastest variant (simplified)
        best = Enum.find(variants, fn v -> v[:meta][:speed] == "fastest" end) || List.first(variants)
        {:ok, best[:implementation]}

      ["minimize", "memory"] ->
        # Select most memory-efficient variant
        best =
          Enum.find(variants, fn v -> v[:meta][:memory] == "minimal" end) || List.first(variants)

        {:ok, best[:implementation]}

      _ ->
        {:ok, List.first(variants)[:implementation]}
    end
  end

  defp increment_state(state) do
    %{
      state
      | depth: state.depth + 1,
        iterations: state.iterations + 1
    }
  end

  defp finalize_state(state) do
    Map.put(state, :finalized, true)
  end

  defp record_transformation(from_expr, to_expr) do
    step = %{
      from: from_expr.value,
      to: to_expr.value,
      rule: "#{from_expr.generator}",
      timestamp: System.system_time(:millisecond)
    }

    put_in(to_expr.expansion_state.history, [step | to_expr.expansion_state.history])
  end

  @doc """
  Creates common generator seeds for testing and examples.
  """
  def create_seed(type, spec \\ %{})

  def create_seed(:fibonacci, _spec) do
    create_expandable(:lazy, %{
      rule: "fibonacci",
      state: [0, 1]
    })
  end

  def create_seed(:primes, _spec) do
    create_expandable(:lazy, %{
      rule: "sieve_primes", 
      state: [2, []]
    })
  end

  def create_seed(:collatz, spec) do
    start = Map.get(spec, :start, 27)
    create_expandable(:lazy, %{
      rule: "collatz",
      state: [start, 0]
    })
  end

  def create_seed(:pi, _spec) do
    create_expandable(:lazy, %{
      rule: "pi_leibniz",
      state: [1.0, 1.0, 0]  # Start with π/4 ≈ 1
    })
  end

  def create_seed(:adaptive_sort, spec) do
    create_expandable(:adaptive, %{
      strategy: "size_based",
      hint: Map.get(spec, :hint, "size<50?insertion:quick"),
      input: spec[:input]
    })
  end

  def create_seed(:tree, spec) do
    create_expandable(:lsystem, %{
      axiom: Map.get(spec, :axiom, "A"),
      rules: Map.get(spec, :rules, %{"A" => "B[+A][-A]", "B" => "BB"})
    })
  end

  def create_seed(:fractal_tree, spec) do
    create_expandable(:lsystem, %{
      axiom: Map.get(spec, :axiom, "A"),
      rules: Map.get(spec, :rules, %{
        "A" => "B[+A][-A]BA",
        "B" => "BB"
      })
    }, %{
      visualization: :ascii_tree,
      demo_quality: :showcase
    })
  end

  def create_seed(:email_validator, _spec) do
    create_expandable(:spec, %{
      type: "function",
      name: "validate_email",
      constraints: ["validate_email"]
    })
  end
end