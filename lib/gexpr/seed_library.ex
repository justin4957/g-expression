defmodule Gexpr.SeedLibrary do
  @moduledoc """
  Standard library of impressive example seeds for all generator types.
  
  This is the "fuel" for the expansion CLI - a curated collection of 
  mind-blowing demonstrations that showcase the power of generative computing.
  
  Each seed is designed for maximum "wow factor" while teaching core concepts.
  """

  alias Gexpr.Expansion

  @doc """
  Creates a seed from the standard library.
  """
  def create(seed_name, options \\ %{}) when is_atom(seed_name) do
    case seed_name do
      # === LAZY GENERATORS (Infinite Sequences) ===
      :fibonacci -> create_fibonacci(options)
      :primes -> create_primes(options)
      :collatz -> create_collatz(options)
      :mandelbrot_sequence -> create_mandelbrot_sequence(options)
      :pi_digits -> create_pi_digits(options)
      
      # === ADAPTIVE GENERATORS (Context-Sensitive) ===
      :smart_cache -> create_smart_cache(options)
      :adaptive_serializer -> create_adaptive_serializer(options)
      :performance_router -> create_performance_router(options)
      :memory_optimizer -> create_memory_optimizer(options)
      
      # === L-SYSTEM GENERATORS (Fractals & Patterns) ===
      :fractal_tree -> create_fractal_tree(options)
      :sierpinski_triangle -> create_sierpinski_triangle(options)
      :dragon_curve -> create_dragon_curve(options)
      :plant_growth -> create_plant_growth(options)
      :network_topology -> create_network_topology(options)
      
      # === SPEC GENERATORS (Intent to Implementation) ===
      :rest_api -> create_rest_api(options)
      :email_validator -> create_email_validator(options)
      :data_transformer -> create_data_transformer(options)
      :crypto_hasher -> create_crypto_hasher(options)
      
      # === GENETIC GENERATORS (Evolutionary) ===
      :pathfinder -> create_pathfinder(options)
      :load_balancer -> create_load_balancer(options)
      :neural_network -> create_neural_network(options)
      :algorithm_optimizer -> create_algorithm_optimizer(options)
      
      _ -> {:error, "Unknown seed: #{seed_name}"}
    end
  end

  @doc """
  Lists all available seeds with descriptions.
  """
  def catalog do
    %{
      lazy: [
        {:fibonacci, "Classic Fibonacci sequence - the perfect introduction to lazy generation"},
        {:primes, "Infinite sequence of prime numbers using the Sieve of Eratosthenes"},
        {:collatz, "The mysterious 3n+1 sequence - simple rule, complex behavior"},
        {:mandelbrot_sequence, "Mandelbrot set iteration values for visual mathematics"},
        {:pi_digits, "Infinite precision π calculation using Leibniz formula"}
      ],
      
      adaptive: [
        {:smart_cache, "Cache that adapts strategy based on access patterns and memory pressure"},
        {:adaptive_serializer, "Serializer that chooses format (JSON/MessagePack/Protobuf) by data shape"},
        {:performance_router, "HTTP router that chooses algorithms based on traffic patterns"},
        {:memory_optimizer, "Memory allocator that adapts to usage patterns"}
      ],
      
      lsystem: [
        {:fractal_tree, "Beautiful branching tree - the perfect demo for visual growth"},
        {:sierpinski_triangle, "Self-similar triangle fractal emerging from simple rules"},
        {:dragon_curve, "Space-filling curve that creates dragon-like patterns"},
        {:plant_growth, "Realistic plant modeling with environmental factors"},
        {:network_topology, "Growing network structures for distributed systems"}
      ],
      
      spec: [
        {:rest_api, "High-level API specification that synthesizes to implementation"},
        {:email_validator, "Email validation spec that generates regex and validation logic"},
        {:data_transformer, "ETL pipeline specification that creates optimized transformations"},
        {:crypto_hasher, "Cryptographic requirements that synthesize secure implementations"}
      ],
      
      genetic: [
        {:pathfinder, "Pathfinding that evolves algorithms based on terrain types"},
        {:load_balancer, "Load balancing that evolves strategy based on traffic patterns"},
        {:neural_network, "Neural architecture search that evolves optimal topologies"},
        {:algorithm_optimizer, "Algorithm variants competing for performance supremacy"}
      ]
    }
  end

  # ============================================================================
  # LAZY GENERATORS - Infinite sequences that unfold incrementally
  # ============================================================================

  defp create_fibonacci(_options) do
    {:ok, Expansion.create_expandable(:lazy, %{
      rule: "fibonacci",
      state: [0, 1],
      description: "The golden ratio sequence - each number is the sum of the previous two"
    }, %{
      visualization: :sequence_chart,
      wow_factor: :high,
      demo_iterations: 12
    })}
  end

  defp create_primes(_options) do
    {:ok, Expansion.create_expandable(:lazy, %{
      rule: "sieve_primes",
      state: [2, []], # [current, sieve]
      description: "Infinite prime numbers using optimized sieve algorithm"
    }, %{
      visualization: :number_grid,
      wow_factor: :medium,
      demo_iterations: 20
    })}
  end

  defp create_collatz(options) do
    start = Map.get(options, :start, 27) # 27 has a particularly long sequence
    {:ok, Expansion.create_expandable(:lazy, %{
      rule: "collatz",
      state: [start, 0], # [current_number, step_count]
      description: "The 3n+1 problem - simple rule that creates unpredictable sequences"
    }, %{
      visualization: :path_trace,
      wow_factor: :high,
      demo_iterations: 50,
      mathematical_mystery: true
    })}
  end

  defp create_mandelbrot_sequence(options) do
    c = Map.get(options, :complex_param, {-0.75, 0.1})
    {:ok, Expansion.create_expandable(:lazy, %{
      rule: "mandelbrot",
      state: [0, c, 0], # [z, c, iteration]
      description: "Mandelbrot iteration: z = z² + c (generates fractal boundary data)"
    }, %{
      visualization: :complex_plane,
      wow_factor: :very_high,
      demo_iterations: 100,
      artistic_value: true
    })}
  end

  defp create_pi_digits(_options) do
    {:ok, Expansion.create_expandable(:lazy, %{
      rule: "pi_leibniz",
      state: [3, 1, 4], # [current_approximation, term, iteration]
      description: "Infinite precision π using Leibniz series: π/4 = 1 - 1/3 + 1/5 - 1/7 + ..."
    }, %{
      visualization: :convergence_chart,
      wow_factor: :high,
      demo_iterations: 1000,
      mathematical_beauty: true
    })}
  end

  # ============================================================================
  # ADAPTIVE GENERATORS - Context-sensitive algorithms
  # ============================================================================

  defp create_smart_cache(_options) do
    {:ok, Expansion.create_expandable(:adaptive, %{
      strategy: "cache_policy",
      hint: "memory_pressure<80?lru:lfu|access_pattern=random?fifo:lru",
      policies: ["lru", "lfu", "fifo", "adaptive_replacement"],
      description: "Cache that evolves its eviction policy based on memory and access patterns"
    }, %{
      context_sensitivity: :very_high,
      wow_factor: :medium,
      real_world_value: :high
    })}
  end

  defp create_adaptive_serializer(_options) do
    {:ok, Expansion.create_expandable(:adaptive, %{
      strategy: "format_selection",
      hint: "size<1kb?json:msgpack|nested_depth>5?protobuf:json|cpu_bound?json:msgpack",
      formats: ["json", "messagepack", "protobuf", "cbor"],
      description: "Serializer that chooses optimal format based on data characteristics"
    }, %{
      context_sensitivity: :high,
      wow_factor: :medium,
      performance_impact: :significant
    })}
  end

  defp create_performance_router(_options) do
    {:ok, Expansion.create_expandable(:adaptive, %{
      strategy: "routing_algorithm",
      hint: "concurrent_requests<100?linear:hash|geographic_spread?geohash:consistent",
      algorithms: ["linear_search", "hash_table", "trie", "geohash", "consistent_hash"],
      description: "HTTP router that adapts algorithm based on traffic patterns"
    }, %{
      context_sensitivity: :high,
      wow_factor: :high,
      scalability_showcase: true
    })}
  end

  defp create_memory_optimizer(_options) do
    {:ok, Expansion.create_expandable(:adaptive, %{
      strategy: "allocation_strategy",
      hint: "heap_fragmentation>50?compacting:bump|allocation_rate>1gb/s?pool:malloc",
      strategies: ["bump_allocator", "pool_allocator", "malloc", "compacting_gc"],
      description: "Memory allocator that adapts to application usage patterns"
    }, %{
      context_sensitivity: :very_high,
      wow_factor: :medium,
      systems_programming: true
    })}
  end

  # ============================================================================
  # L-SYSTEM GENERATORS - Fractal and recursive structures  
  # ============================================================================

  defp create_fractal_tree(_options) do
    {:ok, Expansion.create_expandable(:lsystem, %{
      axiom: "A",
      rules: %{
        "A" => "B[+A][-A]BA",
        "B" => "BB"
      },
      description: "Fractal tree with branching - demonstrates emergent complexity from simple rules"
    }, %{
      visualization: :ascii_tree,
      wow_factor: :very_high,
      demo_iterations: 5,
      artistic_beauty: true,
      showcase_demo: true
    })}
  end

  defp create_sierpinski_triangle(_options) do
    {:ok, Expansion.create_expandable(:lsystem, %{
      axiom: "F-G-G",
      rules: %{
        "F" => "F-G+F+G-F",
        "G" => "GG"
      },
      angle: 120,
      description: "Sierpinski triangle fractal - infinite detail from finite rules"
    }, %{
      visualization: :geometric_plot,
      wow_factor: :high,
      demo_iterations: 6,
      mathematical_elegance: true
    })}
  end

  defp create_dragon_curve(_options) do
    {:ok, Expansion.create_expandable(:lsystem, %{
      axiom: "FX",
      rules: %{
        "X" => "X+YF+",
        "Y" => "-FX-Y"
      },
      angle: 90,
      description: "Dragon curve - space-filling curve with dragon-like appearance"
    }, %{
      visualization: :path_trace,
      wow_factor: :high,
      demo_iterations: 12,
      geometric_beauty: true
    })}
  end

  defp create_plant_growth(_options) do
    {:ok, Expansion.create_expandable(:lsystem, %{
      axiom: "S",
      rules: %{
        "S" => "F[+S][-S]FS", # Main stem with branches
        "F" => "FF"          # Segment growth
      },
      environmental_factors: %{
        sunlight: 0.8,
        water: 0.6,
        nutrients: 0.7
      },
      description: "Realistic plant growth with environmental factors affecting development"
    }, %{
      visualization: :organic_growth,
      wow_factor: :high,
      demo_iterations: 6,
      biological_realism: true
    })}
  end

  defp create_network_topology(_options) do
    {:ok, Expansion.create_expandable(:lsystem, %{
      axiom: "N",
      rules: %{
        "N" => "N[+N][-N]CN", # Node with connections
        "C" => "CC"           # Connection growth
      },
      network_properties: %{
        redundancy: 0.8,
        latency_optimization: true,
        fault_tolerance: 0.9
      },
      description: "Self-organizing network topology with fault tolerance and optimization"
    }, %{
      visualization: :network_graph,
      wow_factor: :medium,
      demo_iterations: 4,
      distributed_systems: true
    })}
  end

  # ============================================================================
  # SPEC GENERATORS - Intent-based programming
  # ============================================================================

  defp create_rest_api(_options) do
    {:ok, Expansion.create_expandable(:spec, %{
      type: "rest_api",
      specification: %{
        entity: "users",
        operations: ["create", "read", "update", "delete", "list"],
        authentication: "jwt",
        rate_limiting: "100/minute",
        validation: "strict",
        serialization: "json"
      },
      description: "REST API spec that synthesizes complete implementation with middleware"
    }, %{
      synthesis_complexity: :high,
      wow_factor: :very_high,
      practical_value: :very_high,
      ai_potential: true
    })}
  end

  defp create_email_validator(_options) do
    {:ok, Expansion.create_expandable(:spec, %{
      type: "validator",
      constraints: [
        "must_contain_at_symbol",
        "domain_must_have_dot",
        "no_consecutive_dots", 
        "rfc5322_compliant",
        "internationalized_domains"
      ],
      description: "Email validation spec that generates optimized regex and validation logic"
    }, %{
      synthesis_complexity: :medium,
      wow_factor: :medium,
      correctness_critical: true
    })}
  end

  defp create_data_transformer(_options) do
    {:ok, Expansion.create_expandable(:spec, %{
      type: "etl_pipeline",
      source_schema: %{
        format: "csv",
        columns: ["id", "name", "email", "created_at"],
        encoding: "utf-8"
      },
      target_schema: %{
        format: "parquet",
        partitioning: ["year", "month"],
        compression: "snappy"
      },
      transformations: [
        "normalize_email",
        "extract_domain",
        "parse_timestamp",
        "validate_id"
      ],
      description: "ETL specification that synthesizes optimized data transformation pipeline"
    }, %{
      synthesis_complexity: :high,
      wow_factor: :high,
      big_data_relevance: true
    })}
  end

  defp create_crypto_hasher(_options) do
    {:ok, Expansion.create_expandable(:spec, %{
      type: "cryptographic_function",
      requirements: %{
        security_level: "256_bit",
        resistance: ["collision", "preimage", "second_preimage"],
        performance_target: "1M_hashes_per_second",
        side_channel_resistance: true
      },
      description: "Cryptographic specification that synthesizes secure hash implementation"
    }, %{
      synthesis_complexity: :very_high,
      wow_factor: :medium,
      security_critical: true,
      mathematical_rigor: true
    })}
  end

  # ============================================================================
  # GENETIC GENERATORS - Evolutionary computation
  # ============================================================================

  defp create_pathfinder(_options) do
    {:ok, Expansion.create_expandable(:genetic, %{
      variants: [
        %{
          name: "dijkstra",
          implementation: {:pathfinding, :dijkstra},
          fitness_metrics: %{speed: 0.6, memory: 0.9, optimality: 1.0}
        },
        %{
          name: "a_star", 
          implementation: {:pathfinding, :a_star},
          fitness_metrics: %{speed: 0.9, memory: 0.7, optimality: 0.95}
        },
        %{
          name: "jps",
          implementation: {:pathfinding, :jump_point_search},
          fitness_metrics: %{speed: 0.95, memory: 0.8, optimality: 0.85}
        }
      ],
      goal: ["maximize", "speed"],
      description: "Pathfinding that evolves optimal algorithm based on terrain characteristics"
    }, %{
      evolution_complexity: :high,
      wow_factor: :high,
      gaming_relevance: true
    })}
  end

  defp create_load_balancer(_options) do
    {:ok, Expansion.create_expandable(:genetic, %{
      variants: [
        %{
          name: "round_robin",
          implementation: {:balancing, :round_robin},
          fitness_metrics: %{latency: 0.7, throughput: 0.8, fairness: 1.0}
        },
        %{
          name: "least_connections",
          implementation: {:balancing, :least_connections}, 
          fitness_metrics: %{latency: 0.8, throughput: 0.9, fairness: 0.8}
        },
        %{
          name: "weighted_response",
          implementation: {:balancing, :weighted_response},
          fitness_metrics: %{latency: 0.9, throughput: 0.95, fairness: 0.7}
        }
      ],
      goal: ["optimize", "latency", "throughput"],
      description: "Load balancer that evolves strategy based on traffic patterns and server health"
    }, %{
      evolution_complexity: :medium,
      wow_factor: :high,
      infrastructure_relevance: true
    })}
  end

  defp create_neural_network(_options) do
    {:ok, Expansion.create_expandable(:genetic, %{
      variants: [
        %{
          name: "shallow_wide",
          architecture: %{layers: 3, neurons_per_layer: 512},
          fitness_metrics: %{accuracy: 0.85, training_time: 0.9, memory: 0.6}
        },
        %{
          name: "deep_narrow", 
          architecture: %{layers: 12, neurons_per_layer: 64},
          fitness_metrics: %{accuracy: 0.92, training_time: 0.4, memory: 0.8}
        },
        %{
          name: "residual_network",
          architecture: %{layers: 18, neurons_per_layer: 128, skip_connections: true},
          fitness_metrics: %{accuracy: 0.96, training_time: 0.6, memory: 0.5}
        }
      ],
      goal: ["maximize", "accuracy"],
      description: "Neural architecture search that evolves optimal network topology"
    }, %{
      evolution_complexity: :very_high,
      wow_factor: :very_high,
      ai_ml_relevance: true,
      research_potential: true
    })}
  end

  defp create_algorithm_optimizer(_options) do
    {:ok, Expansion.create_expandable(:genetic, %{
      variants: [
        %{
          name: "quicksort_optimized",
          implementation: {:sorting, :quicksort, %{pivot_strategy: :median_of_three}},
          fitness_metrics: %{avg_performance: 0.9, worst_case: 0.3, memory: 0.9}
        },
        %{
          name: "heapsort_stable",
          implementation: {:sorting, :heapsort, %{stability: true}},
          fitness_metrics: %{avg_performance: 0.7, worst_case: 0.9, memory: 0.95}
        },
        %{
          name: "timsort_adaptive",
          implementation: {:sorting, :timsort, %{run_detection: true}},
          fitness_metrics: %{avg_performance: 0.85, worst_case: 0.85, memory: 0.8}
        }
      ],
      goal: ["balanced_optimization"],
      description: "Algorithm variants competing for supremacy across different performance metrics"
    }, %{
      evolution_complexity: :high,
      wow_factor: :medium,
      computer_science_education: true
    })}
  end

  @doc """
  Creates a demo sequence showcasing multiple seed types for maximum impact.
  """
  def demo_sequence do
    [
      {:fibonacci, "🌱 The classic - watch numbers grow organically"},
      {:fractal_tree, "🌳 Visual explosion - simple rules, infinite complexity"}, 
      {:smart_cache, "🧠 Adaptive intelligence - algorithms that think"},
      {:pathfinder, "⚡ Evolution in action - survival of the fastest"},
      {:rest_api, "🚀 Intent becomes reality - describe what you want, get working code"}
    ]
  end

  @doc """
  The showcase demo that displays the most impressive visual growth.
  """
  def showcase_demo do
    create(:fractal_tree, %{
      max_iterations: 6,
      real_time_growth: true,
      visual_mode: :ascii_art_enhanced
    })
  end
end