defmodule LockScreenQRCodeWeb.DesignLive do
  use LockScreenQRCodeWeb, :live_view
  require Logger
  alias LockScreenQRCode.Requests
  alias LockScreenQRCode.Templates
  import LockScreenQRCodeWeb.Components.PhonePreview

  @impl true
  def mount(_params, _session, socket) do
    :telemetry.execute([:lock_screen_qr_code, :design_live, :mount], %{status: :start})

    # QR request is now always available due to the hook creating one if needed
    if socket.assigns[:qr_request] do
      Logger.info("DesignLive mounted with QR request: #{socket.assigns.qr_request.id}")
    else
      Logger.warning("QR request should have been created by hook but wasn't found")
    end

    templates = Templates.all()

    # Default to the first template if none is selected
    template = socket.assigns[:qr_request].template || List.first(templates).id
    theme = Templates.get_theme(template)

    # Set qr_preview to nil since we'll use the component directly
    {:ok, assign(socket,
      templates: templates,
      selected_template: template,
      qr_preview: nil,
      theme: theme
    )}
  end

  @impl true
  def handle_event("select_template", %{"template" => template_id}, socket) do
    Logger.info("Selected template: #{template_id}")

    # Update the QR request with the selected template
    case Requests.update_qr_request(socket.assigns.qr_request, %{template: template_id}) do
      {:ok, updated_qr_request} ->
        theme = Templates.get_theme(template_id)

        {:noreply,
         socket
         |> assign(:qr_request, updated_qr_request)
         |> assign(:selected_template, template_id)
         |> assign(:theme, theme)}

      {:error, _changeset} ->
        Logger.error("Failed to update template for QR request: #{socket.assigns.qr_request.id}")
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>

      <div class="w-full max-w-5xl bg-white/90 backdrop-blur-sm rounded-2xl shadow-2xl p-4 lg:p-8 relative z-10">
        <h1 class="text-2xl lg:text-4xl font-bold text-center text-gray-800 mb-1 lg:mb-2">Make it pop!</h1>
        <p class="text-center text-gray-600 mb-2 lg:mb-8">Choose a style that matches your vibe</p>

        <!-- Hidden elements for testing -->
        <div class="hidden">
          <span id="qr-url"><%= @qr_request.url %></span>
          <span id="qr-name"><%= @qr_request.name || "" %></span>
        </div>

        <!-- Mobile Layout -->
        <div class="md:hidden">
          <div class="flex flex-col items-center space-y-0">
            <!-- Phone Preview - Even smaller with less space -->
            <div style="transform: scale(0.7); transform-origin: top center; margin-bottom: -140px;">
              <.phone_preview
                qr_request={@qr_request}
                theme={@theme}
                gradient={@templates |> Enum.find(fn t -> t.id == @selected_template end) |> Map.get(:gradient)}
              />
            </div>

            <!-- Color Options - Moved up to reduce white space -->
            <div class="w-full overflow-x-auto scrollbar-hide pt-0">
              <div class="flex justify-start gap-2 px-2 py-1 min-w-full">
                <%= for template <- @templates do %>
                  <button
                    phx-click="select_template"
                    phx-value-template={template.id}
                    class={[
                      "flex-none min-w-[7rem] overflow-hidden rounded-lg",
                      if @selected_template == template.id do
                        "border-2 border-indigo-500 ring-1 ring-indigo-300"
                      else
                        "border border-gray-200"
                      end
                    ]}
                  >
                    <div class={"h-14 bg-gradient-to-br #{template.gradient}"}></div>
                    <div class="py-1 px-1 bg-white text-center">
                      <span class="text-xs whitespace-nowrap">{template.name}</span>
                    </div>
                  </button>
                <% end %>
              </div>
            </div>
          </div>
        </div>

        <!-- Desktop Layout -->
        <div class="hidden md:flex flex-row md:gap-2 lg:gap-16 items-center mb-16">
          <!-- Phone Mockup Preview -->
          <div class="flex-shrink-0 flex justify-center">
            <.phone_preview
              qr_request={@qr_request}
              theme={@theme}
              gradient={@templates |> Enum.find(fn t -> t.id == @selected_template end) |> Map.get(:gradient)}
            />
          </div>

          <!-- Template Gallery -->
          <div class="w-full pl-8">
            <div class="grid grid-cols-4 gap-4">
              <%= for template <- @templates do %>
                <button
                  phx-click="select_template"
                  phx-value-template={template.id}
                  class={[
                    "flex flex-col rounded-lg overflow-hidden shadow-md transform transition-all hover:scale-105",
                    if @selected_template == template.id do
                      "border-2 border-indigo-500 ring-2 ring-indigo-300 ring-offset-1"
                    else
                      "border border-gray-200 hover:border-indigo-400"
                    end
                  ]}
                >
                  <div class={"aspect-square w-full bg-gradient-to-br #{template.gradient}"}>
                  </div>
                  <div class="bg-white py-2 px-1 text-center w-full">
                    <span class="text-sm font-medium text-gray-900">{template.name}</span>
                  </div>
                </button>
              <% end %>
            </div>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row justify-between gap-3 mt-2">
          <.link
            navigate={~p"/create"}
            replace={true}
            class="w-full sm:w-auto bg-white text-indigo-600 border border-indigo-200 hover:bg-indigo-50 font-medium rounded-full py-2 px-6 shadow-sm flex justify-center order-2 sm:order-1"
          >
            &larr; Back
          </.link>
          <.link
            navigate={~p"/preview"}
            class="w-full sm:w-auto bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-full py-2 px-6 shadow-md flex justify-center order-1 sm:order-2"
          >
            Continue &rarr;
          </.link>
        </div>
      </div>

    <style>
      .scrollbar-hide::-webkit-scrollbar {
        display: none;
      }
      .scrollbar-hide {
        -ms-overflow-style: none;
        scrollbar-width: none;
      }
    </style>
    </Layouts.app>
    """
  end

  # We no longer need the generate_qr_preview function as we're using the QRCode component
end
