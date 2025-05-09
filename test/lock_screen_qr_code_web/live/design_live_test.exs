defmodule LockScreenQRCodeWeb.DesignLiveTest do
  use LockScreenQRCodeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias LockScreenQRCode.Requests

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
      assert view.module == LockScreenQRCodeWeb.DesignLive
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
    #   assert view.module == LockScreenQRCodeWeb.DesignLive
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

    test "displays template options", %{conn: conn} do
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

      # Verify template options are displayed
      assert has_element?(view, "button", "Pop Vibes")
      assert has_element?(view, "button", "Ocean Blue")
      assert has_element?(view, "button", "Sunny Side")
      assert has_element?(view, "button", "Monochrome")
    end

    test "selects and saves template choice", %{conn: conn} do
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

      # Click on the Ocean Blue template
      view |> element("button", "Ocean Blue") |> render_click()

      # Verify the template was selected (highlighted)
      html = render(view)
      assert html =~ "Ocean Blue"

      # Check the database was updated
      updated_qr_request = Requests.get_qr_request(qr_request.id)
      assert updated_qr_request.template == "ocean_blue"
    end

    test "navigation buttons work correctly", %{conn: conn} do
      # Create a QR request
      {:ok, qr_request} =
        Requests.create_qr_request(%{
          url: "https://example.com"
        })

      # Set up test conn with session data
      {:ok, view, _html} =
        conn
        |> init_test_session(%{"qr_request_token" => qr_request.token})
        |> live("/design")

      # Test back button
      assert {:error, {:live_redirect, %{to: "/create"}}} =
               view
               |> element("button", "Back")
               |> render_click()

      # Set up view again for continue button test
      {:ok, view, _html} =
        conn
        |> init_test_session(%{"qr_request_token" => qr_request.token})
        |> live("/design")

      # Test continue button
      assert {:error, {:live_redirect, %{to: "/preview"}}} =
               view
               |> element("button", "Continue")
               |> render_click()
    end
  end
end
