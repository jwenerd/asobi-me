# asobi-me

A spec-driven creative coding studio for building generative SVG art, Ruby **Object-to-Art** visualizations, and interactive / audio-reactive animations with the [`asobi`](https://asobi.myura.me/) gem.

See [PROJECT_SPEC.md](PROJECT_SPEC.md) for the full project specification and conventions.

## Quick Start

Open a new terminal in this directory (`chruby` auto-switches to Ruby `3.4.1` via `.ruby-version`):

```sh
bin/setup                            # Verify Ruby 3.4.1 and install gems
bundle exec rake list                # List available sketches
bin/live 01-generative-bloom         # Launch live-reloading browser preview
```

## Common Workflows

```sh
# 1. Create a new creative project from spec + template
bin/new-sketch my-cosmos --type generative    # or: object, interactive

# 2. Live code in the browser (save sketch.rb to hot-reload)
bin/live my-cosmos
bin/live my-cosmos --port 5000 --no-open

# 3. Export stills (SVG) and standalone animations (HTML) to exports/<slug>/
bin/export my-cosmos
bin/export my-cosmos --at 1.5                 # Also save SVG keyframe at 1.5s
bin/export                                    # Export every sketch

# 4. Convert browser recordings (press 'R' in live view) with ffmpeg
bin/convert-video recording.webm --mp4 --gif
```

### Live Preview Shortcuts
- **`R`** — Record animation video (`.webm`)
- **`F`** — Fullscreen (great with `controls: false` for VJ / projection)
- **`M`** — Mute audio
- **`Ctrl-C`** in terminal — Stop the preview server

### Starter Sketches Included
1. `01-generative-bloom` — Generative looping SVG/HTML animation using shared studio palettes.
2. `02-object-to-art-orrery` — Custom Ruby classes (`Planet`, `Orrery`) implementing `to_art`.
