defmodule QrCodeWeb.QrSessionHook do
  @moduledoc """
  Hook for managing QR code request data between LiveViews.

  This hook ensures that QR request data is properly loaded when navigating
  between LiveViews in the QR code creation flow.
  """
  import Phoenix.Component
  import Phoenix.LiveView
  require Logger
  alias QrCode.Requests

  def on_mount(:ensure_qr_data, _params, session, socket) do
    # Dump all session data for debugging
    Logger.debug("Session data: #{inspect(session)}")

    # Check if we have a QR request token in the session
    if token = session["qr_request_token"] do
      Logger.info("Found QR request token in session: #{token}")

      # Load QR request from database by token
      case Requests.get_qr_request_by_token(token) do
        %QrCode.QrRequest{} = qr_request ->
          # If we found the request, proceed normally
          Logger.info("Loaded QR request - ID: #{qr_request.id}, URL: #{qr_request.url}, Token: #{token}")

          # Dump the raw QR request data for debugging
          IO.inspect(qr_request, label: "QR REQUEST FROM DATABASE")

          {:cont, assign(socket, :qr_request, qr_request)}

        nil ->
          # If token in session is invalid, redirect to /start to create new one
          Logger.warning("QR request with token #{token} not found in database")
          {:halt, redirect(socket, to: "/start")}
      end
    else
      # No QR request token in session, redirect to /start to establish session
      Logger.info("No QR request token in session, redirecting to /start")
      {:halt, redirect(socket, to: "/start")}
    end
  end
end
