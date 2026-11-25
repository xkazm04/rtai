# Brief n29-03-gloria-walk: Gloria's own p70 walk and run set, ONE ROW PER JOB (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
02:33 launched. **Commit the wired sheets by 03:22 (walk set alone if the run set is not complete).** **Report and END by 03:36**, committed or not; never end
with finished, passing work uncommitted. Keep the round's `STATE.md` current (every step, with the time).

## The owner's pick
"Gloria's own walk and run set": today she walks on the bare stride with the brass gun on the palm
(`rivet_motion.json` `walk_grid.by_weapon.gloria: "bare_claw_p70"`). Build her own p70 walk and run grids by **image edits
of the pistol's p70 sheets, one row per job** (walk rows 1-8, run rows 1-8 = 16 jobs), the brass gun exactly as drawn in
n28 (`p70/rivet_eq_gloria.png`, `_diag`, `_left`; concept `C:/Users/kazda/kiro/gtai-masters/n28/keys/gloria_concept_n28.png`),
held in ONE claw as on those strips, the other claw free. Then flip `walk_grid.by_weapon.gloria` to `"gloria"` (or delete
the row: read the table's `doc` and the code that reads it, `RivetWalk`, and pick the one that loads the new files).
Legs, boots, soles and stride are the pistol's by construction (copy the pistol's `grid_stride` rows for gloria, as n28's
wire step did: `wire_data.py <weapon> <donor> <dir>`).

## Inputs and route (read whole)
- Donor: `project/features/characters/art/view/p70/rivet_walk_eq_pistol.png` (732x1512), `rivet_run8_eq_pistol.png`
  (1552x1568). The files `rivet_walk_eq_gloria.png` / `rivet_run8_eq_gloria.png` there today are the OLD long-gun grids
  (withheld by the bare_claw_p70 row): the new sheets replace them (same names), update their provenance.
- The one-row-per-job route as n28 used it for the molotov's run row 1: `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/`
  (`STATE.md` whole, `jobs_row1.json` = the prompt template, `scripts/`: `prep.py`, `legiou.py`, `stride.py`,
  `finish_tone.py`, `fix_row1.py`, `shift5.py`, `capture28.py`) and the ray gun's bars table
  `evidence/n28-keys/grid_ray_gun.md`. Lessons there: the model can draw a row's soles x-shifted from the donor (the in-game
  foot_slide then fails while sheet metrics pass): measure sole x per cell against the donor and fix by registration or
  donor legs under a seam; a capture does NOT reimport changed pngs, `--import` first.
- The sword round of this run uses the same scripts with the katana as donor:
  `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/` (read its STATE for what worked tonight).
- Image tool `node C:/Users/kazda/kiro/gtai-art/gen.mjs <roundDir> [jobName]`; hand-copy rule (png under
  `~/.codex/generated_images/<new dir>/` after 4-6 min, never copied to `out/`: copy by hand, stop that gen tree by PID).
  Usage-limit answer: stop, `BLOCKED images`. **At most 13 images this call**; count them in STATE.
- Round dir: `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/`.

## Bars per row (as n28)
Dome deviation <= 3 % of the donor dome width; sole y <= 2 px; sole x within 3 px of the donor per cell; leg IoU >= 0.80;
the same leading boot; no extra limb or hand; no pistol remnant (the dark pistol body, a second hand on the gun); the gun
brass (median hue 35-45 deg), no red, no teal; collar a rigid orange-and-black hazard collar, never rope; tone dev <= 2.
In game: foot_slide turn_090 lane at 32 px/m, walk hold <= 2 cm, run step <= 7 cm, beside the pistol's. One retry per
row; a row that fails twice takes the donor's legs under a seam (as `fix_row1.py`) or stays out: **two failed routes on
one row = stop and report it**. Order: walk rows 1-8 first (commit the walk set alone if the run set cannot finish: the
code falls back to the bare run for a sheet without a run8, `RivetWalk.path_of`; check it does for gloria).

