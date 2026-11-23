# frozen_string_literal: true

module Studio
  # Curated color palettes for consistent visual studies across sketches.
  # Pass any palette with splat syntax: `art.colored(*Studio::Palettes::MIDNIGHT_NEON)`
  module Palettes
    MIDNIGHT_NEON = %w[#ffd166 #ff4d6d #00f5d4 #9b5de5 #f15bb5].freeze
    SUMI_GOLD     = %w[#f4e8c1 #e0b354 #c85a32 #8c3b2b #2b2d42].freeze
    SOLAR_DRIFT   = %w[#ffbe0b #fb5607 #ff006e #8338ec #3a86ff].freeze
    OCEAN_GLASS   = %w[#caf0f8 #90e0ef #00b4d8 #0077b6 #03045e].freeze
    BOTANICAL     = %w[#dad7cd #a3b18a #588157 #3a5a40 #344e41].freeze
    CYBER_ROSE    = %w[#ff70a6 #ff9770 #ffd670 #e9ff70 #70d6ff].freeze

    BACKGROUNDS = {
      night:   "#070812",
      ink:     "#11131c",
      paper:   "#faf6ee",
      charcoal:"#181a20",
      void:    "#000000"
    }.freeze

    ALL = {
      midnight_neon: MIDNIGHT_NEON,
      sumi_gold:     SUMI_GOLD,
      solar_drift:   SOLAR_DRIFT,
      ocean_glass:   OCEAN_GLASS,
      botanical:     BOTANICAL,
      cyber_rose:    CYBER_ROSE
    }.freeze

    module_function

    def fetch(name)
      ALL.fetch(name.to_sym)
    end

    def bg(name)
      BACKGROUNDS.fetch(name.to_sym)
    end
  end
end
