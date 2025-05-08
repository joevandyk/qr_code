defmodule QrCodeWeb.PageController do
  use QrCodeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
