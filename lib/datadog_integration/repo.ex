defmodule DatadogIntegration.Repo do
  use Ecto.Repo,
    otp_app: :datadog_integration,
    adapter: Ecto.Adapters.Postgres
end
