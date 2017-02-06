use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :bonbon, Bonbon.Endpoint,
    secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :bonbon, Bonbon.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_URL"),
    pool_size: 20

config :guardian, Guardian,
    allowed_algos: ["HS512"],
    verify_module: Guardian.JWT,
    issuer: "Bonbon",
    ttl: { 30, :days },
    allowed_drift: 2000,
    verify_issuer: true,
    secret_key: System.get_env("GUARDIAN_SECRET_KEY"),
    serializer: Bonbon.GuardianSerializer
