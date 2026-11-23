# Brief 06 `films-final` - lane yard, run n25 (2026-11-23)

HARD STOP: wall clock 06:20. Last commit by 06:12. Check `date` after each step; when time runs short, keep what is verified and report the rest as not done.

## Context
FILMS ONLY. No product file changes: no code, no tests, no data, no art in `project/`, no tools. The yard art is final at HEAD (call 05, your own commits f97b550c9..2d8845aba: lots fitted between the city roofs, the west loading annex, solid steel gate posts). The masters films in `C:\Users\kazda\kiro\gtai-masters\n25\yard\` were recorded at 04:24 (call 04b), before those changes, so the owner's films show the old west field, the old lot overlap and mesh gate posts. Re-record them from HEAD with exactly the same scenes, cameras, tick ranges and encoder settings you used in call 04b (they are recorded in `evidence/yard/films.json`: `pair_scene`, `pilot_scene`, `mid_framing`, start ticks, CRF 18). Read `git log --oneline -15` and `evidence/yard/films.json` first.

The director's final gate ran on HEAD before this call; do not commit anything under `project/` or `tools/`.

Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n25/appdata/yard`, `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a time. `--rendering-driver d3d12`; any window `--position 0,1440` (never the main display). Kill only PIDs you started, never by name. Render to scratch under `build/` first, then replace the masters file only when the new file is verified.

## Work, in order
1. **Pair films** `pair_mid_32ppm.mp4`, `pair_gate_32ppm.mp4`, `pair_harbor_32ppm.mp4` (plain left, torn_line right, same tick ranges and centres as `films.json`), and the three 64 px/m pair stills (`pair_mid_64ppm_t2290.png`, `pair_gate_64ppm_t6400.png`, `pair_harbor_64ppm_t8460.png`). ffprobe each film (1920x1080, 60 fps, h264, 15-40 s). Look at frames at 2, 13 and 25 s of each film and at each still: the right half must show the steel gate posts (gate) and the lot between the roofs (harbor).
2. **The full prologue on the default dressing** `prologue_torn_line.mp4` (seed-7 pilot to the end card, same scene and flags) and the three excerpts `excerpt_wave1.mp4` (start tick 2858), `excerpt_wave2.mp4` (5496), `excerpt_end_card.mp4` (same selection as before; if the pilot's ticks moved, the selection rule in `films.json` decides). ffprobe each; look at `excerpt_wave1.mp4` at 12 s (the west of the yard must now show the annex, not a flat field) and the last frame of `excerpt_end_card.mp4` (no void at the right edge of the street). Keep the bitrate sane: if a file exceeds 60 Mbit/s, re-encode from the same frames with `-crf 20 -preset slow` and say so.
3. **One new 64 px/m close-up still** of the west annex at the yard's west fence (the same camera as `evidence/yard/west_32ppm.png`, at 64 px/m) to the masters as `west_64ppm_torn_line.png`.
4. **Update** `evidence/yard/films.json` (sha256, frames, durations, ticks for every replaced file; add the new still) and re-make `stills_sheet.png` in the masters from the new stills if its tool is in `project/dev/prologue_yard/` or `build/`. Commit only `evidence/yard/films.json` (and any new `evidence/yard/*.png`), message in the repo's style, staged per path.

## Files: allowlist (any other path: stop and report a NEED)
Write: `C:\Users\kazda\kiro\gtai-masters\n25\yard\*.mp4` and `*.png` named above (NOT `frames.json`, NOT `concepts\`, NOT `concept_plates_a_b_c.mp4`), `evidence/yard/films.json`, `evidence/yard/*.png`, scratch under `build/`.
Read only: everything else. FORBIDDEN to change: all of `project/**`, `tools/**`, `docs/**`, `JOURNAL.md`, `REPORT.md`, `C:\Users\kazda\kiro\gtai-art`, the worktrees `gtai-wt/int-n20` and `gtai-wt/n23-*`.

## Law
AGENTS.md + STANDARDS.md. Stage per path; no amend, rebase, stash, `add -A` or `commit -a`; never push. If the commit hook complains about something outside your allowlist, stop and report it (do not fix it). Fix lint and format findings in your own edit and go on (there should be none: evidence only).

## Report
Per step: done or not done; every output file with its ffprobe line (codec, size, fps, duration, bitrate) and sha256; what you saw in each looked-at frame; the commit; anything that differs from the 04:24 films (ticks, selection, length).
