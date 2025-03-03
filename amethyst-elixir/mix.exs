defmodule Amethyst.MixProject do
  use Mix.Project

  def project do
    [
      app: :amethyst,
      version: "1.7.2-0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ExDoc
      name: "Amethyst",
      source_url: "https://github.com/henryk-kramer/amethyst",
      docs: &docs/0
    ]
  end

  def application do
    [
      extra_applications: [:logger, :observer, :wx, :runtime_tools],
      mod: {Amethyst.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.37.2", only: :dev, runtime: false},
      {:observer_cli, "~> 1.8"}
    ]
  end

  defp docs do
    [
      main: "Amethyst.Application"
    ]
  end
end
