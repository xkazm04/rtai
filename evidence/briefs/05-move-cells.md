# Brief 05 `move-cells` (lane move, n19): drawn cells for the vault and cover

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.

## Goal
Replace the stand-in poses (the roll ball for the vault, the squashed standing cell for low cover) with drawn
cells, for both tilt art sets (`p55`, `p70`): at least
- `vault_plant`: one hand on the obstacle, body horizontal-ish, legs swinging over (the take-off/apex cell);
- `vault_land`: landing crouch, about to stand (the last third);
- `cover_low`: crouched, side/back to the box, gun held up, helmet visible (low cover IN);
- `cover_high`: standing flat against a wall, gun held up beside the helmet (high cover IN).
Peek uses the existing facing/fire cells (no new cell), unless you show it does not read.

## Art law (binding)
- References are ONLY this project's own art: `project/features/characters/art/view/p55/rivet_frames.png` and
  `p70/rivet_frames.png` (14 cells: 8 facings, walk, sprint, roll, claw, hit, death) and his equipped strips in the
  same folders. Same style, outline weight, palette, light from the same side, same figure height (`FIG_PX`
  110 at the strip's scale) and foot pad as `rivet_frames.gd` reads them.
- Rivet's striped neck band is a **rigid hazard collar** (orange/black), never cloth, never a scarf, never
  fluttering. Red is blood only; vermilion only for danger/objectives and the collar.
- Generate with your built-in `image_gen`. Masters (raw generations) go to
  `C:/Users/kazda/kiro/gtai-masters/n19/move/masters/` (never into git), each with a manifest entry in the
  `art_src/` format (read `art_src/` for it). Prompts committed under `docs/art/prompts/n19/move/` (one .md per
  cell family, with the exact prompt and the reference list).
- Cut with a script `tools/art/move_cells_cut.py` (keying, crop to alpha, scale to the strip's figure height,
  feet on the pad, write a strip per pitch): never by hand. Output `project/features/characters/art/rivet/moves/
  <pitch>/rivet_moves.png` (+ a small JSON naming the cells in order, with a schema if the repo pattern needs
  one) and `.import` files. A provenance line per shipped PNG in `steam/ai-provenance/2026-11.jsonl` (append
  only, the format of its recent `image_gen` lines).
- Look at every generation yourself. Reject any where the collar reads as cloth, the proportions differ from the
  strip, a gun is in the wrong hand for its facing, or the style drifts. Say how many you rejected and why.

## Wiring
- A `MoveCells` reader in `features/player/` (or `features/characters/art/rivet/moves/` code beside it if the repo
  pattern wants that) that maps the vault's phase (lift, frame) and the cover's phase (low/high, IN) to a cell.
- VaultView and CoverView show the drawn cell instead of the stand-in when it exists for the current art; the
  stand-in stays the fallback (flat top view has no drawn cells: keep its stand-in) and a data flag
  `vault.drawn_cells` / `cover.drawn_cells` (true) switches back to the stand-in.
- The anim lane owns `features/characters/**` code: at most two one-line call sites there (named in the commit,
  file:line), e.g. one line in `rivet_frames.gd::step` like `path = MoveCells.path_or(rig, art, path)`.
  If impossible within that, stop and report the minimal set.

## Evidence
Re-render the vault course and the cover course with the drawn cells: same-tick stills old stand-in | drawn
cells at tilt 55 and 70, 32 and 64 px/m, sheets, a 32 px/m clip of each course at tilt 70, to
`C:/Users/kazda/kiro/gtai-masters/n19/move/cells/` with an INDEX.md saying honestly what you see.
Unit test: the cell mapping (each phase -> the right cell; fallback when the art is missing; flag off -> stand-in).

## Repo law
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`; commit `.uid` and `.import`
files. No features/combat, city, native, goldens. Stage per path; no stash, add -A, reset --hard; never push; never
stage JOURNAL.md. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
quick gate + lint clean; `run_unit.mjs --changed` and `--fast` green; vault + cover scenarios green; both dev
course verdicts `ok exit 0; SCRIPT ERROR 0; unknown arg 0`; cells, masters, manifest, prompts, provenance lines
present; `git status` clean.
