# Agent Instructions — Asobi Creative Studio

This repository is a Ruby creative coding studio powered by the `asobi` gem (`>= 0.2.1`).

## Before Writing or Editing Sketches
1. Read `.agents/skills/asobi/SKILL.md` for the full 78-word `asobi` API vocabulary and critical gotchas.
2. Follow the studio structure and conventions documented in `PROJECT_SPEC.md`.

## Environment & Commands
- Ruby version is pinned to `3.4.1` in `.ruby-version` (managed by `chruby` at `~/.rubies/ruby-3.4.1`).
- In non-interactive shells where `~/.zshrc` is not loaded, activate Ruby before running commands:
  ```sh
  source /opt/homebrew/opt/chruby/share/chruby/chruby.sh && chruby 3.4.1
  ```
- Scaffold a new sketch: `bin/new-sketch <slug> --type generative|object|interactive`
- Live preview: `bin/live <slug>` (uses `bundle exec asobi`)
- Headless export (SVG / HTML, cached per sketch): `bin/export <slug>` (or `bin/export` for all; supports `--force` and `--prune`)
- Build static GitHub Pages gallery (`_site/`): `bin/build-site` (or `bundle exec rake site`)
- Convert browser recordings: `bin/convert-video <input.webm> --mp4 --gif`

## Studio Rules
- Every sketch in `sketches/<slug>/sketch.rb` must end with `show ...` so both `bin/live` and `bin/export` work seamlessly.
- Never run `bundle exec asobi` without `--no-open` or `ASOBI_LIVE=0` in headless/CI checks (it starts a blocking server). Use `bin/export <slug>` to verify sketches render without errors.
- Keep `sketches/<slug>/SPEC.md` updated when changing a sketch's creative concept, parameters, canvas dimensions, or export targets — its header fields (`# Title`, `Category`, `Created`, `Status`, `Canvas / Paper`, `## Concept`) automatically populate the published GitHub Pages gallery cards.
- Keep `exports/` and `_site/` gitignored; GitHub Actions (`.github/workflows/pages.yml`) builds and deploys `_site/` on pushes to `main`.
