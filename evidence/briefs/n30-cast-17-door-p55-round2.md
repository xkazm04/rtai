# n30-cast-17: door carrier eight, p55 round 2 (tag `c17`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `evidence/briefs/n30-cast-16-door-p55.md` (round 1's brief: method,
commit rules, allowlist: all of it applies here), `docs/art/cast-audit.md` "## Door eight, p55 round, n30" (round 1's plan,
table, what the rejected edits taught) and `C:\Users\kazda\kiro\gtai-art\foes-n30\door8d\STATE.md` ("## c16").
Launched ~15:31. Images done by 15:55. Commit by 16:08. Hard stop 16:15 (report and END). Never end with finished uncommitted work.

## Where it stands (after `15590aa9b`)
p55 right 2.05 / 6.98 (sole on 5-8 over the bar 2 by 0.05; jump fine); p55 down-right 2.72 / 11.78 (sole on 5-8 over).
p70 both pass: do not touch p70. WALK = EIGHT only if every facing passes both bars (sole <= 2, jump <= 12) or beats the four.

## Do (round 1's own "next round")
1. Down-right 5-8 contact: D6 and D7 landed boots set BACK to meet D5's (ask about HALF the distance you compute: the model
   overshoots backward moves; anchor to a drawn landmark in the same cell). One job per drawing, rounds dir `door8e`
   (copy door8d's tools/ + jobs.json; Ref 1 = the CURRENT source row incl. every accepted splice so far).
2. Right 5-8 contact: one second cell (D5 or D6, whichever the probe `build/look/n30-c16/probe_all.py` says lowers the
   5-8 slide; NOT D8: it moves `EIGHT_STEP_M` and every facing).
3. At most 6 images. Splice, xor checks, 2x crop look, provenance lines for accepted images only.
4. Cut, anchors, `run_unit --select=test_cast_door_walk`, lane lock, `node tools/film/cast_door_films.mjs build/look/n30-c17/feet feet`.
   Table four / eight c16 / eight c17. Commit rules as round 1 (art only if a blocking number improves and none gets worse;
   a separate `WALK = EIGHT` commit only if every facing passes; then `door8_p55_64.png` still and `door8_walk_32.mp4`
   15-40 s to masters only if time remains before 16:15; otherwise say so).
5. Append "## Door eight, p55 round 2, n30" (table, verdict) to `docs/art/cast-audit.md`, commit (pathspec).

## Allowlist
As round 1 with `door8e` and `build/look/n30-c17/**`. Builder c18 works beside you on `docs/decisions.md` and masters
`frames.json`: do not touch those. Anything else: NEED.

## Report
Images used, cells, the table, the verdict, commits, every command's result line, what is left.