## Wiring, checks, commit
`--import`; `rivet_motion.json` gloria rows (cycle cell, walk_profile_travel, by_weapon) and the pins in
`project/tests/unit/test_rivet_grid_stride.gd` (keep the file under 300 lines; 200 is the soft cap); provenance appended
to `steam/ai-provenance/2026-11.jsonl`; `node tools/tests/run_unit.mjs --changed`; `node tools/gate/quick.mjs`; commit
`git add <paths>` + `git commit -m "keys n29: Gloria walks and runs on her own p70 grids (pistol donor)" -- <paths>` incl. the
`.png.import` files. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and
format findings in your own edit and go on. Hook fails only on `tools/film/kill_reel_*.break.test.mjs` /
`tools/merge/clash.test.mjs`: `--import`, commit again once; never skip it (it can take 12 min).
After the code/table commit, if time: `node tools/mutate/mutate.mjs --file=project/features/characters/rivet_walk.gd
--max=10 --lines=<lines you touched> --tests=test_rivet_grid_stride,test_rivet_walk_sprint_fallback` (only if you touched code).

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; only through
`tools/dev/run.mjs`, `tools/godot/check.mjs`, `run_unit.mjs`, the film tools, `tools/lib/godot.mjs`; d3d12; windowed
`--position 0,1440`. **No Godot until the file `build/n29-sword.done` exists** (the sword builder holds the lane one Godot until then); image work needs no Godot. `mem-budget: waiting` = machine full, not a hang.

## Evidence (after the commit, separate commit)
`C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/`: `grid_gloria_64.png` / `_32.png` (stop-gap | new | pistol, 8 facings,
walking 6.75 / sprinting 9.3 m/s, same tick: `capture28.py`), and Gloria walking beside the pistol at 32 and 64 px/m
(`gloria_walk_32.mp4`, 1080p60, 15-40 s, ffprobe it). `evidence/n29-keys/grid_gloria.md` (bars table, foot_slide beside
the pistol's, IMAGES).

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p70/rivet_{walk,run8}_eq_gloria.png(.import)`, `project/data/tables/rivet_motion.json`
(gloria rows only), `project/tests/unit/test_rivet_grid_stride.gd` (gloria pins), `steam/ai-provenance/2026-11.jsonl`
(append), `evidence/n29-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n29/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/**`, `build/**`.
Forbidden: every other weapon's art, the donors (read only), `weapons.json`, `weapon_art.json`, code outside the allowlist,
the HUD files, `project/features/souls/**`, `project/features/combat/**`, `project/boot/prologue/**`, cast art, `native/`,
`JOURNAL.md`, `REPORT.md`, `docs/decisions.md`.

## Report (short), then END
IMAGES n, rows passed / fixed / failed (table), foot_slide beside the pistol's, commit shas, stills/clip paths + ffprobe,
STATE `Next`.

## This call (n29-03c, resumes the prep round; overrides the above where they differ)
- Resume `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/STATE.md` `## Next` 1-5. Walk rows 1-3 PASS and kept
  (`keep/`). Walk row 4 was stopped at 02:23 after 11 min: first look for a late png (a new dir under
  `~/.codex/generated_images` after 02:12 with a 4-cell three-quarter-back-right Rivet + brass gun) before relaunching.
- Order: walk 4-8, then run 1-8. **Two jobs in flight at most** for this builder (the sword builder runs up to two
  more): one job at a time when the tool is congested (any job over 8 min).
- If the walk set (8 rows) passes and `build/n29-sword.done` exists by 03:10: wire and commit the walk set alone
  (check `RivetWalk.path_of` falls back to the bare run for gloria's missing run8, or keep the run on bare: read the code;
  the sword round's `scripts/wire_data_any.py` is the walk-only wirer). Otherwise image work only, rows kept, STATE Next
  exact for the next call.
- Director's look at rows 1-3 (`walk_rows_judge_64.png`): accepted. Row 1's muzzle overhang of 1-4 px at the cell edge:
  bring the gun tip inside the cell in the toned row (shift only the gun pixels by registration, legs untouched) or say it
  stays cut.
- Allowlist adds `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/**` and `gtai-masters/n29/keys/gloria/**`; the
  sword round dir and the sword files are forbidden (another builder). Never delete anything in Temp or `~/.codex` you did
  not create; free only your own processes, by PID.
- Commit each finished part as soon as its checks pass; report and END by 03:36.
