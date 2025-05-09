defmodule QrCodeWeb.AboutLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :about_live, :mount], %{status: :start})
    Logger.info("AboutLive mounted")
    {:ok, socket}
  end
end
