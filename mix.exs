defmodule Deparam.MixProject do
  use Mix.Project

  def project do
    [
      app: :deparam,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:ex_unit, :mix]],
      package: package(),

      # Docs
      name: "Deparam",
      source_url: "https://github.com/tlux/deparam",
      docs: [
        main: "Deparam",
        extras: ["README.md"],
        groups_for_modules: [
          Types: [
            Deparam.Types.Any,
            Deparam.Types.Array,
            Deparam.Types.Boolean,
            Deparam.Types.Enum,
            Deparam.Types.Float,
            Deparam.Types.Integer,
            Deparam.Types.Map,
            Deparam.Types.String,
            Deparam.Types.Upload,
            Deparam.Types.URL,
            Deparam.Types.WordList
          ]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:plug, "~> 1.0", optional: true}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_env), do: ["lib"]

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tlux/deparam"
      }
    ]
  end
end
