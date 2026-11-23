# frozen_string_literal: true

require_relative "../../lib/studio"

palette = Studio::Palettes::MIDNIGHT_NEON

outer_petal = petal(42, 11).move(up: 24)
outer_ring  = outer_petal.repeat(16).in_fan.colored(*palette).opacity(0.85)
inner_ring  = petal(24, 7).move(up: 14).repeat(8).in_fan.colored(*palette.reverse)
halo        = ring(66, 0.7).colored(palette[2]).opacity(0.45)

bloom = halo +
        outer_ring.spin(every: 12).trail(3).glowing(2) +
        inner_ring.spin(every: 6, clockwise: false) +
        star(10, 5).colored(palette[0]).pulse(1.25, every: 3)

show bloom, on: Studio::Palettes.bg(:night), paper: [240, 240], grain: true
