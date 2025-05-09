defmodule LockScreenQRCodeWeb.HomeLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger

  alias LockScreenQRCodeWeb.UrlValidator
  import LockScreenQRCodeWeb.Components.PhonePreview

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :home_live, :mount], %{status: :start})
    Logger.info("HomeLive mounted")

    # Demo URL for the home page preview
    socket = assign(socket, demo_url: "https://example.com/demo")

    {:ok, socket}
  end

  @impl true
  def handle_event("next", %{"url" => url}, socket) do
    Logger.info("Validating URL: #{url}")

    case UrlValidator.validate(url) do
      {:ok, _uri} ->
        # URL is valid, clear any previous error and proceed (QR generation comes later)
        Logger.info("URL valid: #{url}")
        assigns = %{url: url, url_error: nil}
        # Trigger QR code generation (Story 3)
        # socket = trigger_qr_generation(socket, url)
        {:noreply, assign(socket, assigns)}

      {:error, reason} ->
        # URL is invalid, set error message
        Logger.warning("URL invalid", url: url, reason: reason)
        # Emit telemetry event for failed validation
        :telemetry.execute([:lock_screen_qr_code, :url_validation, :failed], %{error_count: 1}, %{
          url: url,
          reason: reason
        })

        error_message = error_reason_to_message(reason)
        {:noreply, assign(socket, url: url, url_error: error_message)}
    end
  end

  # Helper function to map error reasons to Gettext messages
  defp error_reason_to_message(:invalid_scheme),
    do: gettext("URL must start with http:// or https://")

  defp error_reason_to_message(:invalid_format), do: gettext("Please enter a valid URL.")
  defp error_reason_to_message(:invalid_input), do: gettext("Invalid input provided.")

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 py-12 px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center relative overflow-hidden">
      <!-- Decorative background elements -->
      <div class="absolute top-0 left-0 w-64 h-64 bg-yellow-400 rounded-full opacity-70 blur-3xl -translate-x-1/2 -translate-y-1/2">
      </div>
      <div class="absolute bottom-0 right-0 w-96 h-96 bg-teal-400 rounded-full opacity-70 blur-3xl translate-x-1/4 translate-y-1/4">
      </div>
      <div class="absolute top-1/2 right-0 w-80 h-80 bg-purple-400 rounded-full opacity-60 blur-3xl translate-x-1/3">
      </div>
      <div class="absolute bottom-0 left-1/4 w-72 h-72 bg-coral-400 rounded-full opacity-60 blur-3xl">
      </div>

    <!-- Main Content -->
      <div class="max-w-5xl mx-auto z-10 relative">
        <!-- Mobile-friendly Navigation -->
        <nav class="absolute top-0 left-0 right-0 z-30 py-6 px-6">
          <div class="flex justify-end items-center">
            <!-- Desktop Navigation -->
            <div class="hidden md:flex space-x-6">
              <.link navigate="/" class="text-indigo-600 border-b-2 border-indigo-600 font-medium">
                Home
              </.link>
              <.link navigate="/about" class="text-gray-600 hover:text-indigo-600 transition">
                About
              </.link>
            </div>

    <!-- Mobile Hamburger Button -->
            <button
              phx-click={JS.toggle(to: "#mobile-menu")}
              class="md:hidden flex items-center justify-center p-2 h-10 w-10 rounded-md bg-white/80 backdrop-blur-sm shadow-sm"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-6 w-6 text-indigo-600"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>

    <!-- Mobile Menu (Hidden by default) -->
          <div
            id="mobile-menu"
            class="hidden md:hidden mt-4 mr-0 ml-auto w-48 bg-white/95 backdrop-blur-sm py-2 rounded-lg shadow-lg"
          >
            <.link
              navigate="/"
              class="block px-4 py-3 text-indigo-600 font-medium border-l-4 border-indigo-600"
            >
              Home
            </.link>
            <.link
              navigate="/about"
              class="block px-4 py-3 text-gray-600 hover:text-indigo-600 hover:bg-indigo-50"
            >
              About
            </.link>
          </div>
        </nav>

    <!-- Header space -->
        <div class="mb-16"></div>

    <!-- Hero Section -->
        <div class="flex flex-col-reverse md:flex-row items-center gap-12">
          <!-- Text Content -->
          <div class="md:w-1/2">
            <h1 class="text-5xl font-bold text-gray-800 leading-tight">
              Don't make <br /> sharing <span class="text-indigo-600">awkward</span>
            </h1>
            <p class="mt-6 text-xl text-gray-600">
              No need to unlock your phone or search for links. Your QR code appears right on your lock screen, so you can simply show your phone and keep the conversation flowing. One quick scan connects people to your website, social profiles, or contact info.
            </p>
            <div class="mt-10">
              <.link
                navigate={~p"/start"}
                class="w-full sm:w-auto bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-full py-3 px-8 shadow-md flex justify-center"
              >
                Create my QR code - only $5
              </.link>
            </div>
          </div>

    <!-- Phone Preview -->
          <div class="md:w-1/2 relative">
            <div class="relative mx-auto transform rotate-6 z-10">
              <div class="relative w-64 md:w-72 mx-auto">
                <.phone_preview
                  url={@demo_url}
                  display_text="Scan to connect with me"
                  template="pop_vibes"
                  class="w-full"
                />
              </div>
            </div>
            <div class="absolute top-8 -right-8 w-64 h-64 bg-indigo-400 rounded-full opacity-30 blur-2xl">
            </div>
            <div class="absolute -bottom-8 -left-8 w-64 h-64 bg-pink-400 rounded-full opacity-30 blur-2xl">
            </div>
          </div>
        </div>

    <!-- Feature section -->
        <div class="mt-24 text-center">
          <h2 class="text-3xl font-bold text-gray-800">How it works</h2>
          <p class="mt-4 text-xl text-gray-600 max-w-2xl mx-auto">
            Share your links without interrupting the conversation
          </p>

          <div class="mt-12 grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Feature 1 -->
            <div class="bg-white/90 backdrop-blur-sm p-6 rounded-xl shadow-lg">
              <div class="w-12 h-12 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                1
              </div>
              <h3 class="text-xl font-bold text-gray-800 mb-2">Enter your URL</h3>
              <p class="text-gray-600">Add any link you want others to access with a simple scan</p>
            </div>

    <!-- Feature 2 -->
            <div class="bg-white/90 backdrop-blur-sm p-6 rounded-xl shadow-lg">
              <div class="w-12 h-12 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                2
              </div>
              <h3 class="text-xl font-bold text-gray-800 mb-2">Choose your style</h3>
              <p class="text-gray-600">Select a design that matches your personal style</p>
            </div>

    <!-- Feature 3 -->
            <div class="bg-white/90 backdrop-blur-sm p-6 rounded-xl shadow-lg">
              <div class="w-12 h-12 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                3
              </div>
              <h3 class="text-xl font-bold text-gray-800 mb-2">Set as wallpaper</h3>
              <p class="text-gray-600">
                Your QR code is always available - no need to unlock your phone
              </p>
            </div>
          </div>

          <div class="mt-12">
            <.link
              navigate={~p"/start"}
              class="w-full sm:w-auto bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-full py-3 px-8 shadow-md flex justify-center"
            >
              Get your QR code - $5 &rarr;
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
