# Brief n29-11-sword-run-k: the plasma sword's run step under the 7 cm bar by one run_row_k value (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
`06:04` launched. **Commit by `06:50`** (the pre-commit hook can take 12 min: start `git commit` by 06:38). Evidence commit
by `07:05`. **Report and END by `07:08`**, committed or not. 0 images.

## Why
`evidence/n29-keys/grid_plasma_sword.md` (read whole, esp. "foot_slide (run sheet)" and the run_row_k lines): the sword's own
p70 run8 (`rivet_run8_eq_plasma_sword.png`) has run step mean / max **8.29 / 9.38 cm** at 32 px/m in the legs film turn_090
lane (octant 0), bar **<= 7 cm mean**; the katana donor 7.76 / 9.15, Gloria 6.54, the pistol 6.10. `rivet_motion.json`
`grid_stride.run_row_k` scales a row's run cycle (`RivetWalk` reads `"<art>/<weapon>/<octant>"`, 1.0 if absent;
`project/features/characters/rivet_walk.gd:157`); the sword has only `p70/plasma_sword/1` 0.98 (the own-vs-bare rule: own
travel / bare travel where own < bare). Octant 0 has no entry, so it plays the bare run's cycle against the sword's own legs.

## Steps
1. Measure the sword's own octant-0 travel the way `p70/plasma_sword/1` and `p70/gloria/5` were derived
   (`evidence/n29-keys/grid_plasma_sword.md` line ~58-75 table, `evidence/n29-keys/grid_gloria.md` line ~21; the round STATE
   in `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/`). If the rule gives a k != 1 for octant 0 that the earlier call
   missed, that is the candidate. Otherwise a small sweep: k in {0.94, 0.97, 1.03, 1.06} for `p70/plasma_sword/0`.
2. For each candidate, the legs film + foot_slide exactly as the n29-02c call did it (brief `evidence/briefs/n29-02c-sword-run.md`
   "Evidence"; script `capture28.py` from `C:/Users/kazda/kiro/gtai-art/rivet-n28/*/scripts/`, `tools/film/foot_slide.py`),
   turn_090 row 0 at 32 px/m. **Run all candidates in as few Godot processes as the tool allows** (memory cap). First re-measure
   k = 1 (HEAD) to confirm 8.29 within 0.1; if HEAD does not reproduce, stop and report.
3. Accept the k with the lowest run step mean only if: mean <= 7.0 cm, or mean improves by >= 0.6 cm; run hold max not worse
   than 1.56; the walk numbers unchanged (walk does not read run_row_k: confirm); the run cycle at 32 px/m does not look rushed
   or slow (cycle rate change <= 6 %: state it). If none passes, commit nothing to the table; write the table of results.
4. Pass: add `"p70/plasma_sword/0": <k>` to `rivet_motion.json` `grid_stride.run_row_k` (sorted keys) and the same pin in
   `project/tests/unit/test_rivet_grid_stride.gd` `RUN_ROW_K`; `node tools/tests/run_unit.mjs --changed`; commit
   "keys n29: plasma sword run octant 0 run_row_k <k> (run step <old> -> <new> cm)". Then mutate is not needed (data only).
   Append ONE line to `docs/decisions.md`:
   `- [2026-11-25] DECISION n29 keys plasma sword run: run_row_k p70/plasma_sword/0 <k> (<how derived>); run step mean 8.29 -> <new> cm at 32 px/m (bar 7, katana donor 7.76); rejected: <the other ks with their numbers>.`
5. Check tapes/replays are untouched: run_row_k is animation only; `--changed` must stay green; if any scenario or replay test
   pins it, stop and report.

## Evidence (separate commit)
`evidence/n29-keys/grid_plasma_sword.md`: append "## run_row_k octant 0 (n29-11)" with the sweep table (k, run step mean/max,
run hold mean/max, cycle rate) and the film paths. Stills to `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/` named
`sword_run_k_*`. If time remains after the evidence commit: a 32 px/m 1080p60 clip 15-20 s of the sword sprint with the new k
(`tools/film/` kit, as `evidence/n29-keys/films.md` made `sword/plasma_sword_32.mp4`), `sword/plasma_sword_run_k_32.mp4`.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot is shared with
another builder (collar transplant) through the mutex `build/n29-godot.lock`: before EVERY Godot step (a capture, a test run,
an --import, and every git commit because the pre-commit hook runs Godot) take it with
`(set -o noclobber; echo "swordk $(date +%H:%M)" > build/n29-godot.lock)` (fails while held: re-try every 60 s; older than
25 min = stale, delete it) and `rm build/n29-godot.lock` as soon as that step ends. Windowed runs: `--position 0,1440`.
Fix lint and format findings in your own edit and go on. If the hook fails only on `tools/film/kill_reel_*.break.test.mjs`
or `tools/merge/clash.test.mjs`: `--import`, commit again once. Never skip the hook. No amend, no rebase, no stash,
no `git add -A/./-u`. Python with `-I`.

## Allowlist (anything else: stop and report a NEED)
`project/data/tables/rivet_motion.json` (only `grid_stride.run_row_k`), `project/tests/unit/test_rivet_grid_stride.gd`
(only `RUN_ROW_K`), `docs/decisions.md` (append one line), `evidence/n29-keys/grid_plasma_sword.md`,
`C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/**`, `build/**`.
Forbidden: every art sheet (another builder edits `p55/rivet_run8.png`), code, every other table, the HUD files,
`project/features/souls/**`, `project/features/combat/**`, `project/boot/prologue/**`, cast art, `native/`, `JOURNAL.md`,
`REPORT.md`, other lanes' worktrees. Never delete anything in Temp you did not create.

## Report (short), then END
Sweep table, the k chosen or "none passed", commit shas, what you ran, what you could not do.
