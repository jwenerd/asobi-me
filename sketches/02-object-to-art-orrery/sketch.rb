# frozen_string_literal: true

require_relative "../../lib/studio"

class Planet
  include Asobi::Art

  def initialize(name:, radius:, distance:, color:, year:, moons: 0)
    @name = name
    @radius = radius
    @distance = distance
    @color = color
    @year = year
    @moons = moons
  end

  def to_art
    track = ring(@distance, 0.45).colored(:dimgray).opacity(0.45)
    body  = circle(@radius).colored(@color).glowing(1.5)

    if @moons.positive?
      moon_dot = circle(1.6).colored(:white).orbit(@radius + 5, every: 1.5)
      body += moon_dot
    end

    track + body.orbit(@distance, every: @year)
  end
end

class StarField
  include Asobi::Art

  def initialize(count: 48, span: [240, 240], seed: 7)
    @count = count
    @span = span
    @seed = seed
  end

  def to_art
    circle(1.1).colored(:white)
      .repeat(@count)
      .change_each { |dot, t, i| dot.scale(0.6 + (i % 3) * 0.4).opacity(0.25 + t * 0.5) }
      .scattered(over: @span, seed: @seed)
  end
end

palette = Studio::Palettes::MIDNIGHT_NEON
sun = circle(14).colored(palette[0]).glowing(4).pulse(1.12, every: 4)

planets = [
  Planet.new(name: :amber,  radius: 4.5, distance: 32, color: palette[1], year: 4),
  Planet.new(name: :cyan,   radius: 6.5, distance: 56, color: palette[2], year: 6, moons: 1),
  Planet.new(name: :violet, radius: 5.5, distance: 82, color: palette[3], year: 9),
  Planet.new(name: :rose,   radius: 4.0, distance: 106, color: palette[4], year: 12)
]

orrery = StarField.new + sun + planets.reduce(:+)

show orrery, on: Studio::Palettes.bg(:night), paper: [260, 260], grain: true
