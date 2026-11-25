# Brief n29-06 `belt-finish`: the snaking belt's evidence: pilots, readability, before/after, film (lane yard, run n29)

HARD STOP: {STOP} local (report and END). First commit by {A}. LAST COMMIT started by {LAST}. Check `date` often. Never let the call end before its commit.

## Setup and law
Read `evidence/briefs/n29-03b-belt-snake-0232.md` in full (Setup, the design, Part B steps 2 to 8, Owned files, Forbidden, Repo law, Report). That call landed Part A and Part B step 1: `5d373c8e6`, `ffeeb3165` (five `span_*` over-print rows in `arched_line`, joins <= 0.293 m, lanes 31 ok 0 FAIL in `evidence/yard29/belt_lanes.txt`), `6cb6cdef6` (`evidence/yard29/belt_snake_mid_32ppm.png`). State file: `C:/Users/kazda/kiro/gtai-art/factory-n29/belt-state.md`. No image generation in this call. One Godot at a time: {GODOT_RULE}.

## Work, in order (the brief's Part B steps 3 to 8)
1. Pilots seeds 7, 3, 11, 21, 42 -> `evidence/yard29/prologue-yard-pilots-spans.json`, one Godot process; expected = `evidence/yard29/prologue-yard-pilots-hall.json` (same end ticks, deaths, lowest health, sha256). Commit.
2. Readability under a span (Rivet and a patrol cop standing under the bend_tail S and the door_feed span): patrol blue >= 65 % of daylight, Rivet luminance delta against the floor-only value; `evidence/yard29/readability.py`, `rivet_delta.py`; -> `evidence/yard29/belt_bars.md`.
3. Stills (LOOK at each, one line each in the report): `evidence/yard29/belt_snake_before_after_mid_32ppm.png` (same tick, `9021d82cd` without spans | HEAD; the before by a temp row `arched_nospan` = arched_line minus the five span rows, removed afterwards, never committed), `evidence/yard29/plate_vs_game_mid_snake_32ppm.png` (layout of `evidence/yard28/plate_vs_game_mid_32ppm.png`), `evidence/yard29/belt_snake_64ppm.png` (Rivet under a span). Commit.
4. Film `C:/Users/kazda/kiro/gtai-masters/n29/yard/belt_snake_before_after_mid_32ppm.mp4`: 20 to 25 s, before left | after right, 960x1080 crops hstacked to 1920x1080, 60 fps, h264 yuv420p, same ticks, the mid-yard fight; method `evidence/yard29/film.sh`. `ffprobe`. Append it and the 64 px/m still to `C:/Users/kazda/kiro/gtai-masters/n29/yard/frames.json` (best first).
5. `node tools/gate/quick.mjs`; commit evidence. Only if 10+ min remain before {LAST}: `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard_overprint.gd --max=20 --tests=test_prologue_raised_line` (12 min budget), quote killed/(killed+survived).

## Owned files
`evidence/yard29/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/yard/**`, `project/dev/prologue_yard/**`, `project/data/tables/prologue_yard_dressings.json` (temp row only, never committed). Anything else: a NEED in your report.
