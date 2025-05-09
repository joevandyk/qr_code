defmodule LockScreenQRCode.Templates do
  @moduledoc """
  Module for managing QR code templates.
  Provides a centralized location for template definitions and helper functions.
  """

  @doc """
  Returns a list of all available templates.
  """
  def all do
    [
      %{id: "pop_vibes", name: "Pop Vibes", gradient: "from-pink-400 to-purple-500"},
      %{id: "ocean_blue", name: "Ocean Blue", gradient: "from-teal-400 to-blue-500"},
      %{id: "sunny_side", name: "Sunny Side", gradient: "from-yellow-400 to-orange-500"},
      %{id: "monochrome", name: "Monochrome", gradient: "from-gray-800 to-gray-900"},
      %{id: "clean_white", name: "Clean White", gradient: "from-gray-50 to-white"},
      %{id: "neon_glow", name: "Neon Glow", gradient: "from-green-400 via-blue-500 to-purple-600"},
      %{id: "sunset_dream", name: "Sunset Dream", gradient: "from-red-400 via-pink-500 to-purple-500"},
      %{id: "forest_mist", name: "Forest Mist", gradient: "from-emerald-400 to-teal-600"},
      %{id: "midnight_sky", name: "Midnight Sky", gradient: "from-indigo-900 to-blue-900"},
      %{id: "amber_gold", name: "Amber Gold", gradient: "from-yellow-500 to-amber-700"},
      %{id: "rose_petal", name: "Rose Petal", gradient: "from-rose-400 to-pink-600"},
      %{id: "lime_fresh", name: "Lime Fresh", gradient: "from-lime-400 to-green-600"}
    ]
  end

  @doc """
  Returns a list of template IDs that use a light theme.
  """
  def light_theme_templates do
    ["clean_white"]
  end

  @doc """
  Gets a template by ID.
  """
  def get(template_id) do
    Enum.find(all(), fn t -> t.id == template_id end)
  end

  @doc """
  Gets the gradient for a template by ID.
  If the template is not found, returns a default gradient.
  """
  def get_gradient(template_id) do
    case get(template_id) do
      nil -> "from-gray-400 to-gray-600" # Default gradient if template not found
      template -> template.gradient
    end
  end

  @doc """
  Determines the theme (light or dark) for a template.
  """
  def get_theme(template_id) do
    if template_id in light_theme_templates(), do: "light", else: "dark"
  end
end
