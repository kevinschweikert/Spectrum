defmodule Spotifyr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SpotifyrWeb.Telemetry,
      Spotifyr.Repo,
      {DNSCluster, query: Application.get_env(:spotifyr, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Spotifyr.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Spotifyr.Finch},
      # Start a worker by calling: Spotifyr.Worker.start_link(arg)
      # {Spotifyr.Worker, arg},
      # Start to serve requests, typically the last entry
      SpotifyrWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spotifyr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpotifyrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
