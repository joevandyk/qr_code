defmodule QrCodeWeb.DesignLive do
  use QrCodeWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    :telemetry.execute([:qr_code, :design_live, :mount], %{status: :start})

    url = params["url"]
    name = params["name"]

    Logger.info("DesignLive mounted with URL: #{url || "nil"}, Name: #{name || "nil"}")

    {:ok, socket |> assign(:url, url) |> assign(:name, name)}
  end
end
