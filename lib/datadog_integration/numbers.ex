defmodule DatadogIntegration.Numbers do
  use Spandex.Decorators
  @moduledoc """
  All the HTTP calls would be auto traces, but for others like cron jobs
  we need to manually trace them, this is how we can trace functions,
  further more it doesn't trace private funcations that why I have
  do_process/1 is public.
  """

  @decorate trace(tracer: DatadogIntegration.Datadog.Tracer)
  def execute() do
    Enum.map(1..2000, &(do_process/1))
  end

  @decorate span(tracer: DatadogIntegration.Datadog.Tracer)
  def do_process(number) do
    Process.sleep(number)
    IO.inspect(number)
  end
end
