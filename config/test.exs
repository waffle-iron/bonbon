use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bonbon, Bonbon.Endpoint,
    http: [port: 4001],
    server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :bonbon, Bonbon.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "postgres",
    password: "postgres",
    database: "bonbon_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox,
    types: Bonbon.PostgresTypes

config :guardian, Guardian,
    allowed_algos: ["HS512"],
    verify_module: Guardian.JWT,
    issuer: "Bonbon",
    ttl: { 30, :days },
    allowed_drift: 2000,
    verify_issuer: true,
    secret_key: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.e30.6bK5p0FPG1KY68mstRXiUjWtti5EbPmDg0QxP702j3WTEcI16GXZAU0NlXMQFnyPsrDyqCv9p6KRqMg7LcswMg",
    serializer: Bonbon.GuardianSerializer,
    hooks: GuardianDb
