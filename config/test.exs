import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :qr_code, QrCode.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "qr_code_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :qr_code, QrCodeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "AhQYk/zdVuqbWj/ngiQs0wIfpanDWBIjVFrV9nfbhQ/x0NLPAaivY1MBzz6z4K5X",
  server: true

# In test we don't send emails
config :qr_code, QrCode.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure Wallaby for feature tests
config :wallaby,
  # Use Wallaby.Chrome module for the driver
  driver: Wallaby.Chrome,
  screenshot_dir: "tmp/wallaby/screenshots",
  # Automatically take screenshot on errors
  screenshot_on_failure: true,
  # The base_url needs to point to the running Phoenix app during tests
  # We configure it in the test setup using Wallaby.start_session/1
  # base_url: QrCodeWeb.Endpoint.url(), # This might not work directly here
  js_logger: true

# Import test configuration from endpoint.exs
# import_config "../lib/qr_code_web/endpoint.ex" # Removed as it causes compile-time issues
