# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :datadog_integration,
  ecto_repos: [DatadogIntegration.Repo],
  adapter: Ecto.Adapters.Postgres,
  loggers: [
    {Ecto.LogEntry, :log, [:info]},
    {SpandexEcto.EctoLogger, :trace, ["datadog_integration_repo"]}
  ]

# Configures the endpoint
config :datadog_integration, DatadogIntegrationWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DatadogIntegrationWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DatadogIntegration.PubSub,
  live_view: [signing_salt: "x68dSpzY"],
  instrumenters: [SpandexPhoenix.Instrumenter]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :datadog_integration, DatadogIntegration.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# convert logs string to JSON.
config :logger,
  backends: [LoggerJSON],
  format: "$dateT$time [$level]$levelpad $metadata $message\n",
  metadata: [:id, :request_id, :mfa, :line, :trace_id, :span_id]

config :datadog_integration, :datadog,
  host: "localhost",
  listning_port: 8125, # datadog egent listen for traces
  default_port: 8126 # datadog agent send treces

config :datadog_integration, DatadogIntegration.Datadog.Tracer,
  adapter: SpandexDatadog.Adapter,
  service: :datadog_integration,
  type: :web

config :spandex, :decorators, tracer: DatadogIntegration.Datadog.Tracer

config :spandex_ecto, SpandexEcto.EctoLogger,
  service: :datadog_integration_ecto,
  tracer: DatadogIntegration.Datadog.Tracer,
  otp_app: :datadog_integration

config :spandex_phoenix, tracer: DatadogIntegration.Datadog.Tracer

config :datadog_integration,
  spandex_batch_size: "SPANDEX_BATCH_SIZE" |> System.get_env("10") |> String.to_integer(),
  spandex_sync_threshold: "SPANDEX_SYNC_THRESHOLD" |> System.get_env("100") |> String.to_integer()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
