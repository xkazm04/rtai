# Builder n31-melee-03p6 (sonnet, 35 min): render the four missing fatality takes

Read `evidence/briefs/n31-common.md` (binding), `evidence/briefs/n31-melee-03p5-fatal-takes2.md` (steps 3-4 are
this call) and `evidence/n31-melee/03-fatal/takes.md`. Tag `03p6`. Launched 03:19; commit by 03:45; report and
END by 03:55 whatever state. `git commit -- <paths>`.

WHY 03p5 FAILED: it took `build/n31/godot.lock` in its own name and then called `tools/melee/fatal_takes.sh`,
whose `tools/melee/play_take.mjs` takes the SAME lock itself per run (exclusive create, waits while < 30 min
old) -> it waited on itself for 27 minutes. So: **do NOT take the lane lock yourself before fatal_takes.sh.**
The tool takes and frees it per run. If the lock is held by builder `04f`, the tool waits - that is correct.
Take the lock by hand only for a Godot run that does not go through play_take (none planned here).

1. `tools/melee/fatal_takes.sh katana plasma_sword electro_baton claw` (APPDATA + GODOT_BIN exported; run it in
   the background with an out file under `build/n31/03p6/`, poll the file). ~5 min a weapon, both arms.
   If one weapon fails, read the log under `build/dev/`, fix only a tools/melee problem, go on with the next.
2. Per weapon: ffprobe 1920x1080 and 30-40 s; find the first fatality second (stills 1 s apart from 8 s with
   `ffmpeg -ss <s> -i <mp4> -frames:v 1 build/n31/03p6/<w>_<s>.png`, Read each png) and LOOK: name the second
   and what is drawn on the right half (split halves / overload / rake) and what the left (main) half shows.
3. `C:/Users/kazda/kiro/gtai-masters/n31/melee/frames.json`: another builder (04f) also adds entries tonight.
   Edit it with ONE small node one-liner that reads, inserts your entries after the `beside_fatal_chainsaw.mp4`
   entry and writes, right after you read it (never hold a stale copy). One entry per weapon rendered:
   `{file: "beside_fatal_<w>.mp4", title, ppm: 32, before: "main (--melee-sweep=off,--kill-feed=off)", note: "<second>: <what is drawn>"}`.
4. Append the seconds and looks to `evidence/n31-melee/03-fatal/takes.md`; commit it. Delete your scratch pngs
   that nothing references.
Owned: `tools/melee/fatal_takes.sh` (fixes only), `evidence/n31-melee/03-fatal/takes.md`, masters
`fatal_*`/`beside_fatal_*` files and their frames.json entries. Nothing else. Before killing any PID print its
CommandLine and kill only your own. Final report: weapons rendered, seconds, looks, commits.
