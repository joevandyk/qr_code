defmodule LockScreenQRCodeWeb.PreviewLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :preview_live, :mount], %{status: :start})
    Logger.info("PreviewLive mounted")
    {:ok, socket}
  end
end
