# frozen_string_literal: true

require_relative "../../lib/studio"

# --- Tunable Parameters (edit live & save to hot-reload) -------------------
GRID_COUNT   = 12       # Number of lines per axis (lower = sparser)
GRID_SPAN    = 210.0    # Overall width & height of the grid
STROKE_WIDTH = 1.2      # Line thickness
GRID_STYLE   = :lines   # :lines (full-span grid) or :segments (sparse ticks)

LOOP_SECONDS = 30.0     # Seamless polyrhythm master cycle (900 frames @ 30fps)
MAX_DRIFT    = 8.5      # Peak RGB separation distance (in canvas units)
MAX_TILT     = 0.9      # Subtle peak rotation (degrees) during drift
LINE_WAVE    = 0.35     # Per-line phase ripple (0.0 = rigid sheets)

GLOW         = 0.8      # Subtle halo around lines (0 = razor sharp)
GRAIN        = true     # Subtle film grain overlay
BACKGROUND   = Studio::Palettes.bg(:void)
PAPER        = [320, 320].freeze

# Three independent additive RGB layers with continuous coprime polyrhythms.
# No flat dead-zone: each channel breathes continuously toward and away from
# alignment on its own interference envelope (g1, g2), modulates its drift
# offset (amp_cycles), and warps its wiggle rate (warp_freq / warp_amp).
# Zero frozen stillness — layers pass organically through crisp white and
# cyan/yellow/magenta crossovers while perpetually in motion.
CHANNELS = [
  {
    color: "#ff2a3c", # Red
    g1: 3, g2: 5, p1: 0.72, p2: 0.18,
    amp_cycles: 2, amp_phase: 0.15, amp_scale: 1.00,
    fx: 3, fy: 5, px: 0.00, py: 0.25,
    warp_freq: 2, warp_amp: 0.40, warp_phase: 0.10,
    tilt_dir: 1.0
  },
  {
    color: "#1aff5c", # Green
    g1: 2, g2: 7, p1: 0.45, p2: 0.62,
    amp_cycles: 3, amp_phase: 0.55, amp_scale: 0.88,
    fx: 5, fy: 3, px: 0.33, py: 0.00,
    warp_freq: 3, warp_amp: 0.35, warp_phase: 0.48,
    tilt_dir: -0.65
  },
  {
    color: "#2b6bff", # Blue
    g1: 4, g2: 5, p1: 0.10, p2: 0.85,
    amp_cycles: 3, amp_phase: 0.82, amp_scale: 1.00,
    fx: 4, fy: 6, px: 0.62, py: 0.72,
    warp_freq: 2, warp_amp: 0.44, warp_phase: 0.77,
    tilt_dir: -1.0
  }
].freeze

TAU = 2.0 * Math::PI

def smoothstep(x)
  c = x.clamp(0.0, 1.0)
  c * c * (3.0 - 2.0 * c)
end

# Continuous polyrhythmic breathing envelope for one channel at normalized time t.
# Smoothly dips close to 0 (passing alignment) and swells to varied peaks
# without any flat stillness hold.
def channel_envelope(channel, t)
  raw = 0.56 * Math.sin(TAU * channel[:g1] * t + TAU * channel[:p1]) +
        0.44 * Math.sin(TAU * channel[:g2] * t + TAU * channel[:p2])
  norm = (raw + 1.0) * 0.5 # 0.0..1.0 continuously, no dead-zone
  amp_swell = 0.55 + 0.45 * (0.5 + 0.5 * Math.sin(TAU * channel[:amp_cycles] * t + TAU * channel[:amp_phase]))
  smoothstep(norm) * (0.25 + 0.75 * norm) * amp_swell * channel[:amp_scale]
end

# Evenly spaced centered positions for GRID_COUNT lines across GRID_SPAN.
def grid_positions(count, span)
  return [0.0] if count <= 1

  step = span.to_f / (count - 1)
  Array.new(count) { |i| -span / 2.0 + i * step }
end

# Offset [dx, dy, angle] for a channel and line index using a phase-warped
# oscillator so the wiggle rate speeds up and slows down organically.
def line_wiggle(channel, env, t, index, axis_offset: 0.0)
  return [0.0, 0.0, 0.0] if env.zero?

  wave = (index - (GRID_COUNT - 1) / 2.0) * LINE_WAVE + axis_offset
  warp = channel[:warp_amp] * Math.sin(TAU * channel[:warp_freq] * t + TAU * channel[:warp_phase])
  amp  = MAX_DRIFT * env

  phase_x = TAU * (channel[:fx] * t + warp) + TAU * channel[:px] + wave
  phase_y = TAU * (channel[:fy] * t - warp * 0.85) + TAU * channel[:py] - wave * 0.7

  dx    = amp * Math.sin(phase_x)
  dy    = amp * Math.sin(phase_y)
  angle = MAX_TILT * channel[:tilt_dir] * env * Math.sin((phase_x + phase_y) * 0.5)

  [dx, dy, angle]
end

# Build one sparse color layer (Red, Green, or Blue) at phase t.
def build_layer(channel, t, env: nil)
  env = channel_envelope(channel, t) if env.nil?
  positions = grid_positions(GRID_COUNT, GRID_SPAN)
  parts = []

  if GRID_STYLE == :segments
    step    = GRID_COUNT > 1 ? GRID_SPAN / (GRID_COUNT - 1) : GRID_SPAN
    seg_len = step * 0.36
    base_h  = line(seg_len).outlined(channel[:color], width: STROKE_WIDTH)

    positions.each_with_index do |y, row|
      positions.each_with_index do |x, col|
        dx, dy, angle = line_wiggle(channel, env, t, row + col * 0.5)
        rot = (row + col).even? ? angle : 90.0 + angle
        parts << base_h.rotate(rot).move(right: x + dx, down: y + dy)
      end
    end
  else
    base_h = line(GRID_SPAN).outlined(channel[:color], width: STROKE_WIDTH)
    base_v = base_h.rotate(90)

    positions.each_with_index do |pos, i|
      dx_h, dy_h, ang_h = line_wiggle(channel, env, t, i, axis_offset: 0.0)
      parts << base_h.rotate(ang_h).move(right: dx_h, down: pos + dy_h)

      dx_v, dy_v, ang_v = line_wiggle(channel, env, t, i, axis_offset: 1.1)
      parts << base_v.rotate(ang_v).move(right: pos + dx_v, down: dy_v)
    end
  end

  layer = parts.reduce(:+)
  layer = layer.glowing(GLOW) if GLOW.positive?
  layer.blended(:screen)
end

# Pre-build resting (aligned) layers once so Asobi::Memo reuses their SVG
# fragments whenever a channel is in a stillness pocket.
REST_LAYERS = CHANNELS.to_h { |ch| [ch[:color], build_layer(ch, 0.0, env: 0.0)] }.freeze

rgb_grid = nothing.animate(every: LOOP_SECONDS) do |_picture, t|
  CHANNELS.map do |channel|
    env = channel_envelope(channel, t)
    env.zero? ? REST_LAYERS[channel[:color]] : build_layer(channel, t, env:)
  end.reduce(:+)
end

show rgb_grid, on: BACKGROUND, paper: PAPER, grain: GRAIN
