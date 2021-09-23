defmodule Budget.MixProject do
  use Mix.Project

  def project do
    [
      app: :budget,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Budget.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:tesla_cache, "~> 1.1.0"},
      {:mint, "~> 1.4"},
      {:castore, "~> 0.1"},
      {:certifi, "~> 2.6"},
      # Non-production dependencies.
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.0", only: [:test]},
      {:tix, "~> 0.4.2", only: :test, runtime: false}
    ]
  end

  defp aliases do
    [
      t: ["test --max-failures 1 --seed 0"],
      external: ["test --max-failures 1 --seed 0 --include external:true"]
    ]
  end
end
