# 04 — RGB Grid Drift (Instagram Story 9:16)

- **Slug**: `04-rgb-grid-drift-story`
- **Category**: `generative`
- **Created**: 2026-11-22
- **Status**: Active Live Session

## Concept
Vertical **9:16** Instagram Story variation of [03-rgb-grid-drift](../03-rgb-grid-drift/SPEC.md). Preserves true square cells (`9 × 16` cell grid = `10` vertical × `17` horizontal lines) across a full-frame `9:16` canvas with clean proportional margins (~11.7%) and continuous coprime RGB polyrhythms.

## Visual Direction
- **Palette**: Pure additive RGB (`#ff2a3c`, `#1aff5c`, `#2b6bff`)
- **Background**: `Studio::Palettes.bg(:void)` (`#000000`)
- **Canvas / Paper**: `[270, 480]` (exact `9:16` vertical portrait — scales 4× cleanly to `1080 × 1920` for Instagram Story)
- **Texture / Effects**: `blended(:screen)`, subtle `glowing`, `grain: true`

## Motion / Object-to-Art Design
- **Core primitives**: `line`, `outlined`, `move`, `rotate`, `glowing`, `blended(:screen)`
- **Grid layout**: `10` vertical × `17` horizontal lines (`9 × 16` exact square cells of `23 × 23`, spanning `207 × 368`)
- **Motion / Loop duration**: `every: 30` seconds seamless polyrhythmic loop (900 frames @ 30fps)
  - Continuous coprime breathing envelopes per channel (`g1`/`g2`, no dead-zone) — zero frozen stillness
  - Per-channel coprime amplitude swells (`amp_cycles`) for varying drift distances
  - Phase-warped oscillators (`warp_freq` / `warp_amp`) for continuously varying wiggle rates

## Export Targets & Instagram Story Upload
- [x] Standalone looping HTML (`bin/export 04-rgb-grid-drift-story`)
- [ ] Static SVG keyframe (`bin/export 04-rgb-grid-drift-story --at 15`)
- [ ] Instagram Story MP4 (`1080 × 1920`, H.264 `yuv420p`):
  1. Press **`R`** in the live browser preview to record a `.webm` clip.
  2. Convert & upscale cleanly to `1080 × 1920` MP4:
     ```sh
     ffmpeg -y -i recording.webm -vf "scale=1080:1920:flags=lanczos" -c:v libx264 -pix_fmt yuv420p -crf 18 -movflags +faststart exports/video/rgb-grid-drift-story.mp4
     ```

## Notes & Iterations
- Branched from `03-rgb-grid-drift` (v3 continuous polyrhythms) with proportional `9:16` vertical framing and exact square cells.
