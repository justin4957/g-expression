defmodule Gexpr.JsCompiler do
  @moduledoc """
  G-Expression to JavaScript compiler.
  
  This module demonstrates the core value proposition of G-Expressions:
  they can be losslessly compiled to any target language, proving their
  utility as a universal computational substrate.
  
  ## Examples
  
      # Simple arithmetic
      add_expr = {:app, {:ref, "+"}, {:vec, [{:lit, 20}, {:lit, 22}]}}
      {:ok, js_code} = Gexpr.compile_to_js(add_expr)
      # js_code => "(20 + 22)"
      
      # Lambda function
      double = {:lam, %{params: ["x"], body: {:app, {:ref, "*"}, {:vec, [{:ref, "x"}, {:lit, 2}]}}}}
      {:ok, js_func} = Gexpr.compile_to_js(double)
      # js_func => "(x) => { return (x * 2); }"
  """

  alias Gexpr.PrimeMover

  @doc """
  Compiles a G-Expression to JavaScript code.
  
  This is the key function that proves G-Expressions can be transformed
  into practical, executable code in mainstream languages.
  """
  @spec compile_to_js(PrimeMover.prime_gexpr()) :: {:ok, String.t()} | {:error, String.t()}
  def compile_to_js(gexpr) do
    try do
      js_code = compile_gexpr(gexpr)
      {:ok, js_code}
    rescue
      e -> {:error, "Compilation failed: #{Exception.message(e)}"}
    end
  end

  @doc """
  Compiles a G-Expression to a complete JavaScript function.
  
  This wraps the expression in a function declaration for easy testing.
  """
  @spec compile_to_js_function(PrimeMover.prime_gexpr(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def compile_to_js_function(gexpr, function_name \\ "gexpr_func") do
    case compile_to_js(gexpr) do
      {:ok, js_expr} ->
        js_function = """
        function #{function_name}() {
          return #{js_expr};
        }
        """
        {:ok, js_function}
      
      error -> error
    end
  end

  @doc """
  Compiles a G-Expression lambda to a JavaScript function with parameters.
  """
  @spec compile_lambda_to_js_function(PrimeMover.prime_gexpr(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def compile_lambda_to_js_function({:lam, %{params: params, body: body}}, function_name \\ "gexpr_func") do
    case compile_to_js(body) do
      {:ok, js_body} ->
        params_str = Enum.join(params, ", ")
        js_function = """
        function #{function_name}(#{params_str}) {
          return #{js_body};
        }
        """
        {:ok, js_function}
      
      error -> error
    end
  end

  def compile_lambda_to_js_function(gexpr, _function_name) do
    {:error, "Expected lambda expression, got: #{inspect(gexpr)}"}
  end

  # Private compilation functions

  defp compile_gexpr({:lit, value}) when is_number(value), do: to_string(value)
  defp compile_gexpr({:lit, true}), do: "true"
  defp compile_gexpr({:lit, false}), do: "false"
  defp compile_gexpr({:lit, nil}), do: "null"
  defp compile_gexpr({:lit, value}) when is_binary(value), do: "\"#{escape_js_string(value)}\""
  defp compile_gexpr({:lit, value}) when is_atom(value), do: "\"#{value}\""
  defp compile_gexpr({:lit, {:list, elements}}), do: "[#{compile_list_elements(elements)}]"
  defp compile_gexpr({:lit, value}), do: "#{inspect(value)}"

  defp compile_gexpr({:ref, name}), do: name

  defp compile_gexpr({:vec, elements}) do
    compiled_elements = Enum.map(elements, &compile_gexpr/1)
    "[#{Enum.join(compiled_elements, ", ")}]"
  end

  defp compile_gexpr({:lam, %{params: params, body: body}}) do
    compiled_body = compile_gexpr(body)
    params_str = Enum.join(params, ", ")
    "(#{params_str}) => { return #{compiled_body}; }"
  end

  defp compile_gexpr({:app, {:ref, op}, {:vec, [left, right]}}) when op in ["+", "-", "*", "/", "<=", ">=", "<", ">", "==", "!="] do
    compiled_left = compile_gexpr(left)
    compiled_right = compile_gexpr(right)
    js_op = map_operator(op)
    "(#{compiled_left} #{js_op} #{compiled_right})"
  end

  defp compile_gexpr({:app, {:ref, "eq?"}, {:vec, [left, right]}}) do
    compiled_left = compile_gexpr(left)
    compiled_right = compile_gexpr(right)
    "(#{compiled_left} === #{compiled_right})"
  end

  defp compile_gexpr({:app, {:ref, "cond"}, {:vec, [condition, then_expr, else_expr]}}) do
    compiled_condition = compile_gexpr(condition)
    compiled_then = compile_gexpr(then_expr)
    compiled_else = compile_gexpr(else_expr)
    "(#{compiled_condition} ? #{compiled_then} : #{compiled_else})"
  end

  defp compile_gexpr({:app, fun_expr, arg_expr}) do
    compiled_fun = compile_gexpr(fun_expr)
    
    case arg_expr do
      {:vec, args} ->
        compiled_args = Enum.map(args, &compile_gexpr/1)
        args_str = Enum.join(compiled_args, ", ")
        "(#{compiled_fun})(#{args_str})"
      
      single_arg ->
        compiled_arg = compile_gexpr(single_arg)
        "(#{compiled_fun})(#{compiled_arg})"
    end
  end

  defp compile_gexpr({:match, expr, branches}) do
    compiled_expr = compile_gexpr(expr)
    compile_match_branches(compiled_expr, branches)
  end

  defp compile_gexpr({:fix, f}) do
    # Y-combinator in JavaScript
    compiled_f = compile_gexpr(f)
    """
    ((f) => {
      const Y = (g) => ((x) => g((v) => x(x)(v)))((x) => g((v) => x(x)(v)));
      return Y(#{compiled_f});
    })(#{compiled_f})
    """
  end

  defp compile_gexpr(gexpr) do
    raise "Unsupported G-Expression: #{inspect(gexpr)}"
  end

  defp compile_list_elements(elements) do
    elements
    |> Enum.map(&compile_literal_value/1)
    |> Enum.join(", ")
  end

  defp compile_literal_value(value) when is_number(value), do: to_string(value)
  defp compile_literal_value(true), do: "true"
  defp compile_literal_value(false), do: "false"
  defp compile_literal_value(nil), do: "null"
  defp compile_literal_value(value) when is_binary(value), do: "\"#{escape_js_string(value)}\""
  defp compile_literal_value(value) when is_atom(value), do: "\"#{value}\""
  defp compile_literal_value({:list, elements}), do: "[#{compile_list_elements(elements)}]"
  defp compile_literal_value(value), do: "#{inspect(value)}"

  defp compile_match_branches(expr_code, branches) do
    # Convert pattern matching to if-else chain
    compile_branch_chain(expr_code, branches)
  end

  defp compile_branch_chain(_expr_code, []) do
    "null"  # Default case when no patterns match
  end

  defp compile_branch_chain(expr_code, [{{:lit_pattern, pattern_value}, result_expr} | rest]) do
    compiled_result = compile_gexpr(result_expr)
    compiled_pattern = compile_literal_value(pattern_value)
    rest_chain = compile_branch_chain(expr_code, rest)
    
    "(#{expr_code} === #{compiled_pattern} ? #{compiled_result} : #{rest_chain})"
  end

  defp compile_branch_chain(expr_code, [{:else_pattern, result_expr} | _rest]) do
    compile_gexpr(result_expr)
  end

  defp compile_branch_chain(expr_code, [_unknown_pattern | rest]) do
    compile_branch_chain(expr_code, rest)
  end

  defp map_operator("<="), do: "<="
  defp map_operator(">="), do: ">="
  defp map_operator("<"), do: "<"
  defp map_operator(">"), do: ">"
  defp map_operator("=="), do: "==="
  defp map_operator("!="), do: "!=="
  defp map_operator(op), do: op

  defp escape_js_string(str) do
    str
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
    |> String.replace("\n", "\\n")
    |> String.replace("\r", "\\r")
    |> String.replace("\t", "\\t")
  end

  @doc """
  Creates a complete HTML file with the compiled JavaScript for easy testing.
  """
  @spec create_test_html(String.t(), String.t()) :: String.t()
  def create_test_html(js_code, test_description \\ "G-Expression Test") do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <title>#{test_description}</title>
    </head>
    <body>
      <h1>#{test_description}</h1>
      <div id="output"></div>
      
      <script>
        #{js_code}
        
        // Test runner
        try {
          const result = gexpr_func();
          document.getElementById('output').innerHTML = 
            '<p><strong>Result:</strong> ' + JSON.stringify(result) + '</p>';
          console.log('G-Expression result:', result);
        } catch (error) {
          document.getElementById('output').innerHTML = 
            '<p><strong>Error:</strong> ' + error.message + '</p>';
          console.error('G-Expression error:', error);
        }
      </script>
    </body>
    </html>
    """
  end

  @doc """
  Writes compiled JavaScript to a file and optionally creates an HTML test file.
  """
  @spec write_js_file(String.t(), String.t(), boolean()) :: :ok | {:error, String.t()}
  def write_js_file(js_code, filename, create_html \\ true) do
    try do
      File.write!(filename, js_code)
      
      if create_html do
        html_filename = String.replace(filename, ".js", ".html")
        html_content = create_test_html(js_code)
        File.write!(html_filename, html_content)
        IO.puts("Created #{filename} and #{html_filename}")
      else
        IO.puts("Created #{filename}")
      end
      
      :ok
    rescue
      e -> {:error, "Failed to write file: #{Exception.message(e)}"}
    end
  end

  @doc """
  Runs a JavaScript file with Node.js and returns the output.
  """
  @spec run_with_node(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def run_with_node(js_file) do
    case System.cmd("node", [js_file], stderr_to_stdout: true) do
      {output, 0} -> {:ok, String.trim(output)}
      {error_output, _} -> {:error, "Node.js execution failed: #{error_output}"}
    end
  rescue
    e -> {:error, "Failed to run Node.js: #{Exception.message(e)}"}
  end

  @doc """
  End-to-end compilation and testing: G-Expression → JavaScript → Node.js execution.
  """
  @spec compile_and_run(PrimeMover.prime_gexpr(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def compile_and_run(gexpr, function_name \\ "gexpr_func") do
    with {:ok, js_code} <- compile_to_js_function(gexpr, function_name),
         js_file <- "/tmp/#{function_name}.js",
         :ok <- File.write(js_file, js_code <> "\nconsole.log(#{function_name}());"),
         {:ok, output} <- run_with_node(js_file) do
      {:ok, output}
    else
      error -> error
    end
  end
end