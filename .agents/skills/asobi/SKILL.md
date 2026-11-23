---
name: asobi
description: Write creative coding sketches, generative SVG art, and pure-function looping animations in Ruby using the asobi gem (Object to Art. Art to Object.). Use when converting Ruby numbers, strings, arrays, hashes, or custom classes into SVG or standalone looping HTML, or when making pictures react to clicks, keys, a microphone or music and play sound.
---

# asobi (Ruby Creative Coding — Object to Art. Art to Object.)

`asobi` is a zero-dependency Ruby >= 3.2 creative coding library built around one loop:

1. **Object to Art**: Convert any Ruby value (`Numeric`, `String`, `Array`, `Range`, `Hash`, or custom classes defining `def to_art`) into a picture with `to_art`.
2. **Art to Object**: Every picture (`Asobi::Art`) and motion (`Asobi::Motion`) is an immutable Ruby value. Chain methods (`colored`, `move`, `rotate`, `in_fan`, `spin`, `glowing`) or combine with `+`, `on`, `beside`, `above` without mutating a shared canvas.

## Installation & Execution

- Install: `gem install asobi` (no native dependencies; Ruby >= 3.2 stdlib only).
- Pure mode (no core extensions on `Numeric`/`String`/`Array`/`Hash`): `require "asobi/pure"` (`Asobi.art(obj)` instead of `obj.to_art`).
- Local live coding: `asobi sketch.rb` (opens browser live view and reloads on save).
- Headless / Script export:
  - `art.save("out.svg")` exports static SVG (or `motion.save("out.html")` for standalone looping HTML).
  - `art.to_svg` returns SVG markup as a String.
  - Sketches evaluated interactively end with `show art, on: :black, grain: true`.

## Critical Rules & Gotchas

- Coordinates are centered at `[0, 0]`, with positive `y` pointing down (`up:` subtracts `y`).
- All parameters have sensible defaults (`circle` works with zero arguments).
- Motion durations (`spin(every: 6)`, `orbit(40, every: 6)`) must be **non-negative** (`>= 0`). To spin or orbit counter-clockwise, pass `clockwise: false` instead of a negative `every:`.
- Do not call `array.to_art` and then `.in_fan`: `array.to_art` lays items out in a row first; build centered items (`petal(...).repeat(n).in_fan`) or arrange with `.in_ring(r)`.

## Reactions & Sound

- A reaction word comes right after a motion and says who turns its frames instead of the clock: `flower.pulse.when_clicked`, `flower.spin.while_hovered`, `flower.spin.when_pressed("a")`, `ring.pulse.on_beat` (the microphone) or `on_beat(:music)`.
- `by` picks the frame from a value: `by(:mouse_x)`, `by(:mouse_y)`, `by(:mic)`, `by(:mic, :low)` (also `:mid`, `:high`, `:pitch`), `by(:music)`, `by(:music, :low)`.
- The answer is still a picture: `dot.pulse.when_clicked.repeat(12).in_ring(60)` gives twelve dots that each react on their own.
- `play "song.mp3"` is a top-level word like `show`: one song per sketch, looped, read from the sketch's folder (`volume: 0.5` to turn it down). `:music` means the sound asobi itself plays.
- `sounding(sound)` comes right after `when_clicked`, `while_hovered`, `when_pressed` or `on_beat`, never after `by(...)` or a plain motion. Sounds: `:pop`, `:kick`, `:snare`, `:hat`, `:clap`, `:bell`, or a note such as `:c4`, `:cs4`, `"Bb3"`.
- Browsers start sound and the microphone only after a click or key press on the picture. A saved `.html` still reacts and carries its song (up to 20 MB); a saved `.svg` shows the picture at rest.
- `show art, controls: false` hides the buttons for projecting; in the player, `f` is full screen and `m` mutes.

## Vocabulary (78 Words in 10 Groups)

- **shapes** (22): `circle`, `ellipse`, `rect`, `square`, `triangle`, `polygon`, `star`, `line`, `text`, `path`, `arc`, `wave`, `ring`, `heart`, `petal`, `moon`, `drop`, `cloud`, `space`, `nothing`, `hsl`, `gray`
- **combine** (7): `on`, `under`, `+`, `repeat`, `*`, `beside`, `above`
- **change** (7): `move`, `rotate`, `scale`, `grow`, `shrink`, `mirror`, `flip`
- **color** (4): `colored`, `outlined`, `stroke`, `opacity`
- **effect** (5): `glowing`, `blurred`, `blended`, `shadowed`, `clipped_by`
- **arrange** (8): `in_row`, `in_column`, `in_grid`, `in_ring`, `in_fan`, `in_spiral`, `scattered`, `change_each`
- **to_art** (1): `to_art`
- **motion** (12): `spin`, `pulse`, `sway`, `orbit`, `fade`, `bounce`, `drift`, `shift_color`, `one_by_one`, `trail`, `animate`, `at`
- **react** (7): `when_clicked`, `while_hovered`, `when_pressed`, `on_beat`, `by`, `sounding`, `play`
- **show** (5): `show`, `save`, `to_svg`, `bounds`, `turn`

## Documentation Endpoints

- Human Reference: https://asobi.myura.me/reference (Markdown: https://asobi.myura.me/reference.md)
- Full LLM Context: https://asobi.myura.me/llms-full.txt
- Interactive ruby.wasm Playground: https://asobi.myura.me/playground
