defmodule QrCodeWeb.MobileMockupTest do
  use ExUnit.Case, async: false
  use Wallaby.Feature

  import Wallaby.Browser
  import Wallaby.Query, only: [css: 1]

  @moduletag :feature

  alias QrCodeWeb.Endpoint

  @base_url "http://localhost:#{Endpoint.config(:port, 4002)}"
  @screenshot_prefix "mobile_mockup_"

  # iPhone SE viewport size
  @iphone_se_width 375
  @iphone_se_height 667

  setup do
    # Ensure screenshot directory exists
    screenshot_dir = "tmp/wallaby/mobile_screenshots"
    File.mkdir_p!(screenshot_dir)
    :ok
  end

  feature "Take iPhone SE screenshots of all pages", %{session: session} do
    # For each page with descriptive paths
    pages = [
      {"home", "/mockup/home"},
      {"create", "/mockup/create"},
      {"design", "/mockup/design"},
      {"preview", "/mockup/preview"},
      {"checkout", "/mockup/checkout"},
      {"download", "/mockup/download"},
      {"about", "/mockup/about"}
    ]

    for {name, path} <- pages do
      session
      |> visit(@base_url <> path)
      |> resize_window(@iphone_se_width, @iphone_se_height)
      # Take a regular screenshot with the true viewport size
      |> take_screenshot(name: "#{@screenshot_prefix}#{name}")

      # Log the screenshot capture for debugging
      IO.puts("Captured iPhone SE screenshot for: #{name}")
    end

    # Take an additional screenshot with the mobile menu open
    session
    |> visit(@base_url <> "/mockup/home")
    |> resize_window(@iphone_se_width, @iphone_se_height)
    |> click(css("#mobile-menu-button"))
    |> take_screenshot(name: "#{@screenshot_prefix}home_with_menu_open")

    IO.puts("Captured iPhone SE screenshot with mobile menu open")
  end
end
