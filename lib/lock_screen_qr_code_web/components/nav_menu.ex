defmodule LockScreenQRCodeWeb.Components.NavMenu do
  use Phoenix.Component

  # Import link component and path helpers
  import Phoenix.Component

  def render(assigns) do
    ~H"""
    <nav class="absolute top-0 left-0 right-0 z-30 py-4 px-6 flex justify-between items-center">
      <a href="/mockup/step1" class="text-indigo-600 hover:text-indigo-800 font-semibold">
        QR Lock Screen
      </a>
      <div class="flex space-x-6">
        <a href="/mockup/step1" class="text-gray-600 hover:text-indigo-600 transition">
          Home
        </a>
        <a href="/mockup/about" class="text-gray-600 hover:text-indigo-600 transition">
          About
        </a>
      </div>
    </nav>
    """
  end
end
