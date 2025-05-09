defmodule QrCodeWeb.DesignLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :design_live, :mount], %{status: :start})
    Logger.info("DesignLive mounted")
    {:ok, socket}
  end
end
