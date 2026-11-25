# n30-11 collar-film: the p55 collar rows 3, 6, 7 clip at 32 px/m, before | after (lane keys, 0 images, no product files)

**Commit within 30 minutes of launch, report and END within 45** (`date +%H:%M` first; write both deadlines in your first line).
Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`,
`commit -a`, `reset --hard`; stage per path with `git commit -- <paths>` (other builders commit in this worktree).
**No image generation, no edits under `project/`.**

## Goal
The owner judges the collar by a film. Make `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/collar_p55_rows367_32.mp4`
exactly like n29's `collar_p55_32_r8.mp4` (read `evidence/n29-keys/films.md` sections "Job 2 clip" and "Job 2b"): the bare-hands
harness `evidence/n29-keys/films/run_hands.py <outdir> 32 1` (movie mode: check the script's args; n29 called the 32 px/m movie
run `run_after8_32`, 963 frames) at 32 px/m, view tilt, 16 beats x 60 frames from tick 58+120*beat, before | after side by side,
480x540 crop at 720,270 scaled 2x nearest per side, 1920x1080, 60 fps, 15-40 s.
- **before** = the sheet at `5114a4441` (main, before any n30 collar edit). Do NOT check out main: render it from this worktree by
  temporarily installing `git show 5114a4441:project/features/characters/art/view/p55/rivet_run8.png` into the worktree path, then
  `--import` and **verify the imported texture is the before sheet** (the n30-08 builder found a stale import once: see
  `build/n30-08/chain.sh` and copy its check that the `.godot/imported` texture's mtime/sha follows the installed png), run, then put
  the HEAD sheet back (`git checkout HEAD -- <that png>` is allowed for this one path), `--import` again and verify. End with
  `git status --short project/` empty for that png.
- **after** = HEAD (rows 3, 6, 7 8/8 rigid since `68d873f9e`).
- Which beats show rows 3, 6, 7 (1-based sheet rows = 0-based 2, 5, 6): name them in the md. Burn a small label per side
  ("before 5114a44" / "after n30") as n29 did, if `compose.py` does.
- ffprobe the clip (width, height, r_frame_rate, duration, nb_frames). Look at 3 frames (one per changed row, sprint beats) with the
  Read tool and write what you see.
- Also a 64 px/m still is already in `collar/row67_64_ingame_final.png` and `row3_64_ingame.png`: no new 64 run needed.
- Add the clip FIRST in `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json` (`file`, `title`, `ppm` 32, `before`
  "5114a4441 sheet", `note`); keep 8-15 entries (drop the weakest collar still if it goes over 15). Write `evidence/n30-keys/films.md`
  section "Collar rows 3, 6, 7 clip" (runs, ffprobe, what you saw). Commit `evidence(keys n30): collar rows 3, 6, 7 clip at 32 px/m`.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Lane lock
`build/n30-godot.lock` (create exclusively with tag `n30-11` + your pid; if it exists and is not yours, wait; delete yours after).
You may hold it across the before run + restore (the sheet swap must not interleave with another builder's run). Only through
runGodot (`run_hands.py` does). d3d12, `--position 0,1440`. `mem-budget: waiting` = machine full, not a hang. Free only your own
processes, by PID.

## Allowlist (anything else: stop and report a NEED)
Temporary only, restored before you end: `project/features/characters/art/view/p55/rivet_run8.png`. Write: `evidence/n30-keys/films.md`,
`C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json`, `build/n30-11/**`.
Forbidden: other art, code, data, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, other worktrees. Never delete anything in Temp
or `~/.codex` you did not create.

## Report (short), then END
Runs, the ffprobe line, beats per row, what you saw in the 3 frames, the commit sha, `git status` for the sheet.
