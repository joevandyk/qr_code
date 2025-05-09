defmodule QrCodeWeb.DownloadLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :download_live, :mount], %{status: :start})
    Logger.info("DownloadLive mounted")
    {:ok, socket}
  end
end
