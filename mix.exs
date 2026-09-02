defmodule Managoat.ACP.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/managoat/managoat_acp"

  def project do
    [
      app: :managoat_acp,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "A client-side Agent Client Protocol session that outlives the turn, with a per-tool permission policy, block normalisation, usage accounting and a tracer, behind a writer callback.",
      package: package(),
      source_url: @source_url,
      docs: docs(),
      dialyzer: dialyzer(),
      test_coverage: [
        # What this suite measures on its own, set from the first
        # `mix test --cover` run after extraction (#1339) rather than to
        # pass. Raise it as the library's own tests grow; never lower it.
        summary: [threshold: 90]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp deps do
    [
      # Tooling for the repository, not the package: docs for hexdocs.pm (built
      # by `mix hex.publish`), credo and dialyzer for CI. dialyxir is pinned to
      # the commit that added OTP 28 support; 1.4.7 crashes on OTP 28 warnings.
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir,
       github: "jeremyjh/dialyxir",
       ref: "3553678f4d69281ac6db61034bcf35bcb30cfd78",
       only: [:dev, :test],
       runtime: false},
      {:jason, "~> 1.2"},
      # The tracer opens and closes OTel spans through the API macros
      # (`OpenTelemetry.Tracer`). The API package is the portable half of
      # OpenTelemetry: with no SDK started every span call is a no-op, so a
      # consumer that does not trace pays nothing and configures nothing.
      # The SDK, the exporter and the instrumentation libraries belong to
      # the host application.
      {:opentelemetry_api, "~> 1.4"}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url, "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"},
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE NOTICE)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp dialyzer do
    [
      ignore_warnings: ".dialyzer_ignore.exs",
      # A fixed path so CI can cache the PLT across runs.
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
