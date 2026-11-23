# 03 — RGB Grid Drift

- **Slug**: `03-rgb-grid-drift`
- **Category**: `generative`
- **Created**: 2026-11-22
- **Status**: Active Live Session

## Concept
A sparse minimalist grid of crisp lines rendered in three overlaid primary layers — **Red**, **Green**, and **Blue** — composited with additive `:screen` blending on a dark canvas. Each RGB layer moves on its own independent coprime polyrhythm with irregular rest pockets, varying drift offsets, and continuously warping wiggle rates — producing unpredictable stretches of pure white unison, single-channel peels (cyan/yellow/magenta leftovers), and full three-way chromatic blooms.

## Visual Direction
- **Palette**: Pure additive RGB (`#ff2a3c`, `#1aff5c`, `#2b6bff`)
- **Background**: `Studio::Palettes.bg(:void)` (`#000000`)
- **Canvas / Paper**: `[320, 320]`
- **Texture / Effects**: `blended(:screen)`, subtle `glowing`, `grain: true`

## Motion / Object-to-Art Design
- **Core primitives**: `line`, `outlined`, `move`, `rotate`, `glowing`, `blended(:screen)`
- **Grid layout**: `12 × 12` intersecting horizontal and vertical lines (`GRID_STYLE = :lines`, also supports `:segments`)
- **Motion / Loop duration**: `every: 30` seconds seamless polyrhythmic loop (900 frames @ 30fps)
  - Continuous coprime breathing envelopes per channel (`g1`/`g2`, no dead-zone) — zero frozen white stillness; layers pass naturally through white and cyan/yellow/magenta crossovers in motion
  - Per-channel coprime amplitude swells (`amp_cycles`) for varying drift distances
  - Phase-warped oscillators (`warp_freq` / `warp_amp`) for continuously varying wiggle rates

## Export Targets
- [x] Standalone looping HTML (`bin/export 03-rgb-grid-drift`)
- [ ] Static SVG keyframe (`bin/export 03-rgb-grid-drift --at 15`)
- [ ] Recorded video -> MP4 / GIF (`bin/convert-video <file.webm> --mp4 --gif`)

## Notes & Iterations
- v1: Single shared 10s sync/wiggle envelope across all 3 channels.
- v2: Upgraded to pure-`asobi` 30s Independent RGB Polyrhythms (Option B) with irregular intervals, varying drift offsets, and phase-warped wiggle rates.
- v3: Removed dead-zone stillness (Flavor 2) — perpetual continuous living drift with gentler base frequencies and passing white/CMY alignment crossovers.
