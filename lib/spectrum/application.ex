defmodule Spectrum.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Spectrum.Release.migrate()

    children = [
      SpectrumWeb.Telemetry,
      Spectrum.Repo,
      {DNSCluster, query: Application.get_env(:spectrum, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Spectrum.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Spectrum.Finch},
      # Start a worker by calling: Spectrum.Worker.start_link(arg)
      # {Spectrum.Worker, arg},
      {AshAuthentication.Supervisor, otp_app: :spectrum},
      # Start to serve requests, typically the last entry
      SpectrumWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spectrum.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpectrumWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
