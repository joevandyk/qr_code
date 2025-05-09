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
    # Check if we have a QR request token in the session
    if token = session["qr_request_token"] do
      case Requests.get_qr_request_by_token(token) do
        %QrCode.QrRequest{} = qr_request ->
          {:cont, assign(socket, :qr_request, qr_request)}

        nil ->
          {:halt, redirect(socket, to: "/start")}
      end
    else
      {:halt, redirect(socket, to: "/start")}
    end
  end
end
