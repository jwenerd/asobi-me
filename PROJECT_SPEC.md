# Asobi Creative Studio — Project Spec

This workspace is a spec-driven creative coding studio built on the [`asobi`](https://asobi.myura.me/) Ruby gem (**Object to Art. Art to Object.**). Every creative piece lives in its own folder under `sketches/` with a brief `SPEC.md` and runnable `sketch.rb`.

---

## 1. Environment & Tooling

- **Ruby**: `3.4.1` pinned in `.ruby-version` (auto-activated via `chruby`).
- **Gemfile**: `asobi` (`~> 0.2.1`, zero native dependencies) + `rake`.
- **Media conversion**: `ffmpeg` (Homebrew) for converting browser-recorded `.webm` clips to `.mp4` or `.gif`.
- **AI Agent Skill**: Official `asobi` skill installed at `.agents/skills/asobi/SKILL.md`.

---

## 2. Directory Layout

```text
asobi-me/
├── .ruby-version              # Pinned Ruby version (3.4.1)
├── Gemfile / Gemfile.lock     # Bundled dependencies (asobi, rake)
├── PROJECT_SPEC.md            # This studio specification
├── AGENTS.md                  # AI coding agent workspace instructions
├── README.md                  # Quick-start commands & cheat sheet
├── Rakefile                   # Task wrappers (new, live, export, media)
├── .agents/skills/asobi/      # Official asobi SKILL.md (78-word API + gotchas)
├── bin/
│   ├── setup                  # Verify Ruby + install gems
│   ├── new-sketch             # Scaffold sketches/<slug>/ (SPEC.md + sketch.rb)
│   ├── live                   # Start live-reloading browser preview
│   ├── export                 # Headless SVG / standalone HTML exporter
│   └── convert-video          # ffmpeg WebM -> MP4 / GIF helper
├── lib/
│   ├── studio.rb              # Shared loader for sketches
│   └── studio/
│       ├── palettes.rb        # Reusable color palettes
│       └── exporter.rb        # Headless Asobi::Sketch evaluator & exporter
├── templates/
│   ├── SPEC.md.erb            # Per-project creative spec template
│   └── sketch.rb.erb          # Starter templates (generative/object/interactive)
├── sketches/
│   └── <slug>/
│       ├── SPEC.md            # Creative brief, visual rules, export targets
│       ├── sketch.rb          # Self-contained asobi sketch ending with `show`
│       └── *.mp3 / *.wav      # Optional local audio for `play "track.mp3"`
├── assets/
│   ├── audio/                 # Shared audio library (copy or symlink into sketch folder)
│   └── data/                  # Datasets (CSV/JSON/Ruby) for Object-to-Art visuals
└── exports/
    └── <slug>/                # Generated .svg, .html, .mp4, .gif outputs (gitignored)
```

---

## 3. Creative Project Lifecycle

1. **Spec** — Run `bin/new-sketch <slug> [--type generative|object|interactive]` (or `bundle exec rake "new[<slug>,<type>]"`). Fill out `sketches/<slug>/SPEC.md` with the concept, mood/palette, motion/reactivity rules, and target outputs.
2. **Live Code** — Run `bin/live <slug>`. Save edits to `sketches/<slug>/sketch.rb` to see instant updates in the browser without resetting motion phase or restarting audio.
3. **Extract Reusable Objects** — When a visual primitive or domain model proves reusable across sketches, move it into `lib/studio/<module>.rb` using `include Asobi::Art` and `def to_art`.
4. **Export** — Run `bin/export <slug>` (or `bin/export` for all sketches) to produce:
   - `.svg` for static art (and keyframe `.svg` snapshots of motions via `--at <seconds>`),
   - standalone `.html` for looping/interactive/audio-carrying motions.
5. **Record & Convert Video** — Press **`R`** in the live browser preview to record video (`.webm`), then run `bin/convert-video recording.webm --mp4 --gif` to produce shareable clips under `exports/`.

---

## 4. Sketch Conventions

- Keep every `sketches/<slug>/sketch.rb` directly runnable by `bundle exec asobi sketches/<slug>/sketch.rb`.
- Always end a sketch with `show <picture_or_motion>, on: ..., paper: ..., grain: ...`.
  - This allows both live preview (`bin/live`) and headless export (`bin/export`) to work automatically with zero boilerplate.
- **Shared library usage**:
  ```ruby
  require_relative "../../lib/studio"
  ```
- **Pure-Ruby domain models (Object to Art)**:
  - Define `def to_art` on your Ruby classes.
  - `include Asobi::Art` to enable chaining `asobi` words (`.colored`, `.spin`, `.move`, `.glowing`) directly on instances.
  - Use `require "asobi/pure"` in standalone Ruby scripts/libraries where core extensions on `Numeric`/`String`/`Array`/`Hash` should be avoided.
- **Audio & VJ sketches**:
  - `play "song.mp3"` resolves files relative to the sketch's own folder (`sketches/<slug>/`). Store track files inside `sketches/<slug>/` (or symlink from `assets/audio/`).
  - Embedded audio in exported `.html` supports files up to 20 MB.
  - Use `controls: false` in `show` for clean projection/VJ views (`f` = fullscreen, `m` = mute, `r` = record).
- **Determinism**:
  - Pass explicit `seed:` arguments to `.scattered(over: ..., seed: 42)` so exports and re-renders are reproducible.

---

## 5. Key `asobi` Rules & Gotchas

- Origin `[0, 0]` is at the center; positive `y` points **down** (`move(up: 20)` subtracts `y`).
- Motion durations (`every:`) must be **non-negative** (`>= 0`). Use `clockwise: false` for reverse rotation/orbit.
- Do not chain `array.to_art.in_fan` (since `array.to_art` arranges items in a row first); build centered items with `.repeat(n).in_fan` or lay them out with `.in_ring(r)`.
- `sounding(...)` must follow an event reaction (`when_clicked`, `while_hovered`, `when_pressed`, `on_beat`) — never `by(...)` or an unreactive motion.

---

## 6. Reference Links

- Official site: https://asobi.myura.me/
- Step-by-step Guide: https://asobi.myura.me/guide
- Full 78-Word Reference: https://asobi.myura.me/reference
- Browser Playground (ruby.wasm): https://asobi.myura.me/playground
- GitHub Repository: https://github.com/Hayato1031/asobi
