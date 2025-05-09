defmodule LockScreenQRCodeWeb.HomeLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger

  alias LockScreenQRCodeWeb.UrlValidator

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :home_live, :mount], %{status: :start})
    Logger.info("HomeLive mounted")
    {:ok, socket}
  end

  @impl true
  def handle_event("next", %{"url" => url}, socket) do
    Logger.info("Validating URL: #{url}")

    case UrlValidator.validate(url) do
      {:ok, _uri} ->
        # URL is valid, clear any previous error and proceed (QR generation comes later)
        Logger.info("URL valid: #{url}")
        assigns = %{url: url, url_error: nil}
        # Trigger QR code generation (Story 3)
        # socket = trigger_qr_generation(socket, url)
        {:noreply, assign(socket, assigns)}

      {:error, reason} ->
        # URL is invalid, set error message
        Logger.warning("URL invalid", url: url, reason: reason)
        # Emit telemetry event for failed validation
        :telemetry.execute([:lock_screen_qr_code, :url_validation, :failed], %{error_count: 1}, %{
          url: url,
          reason: reason
        })

        error_message = error_reason_to_message(reason)
        {:noreply, assign(socket, url: url, url_error: error_message)}
    end
  end

  # Helper function to map error reasons to Gettext messages
  defp error_reason_to_message(:invalid_scheme),
    do: gettext("URL must start with http:// or https://")

  defp error_reason_to_message(:invalid_format), do: gettext("Please enter a valid URL.")
  defp error_reason_to_message(:invalid_input), do: gettext("Invalid input provided.")
end
