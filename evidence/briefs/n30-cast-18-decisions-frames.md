# n30-cast-18: two decisions.md lines + frames.json prune (tag `c18`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Launched ~15:31. Hard stop 15:55. No Godot needed.

## Do
1. Append these two lines to the END of `docs/decisions.md`, verbatim, one at a time (append only; check `git diff docs/decisions.md`
   shows exactly your two added lines and nothing else before committing):

- [2026-11-25] DECISION n30 cast pile-driver pads: no planted-pad redraw this run. A one-cell edit probe (p70 right drawing 4, 2 images) put the planted rear pad 27.6 of the 29 sheet px asked on the second try but 7.2 sheet px off the floor (the first overshot to 42.4); a redraw that registration can pass needs about 20 cells at both pitches, about 40-50 images and 2-3 builder hours. The eight ships with sliding soles (jump passes); the redraw is an owner call. Rejected: registration on the shipped art (sole +7.7 to +9.6 px in every facing).
- [2026-11-25] DECISION n30 cast door eight p55 round: two one-cell edits ship as art (`15590aa9b`: p55 right drawing 7 support boot back, down-right drawing 5 landed boot right; p55 right 2.15/7.69 -> 2.05/6.98, down-right 3.06/11.93 -> 2.72/11.78), WALK stays FOUR because both p55 soles are still over the 2 px bar. Re-check: a further round that brings both p55 soles <= 2 switches `CastDoorAnchors.WALK` (one value).

   Commit: `git commit -m "docs: n30 cast decisions (pile-driver pads not redrawn, door p55 round)" -- docs/decisions.md`
   (message ends with the Co-Authored-By line from _common.md).
2. `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` has 16 entries (cap 15). Remove the entry whose file is
   `war8_walk_32.mp4` (the eight-only clip; the eight is the right half of `war8_four_eight_32.mp4` and
   `war8_live_four_eight_32.mp4`), and in any remaining entry whose `before` names `war8_walk_32.mp4`, leave it as is unless it
   is that entry. Keep order, valid JSON (check with `node -e "JSON.parse(require('fs').readFileSync(...))"`). Then delete the
   file `C:\Users\kazda\kiro\gtai-masters\n30\cast\war8_walk_32.mp4`. Not a repo file: no commit.
3. List the masters folder and frames.json files; say any file on disk that frames.json does not reference (do NOT delete
   others, just list them).

## Allowlist
`docs/decisions.md` (append), the masters `frames.json` and `war8_walk_32.mp4`. Builder c17 works on door art beside you:
never stage its files. Anything else: NEED.

## Report
Commit hash, the two lines as committed, frames.json count, unreferenced masters files.
