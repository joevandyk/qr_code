defmodule QrCodeWeb.CreateLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :create_live, :mount], %{status: :start})
    Logger.info("CreateLive mounted")

    {:ok,
     socket
     |> assign(:url, "")
     |> assign(:name, "")
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("validate", %{"url" => url, "name" => name}, socket) do
    # Basic validation during typing (live feedback)
    error = validate_url(url)

    {:noreply,
     socket
     |> assign(:url, url)
     |> assign(:name, name)
     |> assign(:error, error)}
  end

  @impl true
  def handle_event("save", %{"url" => url, "name" => name}, socket) do
    # Final validation before submission
    case validate_url(url) do
      nil ->
        Logger.info("Valid URL submitted: #{url}, name: #{name}")
        # Pass parameters directly via navigation
        {:noreply,
         socket
         |> push_navigate(to: ~p"/design?#{%{url: url, name: name}}")}

      error ->
        Logger.warning("Invalid URL submitted: #{url}, error: #{error}")
        {:noreply,
         socket
         |> assign(:error, error)}
    end
  end

  # URL validation function
  defp validate_url(""), do: nil
  defp validate_url(url) do
    cond do
      not String.starts_with?(url, ["http://", "https://"]) ->
        "URL must start with http:// or https://"

      String.length(url) < 10 ->
        "URL is too short"

      not valid_url_format?(url) ->
        "Please enter a valid URL"

      true -> nil
    end
  end

  defp valid_url_format?(url) do
    uri = URI.parse(url)
    uri.scheme != nil && uri.host =~ "."
  end
end
