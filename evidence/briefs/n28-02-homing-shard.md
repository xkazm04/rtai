# Brief n28-02-homing-shard: the homing shard's own p70 walk and run grids, by image edit of the plasma rifle's sheets (the TEST)

Lane `keys`, branch `n28-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Check `date` first and often. Commit each finished part within 25 minutes of it passing. Commit the grids by 18:35.
Report and END by 18:52 at the latest, whatever state you are in** (the pre-commit hook takes about 12 minutes on this
shared machine). Small commits, staged per path, `git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`,
no `commit -a`, no `reset --hard`, never push. Fix lint and format findings in your own edit and go on. mutate: `--max=20`,
changed lines only, with a `--tests=` subset and a 10-minute budget.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
`--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display). One Godot process at a time in this
lane; free your own by PID, never by name. Never launch Godot raw: go through `tools/dev/run.mjs`, the test runners, the
film tools or `tools/lib/godot.mjs` (8 GB RAM cap for the whole run; `mem-budget: waiting` = machine full, not a hang).
After new pngs land, a Godot `--import` before the commit (commit the `.import` files). If the pre-commit hook fails on
`tools/film/kill_reel_*.break.test.mjs`: stale class cache, `--import` and commit again.

## Why
Owner (last `DECISION n27 verdicts (owner)` line of `docs/decisions.md`): the five weapons still on stop-gap legs (homing
shard, mini-nuke, molotov, plasma sword, ray gun) get their own walk and run **by image edits of the plasma rifle's walk and
run sheets, one first as a test**. Today they walk on the bare-claw stride with the held part on the palm
(`rivet_motion.json` `walk_grid.borrowed_grid`). You do the test weapon, the homing shard, at tilt 70 (p70) only. p55 keeps
the stop-gap (no p55 work).

## Part 0 first (15 minutes at most, then go on whatever its state): the dash checks the last call could not run
The last call (`64004a59d`, dash cooldown 40 -> 24) could not run Godot: every launch sat in `mem-budget: waiting` (the run's
8 GB cap was full). Read `evidence/n28-keys/dash.md`. Run, in this order, each only if the budget lets Godot start within
5 minutes: `node tools/tests/run_unit.mjs --select=test_pressure_takes,test_bot_dash,test_player_motion_dash`; then the
`pressure_dash_trace` command in `dash.md` (after column). Fill the "after" column of `dash.md`, append the result, commit it
(`git commit -- evidence/n28-keys/dash.md <trace file>`). A failing test that pins the old cooldown: fix it in the same commit
and say so. If Godot cannot start, write `FRICTION mem-budget <minutes>` in your report and go on to the test below (image
generation does not need Godot).

## What exists (read before you start; reuse, do not rebuild)
- The electro gun got its own p70 grids last run from per-row edits with the plasma rifle as donor: round
  `C:/Users/kazda/kiro/gtai-art/library/rounds/20261123-1559-n26keys/` (`STATE.md`, `pipeline.py`, `cut_rows.py`,
  `build_candidate.py <weapon> plasma_rifle vN`, `match_row_scale.py`, `finish_tone.py`, `packed_look.py`, `wire_data.py`,
  `stride.py`, `capture27.py`, `proofs27.py`, `provenance27.py`; its `STATE.md` "Next" names the homing shard exactly this
  way). Write-up: `evidence/n27-keys/grid_electro_gun.md` (per-facing stride table, foot_slide, stills). The packed sheets
  are `project/features/characters/art/view/p70/rivet_walk_eq_plasma_rifle.png` (4 columns x 8 facing rows) and
  `rivet_run8_eq_plasma_rifle.png` (8 x 8). The homing shard's equipped strips: `p70/rivet_eq_homing_shard.png`
  (+ `_left`, `_diag`, `_noflash`).
- `C:/Users/kazda/kiro/gtai-art/gen.mjs <roundDir>` (jobs.json: style, jobs[{name, refs, prompt}]; images come out
  landscape; known fault: a job can stall copying to `./out` after the image already exists under
  `~/.codex/generated_images/`: copy it by hand and log it). Image 1 = the donor, image 2 = the weapon as Rivet holds it.

