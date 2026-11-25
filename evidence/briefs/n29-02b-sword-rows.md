# Brief n29-02b-sword-rows: plasma sword rows 2-8, wire, commit (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
Launched about 01:30. **The wired sheets committed by 02:12** (start the commit by then: the hook can take 12 min).
**Report and END by 02:28**, whatever the state. Never end with finished, passing work uncommitted. If rows are missing
at 01:58, wire what you have only if the sheet is complete; otherwise stop generating, leave the round resumable, report.

## Where it stands (read first, whole)
`C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/STATE.md` (round, scripts, hand-copy rule, the `Next` list you
follow) and `evidence/n29-keys/sword_row1.md` (bars table). Row 1 (walk + run) passed its bars; the director judged the
crops `gtai-masters/n29/keys/sword/row1_judge_64.png` / `_close.png`:
- **Walk row 1: accepted** (one claw, straight amber blade, flat collar, legs as donor).
- **Run row 1: redo at a larger scale.** It was laid out at s0.64 and reads soft at 64 px/m (rivets lost, no
  crossguard, collar stripes still twist on cells 2, 3, 8). For **every run row incl. row 1**, lay the 8 cells out at the
  largest scale that fits the image frame, **at least 0.90** (8 x 194 x 0.95 = 1474 px fits a 1536 frame); if a full row
  at >= 0.90 will not fit, split it into two jobs of 4 cells at 1.0. Walk rows stay as row 1 did (s1.0).
- Use the run-retry prompt (`edit_run_row1_b`) for every row, the facing named per row; add: "the hilt has a small straight
  crossguard as in image two; the neck band is a flat rigid ring with straight stripes, no twist".

## Jobs and images
Rows walk 2-8 (7) + run 1-8 (8, or 16 halves) = 15 to 23 jobs; **at most 26 images this call**. Run two jobs in parallel
(each alone in its own gen.mjs, `Start-Process -PassThru` or `nohup ... &` with the PID noted), hand-copy each png, stop
each tree by PID (never by name). Leave other lanes' pngs in `~/.codex/generated_images` alone. A usage-limit answer:
stop, `BLOCKED images`. Per row: `prep_row.py` bars (dome <= 3 %, sole y <= 2 px, sole x within 3 px of the donor per
cell, leg IoU >= 0.80, same lead, tone post <= 2) + an eye check of a 4x crop (collar flat, no katana remnant, no extra
hand, blade amber as the strip, no red, no teal). One retry per row; a row that fails twice takes the donor's legs under a
seam (`fix_row1.py`-style) or, if the arms fail, the call stops and reports (two failed routes = stop).

## Wiring (needs Godot)
**Godot: do not launch any Godot until the file `build/n29-hud.done` exists** (another builder in this lane holds the
lane's one Godot until then; the director creates the file). Then: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; only through repo
tools (`tools/lib/godot.mjs` `runGodot`, `run_unit.mjs`, `tools/godot/check.mjs`, `tools/dev/run.mjs`, the capture
scripts that go through them); d3d12; windowed `--position 0,1440`; `mem-budget: waiting` = machine full, not a hang.
Steps as STATE `Next` 5-6: assemble the full sheets (848x1480, 1552x1560), `wire_data.py plasma_sword katana <final>`,
`rivet_motion.json` (by_weapon plasma_sword -> its own grid, the cycle cell from katana 66, travel), pins in
`test_rivet_grid_stride.gd` (<= 200 lines), provenance lines appended to `steam/ai-provenance/2026-11.jsonl`, `--import`,
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, then commit:
`git add <paths>` + `git commit -m "keys n29: plasma sword walks and runs on its own p70 grids (katana donor)" -- <paths>`
incl. `.png.import`. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and
format findings in your own edit and go on. Hook fails only on `tools/film/kill_reel_*.break.test.mjs` /
`tools/merge/clash.test.mjs`: `--import`, commit again once; never skip it.

## Evidence (after the commit, only if before 02:24; else leave the exact commands in STATE)
`capture28.py plasma_sword rows + candidate` (masters dir `n29/keys/sword/`), foot_slide turn_090 lane row 0 at 32 px/m
(walk hold <= 2 cm, run step <= 7 cm, katana beside), `grid_plasma_sword_64.png` / `_32.png` (stop-gap | new | katana),
`evidence/n29-keys/grid_plasma_sword.md`; commit the md separately.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p70/rivet_{walk,run8}_eq_plasma_sword.png(.import)`, `project/data/tables/rivet_motion.json`
(plasma_sword rows only), `project/tests/unit/test_rivet_grid_stride.gd` (its pins), `steam/ai-provenance/2026-11.jsonl`
(append), `evidence/n29-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n29/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/**`, `build/**`.
Forbidden: the sword's held/equipped strips and effect art (the hilt rings are combat's this run), the donors (read
only), every other weapon's art, `weapons.json`, `weapon_art.json`, code, the HUD files, `project/features/souls/**`,
`project/features/combat/**`, `project/boot/prologue/**`, cast art, `native/`, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`.

## Report (short), then END
IMAGES n, rows table (bars, retries, donor legs used where), commit shas, foot_slide beside the katana, stills, STATE `Next`.
