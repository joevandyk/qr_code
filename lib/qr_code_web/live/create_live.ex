defmodule QrCodeWeb.CreateLive do
  use QrCodeWeb, :live_view
  require Logger
  alias QrCode.Requests
  alias QrCode.QrRequest
  alias QrCode.Repo

  @sample_sites [
    "https://github.com",
    "https://elixir-lang.org",
    "https://hexdocs.pm",
    "https://phoenixframework.org",
    "https://developer.mozilla.org",
    "https://tailwindcss.com",
    "https://fly.io",
    "https://example.com"
  ]

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:qr_code, :create_live, :mount], %{status: :start})
    Logger.info("CreateLive mounted")

    # Check if there's already a QR request loaded by the hook
    socket =
      if socket.assigns[:qr_request] do
        Logger.info("Using existing QR request with URL: #{socket.assigns.qr_request.url}")
        socket
      else
        # The hook should have loaded the QR request from the session token
        # If we get here, something went wrong with the hook or session
        Logger.warning("No QR request found via hook - should not happen")
        random_url = Enum.random(@sample_sites)
        # We intentionally don't generate a token here - that's the controller's job
        assign(socket, :qr_request, %QrRequest{
          url: random_url,
          name: ""
        })
      end

    # Create a changeset and convert to form
    changeset = QrRequest.changeset(socket.assigns.qr_request, %{})

    {:ok, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"qr_request" => params}, socket) do
    # Create a changeset for validation
    changeset =
      socket.assigns.qr_request
      |> QrRequest.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"qr_request" => params}, socket) do
    # Create or update QR request
    case create_or_update_qr_request(socket, params) do
      {:ok, qr_request} ->
        # Store the QR request in assigns and navigate to design page
        {:noreply,
         socket
         |> clear_flash()
         |> assign(:qr_request, qr_request)
         |> push_navigate(to: ~p"/design")}

      {:error, changeset} ->
        error_message = get_error_message(changeset)
        Logger.error("QR request error: #{error_message}")

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end

  # Create a new QR request or update existing one
  defp create_or_update_qr_request(socket, params) do
    # Print the current qr_request for debugging
    IO.inspect(socket.assigns.qr_request, label: "CURRENT QR REQUEST")
    IO.puts("NEW PARAMS: #{inspect(params)}")

    case socket.assigns.qr_request do
      %QrRequest{id: id} = qr_request when is_integer(id) ->
        # Log the current URL in the DB for comparison
        IO.puts("Current URL in database: #{qr_request.url}")
        IO.puts("URL from form submission: #{params["url"]}")

        # Use the standard update approach
        IO.inspect(params, label: "UPDATE PARAMS")
        Requests.update_qr_request(qr_request, params)

      _ ->
        # Create new request with token
        Requests.create_qr_request(params)
    end
  end

  # Extract a user-friendly error message from a changeset
  defp get_error_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end)
    |> Enum.join("; ")
  end
end
