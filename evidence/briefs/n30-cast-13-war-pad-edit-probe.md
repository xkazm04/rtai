# n30-cast-13: pile-driver planted pad, ONE-cell edit probe (tag `c13`, model opus)

Read `evidence/briefs/_common.md` first: it binds, EXCEPT: no Godot in this call. Launched ~14:52. Hard stop 15:18
(report and END; the session dies at 15:24). No repo change, no commit: an experiment whose answer goes to the owner.
Keep a resumable state file `C:\Users\kazda\kiro\gtai-art\foes-n30\war8r\STATE.md` from the first minute (jobs sent, image
paths, numbers): a later call may continue it.

## Question (one)
Registration of the pile-driver's planted pads failed because the art keeps the planted pad at a fixed offset from the torso
through each contact (`docs/art/cast-audit.md` "## Pile-driver, n30", second table). To pass, the planted pad must move BACK
(against the walk) by about 29 sheet px (sheet cell 288 px) per drawing through a contact. Can ONE image edit of ONE drawing
move one planted pad back by ~29 sheet px (+-8), torso, other pad, gun, identity unchanged? If yes, the redraw is ~20 cells of
edits (a cost for the owner); if not, the call says image edits cannot place it.

## Target
p70, facing right, drawing 4 (contact L = drawings 3-4: planted LEFT/rear pad at -51 (d3), -52 (d4) sheet px from the torso;
carry 0.2). Ask: in drawing 4 the planted pad sits ~29 sheet px further back (toward the left of the frame, i.e. ~-81) on the
same floor line; everything else as drawn. Read how the eight was cut to map sheet px <-> source px: `tools/art/cast_war_eight.py`
(source rows `C:\Users\kazda\kiro\gtai-art\foes-n29\war8\out\war8_70_right.png`, 8 drawings in a row), and the pad x reading in
`tools/art/cast_war_soles.py` / `cast_war_feet.py` (the "contact" reader: lower pad blob). Measure the source scale
(source drawing height / sheet body height ~185.5 px for p70 right) before writing the prompt, and give the move in source px.

## How (copy the n30 door round, which worked)
`C:\Users\kazda\kiro\gtai-art\foes-n30\door8c\` is the template: STATE.md, jobs.json (prompt wording), refs/ (Ref 1 = the
accepted source row, Ref 2 = shipped sheet), `tools/splice.py` (splice the edited drawing only into the source row, checks
other cells xor 0). New round dir `C:\Users\kazda\kiro\gtai-art\foes-n30\war8r\`. Run from `C:\Users\kazda\kiro\gtai-art`:
`node gen.mjs foes-n30/war8r`. Known fault: a job may stall on the copy to `./out` after the image exists under
`~/.codex/generated_images/`: copy it by hand at once (newest png there) instead of waiting for the 900 s timeout.
Image cap: at most 2 images in this call. If the tool answers with a usage limit: stop, write `BLOCKED images`.
Colour law: no red; vermilion only for danger; amber for heat.

## Measure (python + PIL)
On the splice: planted pad x of drawing 4 vs drawing 3 and the torso (the same pad blob reading the cutter/soles tools use,
converted to sheet px with the cut's scale); torso x and height unchanged (+-2 sheet px); other drawings xor 0. Save a 2x crop
old | new of drawings 3-4 to `build/look/n30-c13/` and LOOK at it: is it still the same machine, is the pad on the floor, is
the leg still connected?

## Provenance
If an image was generated: append one line per image to `steam/ai-provenance/2026-11.jsonl` in the worktree working tree
(same fields as the door8c lines there: read the last 5 lines), do NOT commit (the director commits it).

## Report
Images used (n/2), source scale, asked move (source px), achieved move (sheet px), torso drift, other-cell xor, what you saw,
and a one-line verdict: VIABLE (within +-8 sheet px, machine intact) / NOT VIABLE (why).
