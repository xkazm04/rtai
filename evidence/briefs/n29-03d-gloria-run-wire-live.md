# Brief n29-03d-gloria-run-wire: Gloria's run rows 2-8, then wire walk (+ run) and commit (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
Base brief: `evidence/briefs/n29-03-gloria-walk.md` (owner's pick, bars, wiring, evidence, allowlist: all hold).
This brief overrides it where they differ.

## Wall clock (run `date +%H:%M` first and often)
`03:48` launched. **Walk-set commit by `04:13` whatever the run rows' state.** Run-set commit by `04:33`.
**Report and END by `04:48`.** Commit each finished part as soon as its checks pass. Keep `STATE.md` current.

## Where it stands
`C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/STATE.md` (read whole, follow `## Next`). Walk rows 1-8 PASS,
assembled `final/rivet_walk_eq_gloria.png` (732x1512) + `final/travel.json`; director looked at
`gtai-masters/n29/keys/gloria/walk_rows_judge_64.png`: accepted. Run row 1 kept; run row 2 failed in cell 8 only (fix by
height-fit / donor-legs seam in that cell, or its one retry); rows 3-8 not made (rows 5-8 with the short-gun wording).

## Order
1. **Wire and commit the walk set first** (needs Godot: Godot is shared with the molotov-rag builder through a mutex: before EVERY Godot step (an --import, a run_unit run, a capture, a film, and every git commit because the pre-commit hook runs Godot) take the lock with `(set -o noclobber; echo "gloria $(date +%H:%M)" > build/n29-godot.lock)` (it fails while the other builder holds it: re-try every 60 s; a lock older than 25 min is stale, delete it), and `rm build/n29-godot.lock` as soon as that step ends. Never hold it while image jobs run. When you END, delete the lock if it is yours and create `build/n29-gloria2.done`), the walk-only route the last call found in
   the code: delete `walk_grid.by_weapon.gloria` (her grip one_hand -> family pistol -> bare fallback for the run),
   `git rm` the OLD long-gun `p70/rivet_run8_eq_gloria.png` + `.import` in the same commit (else her sprint shows the old
   long gun) **only if no code/test/table outside your allowlist names that file** (grep first; else NEED), drop the
   `run_row_k p70/gloria/{0,3,4}` entries and their pins in `test_rivet_grid_stride.gd`, rewrite
   `project/tests/unit/test_rivet_walk_held_only.gd`'s gloria pins to the new truth (allowed this call), wire the walk with
   `wire_data_any.py gloria pistol final` (the sword round's walk-only wirer), provenance, `--import`,
   `node tools/tests/run_unit.mjs --changed` + `--select=test_rivet_walk_every_weapon,test_rivet_walk_held_only,test_rivet_grid_stride,test_rivet_walk_sprint_fallback`,
   `node tools/gate/quick.mjs --files=<yours>` (`--no-godot` if its parse check fails on untouched `cut_rig.gd` etc.:
   known, say so), commit "keys n29: Gloria walks on her own p70 grid (pistol donor)".
2. Run rows 2-8 by image edits (two jobs in flight at most, run_in_background launches; at most 12 images).
3. When all 8 run rows pass: assemble run8, wire (run_row_k where own < bare), add back a `by_weapon` row only if the code
   needs it (read `RivetWalk.path_of`), pins, provenance, `--import`, tests as above, commit
   "keys n29: Gloria runs on her own p70 grid (pistol donor)".
4. Evidence (separate commit): `capture28.py` gloria rows (set weapon gloria, donor/family pistol), foot_slide turn_090
   at 32 px/m (walk hold <= 2 cm, run step <= 7 cm) beside the pistol's, `grid_gloria_64.png` / `_32.png`
   (stop-gap | new | pistol), a 1080p60 15-40 s clip of Gloria walking then sprinting at 32 px/m tilt 70
   (`gloria_walk_32.mp4`, ffprobe it) in `C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/`,
   `evidence/n29-keys/grid_gloria.md` (bars table of all rows, foot_slide, IMAGES).

## Allowlist additions
`project/tests/unit/test_rivet_walk_held_only.gd` (gloria pins only); `git rm` of `p70/rivet_run8_eq_gloria.png(.import)`
as above. Everything else as the base brief. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`,
`reset --hard`. Fix lint and format findings in your own edit and go on. Free only your own processes, by PID; never
delete anything in Temp or `~/.codex` you did not create.

## Report (short), then END
IMAGES n, run rows table, commit shas, foot_slide walk + run beside the pistol, stills/clip + ffprobe, STATE `Next`.