## The test: is a sheet-sized edit good enough? (images: at most 10 in this call; count them, report `IMAGES n`)
The per-row route cost 16 images a weapon (80 for five; the lane's cap is 60). Test the cheaper one:
1. Round `C:/Users/kazda/kiro/gtai-art/rivet-n28/homing_shard/` with a `STATE.md` updated after every step (resumable:
   a later call must be able to continue from the file alone).
2. **Edit A (2 images)**: the plasma rifle walk sheet and run sheet, each laid out landscape on a flat key background with
   clear gutters (e.g. walk rows 0-3 left, 4-7 right), as image 1; the homing shard equipped strip as image 2. Prompt:
   the same Rivet, the same legs, stride, pose and frame in every cell; only the plasma rifle swapped for the homing shard
   held exactly as in image 2; the collar a rigid orange-and-black hazard collar (flat band, straight stripes, never rope or
   cloth); nothing else changes; no red and no teal on the weapon.
3. Cut, register each cell to the donor cell (by dome/helmet and sole line), then build two candidates per row: **raw**
   (the edited cell) and **legs-kept** (the donor's pixels below the hip line, the edit's above, a feathered seam). Pick
   per row; legs-kept is preferred when its seam is clean, because then the sole travel IS the donor's.
4. Rows that fail the bars below: re-edit with 4-row or single-row edits from the remaining images. Stop at 10.

## Bars, per facing row, against the plasma rifle row of the same facing (prove with a script; table in the evidence md)
- dome width within 3 %, sole line y within 2 px (110 px space), the same leading boot per column, no extra limb or hand;
- the homing shard in the hand(s) as on its equipped strip in that facing; no plasma rifle remnant (barrel, cyan glow);
- the collar rigid (flat band, straight stripes) in every cell; colour law: no red and no teal on the weapon;
- in the game at 32 px/m, 6.75 and 9.3 m/s, `tools/film/foot_slide.py` on the profile rows: walk mean <= 2 cm, run mean
  <= 7 cm (quote the plasma rifle's numbers beside them);
- tone: each row's opaque RGB mean within 2 per channel of the equipped strip (the round's `finish_tone.py`).
**Ship only if all 16 rows pass.** Otherwise leave the homing shard on the stop-gap, commit nothing under `project/`, and
report per row what failed and which edit route came closest (the round and STATE.md are the deliverable then).

## Wire it (only when all 16 rows pass)
Exactly as the electro gun was wired (`wire_data.py`): the pngs `p70/rivet_walk_eq_homing_shard.png` /
`p70/rivet_run8_eq_homing_shard.png`, the stride data rows (`rivet_motion.json` `grid_stride` and whatever else the electro
gun added; copy the plasma rifle's rows where legs-kept was used), the test pins, `--import`, provenance lines appended to
`steam/ai-provenance/2026-11.jsonl` (`provenance27.py` pattern), `node tools/tests/run_unit.mjs --changed`,
`node tools/gate/quick.mjs`, commit: "Homing shard walks and runs on its own p70 grids, edited from the plasma rifle's".

## Evidence (after the commit; commit it separately)
- `C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_homing_shard_64.png` and `_32.png`: per facing, walking 6.75 and
  sprinting 9.3 m/s, same tick: stop-gap (render it from a temp worktree at your start sha: `git worktree add
  build/wt-before-hs <sha>`, `git worktree remove` afterwards; never `git checkout <old> -- <paths>` here) | new homing
  shard | plasma rifle. A 15-25 s 32 px/m tilt-70 1080p60 clip walking and sprinting in 8 directions
  `grid_homing_shard_32.mp4` (ffprobe: 1920x1080, 60 fps; duration in your report).
- `C:/Users/kazda/kiro/gtai-masters/n28/keys/frames.json` (create or append; entries `{file, title, ppm, before, note}`).
- `evidence/n28-keys/grid_homing_shard.md`: the route, images per route, the per-row table, foot_slide numbers, and your
  recommendation for the next four weapons (which edit route, images each, what to change in the prompt).
- Delete scratch renders the md and frames.json do not reference (only your own files).

## Allowlist (anything else: stop and report a NEED line)
`project/features/characters/art/view/p70/rivet_walk_eq_homing_shard*`, `rivet_run8_eq_homing_shard*`,
`project/data/tables/rivet_motion.json` (homing shard rows only), the tests that pin grid stride rows (homing shard only),
the grid loader only if the electro gun wiring shows a homing-shard-specific need, `steam/ai-provenance/2026-11.jsonl`
(append), `evidence/n28-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n28/**`, `C:/Users/kazda/kiro/gtai-masters/n28/keys/**`,
`build/**`.
Forbidden: every other weapon's art, the plasma rifle's art (read only), `weapons.json`, `weapon_art.json` (if a homing
shard row must change, report why first), `project/features/combat/**`, `project/dev/gauntlet/**`,
`project/boot/prologue/**`, `ghost_*.json`, `combat.json`, `enemies.json`, `native/`, other lanes' worktrees, `main`.

## Report (final message)
`IMAGES n`, the route, rows passed per route, the per-row table, foot_slide beside the plasma rifle's, commit shas,
stills/clip + ffprobe line, what `STATE.md` says is next, and your recommendation for the next four.
