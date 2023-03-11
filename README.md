# DatadogIntegration
This is the sample project to install datadog in phoenix using Spandex lib.


##### Spandex
Way to trace a module by spandex.
```elixir
use Spandex.Decorators

@decorate span(tracer: DatadogIntegration.Datadog.Tracer)
def function_to_trace(), do: ["EXECUTION_HERE"]

or If you want to trace everything in module
use DatadogIntegration.Datadog.ModuleTracer

https://github.com/spandex-project/spandex#decorators.
```


#### Configuration
* Add `SPANDEX_BATCH_SIZE` to 10 and `SPANDEX_SYNC_THRESHOLD` to 100 in env variables.
