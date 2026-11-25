# Brief n29-04d-collar-row8: the p55 sprint collar, row 8 only (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
Base brief `evidence/briefs/n29-04c-collar-rows-live.md` (method, bars, commit law, allowlist: all hold). Resume
`C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/STATE.md` (read whole; the jobs, `scripts/comp_row.py`, `scripts/pair.py`).

## Wall clock (run `date +%H:%M` first and often)
`04:58` launched. **Commit by `05:38`.** **Report and END by `05:52`**, committed or not.

## The job
Row 8 of `project/features/characters/art/view/p55/rivet_run8.png` has never been tried: `node C:/Users/kazda/kiro/gtai-art/gen.mjs . row8`
in the round dir (prompt in `jobs.json`, base sheet = the committed sheet with row 4 fixed). At most **2 images** (one try +
one retry; the lane is at its cap after that). Hand-copy rule: the png lands under `~/.codex/generated_images/<new dir>/` after
4-10 min and may never reach `out/`: copy it by hand, stop only that job's tree by PID. A usage-limit answer: `BLOCKED images`.
Composite neck-only with `comp_row.py`, prove 0 changed px outside the masks, judge on a 4x nearest crop (shipped above, new
below) against rows 1, 2, 4, 5: one stiff flat ring, straight vermilion/black diagonal stripes, no twist, no teal, no yellow.
Pass: install, `--import`, provenance, commit "keys n29: Rivet's p55 sprint row 8 wears the rigid hazard collar";
stills `C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/collar_p55_row8_neck_3x.png`; a line in `evidence/n29-keys/collar_p55.md`.
Fail twice: keep shipped, save the reject crop as `collar_p55_row8_rejected_3x.png`, commit the evidence line only.
Rows 3, 6, 7: no more image calls (two routes failed).

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot is shared with the films builder through the mutex `build/n29-godot.lock`: before EVERY Godot step (an --import, a run_unit run, a capture, and every git commit because the pre-commit hook runs Godot) take it with `(set -o noclobber; echo "collar8 $(date +%H:%M)" > build/n29-godot.lock)` (fails while held: re-try every 60 s; older than 25 min = stale, delete it) and `rm build/n29-godot.lock` as soon as that step ends; never hold it during image jobs. On END delete it if yours and create `build/n29-collar8.done`. The films builder makes the collar row 4 in-game before|after: you do not.
