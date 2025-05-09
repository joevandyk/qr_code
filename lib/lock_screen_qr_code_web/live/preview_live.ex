defmodule LockScreenQRCodeWeb.PreviewLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  import LockScreenQRCodeWeb.Components.PhonePreview

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
    <!-- Main Content -->
      <div class="w-full max-w-5xl bg-white/90 backdrop-blur-sm rounded-2xl shadow-2xl p-8 relative z-10">

        <h1 class="text-4xl font-bold text-center text-gray-800 mb-2">Preview Your QR Code</h1>
        <p class="text-center text-gray-600 mb-8">This is how your QR code will look on your lock screen.</p>

        <div class="flex flex-col lg:flex-row gap-8 items-center justify-center">
          <!-- Phone Preview -->
          <div class="flex-shrink-0">
            <!-- Use the shared PhonePreview component -->
            <.phone_preview
              qr_request={@qr_request}
              class="w-[300px]"
              show_watermark={true}
            />
          </div>

          <!-- Preview Info -->
          <div class="flex-grow max-w-lg">
            <div class="bg-gray-50 rounded-xl p-6 shadow-sm">
              <h2 class="text-2xl font-bold text-gray-800 mb-4">Your QR Code is Ready!</h2>

              <div class="mb-6 text-gray-600">
                <p class="mb-3">This QR code will direct anyone who scans it to
                <a class="font-medium text-gray-800" href={@qr_request.url} target="_blank"><%= @qr_request.url %></a>
                </p>
                <p>The code has been styled using the <span class="font-medium"><%= String.capitalize(String.replace(@qr_request.template, "_", " ")) %></span> template.</p>
              </div>

              <div class="bg-yellow-50 p-4 rounded-lg border border-yellow-200 mb-4">
                <div class="flex items-start">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-yellow-500 mt-0.5 mr-2 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <p class="text-sm text-yellow-800">
                    This is a preview only. On the next page, you'll be able to download the full quality image for your lock screen.
                  </p>
                </div>
              </div>

              <div class="text-gray-600">
                <h3 class="font-bold text-gray-700 mb-2">What's next?</h3>
                <ol class="list-decimal pl-5 space-y-1">
                  <li>Continue to download the QR code image</li>
                  <li>Set it as your phone's lock screen</li>
                  <li>Show it to anyone who wants to connect with you</li>
                </ol>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-10 flex flex-col sm:flex-row justify-between gap-4 sm:gap-3">
          <.link
            navigate={~p"/design"}
            replace={true}
            class="w-full sm:w-auto bg-white text-indigo-600 border border-indigo-200 hover:bg-indigo-50 font-medium rounded-full py-3 px-6 shadow-sm flex justify-center items-center gap-2 order-2 sm:order-1"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back
          </.link>
          <.link
            navigate={~p"/download"}
            class="w-full sm:w-auto bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-full py-3 px-6 shadow-md flex justify-center items-center gap-2 order-1 sm:order-2"
          >
            Continue
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
            </svg>
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
