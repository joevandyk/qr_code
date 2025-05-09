defmodule QrCodeWeb.DesignLiveTest do
  use QrCodeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias QrCode.Requests

  describe "DesignLive" do
    # This test is no longer valid as DesignLive now creates a QR request
    # instead of redirecting
    # test "redirects to create page when no QR request is in session", %{conn: conn} do
    #   {:error, {:live_redirect, %{to: to}}} = live(conn, "/design")
    #   assert to == "/create"
    # end

    test "loads QR request data from session", %{conn: conn} do
      # Create a QR request
      {:ok, qr_request} =
        Requests.create_qr_request(%{
          url: "https://example.com",
          name: "Test Site"
        })

      # Set up test conn with session data
      {:ok, view, _html} =
        conn
        |> init_test_session(%{"qr_request_token" => qr_request.token})
        |> live("/design")

      # Verify the data is loaded
      assert view.module == QrCodeWeb.DesignLive
      assert has_element?(view, "#qr-url", "https://example.com")
      assert has_element?(view, "#qr-name", "Test Site")
    end

    # This test is replaced by "redirects to /start when no session data exists"
    # since we no longer create QR requests automatically in the hook
    # test "creates a new QR request when none exists in session", %{conn: conn} do
    #   # Now the DesignLive should create a QR request automatically
    #   {:ok, view, _html} = live(conn, "/design")
    #
    #   # Verify we're on the design page (not redirected)
    #   assert view.module == QrCodeWeb.DesignLive
    #
    #   # Verify the default URL is shown
    #   assert has_element?(view, "#qr-url", "https://example.com")
    # end

    test "redirects to /start when no session data exists", %{conn: conn} do
      # Try accessing design page with no session
      {:error, {:redirect, %{to: to}}} = live(conn, "/design")

      # Should redirect to /start
      assert to == "/start"
    end
  end
end
