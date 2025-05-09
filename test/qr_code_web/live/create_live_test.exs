defmodule QrCodeWeb.CreateLiveTest do
  use QrCodeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "CreateLive" do
    test "redirects to /start when no QR request ID is in session", %{conn: conn} do
      # Try to visit /create directly with no session
      {:error, {:redirect, %{to: to}}} = live(conn, "/create")

      # Should redirect to /start
      assert to == "/start"
    end

    test "renders form with URL and name fields when session exists", %{conn: conn} do
      # Create a test session with a QR request token
      {:ok, qr_request} = QrCode.Requests.create_qr_request(%{url: "https://example.com", name: ""})

      conn =
        conn
        |> init_test_session(%{"qr_request_token" => qr_request.token})

      {:ok, view, _html} = live(conn, "/create")

      assert has_element?(view, "form[phx-submit=save]")
      assert has_element?(view, "input[name=url]")
      assert has_element?(view, "input[name=name]")
      assert has_element?(view, "button[type=submit]", "Continue →")
      assert has_element?(view, "a", "← Back")
    end

    test "validates URL format during input", %{conn: conn} do
      # Create a QR request and add it to the session
      {:ok, qr_request} = QrCode.Requests.create_qr_request(%{url: "https://example.com", name: ""})
      conn = init_test_session(conn, %{"qr_request_token" => qr_request.token})

      {:ok, view, _html} = live(conn, "/create")

      # Test invalid URL
      view
      |> element("form")
      |> render_change(%{url: "invalid-url", name: "Test"})

      # Check for error message - should show an error about the URL scheme
      assert has_element?(view, "p#url-error", ~r/missing a scheme/)

      # Test valid URL format
      view
      |> element("form")
      |> render_change(%{url: "https://example.com", name: "Test"})

      # No error message should be present
      refute has_element?(view, "p#url-error")
    end

    test "redirects to design page and stores session on valid submission", %{conn: conn} do
      # Create a QR request and add it to the session
      {:ok, qr_request} = QrCode.Requests.create_qr_request(%{url: "https://example.com", name: ""})
      conn = init_test_session(conn, %{"qr_request_token" => qr_request.token})

      {:ok, view, _html} = live(conn, "/create")

      # Submit a valid URL
      {:error, {:live_redirect, %{to: to}}} =
        view
        |> element("form")
        |> render_submit(%{url: "https://example.com", name: "Test Site"})

      # Should redirect to design page with no parameters
      assert to == "/design"
    end

    test "shows error and stays on page with invalid submission", %{conn: conn} do
      # Create a QR request and add it to the session
      {:ok, qr_request} = QrCode.Requests.create_qr_request(%{url: "https://example.com", name: ""})
      conn = init_test_session(conn, %{"qr_request_token" => qr_request.token})

      {:ok, view, _html} = live(conn, "/create")

      # Submit invalid URL
      view
      |> element("form")
      |> render_submit(%{url: "invalid", name: "Test"})

      # Should still be on the create page
      assert view.module == QrCodeWeb.CreateLive
      # Should show error message
      assert has_element?(view, "p#url-error")
    end
  end
end
