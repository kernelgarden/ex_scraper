defmodule ExScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_scraper,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.21.0"},
      {:flow, "~> 0.14.3"},
      {:castore, "~> 0.1.0"},
      {:mint, "~> 0.2.0"}
    ]
  end
end
