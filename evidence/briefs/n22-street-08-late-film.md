# n22-street brief 08: film the late-wave drag (film only, no code)

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`. Continue from brief 07 (accepted). The code is
frozen and gated at 7967a0cfa: **you change no file under `project/`, `tools/`, `docs/` or the repo root.**

**Wall-clock hard stop: 06:50 (stop, write the final message). Commit deadline: 06:45.** Never amend, never
rebase. No `git stash`, no `git add -A/./-u`, no `commit -a`, no `reset --hard`, no tags, no merges. Stage per
path; never stage `JOURNAL.md`, `REPORT.md` or `evidence/briefs/**`. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs at `--position 0,1440` (secondary monitor), d3d12.

## Allowlist (any other path: stop and report a NEED)
- Write: `evidence/street/late_film.json` (the only repo file; one commit), and in
  `C:\Users\kazda\kiro\gtai-masters\n22\street\`: `gauntlet_wave8_32.mp4`, `wave8_*.png` stills, `frames.json`.
- Scratch renders go under `build/` (git-ignored); delete the ones nothing references.
- Forbidden: every other lane's worktree, `main`, the product code, the other masters folders.

## The task
The owner's call "late-wave pacing" needs a clip the owner can watch. On the final code, seed 7 `--bot=average`,
headless results give wave 8 = 34.9 s (block `crosswalk`, wave 9 49.6 s, wave 10 66.9 s).

1. Record the same live pipeline you used for `gauntlet_waves4-5_32.mp4` (brief 06: tilt 70, 32 px/m,
   1920x1080, 60 fps, `--fixed-fps 60`, `--pick-view`), seed 7, `--waves=8`. Cut ONE clip
   `gauntlet_wave8_32.mp4`: from 60 frames before wave 8 starts to 60 frames after it clears (about 37 s; if
   over 40 s, cut from the end of the pre-roll, never speed up). Check that the recorded wave seconds and
   picks for waves 1-8 equal the headless seed 7 result (`build/director/s7a.json`), as in film.json
   `matches_headless_first_five`.
2. Extract four stills from the clip (`wave8_<frame>.png`), look at each yourself and write one plain
   sentence per still saying what is on screen (who fights whom, which enemy types, what holds the wave up:
   e.g. a sentry turret behind cover, shield robots, Rivet out of reach). Do not guess: say only what you see.
3. `evidence/street/late_film.json`: commit, seed, flags, clip file + sha256, source frame range, wave 8
   seconds recorded vs headless, the enemies of wave 8, the four inspected stills with notes. One commit:
   `gauntlet evidence: film the late wave-8 drag on the final code`.
4. `frames.json` in the masters folder: keep 15 entries. Replace entry 14 (`segment_plain_block_32.png`,
   the weakest of the segment stills) with the new clip, inserted at position 2 (after `pair_wave2_32.png`),
   title "Wave eight drags", `ppm` 32, `before` null, `note` = your one-line summary of what holds the wave up.
   Keep the file `segment_plain_block_32.png` on disk (REPORT cites the segment stills).

## Final message
The commit sha, the clip's length and sha256, the recorded vs headless wave-8 seconds, the four still notes.
