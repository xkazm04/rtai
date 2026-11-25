# n30-cast-05b: door eight Part B (cut, anchor, measure, commit) (tag `c05b`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `evidence/briefs/n30-cast-05-door-eight-edits.md` (the whole item;
you do its "Part B") and `C:\Users\kazda\kiro\gtai-art\foes-n30\door8c\STATE.md` (Part A's state and hand-off: the three
accepted splices, REDRAWN cells p55 [(2,7),(1,7)], p70 [(2,6) n29 f7 kept, (1,0)]).
Launched 12:36. Hard stop 13:40 (report and END). First commit (art + tool + anchors, WALK still FOUR) by 13:10.

## Shared-index warning
Builder c03b works in the same worktree on the flash files (`cast_far_card.gd`, `foe_turret_card_view.gd`,
`foe_war_card_view.gd`, `test_cast_flash_cards.gd`, `cast_flash_fight.gd`): never stage, commit or edit those. Always
`git commit -m ... -- <your paths>`. The lane Godot lock is shared with c03b: take it per command, release at once.

## Provenance first (5 min)
`git log -1 -- steam/ai-provenance/2026-11.jsonl` and `git diff steam/ai-provenance/2026-11.jsonl`: the three door8c splice
lines are uncommitted working-tree appends (the 12:12 commit died). After your sheet cut, append the shipped-sheet lines
(door8b format, file = the p55/p70 `shield_robot_planted8_armed_walk.png` you rewrite) and commit the provenance file
WITH your art commit (pathspec). Only cast lines may be in your diff of that file; if another lane's line shows up
unstaged in it, stop and write NEED director.

## Part B (as in the item brief), measured BEFORE any WALK switch
1. Extend `REDRAWN` in `tools/art/cast_door_eight.py` for the three splices; recut; byte-compare: every other sheet cell unchanged.
2. Regenerate the anchors (`tools/art/cast_door_soles.py`), import (run_unit `--select=test_cast_door` imports first).
3. `node tools/film/cast_door_films.mjs build/look/n30-c05/feet feet`. Table per pitch x facing: four / eight n29 /
   eight with edits, sole and jump, with the per-drawing culprit for any cell over a bar (sole <= 2, jump <= 12).
4. Commit "cast: door eight, three one-row edits (p55 f8 right and down-right, p70 down-right f1)" (art + .import + tool
   + anchors + provenance), WALK still FOUR. `node tools/tests/run_unit.mjs --select=test_cast_door` green first.
5. Switch `CastDoorAnchors.WALK = EIGHT` in a SEPARATE commit ONLY if the eight beats the four in EVERY measured facing
   (sole and jump both <= the four's, or both within the bars). Otherwise leave FOUR and say which facing blocks it.
6. Append "Door eight with three more edits, n30" (the table + verdict) to `docs/art/cast-audit.md`; commit (pathspec).
7. 64 px/m before|after still `C:\Users\kazda\kiro\gtai-masters\n30\cast\door8_edits_64.png` (the film tool's `stills`); LOOK
   at it; append its entry to `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (keep entries; valid JSON).
   If time is left and the eight switched: a 32 px/m walk clip `door8_walk_32.mp4` (15-40 s, ffprobe).
No new image jobs in this call (if p55 dr still fails on x, say so; the director decides on a retry).

## Allowlist
As the item brief's Allowlist (`gtai-art/foes-n30/**`, `tools/art/cast_door_eight.py`, `tools/art/cast_door_soles.py`,
`cast_door_anchors.gd`, the door walk sheets + `.import`, `tools/film/cast_door_films.mjs`, `test_cast_door*.gd` counts,
`docs/art/cast-audit.md` append, `steam/ai-provenance/2026-11.jsonl` append, `build/look/n30-c05/**`, masters files). Anything else: NEED.

## Report
Commits, the table, the WALK verdict and why, still path and what you saw, test lines, what you could not do.
