# Builder n31-melee-03p7 (sonnet, 30 min): the last two fatality takes (electro baton, claw)

Read `evidence/briefs/n31-common.md` (binding) and `evidence/briefs/n31-melee-03p6-fatal-takes3.md` (same steps,
same lock rule: do NOT take `build/n31/godot.lock` yourself before `tools/melee/fatal_takes.sh`; play_take.mjs
takes and frees it per run). Tag `03p7`. Launched 03:58; commit by 04:22; report and END by 04:30.

1. `tools/melee/fatal_takes.sh electro_baton claw` in the background (out file under `build/n31/03p7/`).
   Baton first: if it is not done by 04:15, do not start the claw.
2. Per weapon: ffprobe 1920x1080 and 30-40 s; stills 1 s apart from 8 s; LOOK; name the first fatality second
   and what the right half draws (baton_overload: amber current / charred body; claw_rake_kill: rake + pieces)
   against the left (main) half.
3. masters frames.json: one read-insert-write node call, entries after `beside_fatal_plasma_sword.mp4`.
4. Append to `evidence/n31-melee/03-fatal/takes.md`, commit (`git commit -- <path>`). Delete unreferenced scratch.
Owned: as 03p6. Builder 05 works beside you (mostly Godot-free). Never remove a lock that is not yours.
