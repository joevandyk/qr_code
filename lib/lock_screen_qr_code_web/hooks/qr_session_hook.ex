defmodule LockScreenQRCodeWeb.QrSessionHook do
  @moduledoc """
  Hook for managing QR code request data between LiveViews.

  This hook ensures that QR request data is properly loaded when navigating
  between LiveViews in the QR code creation flow.
  """
  import Phoenix.Component
  import Phoenix.LiveView
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.QrRequest

  def on_mount(:ensure_qr_data, _params, session, socket) do
    cond do
      # First check for direct ID (primarily for tests)
      id = session["qr_request_id"] ->
        case Requests.get_qr_request(id) do
          %QrRequest{} = qr_request ->
            {:cont, assign(socket, :qr_request, qr_request)}
          nil ->
            Logger.error("QR request not found for ID: #{id}")
            {:halt, redirect(socket, to: "/start")}
        end

      # Then check for token (primary production path)
      token = session["qr_request_token"] ->
        case Requests.get_qr_request_by_token(token) do
          %QrRequest{} = qr_request ->
            {:cont, assign(socket, :qr_request, qr_request)}
          nil ->
            Logger.error("QR request not found for token: #{token}")
            {:halt, redirect(socket, to: "/start")}
        end

      # No session data found
      true ->
        Logger.warning("No QR request ID or token in session")
        {:halt, redirect(socket, to: "/start")}
    end
  end
end
