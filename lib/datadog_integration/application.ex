defmodule DatadogIntegration.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # init spandex first
      {SpandexDatadog.ApiServer, spandex_datadog_options()},

      # Start the Ecto repository
      DatadogIntegration.Repo,
      # Start the Telemetry supervisor
      DatadogIntegrationWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DatadogIntegration.PubSub},
      # Start the Endpoint (http/https)
      DatadogIntegrationWeb.Endpoint
      # Start a worker by calling: DatadogIntegration.Worker.start_link(arg)
      # {DatadogIntegration.Worker, arg}
    ]

    :telemetry.attach(
      "spandex-query-tracer",
      [:datadog_integration, :repo, :query],
      &SpandexEcto.TelemetryAdapter.handle_event/4,
      nil
    )

    :telemetry.attach(
      "logger-json-ecto",
      [:datadog_integration, :repo, :query],
      &LoggerJSON.Ecto.telemetry_logging_handler/4,
      :info
    )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DatadogIntegration.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DatadogIntegrationWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp spandex_datadog_options() do
    [
      host: datadog_host(),
      port: datadog_port(),
      batch_size: spandex_batch_size(),
      sync_threshold: spandex_sync_threshold(),
      http: HTTPoison
    ]
  end

  defp spandex_batch_size(), do: Application.fetch_env!(:datadog_integration, :spandex_batch_size)
  defp spandex_sync_threshold(), do: Application.fetch_env!(:datadog_integration, :spandex_sync_threshold)
  defp datadog_host(), do: :datadog_integration |> Application.fetch_env!(:datadog) |> Keyword.fetch!(:host)
  defp datadog_port(),
    do: :datadog_integration |> Application.fetch_env!(:datadog) |> Keyword.fetch!(:default_port)
end
