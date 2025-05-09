defmodule LockScreenQRCodeWeb.QRImageController do
  use LockScreenQRCodeWeb, :controller
  require Logger
  alias LockScreenQRCode.Compositor
  alias LockScreenQRCode.Requests

  @doc """
  Serves a QR code image by generating it on-demand.
  This approach doesn't store files on disk at all, making it ideal for containerized environments.
  """
  def show(conn, %{"id" => token}) do
    # Only use token-based lookup for more security
    qr_request = Requests.get_qr_request_by_token(token)

    case qr_request do
      nil ->
        Logger.error("QR request not found for token: #{token}")
        conn
        |> put_status(:not_found)
        |> text("QR code not found")

      qr_request ->
        Logger.info("Generating QR code for URL: #{qr_request.url} (format: png, scale: 20)")

        # Generate the QR code directly - note that template field is used, not template_id
        case Compositor.compose(qr_request.url, qr_request.template, text: qr_request.name) do
          {:ok, binary} ->
            conn
            |> put_resp_content_type("image/png")
            |> put_resp_header("cache-control", "public, max-age=3600")
            |> send_resp(200, binary)

          {:error, reason} ->
            Logger.error("Failed to generate QR image: #{inspect(reason)}")
            conn
            |> put_status(:internal_server_error)
            |> text("Failed to generate QR code")
        end
    end
  end
end
