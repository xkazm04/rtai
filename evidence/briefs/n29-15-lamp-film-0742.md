# Brief n29-15 `lamp-film`: the gate lamp pool before | after on film (lane yard, run n29), evidence only

HARD STOP: 08:20 local (report and END). Check `date` often. No product commit: the table edit is TEMPORARY and must be restored byte for byte. No repo commit at all (the film and frames.json live outside the repo).

## Setup
Repo worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n29-yard`). Bash with absolute paths. Every shell that runs Godot:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
You hold this lane's single Godot slot: create `build/yard-godot.lock` with noclobber as `lamp-film <your node pid>`, delete it when your last Godot exits. Godot only through `node tools/art/prologue_yard_film.mjs` (read its header for --still / --movie; it runs through runGodot, 1920x1080, secondary screen). 16 GB cap: `mem-budget: waiting` = wait. Kill only PIDs you started. ffmpeg/ffprobe are on PATH.

## Why
Commit 8652d29b1 gave the `arched_line` row's `yard_lamp_gate` light a floor glow: strength 0 -> 0.30, radius 8 -> 5 m (`evidence/yard29/gate_lamp_sweep.md`: pool gain +3.4 -> +7.0 L*, pellet 101.2 -> 98.4 %, bar 90). The owner has only stills of it (`evidence/yard29/gate_lamp_before_after_32ppm.png`); he judges by film.

## Work
1. Read `git show 8652d29b1 -- project/data/tables/prologue_yard_dressings.json` to see exactly which values changed.
2. "after" = the committed table: a movie `--dressing=arched_line --place=gate --ppm=32`, 20 to 25 s, over a tick window where Rivet and the fight pass near the gate lamp and a pellet flies (look at a still or two first to pick the window; the gate camera's early fight is the likely one). Same window for both takes.
3. "before" = TEMPORARILY put the two pre-8652d29b1 values back (strength 0, radius 8) in that one light entry of `project/data/tables/prologue_yard_dressings.json`, take the same movie, then restore: `git checkout -- project/data/tables/prologue_yard_dressings.json` and confirm `git diff --stat project/data` is empty. Restore even if a take fails.
4. Film: two 960x1080 crops hstacked into 1920x1080 (before left, after right), each crop keeping the lamp foot and the gate lane in view (same crop x both sides; say which), labelled at the top ("before: no lamp pool" / "after: lamp pool 0.30, r 5 m"), h264 yuv420p 60 fps, 15 to 40 s, to `C:/Users/kazda/kiro/gtai-masters/n29/yard/gate_lamp_before_after_32ppm.mp4`. ffprobe it (codec, size, fps, duration). Extract one frame at the middle and LOOK at it: the pool must be visible on the right and absent on the left.
5. In `C:/Users/kazda/kiro/gtai-masters/n29/yard/frames.json` replace the entry whose file is `gate_lamp_before_after_32ppm.png` with the mp4 entry at the same position (file, title "Gate lamp pool before | after, gate fight (N s, 60 fps)", ppm 32, before "no floor glow (left)", note with tick window, crop x and the sweep numbers above). Delete `gate_lamp_before_after_32ppm.png` from masters (the still stays in the repo's evidence). Keep 15 entries, valid JSON (`node -e "require(...)"`).
6. Delete your scratch files under build/ when done.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/data/tables/prologue_yard_dressings.json` (temp values only, restored, never committed), `C:/Users/kazda/kiro/gtai-masters/n29/yard/**` (the one mp4, frames.json, removing the one png), `build/**`.

## Forbidden
Every other repo path (code, tests, schema, docs, `JOURNAL.md`, `REPORT.md`, `evidence/**`), other worktrees, `C:/Users/kazda/kiro/gtai-art/**`. No image generation; never `builder.mjs`, `astra.mjs`, `codex`. No commit at all, no `git add`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`.

## Report (final message, then END)
ffprobe line of the film; tick window; crop x; what you saw in the middle frame (pool left vs right, pellet visible?); `git diff --stat project/data` output (must be empty); what was not done.
