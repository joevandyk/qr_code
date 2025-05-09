defmodule LockScreenQRCodeWeb.DownloadLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :download_live, :mount], %{status: :start})
    Logger.info("DownloadLive mounted")
    {:ok, socket}
  end
end
