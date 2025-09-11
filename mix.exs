defmodule Gexpr.MixProject do
  use Mix.Project

  def project do
    [
      app: :gexpr,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      
      # Docs
      name: "G-Expression System",
      description: "A minimal, self-bootstrapping computational framework",
      source_url: "https://github.com/user/gexpr",
      docs: [
        main: "Gexpr",
        extras: ["README.md"],
        groups_for_modules: [
          "Core System": [Gexpr, Gexpr.PrimeMover, Gexpr.Bootstrap]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:jason, "~> 1.4"}
    ]
  end
end
