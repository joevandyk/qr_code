defmodule QrCodeWeb.PreviewLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :preview_live, :mount], %{status: :start})
    Logger.info("PreviewLive mounted")
    {:ok, socket}
  end
end
