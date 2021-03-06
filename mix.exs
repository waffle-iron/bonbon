defmodule Bonbon.Mixfile do
    use Mix.Project

    def project do
        [
            app: :bonbon,
            version: "0.0.1",
            elixir: "~> 1.3",
            elixirc_paths: elixirc_paths(Mix.env),
            compilers: [:phoenix, :gettext] ++ Mix.compilers,
            build_embedded: Mix.env == :prod,
            start_permanent: Mix.env == :prod,
            consolidate_protocols: Mix.env != :dev,
            aliases: aliases,
            deps: deps,
            dialyzer: [plt_add_deps: :transitive]
        ]
    end

    # Configuration for the OTP application.
    #
    # Type `mix help compile.app` for more information.
    def application do
        [
            mod: { Bonbon, [] },
            applications: [
                :phoenix,
                :phoenix_pubsub,
                :cowboy,
                :logger,
                :gettext,
                :phoenix_ecto,
                :postgrex,
                :absinthe,
                :absinthe_plug,
                :poison,
                :decimal,
                :translecto,
                :ecto_enum,
                :currencies,
                :number,
                :geo,
                :corsica,
                :comeonin,
                :guardian,
                :guardian_db
            ]
        ]
    end

    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
    defp elixirc_paths(_),     do: ["lib", "web"]

    # Specifies your project dependencies.
    #
    # Type `mix help deps` for examples and options.
    defp deps do
        [
            { :phoenix, "~> 1.2.0" },
            { :phoenix_pubsub, "~> 1.0" },
            { :phoenix_ecto, "~> 3.2" },
            { :postgrex, ">= 0.0.0" },
            { :gettext, "~> 0.11" },
            { :cowboy, "~> 1.0" },
            { :absinthe, "~> 1.2.6" },
            { :absinthe_plug, "~> 1.2.5" },
            { :poison, "~> 2.2" },
            { :decimal, "~> 1.3" },
            { :translecto, "~> 0.2.0" },
            { :ecto_enum, "~> 1.0" },
            { :currencies, "~> 0.3.2" },
            { :number, "~> 0.4.2" }, #note: 0.4.2 has precision errors
            { :geo, "~> 1.4" },
            { :tomlex, github: "zamith/tomlex" },
            { :corsica, "~> 0.5.0" },
            { :comeonin, "~> 3.0" },
            { :guardian, "~> 0.14" },
            { :guardian_db, "~> 0.8.0" },
            { :httpoison, "~> 0.9", only: :dev },
            { :floki, "~> 0.10", only: :dev },
            { :simple_markdown, "~> 0.2.1", only: :dev },
            { :simple_markdown_extension_svgbob, "~> 0.0.1", only: :dev },
            { :simple_markdown_extension_highlight_js, "~> 0.0.1", only: :dev },
            { :ex_doc, "~> 0.13", only: :dev }
        ]
    end

    # Aliases are shortcuts or tasks specific to the current project.
    # For example, to create, migrate and run the seeds file at once:
    #
    #     $ mix ecto.setup
    #
    # See the documentation for `Mix` for more info on aliases.
    defp aliases do
        [
            "docs": ["run lib/documentation.exs", "docs"],
            "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
            "ecto.reset": ["ecto.drop", "ecto.setup"],
            "test": ["ecto.create --quiet", "ecto.migrate", "test"]
        ]
    end
end
