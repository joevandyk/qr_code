defmodule LockScreenQRCodeWeb.QrRequestController do
  use LockScreenQRCodeWeb, :controller
  require Logger
  alias LockScreenQRCode.Requests

  # Default URL to use if we need a valid one for initial creation
  @default_url "https://example.com"

  def start(conn, _params) do
    # Create a new QR request with a default URL (will be updated later)
    case Requests.create_qr_request(%{url: @default_url, name: ""}) do
      {:ok, qr_request} ->
        Logger.info("Created initial QR request with token: #{qr_request.token}")

        # Store the token in session and redirect to the create page
        conn
        |> put_session("qr_request_token", qr_request.token)
        |> redirect(to: ~p"/create")

      {:error, changeset} ->
        error_message = error_message_from_changeset(changeset)
        Logger.error("Failed to create initial QR request: #{error_message}")

        # Redirect to create page without a session ID
        conn
        |> put_flash(:error, "Something went wrong. Please try again.")
        |> redirect(to: ~p"/create")
    end
  end

  defp error_message_from_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end)
    |> Enum.join("; ")
  end
end
