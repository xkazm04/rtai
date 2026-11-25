# Brief n29-08 `impression-props`: the i55 floor impression stops hazing the printed props (lane yard, run n29)

HARD STOP: 04:58 local (report and END). First commit by 04:46. LAST COMMIT started by 04:50. Check `date` often. Never let the call end before its commit.

## Setup
Same as `evidence/briefs/n29-05-hall-finish.md` (Setup, Repo law, Forbidden): APPDATA `C:/Users/kazda/kiro/gtai-n29/appdata/yard`, GODOT_BIN, d3d12, `--position 0,1440`, one Godot at a time: a lane Godot slot shared with the running call prologue-film: before EVERY Godot launch create `build/yard-godot.lock` exclusively (`set -o noclobber; echo "impression-props $$ $(date +%H:%M)" > build/yard-godot.lock`), delete it the moment your Godot process exits; if it exists, poll every 30 s (older than 25 min = stale, delete it). One batch per launch. Commit with `git commit -- <paths>` only.

## The finding (director, 01:44 and 03:37)
Floor i55 (`a880ea994`: `arched_line.ground_impression.tint` ffffff33 -> ffffff8c) lays a brown haze over everything the WORLD pass prints under it: at 32 px/m the stains, tyre marks, yellow bay lines, the forklift, the skip, the crate and the south fence and gate lose contrast (`evidence/yard29/floor_i20_vs_i55_mid_32ppm.png`, `evidence/yard29/belt_snake_mid_32ppm.png`). The impression is drawn by `project/boot/prologue/prologue_yard_overprint.gd` `_draw_pieces` FIRST on the over-print layer, then the `over_print` ids (debris and wrecks named in the row) on top in their own colours. Its rect: origin [-1, -1.1], size [62, 35.1] (ends y 34).

## Work, in order
1. Read `prologue_yard_overprint.gd`, `prologue_yard_dressing.gd`, the `arched_line` row, and the stage layout (`prologue_stage.json`, the layout the row names) to list which hazed pieces are debris/wrecks the `over_print` list can name (forklift, skip, crate, ...), and where the south fence and gate sit (y).
2. Data fix first: (a) add those cover/debris ids to `arched_line.over_print` (they then draw over the impression in their own colours; check they were not already printed in their own colours elsewhere = no double draw: look at a 64 px/m crop); (b) if the fence/gate are inside the rect, end the rect north of them (`size` y), and if that leaves a visible seam, say so and pick the less visible of the two. Ground decals (stains, tyre marks, bay lines) are printed in the world pass: if a data-only route keeps them, take it; else write a one-line finding (no code change for them in this call unless it is 1-3 lines in `project/boot/prologue/**` with a unit pin).
3. Unit pin in `project/tests/unit/test_prologue_raised_line.gd` (or the test that pins the row) for what you change. `node tools/tests/run_unit.mjs --changed`.
4. Pilots seeds 7, 3, 11, 21, 42 identical to the last pilots file in `evidence/yard29/` (one Godot process; over-print is visual, expected identical).
5. Stills at the same tick (LOOK at each): `evidence/yard29/impression_props_before_after_mid_32ppm.png` (HEAD before your change | after), same for the gate camera `..._gate_32ppm.png`, and a 64 px/m crop of the forklift or skip. Before = a temp row, never committed. Measure the prop contrast: mean |prop - floor around it| luminance for 3 props, before and after, in `evidence/yard29/impression_props.md`. Bar: each prop's contrast back within 10 % of its i20 (c649a15d6) value, or say where it lands.
6. Film 20 s before|after mid yard to `C:/Users/kazda/kiro/gtai-masters/n29/yard/impression_props_before_after_32ppm.mp4` (method `evidence/yard29/film.sh`; 1920x1080 60 fps h264 yuv420p; ffprobe), append to `frames.json` there.
7. ONE `docs/decisions.md` line (append only): what moved to over_print / the rect end, why.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/data/tables/prologue_yard_dressings.json` (`arched_line` `over_print` and `ground_impression` only; a temp row while rendering), `project/boot/prologue/**` (1-3 lines only, see 2), `project/tests/unit/test_prologue_*`, `project/dev/prologue_yard/**`, `evidence/yard29/**`, `build/**`, `docs/decisions.md` (one appended line), `C:/Users/kazda/kiro/gtai-masters/n29/yard/**`.

## Report (final message, then END)
Commit shas; the ids moved; the rect; the contrast table; pilots vs expected; what you saw in each still; ffprobe; what was not done.

## Session 3 short call (director, 04:30): ~25 minutes
Do steps 1, 2 and 3 only (read, the data fix, the unit pin; `node tools/tests/run_unit.mjs --select=test_prologue_raised_line` instead of --changed), plus ONE after still at the mid camera (`evidence/yard29/impression_props_after_mid_32ppm.png`, LOOK at it). Commit the table + test by 04:46 (`git commit -- <paths>`; the pre-commit hook takes up to 12 min: start it by 04:46). If the data route cannot be found by 04:42, commit nothing to project/ and write the findings (ids, fence y, what draws where) into `evidence/yard29/impression_props.md` and commit that. Steps 4 to 7 are the next session's. prologue-film is running beside you: it owns `evidence/yard29/plate_*`, `plate_judgement.md` and the masters folder; never touch those, and never touch `project/dev/prologue_yard/yard_dusk_capture.gd` / `yard_stills.gd` if they show as modified.
