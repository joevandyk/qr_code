defmodule LockScreenQRCodeWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use LockScreenQRCodeWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-blue-50 to-purple-50">
      <!-- Decorative background elements -->
      <div class="fixed top-0 left-0 w-64 h-64 bg-yellow-400 rounded-full opacity-70 blur-3xl -translate-x-1/2 -translate-y-1/2" />
      <div class="fixed bottom-0 right-0 w-96 h-96 bg-teal-400 rounded-full opacity-70 blur-3xl translate-x-1/4 translate-y-1/4" />
      <div class="fixed top-1/2 right-0 w-80 h-80 bg-purple-400 rounded-full opacity-60 blur-3xl translate-x-1/3" />
      <div class="fixed bottom-0 left-1/4 w-72 h-72 bg-coral-400 rounded-full opacity-60 blur-3xl" />

      <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        {render_slot(@inner_block)}
      </div>

      <.flash_group flash={@flash} />
    </div>
    """
  end
end
