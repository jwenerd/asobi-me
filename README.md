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
#    Unchanged sketches are skipped automatically via per-sketch SHA256 caching.
bin/export my-cosmos
bin/export my-cosmos --at 1.5                 # Also save SVG keyframe at 1.5s
bin/export                                    # Export every changed sketch
bin/export --force                            # Force re-export all sketches
bin/export --prune                            # Remove stale exports/ for deleted sketches

# 4. Build the static gallery site into _site/ (newest-first cards + viewer pages)
bin/build-site                                # Runs cached export + builds _site/
bundle exec rake site                         # Equivalent Rake task

# 5. Convert browser recordings (press 'R' in live view) with ffmpeg
bin/convert-video recording.webm --mp4 --gif
```

## GitHub Pages Deployment

Pushes to `main` trigger [`.github/workflows/pages.yml`](.github/workflows/pages.yml), which:
1. Restores cached `exports/` via `actions/cache` and only re-exports new or modified sketches (`bin/export --prune`).
2. Builds the newest-first gallery + sketch viewer pages into `_site/` (`bin/build-site --skip-export`).
3. Publishes `_site/` directly to GitHub Pages via `actions/deploy-pages`.

### One-Time Repository Setup
1. Push this repo to GitHub (`main` branch).
2. In your GitHub repo go to **Settings → Pages → Build and deployment → Source** and choose **GitHub Actions**.
3. Push a commit to `main` (or run the workflow manually via **Actions → Deploy Gallery to GitHub Pages → Run workflow**) to publish at `https://<username>.github.io/<repo-name>/`.

### Live Preview Shortcuts
- **`R`** — Record animation video (`.webm`)
- **`F`** — Fullscreen (great with `controls: false` for VJ / projection)
- **`M`** — Mute audio
- **`Ctrl-C`** in terminal — Stop the preview server

### Current Sketches
1. `04-rgb-grid-drift-story` — 9:16 vertical RGB polyrhythmic drift study (Instagram Story framing).
2. `03-rgb-grid-drift` — Square additive RGB grid drift with independent coprime polyrhythms.
3. `02-object-to-art-orrery` — Custom Ruby classes (`Planet`, `StarField`) implementing `to_art`.
4. `01-generative-bloom` — Generative looping SVG/HTML animation using shared studio palettes.
