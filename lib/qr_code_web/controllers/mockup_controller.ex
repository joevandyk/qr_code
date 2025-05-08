defmodule QrCodeWeb.MockupController do
  use QrCodeWeb, :controller

  # Reuse the root layout for consistent background/header
  plug :put_root_layout, html: {QrCodeWeb.Layouts, :root}

  def step1(conn, _params) do
    render(conn, :step1)
  end

  def step2(conn, _params) do
    render(conn, :step2)
  end

  def step3(conn, _params) do
    render(conn, :step3)
  end

  def step4(conn, _params) do
    # Add meta refresh header for auto-redirect
    conn
    |> put_resp_header("refresh", "2; url=#{~p"/mockup/step5"}")
    |> render(:step4)
  end

  def step5(conn, _params) do
    render(conn, :step5)
  end
end
