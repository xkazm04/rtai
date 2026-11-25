# n30-cast-05: door carrier eight, three one-row image edits, then four vs eight (tag `c05`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch time + 60 min (report and END). First commit by launch + 30 min.

## Background (read, do not re-derive)
`docs/art/cast-audit.md` "Door carrier on eight drawings, n29" and "Door eight with the redrawn drawing 7, n29"
(lines ~607-725): the table (four vs eight, sole / jump per pitch x facing), and the named next edits: **p55 drawing 8
right and down-right (the torso jumps entering it: p55 right jump 9.61 on 7 -> 8; p55 down-right 13.28 on 7 -> 8, sole
3.45 on 5-8)** and **p70 down-right drawing 1 (jump 12.21 entering it from 8)**. The n29 method that worked for p70 right
drawing 7: an image EDIT of the accepted source row (`C:\Users\kazda\kiro\gtai-art\foes-n29\door8b\jobs.json`: read its
prompt, it is the template), then a SPLICE: only the redrawn drawing's grid cell taken from the edit into the accepted
source (`door8b/out/door8_70_right_f7_splice.png`), and `tools/art/cast_door_eight.py` (its `REDRAWN` dict) replaces only
that sheet cell, every other cell keeps its bytes. Then `tools/art/cast_door_soles.py` regenerates `CastDoorAnchors`, and
`node tools/film/cast_door_films.mjs <out> feet` measures (bars: sole <= 2, jump <= 12, tool's 32 px/m unit).
Accepted sources: `C:\Users\kazda\kiro\gtai-art\foes-n29\door8\out\door8_{55,70}_{right,dr,...}.png` (1774x887, 2x4 grid).
The generated anchors (`project/features/characters/cast_door_anchors.gd`, `EIGHT55` / `EIGHT70`, facings down, dr,
right, ur, up x 8 drawings, `Vector4(sole x, sole y, body x, body y)` sheet px from the cell centre) give where each
drawing's registered sole sits against the torso: e.g. p55 right soles 14, 10.5, 6, -43.5 | 15, 11, 11.5, -47: drawing 8's
rear support foot sits further back than drawing 4's and drawing 7's front foot further forward than drawing 3's.
Before writing a prompt, find from the anchors (and the n29 probe `build/look/n29-door11/probe.py` if it still exists)
which foot is wrong in which direction and by how much in SOURCE pixels (sheet px x source/sheet scale); put that number
in the prompt as "about N % of a foot length further back/forward", as the f7 prompt did.

## Part A: three image edits (no Godot), commit-free, by launch + 25 min
Round dir `C:\Users\kazda\kiro\gtai-art\foes-n30\door8c\` (refs/, jobs.json, run `node C:\Users\kazda\kiro\gtai-art\gen.mjs <round dir>`).
Three jobs, ONE drawing each: `door8_55_right_f8`, `door8_55_dr_f8`, `door8_70_dr_f1`. Ref 1 = the accepted source row,
Ref 2 = the shipped four sheet for identity (as in door8b). Known fault: a job can stall on the copy to `./out` after the
image exists under `~/.codex/generated_images/` (newest file there): copy it by hand at once instead of waiting 900 s.
If the tool answers with a usage limit: stop generating, say `BLOCKED images` in the report, go on with what you have.
At most 6 images in total (one retry per job, only if the first visibly breaks the identity or moves other drawings).
For each result: splice only the edited cell into the accepted source (`<name>_splice.png`, as n29 did), and check:
other cells' silhouettes xor 0 against the source, the edited cell's silhouette changed where intended (LOOK at a 2x crop
of drawing N-1 | N | N+1, before and after). Append one provenance line per accepted image to
`steam/ai-provenance/2026-11.jsonl` (copy the format of the door8b line(s) there; append only, one line at a time).

## Part B: cut, anchor, measure (Godot), by launch + 55 min
Extend `REDRAWN` in `cast_door_eight.py` for the three splices (replace only those sheet cells; byte-compare the rest),
regenerate the anchors with `cast_door_soles.py`, run `node tools/film/cast_door_films.mjs build/look/n30-c05/feet feet`.
Table per pitch x facing: four (= n29) / eight n29 / eight with the edits, sole and jump, with the per-drawing culprit
(the probe) for any cell over a bar. Commit the art + tool + anchors ("cast: door eight, three one-row edits (p55 f8 right
and down-right, p70 down-right f1)") with `WALK` still FOUR. Switch `CastDoorAnchors.WALK = EIGHT` (through the generator's
`--walk`) in a SEPARATE commit ONLY if the eight beats the four in EVERY measured facing (sole and jump both <= the four's,
or both within the bars). Append the table as "Door eight with three more edits, n30" to `docs/art/cast-audit.md`.
Before/after still pair at 64 px/m (the film tool's `stills`) to `C:\Users\kazda\kiro\gtai-masters\n30\cast\door8_edits_64.png`;
LOOK at it; append to `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (keep entries). Report the IMAGES count.

## Allowlist
`C:\Users\kazda\kiro\gtai-art\foes-n30\**`, `tools/art/cast_door_eight.py`, `tools/art/cast_door_soles.py`,
`project/features/characters/cast_door_anchors.gd` (generated), the door walk sheets it writes
(`project/features/**/shield_robot_planted8_armed_walk*.png` + `.import`), `tools/film/cast_door_films.mjs`,
`project/tests/unit/test_cast_door*.gd` (only counts that follow WALK), `docs/art/cast-audit.md` (append),
`steam/ai-provenance/2026-11.jsonl` (append), `build/look/n30-c05/**`, the masters files above. Anything else: NEED.

## Session split (director, 12:05)
Call `c05a` = Part A ONLY (the three image edits + splices + silhouette checks + crops; no Godot, no repo commit except
the provenance lines), launched 12:06, hard stop 12:28. Keep a resumable state file
`C:\Users\kazda\kiro\gtai-art\foes-n30\door8c\STATE.md` (per job: prompt sent, image path, splice path, checks, accepted?).
Part B is a later call `c05b`.
