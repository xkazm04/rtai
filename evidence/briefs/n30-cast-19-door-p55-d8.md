# n30-cast-19: door carrier eight, p55 drawing 8 (tag `c19`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `evidence/briefs/n30-cast-16-door-p55.md` (method, commit rules,
allowlist: all of it applies), `docs/art/cast-audit.md` "## Door eight, p55 round, n30" and "## Door eight, p55 round 2, n30",
and `C:\Users\kazda\kiro\gtai-art\foes-n30\door8e\STATE.md` (c17's log and probe findings).
Launch time T. Images done by T+25. First commit by T+40. Hard stop T+55 and no later than 17:12 (report and END).

## Where it stands (after `6ee306fd8`)
p70 right 1.96 / 6.61 PASS, p70 down-right 1.39 / 12.00 PASS (at the jump bar), p55 right 2.05 / 6.98, p55 down-right
2.08 / 11.78 (bars sole <= 2, jump <= 12). c17's probe (`build/look/n30-c17/probe_all.py`, per-hold drift): the remaining
p55 slide is the drift in the hold just before drawing 8 (right: the D8 hold -2.04; down-right: the late D7 hold -1.97).
The only one-cell fix left is drawing 8, and drawing 8's sole feeds `EIGHT_STEP_M` (from the right facing's D1/D4/D5/D8),
which every facing at both pitches walks on.

## Do
1. (10 min, no Godot) From the probe and `cast_door_soles.py`: compute, for a p55 right D8 sole moved by dx (and a p55 dr D8
   by dx), the new `EIGHT_STEP_M` and the predicted sole / jump in all four facings, p70 included (a step change moves p70's
   numbers too: p70 dr's jump is AT the bar). If no dx brings both p55 soles <= 2 while p70 keeps passing, write that in
   the round's STATE.md, run no images, append "## Door eight, p55 drawing 8, n30" (the computation and verdict) to
   `docs/art/cast-audit.md`, commit it, report and END.
2. Otherwise image edits of the drawing-8 cell(s) only, round dir `door8f` (copy door8e's tools/, Ref 1 = the current
   source row with every accepted splice). Ask for about half the computed distance (the model overshoots backward moves),
   landmark-anchored. At most 4 images.
3. Cut, anchors, `run_unit --select=test_cast_door_walk`, lane lock, `cast_door_films.mjs build/look/n30-c19/feet feet`.
   Table four / eight c17 / eight c19, all four facings. Commit the art only if no facing gets worse on a failing bar and
   p70 keeps passing. A separate `WALK = EIGHT` commit only if every facing passes both bars; then `door8_walk_32.mp4`
   (32 px/m, 15-40 s, ffprobe) and `door8_eight_64.png` (64 px/m) to masters with frames.json entries if time remains
   (frames.json is at its cap of 15: replace `door8_edits_64.png`'s entry with the new still, keep the rest).
4. Append "## Door eight, p55 drawing 8, n30" (computation, table, verdict) to `docs/art/cast-audit.md`, commit (pathspec).

## Allowlist
As round 1 with `door8f` and `build/look/n30-c19/**`; `tools/art/cast_door_soles.py` may print the predicted step (no behaviour
change). Anything else: NEED.

## Report
Computation, images used, the table, the verdict, commits, every command's result line.
