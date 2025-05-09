defmodule QrCodeWeb.MockupController do
  use QrCodeWeb, :controller

  # Reuse the root layout for consistent background/header
  plug :put_root_layout, html: {QrCodeWeb.Layouts, :root}

  def home(conn, _params) do
    render(conn, :home)
  end

  def create(conn, _params) do
    render(conn, :create)
  end

  def design(conn, _params) do
    render(conn, :design)
  end

  def preview(conn, _params) do
    render(conn, :preview)
  end

  def checkout(conn, _params) do
    render(conn, :checkout)
  end

  def download(conn, _params) do
    render(conn, :download)
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end
