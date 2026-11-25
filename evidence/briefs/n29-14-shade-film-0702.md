# Brief n29-14 `shade-film`: the owner's over_print_shade call on film, today vs 0.5 (lane yard, run n29), evidence only

HARD STOP: 07:40 local (report and END). Check `date` often. No product commit: the table edit is TEMPORARY and must be restored byte for byte. Only one commit is allowed, of the new still under `evidence/yard29/` (`git commit -- <path>`), started by 07:35.

## Setup
Repo worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n29-yard`). Bash with absolute paths. Every shell that runs Godot:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
You hold this lane's single Godot slot: create `build/yard-godot.lock` with noclobber as `shade-film <your node pid>`, delete it when your last Godot exits. Godot only through `node tools/art/prologue_yard_film.mjs` (read its header for --still / --movie; it runs through runGodot, 1920x1080, secondary screen). 16 GB cap: `mem-budget: waiting` = wait. Kill only PIDs you started. ffmpeg/ffprobe are on PATH.

## Why
Commit 785d96bc9 added the optional row key `over_print_shade` (absent = 1.0). The director's call for the owner: keep the own-colour wrecks (today) or add `"over_print_shade": 0.5` to `arched_line` (luminance contrast 110 / 94 / 100 % of i20 for forklift / skip / fridges; `evidence/yard29/impression_props.md`). The existing stills show 0.6; the owner needs 0.5 on film.

## Work
1. "today" takes from the committed table: a movie `--dressing=arched_line --place=mid --tick=1757 --frames=1380 --ppm=32` (23 s) and a still at tick 300 at the mid camera, 32 px/m.
2. Add the TEMPORARY `"over_print_shade": 0.5` to the `arched_line` row of `project/data/tables/prologue_yard_dressings.json` (keep sorted keys), and take the same movie and the same still. Then restore the table: `git checkout -- project/data/tables/prologue_yard_dressings.json` and confirm `git diff --stat project/data` is empty. Do this restore even if a take fails.
3. Film: two 960x1080 centre crops hstacked into 1920x1080 (today left, 0.5 right), each labelled at the top ("today (own colour)" / "over_print_shade 0.5"), h264 yuv420p 60 fps, 15 to 40 s, to `C:/Users/kazda/kiro/gtai-masters/n29/yard/overprint_shade_today_vs_05_32ppm.mp4`. Check it with ffprobe (codec, size, fps, duration). Make sure the crops keep the forklift, the skip and the grey fridge bank in view (look at a frame first; shift the crop x if needed and say where).
4. Still: `evidence/yard29/impression_props_shade05_mid_32ppm.png` (today | 0.5, full frames side by side, labelled). Commit only that png (`git commit -m "Yard n29: over_print_shade 0.5 still (today | 0.5, mid 32 px/m, tick 300)" -- evidence/yard29/impression_props_shade05_mid_32ppm.png`).
5. Add ONE entry to `C:/Users/kazda/kiro/gtai-masters/n29/yard/frames.json`, inserted at position 11 (after `plate_vs_game_gate_32ppm.png`), and remove the `belt_pass4_64ppm.png` entry (the list stays 15 entries; delete that png file from masters too). Entry: file, title "Owner's call: wrecks in own colour vs over_print_shade 0.5, mid yard fight (N s, 60 fps)", ppm 32, before "today, key absent (left)", note with the ticks, crop x and the contrast numbers above. Keep the JSON valid (`node -e "require(...)"`).
6. Delete your scratch .avi/.png under build/ when done.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/data/tables/prologue_yard_dressings.json` (temp key only, restored, never committed), `evidence/yard29/impression_props_shade05_mid_32ppm.png`, `C:/Users/kazda/kiro/gtai-masters/n29/yard/**` (the one mp4, frames.json, removing belt_pass4_64ppm.png), `build/**`.

## Forbidden
Every other repo path (code, tests, schema, docs, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`), other worktrees, `C:/Users/kazda/kiro/gtai-art/**`. No image generation; never `builder.mjs`, `astra.mjs`, `codex`. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`.

## Report (final message, then END)
Commit sha; ffprobe line of the film; the crop x; what you saw at 0.5 vs today (forklift colour, skip, fridges, the spans); `git diff --stat project/data` output (must be empty); what was not done.
