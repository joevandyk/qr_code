defmodule LockScreenQRCodeWeb.PageController do
  use LockScreenQRCodeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
