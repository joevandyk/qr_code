defmodule QrCodeWeb.CreateLiveTest do
  use QrCodeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "CreateLive" do
    test "renders form with URL and name fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/create")

      assert has_element?(view, "form[phx-submit=save]")
      assert has_element?(view, "input[name=url]")
      assert has_element?(view, "input[name=name]")
      assert has_element?(view, "button[type=submit]", "Continue →")
      assert has_element?(view, "a", "← Back")
    end

    test "validates URL format during input", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/create")

      # Test invalid URL
      view
      |> element("form")
      |> render_change(%{url: "invalid-url", name: "Test"})

      # Check for error message
      assert has_element?(view, "p#url-error", "URL must start with http:// or https://")

      # Test valid URL format
      view
      |> element("form")
      |> render_change(%{url: "https://example.com", name: "Test"})

      # No error message should be present
      refute has_element?(view, "p#url-error")
    end

    test "redirects to design page with parameters on valid submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/create")

      # Submit a valid URL
      {:error, {:live_redirect, %{to: to}}} =
        view
        |> element("form")
        |> render_submit(%{url: "https://example.com", name: "Test Site"})

      # Should redirect to design page with URL and name parameters
      assert to =~ "/design?"
      assert to =~ "url=https%3A%2F%2Fexample.com"
      assert to =~ "name=Test+Site"
    end

    test "shows error and stays on page with invalid submission", %{conn: conn} do
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
