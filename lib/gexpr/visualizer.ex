defmodule Gexpr.Visualizer do
  @moduledoc """
  Visualization system for G-expression expansion processes.
  
  Provides both terminal ASCII art and web-based visualizations of:
  - Expansion trees and transformation histories
  - Real-time growth processes (L-systems, fractals, sequences)
  - Interactive exploration of seed states and possibilities
  """

  alias Gexpr.Expansion

  @doc """
  Generates a browser-based visualization of expansion history and current state.
  """
  def show_visual(seed, name, options \\ %{}) do
    case options[:format] do
      :web -> create_web_visualization(seed, name, options)
      :terminal -> create_terminal_visualization(seed, name, options)
      _ -> create_web_visualization(seed, name, options)
    end
  end

  @doc """
  Creates real-time growing visualization for L-systems and sequences.
  """
  def grow_visual(seed, name, iterations, options \\ %{}) do
    case seed.generator do
      :lsystem -> grow_lsystem_visual(seed, name, iterations, options)
      :lazy -> grow_sequence_visual(seed, name, iterations, options)
      _ -> grow_generic_visual(seed, name, iterations, options)
    end
  end

  # Web-based visualization
  defp create_web_visualization(seed, name, _options) do
    html_content = generate_html_page(seed, name)
    temp_file = "/tmp/gx_viz_#{name}.html"
    
    case File.write(temp_file, html_content) do
      :ok ->
        # Try to open in browser
        case :os.type() do
          {:unix, :darwin} -> System.cmd("open", [temp_file])
          {:unix, _} -> System.cmd("xdg-open", [temp_file])
          {:win32} -> System.cmd("cmd", ["/c", "start", temp_file])
        end
        
        IO.puts("📊 Opening visualization in browser: #{temp_file}")
        :ok
        
      {:error, reason} ->
        IO.puts("❌ Failed to create visualization: #{reason}")
        {:error, reason}
    end
  end

  defp generate_html_page(seed, name) do
    expansion_data = seed_to_d3_data(seed)
    
    """
    <!DOCTYPE html>
    <html>
    <head>
        <title>G-Expression Visualization: #{name}</title>
        <script src="https://d3js.org/d3.v7.min.js"></script>
        <style>
            body { 
                font-family: 'Monaco', 'Consolas', monospace; 
                margin: 20px; 
                background: #0a0a0a; 
                color: #00ff41; 
            }
            .container { 
                display: flex; 
                gap: 20px; 
            }
            .panel { 
                background: #111; 
                border: 1px solid #333; 
                border-radius: 8px; 
                padding: 20px; 
            }
            .tree-panel { 
                flex: 2; 
                min-height: 600px; 
            }
            .info-panel { 
                flex: 1; 
                max-width: 300px; 
            }
            .node circle { 
                fill: #00ff41; 
                stroke: #00aa2e; 
                stroke-width: 2px; 
            }
            .node text { 
                fill: #00ff41; 
                font-size: 12px; 
            }
            .link { 
                stroke: #00aa2e; 
                stroke-width: 2px; 
            }
            .history-item { 
                margin: 10px 0; 
                padding: 10px; 
                background: #0a0a0a; 
                border-left: 3px solid #00ff41; 
            }
            .generator-badge { 
                display: inline-block; 
                padding: 2px 6px; 
                background: #00aa2e; 
                color: #000; 
                border-radius: 3px; 
                font-size: 10px; 
                font-weight: bold; 
            }
        </style>
    </head>
    <body>
        <h1>🌱 #{name}</h1>
        <div class="container">
            <div class="panel tree-panel">
                <h3>Expansion Tree</h3>
                <svg id="tree-svg"></svg>
            </div>
            <div class="panel info-panel">
                <h3>Seed Information</h3>
                <p><span class="generator-badge">#{seed.generator}</span></p>
                <p><strong>Depth:</strong> #{seed.expansion_state.depth}</p>
                <p><strong>Iterations:</strong> #{seed.expansion_state.iterations}</p>
                
                <h4>Current State</h4>
                <pre>#{inspect(seed.value, pretty: true, limit: 3)}</pre>
                
                <h4>Expansion History</h4>
                <div id="history">
                    #{render_history_html(seed.expansion_state.history)}
                </div>
            </div>
        </div>

        <script>
            const data = #{Jason.encode!(expansion_data)};
            
            const width = 800;
            const height = 600;
            
            const svg = d3.select("#tree-svg")
                .attr("width", width)
                .attr("height", height);
            
            const root = d3.hierarchy(data);
            const treeLayout = d3.tree().size([width - 100, height - 100]);
            treeLayout(root);
            
            // Draw links
            svg.selectAll("path.link")
                .data(root.links())
                .enter()
                .append("path")
                .attr("class", "link")
                .attr("d", d3.linkVertical()
                    .x(d => d.x + 50)
                    .y(d => d.y + 50));
            
            // Draw nodes
            const nodes = svg.selectAll("g.node")
                .data(root.descendants())
                .enter()
                .append("g")
                .attr("class", "node")
                .attr("transform", d => `translate($${d.x + 50},$${d.y + 50})`);
            
            nodes.append("circle")
                .attr("r", 8);
            
            nodes.append("text")
                .attr("dy", "0.3em")
                .attr("x", d => d.children ? -12 : 12)
                .style("text-anchor", d => d.children ? "end" : "start")
                .text(d => d.data.label);
        </script>
    </body>
    </html>
    """
  end

  defp seed_to_d3_data(seed) do
    %{
      label: "#{seed.generator}",
      value: inspect(seed.value),
      children: history_to_tree_nodes(seed.expansion_state.history)
    }
  end

  defp history_to_tree_nodes(history) do
    history
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {step, index} ->
      %{
        label: "Step #{index + 1}",
        value: step.rule,
        children: []
      }
    end)
  end

  defp render_history_html(history) do
    history
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {step, index} ->
      """
      <div class="history-item">
          <strong>Step #{index + 1}:</strong> #{step.rule}<br>
          <small>#{format_timestamp(step.timestamp)}</small>
      </div>
      """
    end)
    |> Enum.join("")
  end

  defp format_timestamp(timestamp) do
    datetime = DateTime.from_unix!(timestamp, :millisecond)
    Calendar.strftime(datetime, "%H:%M:%S.%f")
  end

  # Terminal ASCII visualization
  defp create_terminal_visualization(seed, name, _options) do
    case seed.generator do
      :lsystem -> render_lsystem_ascii(seed, name)
      :lazy -> render_sequence_ascii(seed, name)
      _ -> render_generic_ascii(seed, name)
    end
  end

  # L-System ASCII rendering
  def render_lsystem_ascii(%{value: %{axiom: axiom}} = seed, name) do
    IO.puts("🌳 #{name} (L-System Tree)")
    IO.puts("Axiom: #{axiom}")
    IO.puts("")
    
    # Convert L-system string to visual tree
    tree_lines = axiom_to_ascii_tree(axiom)
    Enum.each(tree_lines, &IO.puts/1)
    
    IO.puts("")
    IO.puts("Depth: #{seed.expansion_state.depth} | Iterations: #{seed.expansion_state.iterations}")
    :ok
  end

  defp axiom_to_ascii_tree(axiom) do
    # Center starting position
    center_x = 40
    start_y = 25
    
    # Parse L-system symbols into tree structure  
    {lines, _, _} = draw_branch(axiom, center_x, start_y, 0, [])
    
    # Convert to string lines
    max_width = 80
    max_height = 30
    
    # Initialize grid with spaces
    grid = for _ <- 1..max_height, do: for(_ <- 1..max_width, do: " ")
    
    # Place characters on grid
    final_grid = Enum.reduce(lines, grid, fn {x, y, char}, acc ->
      safe_x = max(0, min(x, max_width - 1))
      safe_y = max(0, min(y, max_height - 1))
      
      List.update_at(acc, safe_y, fn row ->
        List.replace_at(row, safe_x, char)
      end)
    end)
    
    # Convert to strings and clean up
    final_grid
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
  end

  # Recursive L-system tree drawer with better graphics
  defp draw_branch("", x, y, _angle, lines), do: {lines, x, y}
  
  defp draw_branch("A" <> rest, x, y, angle, lines) do
    # A = main trunk, draw upward with multiple segments
    new_y = y - 3
    new_lines = [
      {x, y, "│"},
      {x, y - 1, "│"},
      {x, y - 2, "│"}
      | lines
    ]
    draw_branch(rest, x, new_y, angle, new_lines)
  end
  
  defp draw_branch("B" <> rest, x, y, angle, lines) do
    # B = branch segment
    new_y = y - 2
    new_lines = [
      {x, y, "│"},
      {x, y - 1, "│"}
      | lines
    ]
    draw_branch(rest, x, new_y, angle, new_lines)
  end
  
  defp draw_branch("[+" <> rest, x, y, angle, lines) do
    # Start right branch
    {branch_rest, remaining} = extract_branch(rest)
    
    # Draw the connection and branch
    connector_lines = [
      {x, y, "├"},
      {x + 1, y - 1, "╱"}
    ]
    
    {branch_lines, _, _} = draw_branch(branch_rest, x + 2, y - 2, angle + 45, lines)
    new_lines = connector_lines ++ branch_lines
    draw_branch(remaining, x, y, angle, new_lines)
  end
  
  defp draw_branch("[-" <> rest, x, y, angle, lines) do
    # Start left branch
    {branch_rest, remaining} = extract_branch(rest)
    
    # Draw the connection and branch
    connector_lines = [
      {x, y, "├"},
      {x - 1, y - 1, "╲"}
    ]
    
    {branch_lines, _, _} = draw_branch(branch_rest, x - 2, y - 2, angle - 45, lines)
    new_lines = connector_lines ++ branch_lines
    draw_branch(remaining, x, y, angle, new_lines)
  end
  
  defp draw_branch(<<_char::utf8, rest::binary>>, x, y, angle, lines) do
    # Skip unknown characters
    draw_branch(rest, x, y, angle, lines)
  end

  defp extract_branch(string) do
    extract_branch_helper(string, "", 0)
  end

  defp extract_branch_helper("", acc, _depth), do: {acc, ""}
  defp extract_branch_helper("[" <> rest, acc, depth) do
    extract_branch_helper(rest, acc <> "[", depth + 1)
  end
  defp extract_branch_helper("]" <> rest, acc, 0) do
    {acc, rest}
  end
  defp extract_branch_helper("]" <> rest, acc, depth) do
    extract_branch_helper(rest, acc <> "]", depth - 1)
  end
  defp extract_branch_helper(<<char::utf8, rest::binary>>, acc, depth) do
    extract_branch_helper(rest, acc <> <<char::utf8>>, depth)
  end

  # Sequence ASCII rendering  
  def render_sequence_ascii(%{value: %{state: state}} = seed, name) do
    IO.puts("🔢 #{name} (Sequence)")
    
    # Show recent sequence values
    history = seed.expansion_state.history
    values = extract_sequence_values(history, state)
    
    IO.puts("Current: #{inspect(state)}")
    IO.puts("Sequence: #{Enum.join(values, ", ")}")
    
    # Visual bar chart for recent values
    if length(values) > 1 do
      IO.puts("")
      render_sequence_chart(values)
    end
    
    IO.puts("")
    IO.puts("Depth: #{seed.expansion_state.depth} | Iterations: #{seed.expansion_state.iterations}")
    :ok
  end

  defp extract_sequence_values(history, current_state) do
    # Extract numeric values from history
    values = 
      history
      |> Enum.reverse()
      |> Enum.map(fn step ->
        case step.from do
          %{state: [a, _b]} -> a
          _ -> nil
        end
      end)
      |> Enum.filter(&(&1 != nil))
    
    # Add current value
    case current_state do
      [a, _b] -> values ++ [a]
      _ -> values
    end
  end

  defp render_sequence_chart(values) do
    if Enum.empty?(values), do: :ok
    
    max_val = Enum.max(values)
    max_height = 10
    
    # Normalize values to chart height (handle zero max_val)
    normalized = if max_val == 0 do
      Enum.map(values, fn _ -> 0 end)
    else
      Enum.map(values, fn val ->
        round(val / max_val * max_height)
      end)
    end
    
    # Show values at top
    IO.puts("Values: #{Enum.join(values, ", ")}")
    IO.puts("")
    
    # Draw chart from top down with better graphics
    for height <- max_height..1 do
      line = Enum.with_index(normalized) |> Enum.map(fn {val, _idx} ->
        cond do
          val >= height -> "▓"
          val == height - 1 -> "░"  # Partial fill for visual smoothness
          true -> " "
        end
      end)
      IO.puts("│" <> Enum.join(line, "") <> "│")
    end
    
    # Bottom border
    bottom = "└" <> String.duplicate("─", length(values)) <> "┘"
    IO.puts(bottom)
    
    # Scale indicators
    if max_val > 0 do
      IO.puts("Scale: 0 to #{max_val}")
    end
  end

  # Generic ASCII rendering
  defp render_generic_ascii(seed, name) do
    IO.puts("🔍 #{name} (#{seed.generator})")
    IO.puts("")
    IO.puts("Current Value:")
    IO.inspect(seed.value, pretty: true, limit: 10)
    IO.puts("")
    IO.puts("Expansion State:")
    IO.puts("  Depth: #{seed.expansion_state.depth}")
    IO.puts("  Iterations: #{seed.expansion_state.iterations}")
    
    unless Enum.empty?(seed.expansion_state.history) do
      IO.puts("")
      IO.puts("Recent History:")
      
      seed.expansion_state.history
      |> Enum.take(3)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.each(fn {step, index} ->
        IO.puts("  #{index + 1}. #{step.rule}")
      end)
    end
    
    :ok
  end

  # Real-time growing visualizations
  defp grow_lsystem_visual(seed, name, iterations, _options) do
    IO.puts("🌱 Growing #{name} in real-time...")
    IO.puts("Press Ctrl+C to stop early")
    IO.puts("")
    
    context = Expansion.create_context()
    current_seed = seed
    
    for i <- 1..iterations do
      IO.puts("=== Step #{i} ===")
      render_lsystem_ascii(current_seed, name)
      IO.puts("")
      
      # Pause for dramatic effect
      :timer.sleep(1500)
      
      # Grow one step
      case Expansion.gexpand(current_seed, context) do
        {:ok, new_seed} -> 
          current_seed = new_seed
        {:error, reason} -> 
          IO.puts("Growth stopped: #{reason}")
          current_seed = current_seed
      end
    end
    
    IO.puts("🎉 Growth complete!")
    {:ok, current_seed}
  end

  defp grow_sequence_visual(seed, name, iterations, _options) do
    IO.puts("📈 Growing #{name} sequence...")
    IO.puts("")
    
    context = Expansion.create_context()
    current_seed = seed
    
    for i <- 1..iterations do
      case current_seed.expansion_state[:last_generated] do
        nil -> :ok
        value -> 
          IO.write("#{value}")
          if rem(i, 10) == 0, do: IO.puts(""), else: IO.write(", ")
      end
      
      # Brief pause
      :timer.sleep(200)
      
      # Grow one step
      case Expansion.gexpand(current_seed, context) do
        {:ok, new_seed} -> 
          current_seed = new_seed
        {:error, reason} -> 
          IO.puts("\nGrowth stopped: #{reason}")
          current_seed = current_seed
      end
    end
    
    IO.puts("\n🎉 Sequence complete!")
    {:ok, current_seed}
  end

  defp grow_generic_visual(seed, name, iterations, _options) do
    IO.puts("⚡ Growing #{name}...")
    
    context = Expansion.create_context()
    current_seed = seed
    
    for i <- 1..iterations do
      IO.puts("Step #{i}: #{seed.generator}")
      
      case Expansion.gexpand(current_seed, context) do
        {:ok, new_seed} -> 
          current_seed = new_seed
          :timer.sleep(500)
        {:error, reason} -> 
          IO.puts("Growth stopped: #{reason}")
          current_seed = current_seed
      end
    end
    
    render_generic_ascii(current_seed, name)
    {:ok, current_seed}
  end
end