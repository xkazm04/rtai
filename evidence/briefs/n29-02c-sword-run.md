# Brief n29-02c-sword-run: plasma sword RUN sheet rows 4-8, wire, commit, evidence (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
Launched 02:33. **Start the wired run-sheet commit by 03:12** (the hook can take 12-15 min: do not wrap it in a shell
timeout under 20 min). **Report and END by 03:32**, whatever the state. Commit each finished part as soon as its checks
pass. Never end with finished, passing work uncommitted. Keep `STATE.md` current (each step, with the time).

## Where it stands (read first, whole)
`C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/STATE.md`: follow its last `Next (run sheet, next call)` list 1-5
exactly. Walk sheet shipped `3dbef1803`, evidence `2bd8769a5` (`evidence/n29-keys/grid_plasma_sword.md`). Run rows 1, 2, 3
kept (`cand_edit_run_row{1_c,2,3}_h`). Run 4 failed try 1 (wrong facing: retry `edit_run_row4_b` with an explicit facing
line). Run 5 was launched 02:12 and not back by 02:23: FIRST look for a late png under `~/.codex/generated_images` newer
than `mark_r5.txt` (skip `others.txt` dirs; content = a running Rivet row with an amber blade) before relaunching.
Rows 6-8 not started; if the blade tip reaches the cell edge, use the shorter-blade line of `edit_walk_row{6,7,8}_b`.
Two jobs in flight at most; the lane's other builder (Gloria) runs its own. Director's look at run rows 1-3: crisp,
crossguard, flat collar: keep that quality.

## Bars per row (unchanged)
dome <= 3 %, sole y <= 2 px, sole x within 3 px of the donor per cell, leg IoU >= 0.80, same lead, tone post <= 2; eye
check 4x crop: collar a flat rigid striped ring (never cloth), no katana remnant, no extra hand, blade amber as the strip,
no red element, no teal, blade tip inside the cell. One retry per row; a row that fails twice takes the katana's legs
under a seam (fix_row1.py style); if the arms/blade fail twice: stop that row and report (two failed routes = stop).
**At most 10 images this call** (count in STATE). Usage-limit answer: stop, `BLOCKED images`.

## Godot
This builder holds the lane's one Godot this call. `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; only through repo
tools (`run_unit.mjs`, `tools/godot/check.mjs`, `tools/dev/run.mjs`, `capture28.py` which goes through them); d3d12;
windowed `--position 0,1440`. `mem-budget: waiting` = machine full, not a hang. Run one `--import` before the commit
(new png). **When you are done with Godot for good (or at END), create the file `build/n29-sword.done`**: the Gloria
builder waits for it before its own Godot use. Free only your own processes, by PID.

## Wiring + commit (STATE Next 3-4)
Assemble, `stride.py`, `wire_data_any.py plasma_sword katana final` (wires run), then `rivet_motion.json`
`walk_grid.by_weapon.plasma_sword: "plasma_sword"` (only with the run sheet complete), RUN_ROW_K pins in
`test_rivet_grid_stride.gd` (keep <= 200 lines by trimming as STATE says), `prov.py run8`, `--import`,
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs --files=<your files>` (quick's Godot parse check
failing on untouched `cut_rig.gd` / `test_rivet_windup.gd` is known environmental: then use `--no-godot` and say so),
`git add <paths>` + `git commit -m "keys n29: plasma sword runs on its own p70 grid (katana donor)" -- <paths>` incl.
`.png.import`. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and format
findings in your own edit and go on. Hook failing only on `tools/film/kill_reel_*.break.test.mjs` /
`tools/merge/clash.test.mjs`: `--import`, commit again once; never skip it.
If the run sheet cannot be complete by 03:05: do not wire it; leave the kept rows + exact STATE Next, report.

## Evidence (after the commit, separate commit, only if before 03:24)
STATE Next 5: `capture28.py plasma_sword` rows (masters `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/`), foot_slide
turn_090 row 0 at 32 px/m: walk hold <= 2 cm (was 1.00/1.56), **run step <= 7 cm** beside the katana's 7.76/9.15 (say
plainly if the sword misses the bar and by how much), `grid_plasma_sword_64.png` / `_32.png` (stop-gap | new | katana, 8
facings), append to `evidence/n29-keys/grid_plasma_sword.md`, commit it alone: "keys n29: plasma sword run grid evidence".

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p70/rivet_run8_eq_plasma_sword.png(.import)`, `project/data/tables/rivet_motion.json`
(plasma_sword rows only), `project/tests/unit/test_rivet_grid_stride.gd` (its pins / the trim), `steam/ai-provenance/2026-11.jsonl`
(append), `evidence/n29-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/**`,
`C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/**`, `build/**`.
Forbidden: the Gloria round dir and gloria files (another builder), the sword's held/equipped strips and effect art (hilt
rings = combat's), the donors (read only), other weapons' art, `weapons.json`, `weapon_art.json`, code, the HUD files,
`project/features/souls/**`, `project/features/combat/**`, `project/boot/prologue/**`, cast art, `native/`, `JOURNAL.md`,
`REPORT.md`, `docs/decisions.md`. Never delete anything in Temp or `~/.codex` you did not create.

## Report (short), then END
IMAGES n, run rows table (bars, retries, donor legs where), commit shas, foot_slide walk + run beside the katana, still
paths, STATE `Next`, whether `build/n29-sword.done` exists.
