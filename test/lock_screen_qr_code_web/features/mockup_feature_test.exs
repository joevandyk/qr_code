defmodule LockScreenQRCodeWeb.MockupFeatureTest do
  use ExUnit.Case, async: false
  use Wallaby.Feature

  # Add feature tag to exclude by default
  @moduletag :feature

  alias LockScreenQRCodeWeb.Endpoint

  @base_url "http://localhost:#{Endpoint.config(:port, 4002)}"
  @screenshot_prefix "mockup_"

  feature "Take screenshot of Step 1", %{session: session} do
    session
    |> visit(@base_url <> "/mockup/step1")
    |> take_screenshot(name: @screenshot_prefix <> "step1")
  end

  feature "Take screenshot of Step 2", %{session: session} do
    session
    |> visit(@base_url <> "/mockup/step2")
    |> take_screenshot(name: @screenshot_prefix <> "step2")
  end

  feature "Take screenshot of Step 3", %{session: session} do
    session
    |> visit(@base_url <> "/mockup/step3")
    |> take_screenshot(name: @screenshot_prefix <> "step3")
  end

  feature "Take screenshot of Step 4", %{session: session} do
    session
    |> visit(@base_url <> "/mockup/step4")
    |> take_screenshot(name: @screenshot_prefix <> "step4")
  end

  feature "Take screenshot of Step 5", %{session: session} do
    session
    |> visit(@base_url <> "/mockup/step5")
    |> take_screenshot(name: @screenshot_prefix <> "step5")
  end
end
