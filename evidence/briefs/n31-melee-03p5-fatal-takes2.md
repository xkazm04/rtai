# Builder n31-melee-03p5 (sonnet, 35 min): the fatality takes the owner can see

Read `evidence/briefs/n31-common.md` (binding) and `evidence/n31-melee/03-fatal/takes.md` (03p4). Tag `03p5`.
Launched ~02:48; commit by 03:12; report and END by 03:22 whatever state (the session stops at 03:32 and kills
you). `git commit -- <paths>`.

Director looked at `gtai-masters/n31/melee/beside_fatal_chainsaw.mp4` at 14 s: the film is 1920x540, two whole
street views side by side; Rivet and the cops are ~10 px figures, the grind cannot be told from main's fall.

1. Move `build/n31/03p4/takes.sh` into the repo as `tools/melee/fatal_takes.sh` (tag `03p5`, same flags:
   before `--melee-sweep=off,--kill-feed=off`, after HEAD defaults; seed 7, frames 2100, 32 px/m) and change the
   composite: the take camera follows Rivet, so crop each raw take to its middle (crop=iw/2:ih:iw/4:0, as
   `tools/melee/sweep_clip.mjs` does), scale to 1080 lines, hstack, pad to 1920x1080, labels "main" / "n31
   fatality" 34 px top-left of each half. Add a `--compose-only` mode that re-composes from the existing
   `fatal_play_<w>_before/_after.mp4`.
2. Re-compose chainsaw first (`--compose-only`, no Godot), ffprobe 1920x1080 and 35 s, LOOK at 14 s and 18 s
   (ffmpeg -ss, Read the png): the grind must be readable on the right half. Commit the script.
3. Render katana, plasma_sword, electro_baton, claw in that order (~5 min a weapon, both arms; lane Godot lock
   with your tag, builder 02p5 renders slow clips beside you: wait, never remove a lock not yours). For each,
   find the first fatality second (step through stills 1 s apart from 8 s) and LOOK at it: name the second and
   what is drawn (split halves / overload / rake). A weapon not rendered by 03:10: list it.
4. `C:/Users/kazda/kiro/gtai-masters/n31/melee/frames.json` (read it first): update the chainsaw entry's note,
   add one `beside_fatal_<w>.mp4` entry per new weapon right after it (title, ppm 32, before, note with the second
   the fatality shows). Append the seconds to `evidence/n31-melee/03-fatal/takes.md`; commit.
Owned: `tools/melee/fatal_takes.sh`, `evidence/n31-melee/03-fatal/takes.md`, masters fatal_* / beside_fatal_* files
and their frames.json entries. Nothing else (no product code). Before killing any PID print its CommandLine and
kill only your own.
