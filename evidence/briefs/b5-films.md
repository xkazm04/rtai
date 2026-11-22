# Brief b5-films: quest 1 and the arena open on hands with the wheel

Lane `controls`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n23-controls`. The wheel is the default and opens on slot 0 `hands` (earlier commits on this branch).
**Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY.**
Read `evidence/briefs/n23-controls-common.md` first: environment and repo law bind this brief.

The owner judges this lane by films. He wants to SEE: quest 1 and the arena opening on hands with the wheel (no flag given, i.e. the new default).

## Films (to `C:\Users\kazda\kiro\gtai-masters\n23\controls\`)
All 32 px/m, tilt 70, 1080p60, d3d12, `--position 0,1440`, committed tree (`--rev=HEAD` in `tools/film/film.mjs`; read `tools/README.md` film section first).
1. `quest1_wheel.mp4`, 20 to 40 s: quest 1 from its first tick with **no** `--controls` flag: the help card (wheel text), Rivet on hands, the wheel HUD showing hands lit and the empty slots dimmed, the first punches / claw, then the first gun picked up: it is **not** auto-selected (DECISION), then a scroll selects it and it fires. If quest 1's scripted pad (`res://dev/frames/quest1_clip.gd`) cannot pick and select a weapon under the wheel, add a wheel step to a dev driver under `project/dev/controls/` (not to the shipped pad), and say so.
2. `arena_wheel.mp4`, 15 to 30 s: the arena (`film.mjs arena`, or a dev driver if the reel's loadout forces a gun) opening on hands, a few claw/punch hits, then a scroll to the pistol and shots. The wheel must be on screen when it changes.
3. `quest1_legacy.mp4`, 10 to 15 s, the same opening with `--controls=legacy` (the before), so the owner sees the difference.
4. Stills from each film at the moments above (`quest1_wheel_hands.png`, `quest1_wheel_pickup.png`, `quest1_wheel_select.png`, `arena_wheel_hands.png`, `arena_wheel_select.png`), and one 64 px/m close-up of the wheel HUD over Rivet holding only hands (`wheel_hands_64.png`).
Look at every frame yourself: the wheel must be readable, Rivet in frame, no SCRIPT ERROR in the log. Quote the dev verdict line (`tools/dev/run.mjs`) or film.log status for each film.

## frames.json
Add entries (file, title, ppm, before, note) for these films and stills to `C:\Users\kazda\kiro\gtai-masters\n23\controls\frames.json` (merge with what is there; 8-15 entries total, best first). Delete scratch renders it does not reference (only in that folder and only files you made).

## Allowlist
`project/dev/controls/**`, `evidence/controls-flip/films.md` (what each film shows, with tick ranges and the commands), the masters folder above. Nothing under `project/features/**`, `project/boot/**`, `tools/**`: if a film needs a product change, stop and report it.

## Report
Each film/still path with its command and verdict line, what you could not show and why.
