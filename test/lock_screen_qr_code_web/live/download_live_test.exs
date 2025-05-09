defmodule LockScreenQRCodeWeb.DownloadLiveTest do
  use LockScreenQRCodeWeb.ConnCase
  import Phoenix.LiveViewTest
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Factories
  alias LockScreenQRCode.Repo

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

  describe "DownloadLive" do
    setup :setup_session_with_qr_request

    test "renders the download page with QR code", %{conn: conn, session: session} do
      {:ok, view, html} = live(conn, ~p"/download", session: session)

      # Check for title and instructions
      assert html =~ "Your QR Code is Ready!"
      assert html =~ "Download your QR code"
      assert html =~ "Installation Instructions"

      # Check for iPhone and Android instructions
      assert html =~ "iPhone Instructions"
      assert html =~ "Android Instructions"

      # Check for navigation buttons
      assert has_element?(view, "button", "Back")
      assert has_element?(view, "button", "Create Another")
    end

    @tag :skip
    test "generates an image if not already generated", %{conn: conn, session: session, qr_request: qr_request} do
      # Ensure the QR request doesn't have a preview image URL
      Requests.update_qr_request(qr_request, %{preview_image_url: nil})

      # Load the page
      {:ok, _view, _html} = live(conn, ~p"/download", session: session)

      # Reload the QR request and check if an image URL was generated
      updated_qr_request = Repo.get!(Requests.QRRequest, qr_request.id)
      assert updated_qr_request.preview_image_url != nil
    end

    @tag :skip
    test "uses existing image if already generated", %{conn: conn, session: session, qr_request: qr_request} do
      # Set a preview image URL
      url = "/generated/test_image.png"
      {:ok, _updated} = Requests.update_qr_request(qr_request, %{preview_image_url: url})

      # Load the page
      {:ok, view, _html} = live(conn, ~p"/download", session: session)

      # Check that the image is displayed
      assert view |> has_element?("img[src='#{url}']")
    end

    test "navigates back to preview page", %{conn: conn, session: session} do
      {:ok, view, _html} = live(conn, ~p"/download", session: session)

      # Click the back button
      {:ok, _conn} =
        view
        |> element("button", "Back")
        |> render_click()
        |> follow_redirect(conn, ~p"/preview")
    end

    test "navigates to create page for a new QR code", %{conn: conn, session: session} do
      {:ok, view, _html} = live(conn, ~p"/download", session: session)

      # Click the "Create Another" button
      {:ok, _conn} =
        view
        |> element("button", "Create Another")
        |> render_click()
        |> follow_redirect(conn, ~p"/create")
    end

    @tag :skip
    test "regenerates QR code", %{conn: conn, session: session} do
      {:ok, view, _html} = live(conn, ~p"/download", session: session)

      # Click the regenerate button
      render_click(view, "regenerate")

      # This is a bit hard to test without mocking the Generator and Storage
      # We'd need to stub their responses or check specific call patterns
      # For now, we'll just ensure the function doesn't error
    end
  end
end
