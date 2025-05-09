defmodule LockScreenQRCode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LockScreenQRCodeWeb.Telemetry,
      LockScreenQRCode.Repo,
      {DNSCluster,
       query: Application.get_env(:lock_screen_qr_code, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LockScreenQRCode.PubSub},
      # Start a worker by calling: LockScreenQRCode.Worker.start_link(arg)
      # {LockScreenQRCode.Worker, arg},
      # Start to serve requests, typically the last entry
      LockScreenQRCodeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LockScreenQRCode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LockScreenQRCodeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
