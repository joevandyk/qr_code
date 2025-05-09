defmodule QrCodeWeb.NavigationTest do
  use QrCodeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "navigation between pages" do
    test "can navigate from home to about and back", %{conn: conn} do
      {:ok, home_view, _html} = live(conn, ~p"/")

      # Navigate to About page (using more specific selector to target the desktop nav)
      {:ok, about_view, _html} =
        home_view
        |> element(~s{.hidden.md\\:flex a[href="/about"]})
        |> render_click()
        |> follow_redirect(conn)

      assert has_element?(about_view, "h1", "Why I Created QR Lock Screen")

      # Navigate back to Home
      {:ok, home_view, _html} =
        about_view
        |> element(~s{.hidden.md\\:flex a[href="/"]})
        |> render_click()
        |> follow_redirect(conn)

      assert has_element?(home_view, ".text-indigo-600", "awkward")
    end

    test "can navigate from home to create page", %{conn: conn} do
      {:ok, home_view, _html} = live(conn, ~p"/")

      # Click on the Start button which will redirect to a regular controller
      # then to the create page
      assert {:error, {:live_redirect, %{to: "/start", kind: :push}}} =
        home_view
        |> element(~s{div.mt-10 a[href="/start"]})
        |> render_click()

      # Follow the redirects through the controller to the create page
      conn = get(conn, "/start")
      assert redirected_to(conn) == "/create"

      # Now visit the create page with the session from the previous request
      {:ok, create_view, _html} = live(recycle(conn), "/create")

      # Verify we're on the create page
      assert has_element?(create_view, "h1", "Add your link")
    end

    test "mobile menu markup is present", %{conn: conn} do
      {:ok, home_view, _html} = live(conn, ~p"/")

      # Verify the mobile menu markup exists
      assert has_element?(home_view, "#mobile-menu")
      assert has_element?(home_view, "button.md\\:hidden")

      # Verify the mobile menu is hidden by default
      assert has_element?(home_view, "#mobile-menu.hidden")
    end
  end
end
