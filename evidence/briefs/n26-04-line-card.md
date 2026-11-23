# Brief n26-04 `line-card`: one torn line instead of six rails, dusk on the ground, cover mutate (lane yard, run n26)

HARD STOP: 16:25 local (stop work, report). LAST COMMIT: 16:20. Check `date` now and then.

## Before anything
- `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` in every shell that runs Godot. One Godot at a time; windowed runs `--position 0,1440`; kill only PIDs you started.
- `git log --oneline -20`: the `line_fire` row, its layout, dusk, fence and pump work are yours (calls 01-03). Run one `"$GODOT_BIN" --headless --path project --import` first.

## Part A: (none) Mulroney's card wiring stays with the Director
The cast branch is NOT merged here (its merge commit trips a tool test outside our files), so `FoeCastView` and `CastCards` do not exist on this branch. Leave `prologue_command_view.gd` `_process` as call 03 shaped it. Do not add stubs for them.

## Part B: the torn line reads as ONE line (the plate's S), not six rails
At 32 px/m (`evidence/yard26/dusk_t6000_32ppm.png`) the conveyor in `line_fire.layout.cover` reads as six separate horizontal rails stepped like a staircase. The plate (`C:\Users\kazda\kiro\gtai-art\factory-n25\out\a-torn-line.png`) has one continuous rail snaking from the burst doors across the yard, with hooks, hanging drums and fallen appliances along it.
1. Keep every cover rect where it is (collision, the gaps of >= 2.5 m and the pilot stay as they are: the gaps must stay walkable and shootable through).
2. Join the sections visually with NON-blocking pieces in `line_fire.layout.debris` (or a new non-colliding list in the row, schema updated): in each gap, a torn belt end and a few loose rollers on the floor running along the line's direction (cut from `C:\Users\kazda\kiro\gtai-art\factory-n26\out\conveyor-run.png`: it has bent and torn sections and loose parts; extend `tools/art/prologue_yard_cut.py`'s spec), so the eye follows one line through the gaps. Where a section turns (`conveyor_turn`, `conveyor_bend`), use the bent piece so the line curves rather than steps; you may add a short non-colliding overhang drawn past a rect's end by up to 0.6 m if it makes the turn read, as long as the gap left between drawn pieces stays >= 2.5 m on screen.
3. Hanging and fallen appliances along the line: 3-5 small pieces (a drum on a hook, a washer on its side, a fridge door) on or beside the sections, from `conveyor-run.png` / `yard-props.png`; on-cover pieces are drawn on the section (no new collision), floor pieces are debris.
4. Stills: `evidence/yard26/line_join_32ppm.png` (before = HEAD before this part, after, same tick 6000, same camera, side by side) and `line_join_64ppm.png` (one gap close up). Seed-7 pilot result byte-identical (render only). One commit.

## Part C: the dusk, done on the ground instead of the whole screen (do this BEFORE Part D)
Call 03 stopped the screen-wide grade at `paper_level` 0.84 because the patrol blue loses contrast as the WHOLE frame darkens (65.8 % at 0.83). At 32 px/m the yard (`evidence/yard26/dusk_t6000_32ppm.png`) still reads as warm daylight, far from the plate's dusk going on night. The plate's way: a dark ground and dark wrecks, with the figures lit.
1. In `project/boot/prologue/**` only (the core `LightLayer` is not ours: do not edit `project/core/**`), add a ground shade for the `line_fire` row: a darker modulate on the yard floor, the street/pavement, the scenery and cover sprites, the hall front and the fence, NOT on fighters, rounds, pickups, markers, the HUD or the fire/lamp pools (pools stay additive above the shade so they read as light on a dark floor). One value in the row, e.g. `"ground_shade": 0.62` (schema updated; absent = 1.0, so `plain`/`torn_line` are unchanged byte for byte).
2. Step it (0.80, 0.70, 0.62, 0.55, 0.48) with the screen grade at 0.84 or back towards 0.92 (try both), and re-run your contrast sampler (`evidence/yard26/dusk_contrast.py`): patrol blue, rifle round and pellet each keep >= 2/3 of their day contrast (a figure lighter than a dark floor counts by absolute contrast). Pick the darkest step that holds; say the numbers for each step.
3. Re-take `dusk_t2858_32ppm.png`, `dusk_t6000_32ppm.png`, `dusk_front_64ppm.png`, `dusk_gate_64ppm.png`, and add `dusk_shade_steps_32ppm.png` (the steps side by side, same tick). Render only: seed-7 pilot result byte-identical. Decisions line. One commit.

## Part D: cover mutate (unmeasured since call 01)
`node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard.gd --max=20` (or the file that builds `line_fire.layout.cover` if that is another one: name it). Kill survivors that are real faults with a test; quote killed/(killed+survived) before and after. One commit if tests were added.

## Owned files (allowlist). Any other path: stop and write the NEED in your final report.
- `project/boot/prologue/**`, `project/data/tables/prologue_yard_dressings.json`, `prologue_stage.json`, their schemas
- `project/dev/prologue/**`, `project/dev/prologue_yard/**`, `tools/art/prologue_yard_*.py` and their tests
- `project/tests/unit/test_prologue_*.gd`, `project/tests/scenarios/scenario_prologue_*.gd`
- `evidence/yard26/**`, `steam/ai-provenance/2026-11.jsonl` (append only), `tools/debt/baseline.json` (only through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n26 yard"`), `docs/decisions.md` (append only)
- `.uid` / `.import` of new files (run one `--import` after adding art, before committing).

## Forbidden
`project/features/**` (incl. cast art), `project/core/**`, `lights.json`, `palette.json`, `input_actions.json`, `combat.json`, `enemies.json`, `weapons.json`, `ghost_*.json`, `cast_cards.json`, `native/**`, quest 1 files and tapes, other worktrees. No balance, timing or collision change.

## Repo law
Typed GDScript, files <= 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Stage per path; one commit per change; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. `node tools/gate/quick.mjs` before each commit. Mutate `--max=20` on changed lines.

## Report (final message)
Commits, pieces cut and placed, gap widths on screen, pilot cmp, mutate scores (before/after), NEEDs, what was not done.
