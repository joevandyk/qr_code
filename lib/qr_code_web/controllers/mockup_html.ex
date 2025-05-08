defmodule QrCodeWeb.MockupHTML do
  use QrCodeWeb, :html

  # This embeds all templates in the lib/qr_code_web/controllers/mockup_html/ directory
  # The render/2 calls in MockupController (e.g., render(conn, :step1))
  # will now correctly find step1.html.heex, step2.html.heex, etc.
  embed_templates "mockup_html/*"
end
