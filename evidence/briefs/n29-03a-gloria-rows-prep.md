# Brief n29-03a-gloria-rows-prep: Gloria's p70 rows by image edit, PREP ONLY (no Godot, no commit)

Read `evidence/briefs/n29-03-gloria-walk.md` whole: goal, inputs, route, bars and allowlist all hold, with these values
and these limits for THIS call:
- `{START}` = 01:42. **Report and END by 02:26.** `{IMAGES}` = **12** (count in STATE; another builder in this lane runs two
  image jobs at once for the plasma sword: run **one** job at a time yourself, so the image tool has at most three in flight).
- **Do not launch Godot at all, write nothing under `project/`, make no git writes.** `{GODOT_RULE}` = none in this call.
  `{COMMIT}` = none in this call. Wiring, capture and commit are the next call's (it resumes from your STATE).
- Do: make the round `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/` (copy and adapt the scripts of
  `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/scripts/` — `mkrefs_row.py`, `prep_row.py`, `judge.py`, `assemble.py`,
  `mkjobs_rows.py` — with the pistol as donor and the brass Gloria strip as image 2; read that round's STATE.md for
  what worked tonight: walk rows at s1.0, run rows at s0.95, the hand-copy rule, two-image prompt template
  `edit_run_row1_b`). Order: **walk rows 1-8 first**, then run rows from 1 while images and time remain.
- Per row: `prep_row.py` bars (the brief's) and a 4x eye check (brass gun in ONE claw as on `p70/rivet_eq_gloria*.png`,
  the other claw free, no pistol remnant, collar flat, no red, no teal). One retry per row.
- At the end: a judge crop of all prepared walk rows at the 64 px/m in-game size (`judge.py`, scale 0.96 as the sword
  round) to `C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/walk_rows_judge_64.png`: pistol donor | new, per row.
- Ignore pngs from other lanes or the sword job in `~/.codex/generated_images` (match your job by its time and prompt;
  note the dir list before each launch, as the sword round's `genimg_before.txt`). Stop only your own gen trees, by PID.

Report (short), then END: IMAGES n, rows table, crop path, STATE `Next` for the wiring call.
