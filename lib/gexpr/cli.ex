defmodule Gexpr.CLI do
  @moduledoc """
  Minimal CLI interface for the G-expression expansion system.
  
  Provides the core commands from expansion-cli-toy.md:
  - plant: Create seed expressions
  - grow: Expand expressions  
  - show: Display expressions
  - peek: Observe without expansion
  - repl: Interactive mode
  """

  alias Gexpr.Expansion
  alias Gexpr.Bootstrap

  @storage_path "/tmp/gexpr_seeds"

  def main(args) do
    case args do
      ["plant" | rest] -> handle_plant(rest)
      ["grow" | rest] -> handle_grow(rest)
      ["show" | rest] -> handle_show(rest)
      ["peek" | rest] -> handle_peek(rest)
      ["repl"] -> handle_repl()
      ["context" | rest] -> handle_context(rest)
      ["save" | rest] -> handle_save(rest)
      ["load" | rest] -> handle_load(rest)
      [] -> show_help()
      _ -> show_help()
    end
  end

  defp handle_plant([name, generator_type | spec_parts]) do
    spec_json = Enum.join(spec_parts, " ")

    case create_seed(generator_type, spec_json) do
      {:ok, seed} ->
        store_seed(name, seed)
        IO.puts("✓ Planted: #{name}")

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
    end
  end

  defp handle_plant(_) do
    IO.puts("Usage: gx plant <name> <generator-type> [inline-spec]")
    IO.puts("Example: gx plant fib lazy")
    IO.puts("         gx plant sort adaptive")
  end

  defp handle_grow([name | options]) do
    case load_seed(name) do
      {:ok, seed} ->
        context = parse_grow_options(options)
        
        if Enum.member?(options, "--visual") do
          iterations = Map.get(context, :iterations, 5)
          case Gexpr.Visualizer.grow_visual(seed, name, iterations, %{}) do
            {:ok, final_seed} ->
              store_seed(name, final_seed)
              IO.puts("✓ Visual growth complete!")
            {:error, reason} ->
              IO.puts("❌ Visual growth failed: #{reason}")
          end
        else
          grow_seed(seed, context, name)
        end

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
    end
  end

  defp handle_grow(_) do
    IO.puts("Usage: gx grow <name> [options]")
    IO.puts("Example: gx grow fib")
    IO.puts("         gx grow fib -n 5")
  end

  defp handle_show([name | options]) do
    case load_seed(name) do
      {:ok, seed} ->
        cond do
          Enum.member?(options, "--visual") ->
            Gexpr.Visualizer.show_visual(seed, name, %{format: :web})
          
          Enum.member?(options, "--tree") ->
            display_tree_json(seed, name, options)
            
          true ->
            format = parse_show_format(options)
            display_seed(seed, format, name)
        end

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
    end
  end

  defp handle_show(_) do
    IO.puts("Usage: gx show <name> [--as format] [--visual] [--tree] [--history]")
    IO.puts("Example: gx show fib")
    IO.puts("         gx show fib --as json")
    IO.puts("         gx show fib --visual")
    IO.puts("         gx show fib --tree")
  end

  defp handle_peek([name | options]) do
    case load_seed(name) do
      {:ok, seed} ->
        depth = parse_peek_depth(options)
        peek_at_seed(seed, depth, name)

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
    end
  end

  defp handle_peek(_) do
    IO.puts("Usage: gx peek <name> [--depth N]")
    IO.puts("Example: gx peek fib --depth 2")
  end

  defp handle_repl do
    IO.puts("G-Expression REPL v0.1.0")
    IO.puts("Type 'help' for commands, 'exit' to quit")
    repl_loop(%{})
  end

  defp handle_context(["set", key, value]) do
    # Store context settings (simplified)
    context = load_context()
    new_context = Map.put(context, String.to_atom(key), parse_context_value(value))
    save_context(new_context)
    IO.puts("✓ Context updated: #{key} = #{value}")
  end

  defp handle_context(["show"]) do
    context = load_context()
    IO.puts("Current context:")

    Enum.each(context, fn {key, value} ->
      IO.puts("  #{key}: #{inspect(value)}")
    end)
  end

  defp handle_context(_) do
    IO.puts("Usage: gx context set <key> <value>")
    IO.puts("       gx context show")
  end

  defp handle_save([name, filename]) do
    case load_seed(name) do
      {:ok, seed} ->
        case save_seed_file(seed, filename) do
          :ok -> IO.puts("✓ Saved #{name} to #{filename}")
          {:error, reason} -> IO.puts("❌ Error: #{reason}")
        end

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
    end
  end

  defp handle_save([name]) do
    handle_save([name, "#{name}.gx"])
  end

  defp handle_save(_) do
    IO.puts("Usage: gx save <name> [filename]")
  end

  defp handle_load([filename]) do
    case load_seed_file(filename) do
      {:ok, {name, seed}} ->
        store_seed(name, seed)
        IO.puts("✓ Loaded #{name} from #{filename}")

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
    end
  end

  defp handle_load(_) do
    IO.puts("Usage: gx load <filename>")
  end

  # Core functionality
  defp create_seed(generator_type, spec_json) do
    parsed_spec = if spec_json == "", do: %{}, else: parse_json(spec_json)

    # Check if it's a library seed first
    seed_name = parsed_spec[:seed] || parsed_spec["seed"]
    
    if seed_name do
      case Gexpr.SeedLibrary.create(String.to_atom(seed_name), parsed_spec) do
        {:ok, seed} -> {:ok, seed}
        {:error, reason} -> {:error, reason}
      end
    else
      # Fall back to basic generator types
      case generator_type do
        "lazy" -> {:ok, Expansion.create_seed(:fibonacci, parsed_spec)}
        "adaptive" -> {:ok, Expansion.create_seed(:adaptive_sort, parsed_spec)}
        "lsystem" -> {:ok, Expansion.create_seed(:tree, parsed_spec)}
        "fractal" -> {:ok, Expansion.create_seed(:fractal_tree, parsed_spec)}
        "primes" -> {:ok, Expansion.create_seed(:primes, parsed_spec)}
        "collatz" -> {:ok, Expansion.create_seed(:collatz, parsed_spec)}
        "pi" -> {:ok, Expansion.create_seed(:pi, parsed_spec)}
        "spec" -> {:ok, Expansion.create_seed(:email_validator, parsed_spec)}
        _ -> {:error, "Unknown generator type: #{generator_type}. Try: lazy, adaptive, lsystem, fractal, primes, collatz, pi, spec"}
      end
    end
  end

  defp grow_seed(seed, context, name) do
    max_iterations = Map.get(context, :iterations, 1)
    expanded_seed = grow_iterations(seed, context, max_iterations)

    store_seed(name, expanded_seed)
    IO.puts("✓ Expanded: #{name}")

    # Show what was generated if applicable
    case expanded_seed.meta[:last_generated] do
      nil -> :ok
      value -> IO.puts("   Generated: #{inspect(value)}")
    end
  end

  defp grow_iterations(seed, context, 0), do: seed

  defp grow_iterations(seed, context, n) when n > 0 do
    expansion_context = Expansion.create_context(context)

    case Expansion.gexpand(seed, expansion_context) do
      {:ok, expanded} ->
        grow_iterations(expanded, context, n - 1)

      {:error, reason} ->
        IO.puts("❌ Expansion failed: #{reason}")
        seed
    end
  end

  defp display_seed(seed, :json, _name) do
    IO.puts(Jason.encode!(seed, pretty: true))
  end

  defp display_seed(seed, :pretty, name) do
    case seed.generator do
      :lsystem -> 
        Gexpr.Visualizer.render_lsystem_ascii(seed, name)
      :lazy ->
        Gexpr.Visualizer.render_sequence_ascii(seed, name)
      _ ->
        IO.puts("#{name}:")
        IO.puts("  Generator: #{seed.generator}")
        IO.puts("  State: #{inspect(seed.expansion_state)}")
        IO.puts("  Value: #{inspect(seed.value)}")

        unless Enum.empty?(seed.expansion_state.history) do
          IO.puts("  History:")

          Enum.each(seed.expansion_state.history, fn step ->
            IO.puts("    #{step.rule}: #{inspect(step.from)} → #{inspect(step.to)}")
          end)
        end
    end
  end

  defp display_seed(seed, :structure, _name) do
    structure = %{
      generator: seed.generator,
      depth: seed.expansion_state.depth,
      iterations: seed.expansion_state.iterations,
      finalized: Map.get(seed.expansion_state, :finalized, false)
    }

    IO.puts(inspect(structure, pretty: true))
  end

  defp display_tree_json(seed, name, options) do
    tree_data = build_expansion_tree(seed, name)
    
    # Check if we should include metadata
    include_meta = Enum.member?(options, "--meta")
    
    # Check if we should include transformation steps
    include_steps = Enum.member?(options, "--steps")
    
    # Build the final tree structure
    final_tree = %{
      name: name,
      root: tree_data,
      metadata: if(include_meta, do: extract_metadata(seed), else: nil),
      transformation_steps: if(include_steps, do: extract_transformation_steps(seed), else: nil),
      generated_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      cli_version: "0.1.0"
    }
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Enum.into(%{})
    
    case Jason.encode(final_tree, pretty: true) do
      {:ok, json} -> IO.puts(json)
      {:error, reason} -> IO.puts("❌ JSON encoding failed: #{reason}")
    end
  end

  defp peek_at_seed(seed, depth, name) do
    IO.puts("#{name} (peek at depth #{depth}):")
    IO.puts("  Current generator: #{seed.generator}")

    case seed.generator do
      :lazy ->
        %{rule: rule, state: state} = seed.value
        IO.puts("  Rule: #{rule}")
        IO.puts("  Current state: #{inspect(state)}")

        # Simulate next values without actually expanding
        case Expansion.apply_lazy_rule(rule, state) do
          {:ok, _new_state, next_value} ->
            IO.puts("  Next would generate: #{inspect(next_value)}")

          _ ->
            IO.puts("  Cannot predict next value")
        end

      _ ->
        IO.puts("  Value: #{inspect(seed.value)}")
    end
  end

  # REPL implementation
  defp repl_loop(env) do
    input = IO.gets("gx> ") |> String.trim()

    case input do
      "exit" ->
        IO.puts("Goodbye!")

      "help" ->
        show_repl_help()
        repl_loop(env)

      "" ->
        repl_loop(env)

      command ->
        new_env = execute_repl_command(command, env)
        repl_loop(new_env)
    end
  end

  defp execute_repl_command("plant " <> rest, env) do
    args = String.split(rest)
    handle_plant(args)
    env
  end

  defp execute_repl_command("grow " <> rest, env) do
    args = String.split(rest)
    handle_grow(args)
    env
  end

  defp execute_repl_command("show " <> rest, env) do
    args = String.split(rest)
    handle_show(args)
    env
  end

  defp execute_repl_command("peek " <> rest, env) do
    args = String.split(rest)
    handle_peek(args)
    env
  end

  defp execute_repl_command("list", env) do
    case list_seeds() do
      {:ok, seeds} ->
        IO.puts("Planted seeds:")

        Enum.each(seeds, fn name ->
          IO.puts("  #{name}")
        end)

      {:error, _} ->
        IO.puts("No seeds planted")
    end

    env
  end

  defp execute_repl_command("demo", env) do
    IO.puts("🎬 Running showcase demo sequence...")
    IO.puts("")
    
    # The fractal tree showcase demo
    case create_seed("fractal", "{}") do
      {:ok, seed} ->
        store_seed("demo_tree", seed)
        case Gexpr.Visualizer.grow_visual(seed, "demo_tree", 5, %{}) do
          {:ok, final_seed} ->
            store_seed("demo_tree", final_seed)
            IO.puts("")
            IO.puts("🎉 Demo complete! Try 'show demo_tree --visual' for browser view")
          {:error, reason} ->
            IO.puts("Demo failed: #{reason}")
        end
      {:error, reason} ->
        IO.puts("Demo setup failed: #{reason}")
    end
    
    env
  end

  defp execute_repl_command("catalog", env) do
    catalog = Gexpr.SeedLibrary.catalog()
    
    IO.puts("📚 Seed Library Catalog")
    IO.puts("=======================")
    
    Enum.each(catalog, fn {category, seeds} ->
      IO.puts("\n#{String.upcase(to_string(category))} GENERATORS:")
      Enum.each(seeds, fn {name, description} ->
        IO.puts("  #{name} - #{description}")
      end)
    end)
    
    IO.puts("\nUsage: plant <name> <generator> '{\"seed\": \"<seed_name>\"}'")
    IO.puts("Example: plant cool fractal '{\"seed\": \"fractal_tree\"}'")
    
    env
  end

  defp execute_repl_command(unknown, env) do
    IO.puts("Unknown command: #{unknown}")
    IO.puts("Type 'help' for available commands")
    env
  end

  # Tree building functions
  defp build_expansion_tree(seed, name) do
    %{
      node_type: "seed",
      name: name,
      generator: seed.generator,
      current_value: serialize_value(seed.value),
      expansion_state: %{
        depth: seed.expansion_state.depth,
        iterations: seed.expansion_state.iterations,
        finalized: Map.get(seed.expansion_state, :finalized, false)
      },
      children: build_history_nodes(seed.expansion_state.history)
    }
  end

  defp build_history_nodes(history) do
    history
    |> Enum.reverse() # Show chronological order
    |> Enum.with_index()
    |> Enum.map(fn {step, index} ->
      %{
        node_type: "transformation",
        step_number: index + 1,
        rule: step.rule,
        timestamp: step.timestamp,
        from_value: serialize_value(step.from),
        to_value: serialize_value(step.to),
        children: [] # Transformations are leaf nodes
      }
    end)
  end

  defp serialize_value(value) when is_map(value) do
    # For L-systems and other complex values, create a structured representation
    case value do
      %{axiom: axiom, rules: rules} ->
        %{
          type: "lsystem",
          axiom: axiom,
          rules: rules,
          axiom_length: String.length(axiom)
        }
      
      %{state: state, rule: rule} ->
        %{
          type: "lazy_sequence",
          rule: rule,
          current_state: state,
          last_value: List.last(state)
        }
      
      %{strategy: strategy, hint: hint} ->
        %{
          type: "adaptive_algorithm",
          strategy: strategy,
          hint: hint
        }
      
      _ ->
        %{
          type: "generic",
          raw_value: inspect(value, limit: 10)
        }
    end
  end

  defp serialize_value(value), do: %{type: "literal", value: value}

  defp extract_metadata(seed) do
    %{
      generator_type: seed.generator,
      total_transformations: length(seed.expansion_state.history),
      creation_timestamp: extract_creation_time(seed.expansion_state.history),
      constraints: seed.expansion_state.constraints,
      resources_used: seed.expansion_state.resources_used,
      seed_metadata: seed.meta
    }
  end

  defp extract_transformation_steps(seed) do
    seed.expansion_state.history
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {step, index} ->
      %{
        step: index + 1,
        rule_applied: step.rule,
        timestamp: step.timestamp,
        datetime: DateTime.from_unix!(step.timestamp, :millisecond) |> DateTime.to_iso8601(),
        transformation_type: classify_transformation(step),
        complexity_change: calculate_complexity_change(step.from, step.to)
      }
    end)
  end

  defp extract_creation_time([]), do: nil
  defp extract_creation_time(history) do
    history
    |> List.last()
    |> Map.get(:timestamp)
    |> case do
      nil -> nil
      ts -> DateTime.from_unix!(ts, :millisecond) |> DateTime.to_iso8601()
    end
  end

  defp classify_transformation(%{rule: "lsystem"}), do: "structural_growth"
  defp classify_transformation(%{rule: "fibonacci"}), do: "sequence_generation"
  defp classify_transformation(%{rule: "lazy"}), do: "sequence_generation"
  defp classify_transformation(%{rule: "adaptive"}), do: "strategy_selection"
  defp classify_transformation(%{rule: "genetic"}), do: "evolutionary_selection"
  defp classify_transformation(%{rule: "spec"}), do: "synthesis"
  defp classify_transformation(_), do: "generic_transformation"

  defp calculate_complexity_change(from, to) do
    from_size = estimate_complexity(from)
    to_size = estimate_complexity(to)
    %{
      from: from_size,
      to: to_size,
      change: to_size - from_size,
      growth_factor: if(from_size > 0, do: to_size / from_size, else: nil)
    }
  end

  defp estimate_complexity(value) when is_binary(value), do: String.length(value)
  defp estimate_complexity(value) when is_list(value), do: length(value)
  defp estimate_complexity(value) when is_map(value) do
    case value do
      %{axiom: axiom} -> String.length(axiom)
      _ -> map_size(value)
    end
  end
  defp estimate_complexity(_), do: 1

  # Storage functions
  defp store_seed(name, seed) do
    File.mkdir_p(@storage_path)
    path = Path.join(@storage_path, "#{name}.seed")
    data = :erlang.term_to_binary(seed)
    File.write!(path, data)
  end

  defp load_seed(name) do
    path = Path.join(@storage_path, "#{name}.seed")

    case File.read(path) do
      {:ok, data} ->
        seed = :erlang.binary_to_term(data)
        {:ok, seed}

      {:error, :enoent} ->
        {:error, "No expression named '#{name}' found"}

      {:error, reason} ->
        {:error, "Failed to load #{name}: #{inspect(reason)}"}
    end
  end

  defp list_seeds do
    case File.ls(@storage_path) do
      {:ok, files} ->
        seeds =
          files
          |> Enum.filter(&String.ends_with?(&1, ".seed"))
          |> Enum.map(&String.replace(&1, ".seed", ""))

        {:ok, seeds}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp save_seed_file(seed, filename) do
    data = %{
      name: Path.basename(filename, ".gx"),
      generator: seed.generator,
      value: seed.value,
      meta: seed.meta,
      created: DateTime.utc_now()
    }

    case Jason.encode(data, pretty: true) do
      {:ok, json} -> File.write(filename, json)
      {:error, reason} -> {:error, reason}
    end
  end

  defp load_seed_file(filename) do
    with {:ok, content} <- File.read(filename),
         {:ok, data} <- Jason.decode(content, keys: :atoms) do
      seed = Expansion.create_expandable(data.generator, data.value, data.meta)
      {:ok, {data.name, seed}}
    else
      {:error, reason} -> {:error, "Failed to load file: #{inspect(reason)}"}
    end
  end

  defp load_context do
    case File.read("/tmp/gexpr_context.json") do
      {:ok, content} ->
        case Jason.decode(content, keys: :atoms) do
          {:ok, context} -> context
          _ -> %{}
        end

      _ ->
        %{}
    end
  end

  defp save_context(context) do
    case Jason.encode(context, pretty: true) do
      {:ok, json} -> File.write("/tmp/gexpr_context.json", json)
      _ -> :ok
    end
  end

  # Parsing helpers
  defp parse_json(""), do: %{}

  defp parse_json(json_string) do
    case Jason.decode(json_string, keys: :atoms) do
      {:ok, data} -> data
      {:error, _} -> %{}
    end
  end

  defp parse_grow_options(options) do
    parse_options(options, %{})
  end

  defp parse_options(["-n", n_str | rest], acc) do
    iterations = String.to_integer(n_str)
    parse_options(rest, Map.put(acc, :iterations, iterations))
  end

  defp parse_options(["--until", _condition | rest], acc) do
    # TODO: implement condition parsing
    parse_options(rest, acc)
  end

  defp parse_options([_unknown | rest], acc) do
    parse_options(rest, acc)
  end

  defp parse_options([], acc), do: acc

  defp parse_show_format(options) do
    case Enum.find_index(options, &(&1 == "--as")) do
      nil ->
        :pretty

      idx ->
        format = Enum.at(options, idx + 1)

        case format do
          "json" -> :json
          "structure" -> :structure
          _ -> :pretty
        end
    end
  end

  defp parse_peek_depth(options) do
    case Enum.find_index(options, &(&1 == "--depth")) do
      nil ->
        1

      idx ->
        depth_str = Enum.at(options, idx + 1)
        String.to_integer(depth_str)
    end
  end

  defp parse_context_value("true"), do: true
  defp parse_context_value("false"), do: false

  defp parse_context_value(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> value
    end
  end

  defp show_help do
    IO.puts("""
    gx - The G-Expression CLI v0.1.0

    Commands:
      plant <name> <generator> [spec]  - Create a seed expression
      grow <name> [options]            - Expand an expression
      show <name> [options]            - Display an expression
      peek <name> [options]            - Observe without expansion
      repl                             - Interactive mode
      context set <key> <value>        - Set expansion context
      context show                     - Show current context
      save <name> [file]               - Save expression to file
      load <file>                      - Load expression from file

    Generator types:
      lazy      - Lazy sequences (fibonacci, etc.)
      adaptive  - Adaptive algorithms
      lsystem   - L-system recursive structures
      spec      - Specifications that synthesize to code

    Show options:
      --as json         - Output as JSON
      --visual          - Open interactive browser visualization
      --tree            - Output expansion tree as JSON
      --tree --meta     - Include detailed metadata
      --tree --steps    - Include transformation analysis

    Examples:
      gx plant fib lazy
      gx grow fib -n 5
      gx show fib --as json
      gx show fib --tree
      gx show fib --tree --meta --steps
      gx peek fib --depth 2
    """)
  end

  defp show_repl_help do
    IO.puts("""
    REPL Commands:
      plant <name> <generator> [spec] - Create seed
      grow <name> [options]           - Expand expression  
      show <name> [options]           - Display expression
      peek <name> [options]           - Observe expression
      list                            - List all seeds
      demo                            - Run showcase fractal tree demo
      catalog                         - Show seed library catalog
      help                            - Show this help
      exit                            - Exit REPL
      
    Show Options:
      show <name> --visual            - Open browser visualization
      show <name> --tree              - JSON expansion tree
      show <name> --tree --meta       - Tree with metadata
      show <name> --tree --steps      - Tree with transformation analysis
      
    Growth Options:  
      grow <name> --visual            - Real-time ASCII growth animation
      
    Example Showcase Demo:
      plant fractal fractal
      grow fractal --visual -n 6
      show fractal --tree --meta
    """)
  end
end