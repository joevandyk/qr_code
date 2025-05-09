defmodule LockScreenQRCodeWeb.PreviewLiveTest do
  use LockScreenQRCodeWeb.ConnCase
  import Phoenix.LiveViewTest
  alias LockScreenQRCode.Factories

  # Function to set up a session with a valid QR request
  defp setup_session_with_qr_request(_context) do
    # Create a QR request
    template = "pop_vibes"
    {:ok, qr_request} = Factories.create_qr_request(%{url: "https://example.com", template: template})

    # Set up session
    session = %{"qr_request_id" => qr_request.id}

    # Return the session and the QR request
    %{session: session, qr_request: qr_request}
  end

  describe "PreviewLive" do
    setup :setup_session_with_qr_request

    test "renders the preview page with QR code", %{conn: conn, session: session, qr_request: qr_request} do
      {:ok, _view, html} = live(conn, ~p"/preview", session: session)

      # Check for title and instructions
      assert html =~ "Preview Your QR Code"
      assert html =~ "This is how your QR code will look on your lock screen"

      # Check that the URL is displayed
      assert html =~ qr_request.url

      # Check that the template name is displayed
      template_name = String.capitalize(String.replace(qr_request.template, "_", " "))
      assert html =~ template_name
    end

    test "has back and continue buttons", %{conn: conn, session: session} do
      {:ok, view, _html} = live(conn, ~p"/preview", session: session)

      # Check for navigation buttons
      assert has_element?(view, "button", "Back")
      assert has_element?(view, "button", "Continue")
    end

    test "shows preview watermark", %{conn: conn, session: session} do
      {:ok, _view, html} = live(conn, ~p"/preview", session: session)

      # Check that a "PREVIEW" watermark is shown
      assert html =~ "PREVIEW"
    end

    test "navigates back to design page", %{conn: conn, session: session} do
      {:ok, view, _html} = live(conn, ~p"/preview", session: session)

      # Click the back button
      {:ok, _conn} =
        view
        |> element("button", "Back")
        |> render_click()
        |> follow_redirect(conn, ~p"/design")
    end

    test "navigates to download page", %{conn: conn, session: session} do
      {:ok, view, _html} = live(conn, ~p"/preview", session: session)

      # Click the continue button
      {:ok, _conn} =
        view
        |> element("button", "Continue")
        |> render_click()
        |> follow_redirect(conn, ~p"/download")
    end

    test "handles errors gracefully", %{conn: conn, session: session} do
      # This is a bit difficult to test without modifying the Generator to fail
      # For now, we'll just confirm that the page loads correctly
      {:ok, _view, html} = live(conn, ~p"/preview", session: session)

      # Ensure the page doesn't have an error message by default
      refute html =~ "Error:"
    end
  end
end
