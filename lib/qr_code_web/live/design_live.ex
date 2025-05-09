defmodule QrCodeWeb.DesignLive do
  use QrCodeWeb, :live_view
  require Logger
  alias QrCode.Requests

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :design_live, :mount], %{status: :start})

    # QR request is now always available due to the hook creating one if needed
    if socket.assigns[:qr_request] do
      Logger.info("DesignLive mounted with QR request: #{socket.assigns.qr_request.id}")
    else
      Logger.warning("QR request should have been created by hook but wasn't found")
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("back", _params, socket) do
    # Navigate back to create page - QR request will be loaded from session by hook
    {:noreply, push_navigate(socket, to: ~p"/create", replace: true)}
  end

  @impl true
  def handle_event("refresh_data", _params, socket) do
    token = socket.assigns.qr_request.token
    Logger.info("Manually refreshing QR request data for token: #{token}")

    case Requests.get_qr_request_by_token(token) do
      %QrCode.QrRequest{} = fresh_qr_request ->
        Logger.info("Refreshed QR request with URL: #{fresh_qr_request.url}")
        {:noreply, assign(socket, :qr_request, fresh_qr_request)}

      nil ->
        Logger.warning("QR request with token #{token} not found during refresh")
        {:noreply, socket}
    end
  end
end
