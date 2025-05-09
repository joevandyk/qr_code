defmodule QrCodeWeb.MockupValidationTest do
  k
  use ExUnit.Case, async: false
  use Wallaby.Feature

  alias QrCodeWeb.Endpoint
  alias HTTPoison

  @base_url "http://localhost:#{Endpoint.config(:port, 4002)}"
  @screenshot_prefix "mockup_"
  @analysis_server "http://localhost:3031"

  setup do
    # Ensure screenshot directory exists
    screenshot_dir = "tmp/wallaby/screenshots"
    File.mkdir_p!(screenshot_dir)
    :ok
  end

  feature "Validate mockup Step 1", %{session: session} do
    # Take a screenshot
    session
    |> visit(@base_url <> "/mockup/step1")
    |> take_screenshot(name: @screenshot_prefix <> "step1")

    # Analyze the screenshot
    screenshot_path = "tmp/wallaby/screenshots/#{@screenshot_prefix}step1.png"

    assert validate_screenshot(screenshot_path, %{
             "header" => true,
             "three_steps" => true,
             "example_gallery" => true,
             "cta_button" => true
           })
  end

  feature "Validate mockup Step 2", %{session: session} do
    # Take a screenshot
    session
    |> visit(@base_url <> "/mockup/step2")
    |> take_screenshot(name: @screenshot_prefix <> "step2")

    # Analyze the screenshot
    screenshot_path = "tmp/wallaby/screenshots/#{@screenshot_prefix}step2.png"

    assert validate_screenshot(screenshot_path, %{
             "template_selection" => true
           })
  end

  feature "Validate mockup Step 3", %{session: session} do
    # Take a screenshot
    session
    |> visit(@base_url <> "/mockup/step3")
    |> take_screenshot(name: @screenshot_prefix <> "step3")

    # Analyze the screenshot
    screenshot_path = "tmp/wallaby/screenshots/#{@screenshot_prefix}step3.png"

    assert validate_screenshot(screenshot_path, %{
             "preview" => true,
             "checkout_button" => true
           })
  end

  # Helper function to analyze a screenshot
  defp validate_screenshot(screenshot_path, expected_elements) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get("#{@analysis_server}/analyze?path=#{screenshot_path}"),
         {:ok, analysis} <- Jason.decode(body) do
      # Check if all expected elements are present
      Enum.all?(expected_elements, fn {element, expected} ->
        case analysis["hasElement"][element] do
          ^expected ->
            true

          _ ->
            IO.puts("Element '#{element}' validation failed. Expected: #{expected}")
            false
        end
      end)
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("Analysis server returned status code: #{status_code}")
        false

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error connecting to analysis server: #{reason}")
        false

      {:error, reason} ->
        IO.puts("Error parsing analysis result: #{reason}")
        false
    end
  end
end
