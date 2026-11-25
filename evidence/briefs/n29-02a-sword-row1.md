# Brief n29-02a-sword-row1: plasma sword legs, katana as donor, ROW 1 ONLY (lane keys, run n29)

You are an art builder for lane `keys` of an unattended night run on RTAI: Uprising (Godot 4.7, internal id `gtai`).
Worktree: `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
Launched about 01:20. **Report and END by 02:05.** This call commits nothing under `project/`; it prepares a resumable
round and two judged rows. Write the round's `STATE.md` as you go (every step, with the time) so a later call resumes it.

## The owner's pick
"Plasma sword legs with the katana as donor": Rivet walking and running with the plasma sword on his own drawn p70 walk
and run grids (today the sword walks on the stop-gap: the bare stride with the held part on the palm). A sword held in
one claw: the katana's own p70 sheets are the donor (legs, boots, soles and stride are the katana's by construction).
Route: **image edits, one row per job, 16 rows** (walk rows 1-8, run rows 1-8). The director judges row 1 before the rest.
**This call does row 1 only: walk row 1 and run row 1 (2 images; at most 1 retry each, so at most 4).**

## Inputs (read, do not modify)
- Donor sheets: `project/features/characters/art/view/p70/rivet_walk_eq_katana.png` (848x1480, 8 facing rows),
  `rivet_run8_eq_katana.png` (1552x1560, 8 facing rows x 8 cells). Weapon reference: the sword's equipped strips
  `p70/rivet_eq_plasma_sword.png` (1944x161, the 8 facings), `rivet_eq_plasma_sword_left.png`; the katana's
  `rivet_eq_katana.png` for how the donor holds its blade.
- The route and its scripts, as used three times in n28: `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/` (read
  `STATE.md` whole: the row-1 job `jobs_row1.json` is the template, and the hand-copy rule) and
  `C:/Users/kazda/kiro/gtai-art/rivet-n28/ray_gun/` (`scripts/`: `mkrefs.py`, `prep.py`, `legiou.py`, `stride.py`,
  `finish_tone.py`, `capture28.py`), `evidence/n28-keys/grid_ray_gun.md` (the bars table), `grid_molotov.md`.
- Image tool: `node C:/Users/kazda/kiro/gtai-art/gen.mjs <roundDir> [jobName]` (reads `<roundDir>/jobs.json`). Known
  fault: the png appears under `~/.codex/generated_images/<new dir>/` after 4-6 min but is never copied to `out/` and the
  job never exits: copy it by hand to `out/<name>.png` and stop the gen tree **by PID** (never by name). If the tool
  answers with a usage limit: stop, write `BLOCKED images` in STATE and your report.

## What to do
1. New round `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/` with `refs/`, `scripts/` (copy the ray gun / molotov
   scripts and set the weapon to plasma_sword, donor katana), `STATE.md`.
2. Refs: donor walk row 1 and donor run row 1 cut from the katana sheets (in a flat green #00B140 frame like
   `refs/donor_run_row1.png` of the molotov round), and the sword's equipped view (cut from `rivet_eq_plasma_sword.png`).
3. Two jobs, row 1 of walk and row 1 of run. Prompt from the molotov row-1 template: image 1 is the katana row; **only
   the katana blade is swapped for the plasma sword exactly as in image 2** (its hilt in the same claw that holds the
   katana's grip, its blade shape and colours as on the strip); legs, boots, soles, stride, body lean and the other arm
   pixel-identical to image 1; no katana remnant (no steel blade, no tsuba, no wrapped grip); colour law: no red, no teal
   on the sword (if the strip's blade glows, keep exactly the strip's hue; say in your report what hue that is); the
   collar a rigid orange-and-black hazard collar with straight stripes, never rope, never cloth.
4. Prep each returned row with the round's scripts (cut, key, register to the donor cells) and measure against the donor:
   dome deviation (bar <= 3 % of the donor dome width), sole y (bar <= 2 px), leg IoU below 64 % of figure height
   (bar >= 0.80), signed travel own vs donor, same leading boot, no extra limb, no remnant, tone deviation (bar <= 2).
   One retry per row if it fails a bar, with the prompt fixed for what failed. If the retry fails too: stop that row.
5. **The judging crops** (no Godot in this call: the lane's one Godot is busy with another builder): with PIL, nearest,
   scale each row so Rivet's figure is the size it reads in game at 64 px/m (find the sheet's px per metre from
   `rivet_motion.json` / the n28 grid evidence or `capture28.py`; say what scale you used), and write
   `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/row1_judge_64.png`: three bands per gait, labelled in plain ASCII:
   `stop-gap` (the bare run/walk row of the same facing with the sword strip's held part laid on the palm, or, if that is
   too much, the bare row alone and say so), `new (sword)`, `katana donor`. Walk band and run band, all cells of row 1.
   Also a 3x nearest close crop of two cells (`row1_judge_close.png`).

## Do not
- Launch Godot (no `--import`, no render, no tests) in this call.
- Touch anything under `project/` or commit anything. No `git` writes at all.
- Edit the donor sheets or any other weapon's art.

## Allowlist
`C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/**`,
`evidence/n29-keys/sword_row1.md` (write your bars table here; no commit). Anything else: stop and report a NEED.

## Report (short), then END
IMAGES used, each row's bars (table), the scale used for the crops, the crop paths, which bars fail and what you saw by
eye (remnants, collar, blade hue), the STATE.md path and its `Next` (the exact steps for rows 2-8 and wiring).
