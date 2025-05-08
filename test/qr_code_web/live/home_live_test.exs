defmodule QrCodeWeb.HomeLiveTest do
  use QrCodeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "HomeLive" do
    test "renders a form and pushes 'next' event on submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "form[phx-submit=next]")
      assert has_element?(view, "input[name=url]")

      view
      |> element("form")
      |> render_submit(%{url: "https://example.com"})

      assert render(view) =~ "https://example.com"
    end

    test "mounts with default assigns", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view.module == QrCodeWeb.HomeLive
      assert has_element?(view, "input[name=url][value='']")
      refute has_element?(view, "img[alt='Generated QR Code']")

      # Check that the error message area is empty/not showing an error
      # We assert the exact outerHTML of the empty container div, including classes
      assert view |> element("#url_error_message") |> render() == "<div id=\"url_error_message\" role=\"alert\" aria-live=\"polite\" class=\"mt-2 text-sm text-red-600\"></div>"
    end
  end
end
