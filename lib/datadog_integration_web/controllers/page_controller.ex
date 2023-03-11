defmodule DatadogIntegrationWeb.PageController do
  use DatadogIntegrationWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
