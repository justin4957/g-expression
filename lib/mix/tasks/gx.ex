defmodule Mix.Tasks.Gx do
  @moduledoc """
  Mix task wrapper for the G-expression CLI.
  
  This allows running `mix gx` commands from the project directory.
  """
  
  use Mix.Task

  @shortdoc "Run G-expression CLI commands"

  def run(args) do
    Gexpr.CLI.main(args)
  end
end