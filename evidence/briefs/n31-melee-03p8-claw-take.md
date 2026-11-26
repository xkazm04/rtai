# Builder n31-melee-03p8 (sonnet, 25 min): claw fatality take + masters frames.json trim

Read `evidence/briefs/n31-common.md` (binding) and `evidence/briefs/n31-melee-03p6-fatal-takes3.md` (same steps,
same lock rule). Tag `03p8`. Launched ~04:35; commit by 04:55; report and END by 05:00 whatever state.
`git commit -- <paths>`. No amend, no rebase.

LOCK RULE: do NOT take `build/n31/godot.lock` yourself before `tools/melee/fatal_takes.sh`; play_take.mjs takes
and frees it per run. You are ALONE on the lock (builder 04g waits for your commit), so nothing should interleave.
If the lock is held at start by a tag that is not yours and is < 30 min old, wait (poll 30 s).

1. `tools/melee/fatal_takes.sh claw` in the background (APPDATA + GODOT_BIN exported, out file
   `build/n31/03p8/takes.out`), poll the file. Fix only a tools/melee problem if it fails.
2. ffprobe 1920x1080 and 30-40 s; stills 1 s apart from 8 s (`ffmpeg -ss <s> -i <mp4> -frames:v 1 ...`), Read
   each png, LOOK: the first fatality second and what the right half draws (claw_rake_kill: rake + pieces) against
   the left (main) half.
3. Masters `C:/Users/kazda/kiro/gtai-masters/n31/melee/frames.json`: ONE node script (read, rebuild, write) that
   leaves exactly these entries in this order (keep each entry's existing fields; add the claw entry new):
   beside_play_katana.mp4, beside_play_plasma_sword.mp4, beside_play_claw.mp4, volumes_before_after.png,
   beside_fatal_chainsaw.mp4, beside_fatal_katana.mp4, beside_fatal_plasma_sword.mp4,
   beside_fatal_electro_baton.mp4, beside_fatal_claw.mp4 (new: `{file, title, ppm: 32, before:
   "main (--melee-sweep=off,--kill-feed=off)", note: "<second>: <what is drawn>"}`), still_grind_chainsaw_64.png,
   beside_impacts_katana.mp4, beside_impacts_plasma_sword.mp4, beside_impacts_chainsaw.mp4, the impacts sheet
   entry (sheet_before_after.png or whatever name the existing entry has), slow_katana.mp4, slow_plasma_sword.mp4.
   If an entry is missing (no file) skip it and say so. Then list masters files no entry names and DELETE them
   (print the list first in your report). Never delete anything outside `gtai-masters/n31/melee/`.
4. Append the claw second and look to `evidence/n31-melee/03-fatal/takes.md`; commit it. Delete scratch pngs.
Owned: `tools/melee/fatal_takes.sh` (fixes only), `evidence/n31-melee/03-fatal/takes.md`, the masters melee
folder. Nothing else. Before killing any PID print its CommandLine and kill only your own.
Final report: claw second + look, the frames.json order written, files deleted, commit sha.
