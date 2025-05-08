defmodule QrCodeWeb.HomeLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :home_live, :mount], %{status: :start})
    Logger.info("HomeLive mounted")
    {:ok, assign(socket, url: "", qr_png: nil, url_error: nil)}
  end

  @impl true
  def handle_event("next", %{"url" => url}, socket) do
    # URL validation and QR code generation will be handled in later stories
    Logger.info("Next event triggered with URL: #{url}")
    # For now, just update the URL in the socket
    {:noreply, assign(socket, url: url)}
  end
end
