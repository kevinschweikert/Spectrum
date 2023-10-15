import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :spotifyr, Spotifyr.Repo,
  database: Path.join(__DIR__, "../test/spotifyr_#{System.get_env("MIX_TEST_PARTITION")}.db"),
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spotifyr, SpotifyrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FSpdpci9CxCkquYoDVhAs40Qn57rYAk/HjbUUIioj4nVwqPAIJMLMvFX1C2Aj8tg",
  server: false

# In test we don't send emails.
config :spotifyr, Spotifyr.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
