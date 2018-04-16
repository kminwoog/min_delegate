defmodule MinDelegate.MixProject do
  use Mix.Project

  def project do
    [
      app: :min_delegate,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "MinDelegate",
      source_url: "https://github.com/kminwoog/min_delegate"
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Define easily :call and :cast, :info functions when using gen_server in elixir."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "min_delegate",
      # These are the default files included in the package
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["kim min woog"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kminwoog/min_delegate"}
    ]
  end
end
