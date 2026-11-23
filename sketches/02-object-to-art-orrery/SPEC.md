# 02 — Object-to-Art Orrery

- **Slug**: `02-object-to-art-orrery`
- **Category**: `object`
- **Status**: Starter Example

## Concept
Demonstrates `asobi`'s **Object to Art. Art to Object.** philosophy by modeling a planetary system as plain Ruby classes (`Planet`, `StarField`) that `include Asobi::Art` and implement `def to_art`.

## Visual Direction
- **Palette**: `Studio::Palettes::SOLAR_DRIFT` & `Studio::Palettes::MIDNIGHT_NEON`
- **Background**: `Studio::Palettes.bg(:night)` (`#070812`)
- **Canvas / Paper**: `[260, 260]`

## Export Targets
- [x] Standalone looping HTML (`bin/export 02-object-to-art-orrery`)
- [x] Static SVG keyframe (`bin/export 02-object-to-art-orrery --at 1.5`)
