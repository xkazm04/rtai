# Brief n30-03d `shadow-still64`: 64 px/m in-play still of the span shadow (lane yard, run n30). EVIDENCE ONLY.

HARD STOP 17:08 (report and END). Commit by 17:05. No code, test or data commit: the lane's final gate passed on `7d87cf75a`.

## Setup
Worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n30-yard`). Bash, absolute paths. `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot only through `node tools/art/prologue_yard_film.mjs` (runGodot). Lane Godot slot `build/yard-godot.lock` (tag `shadow-still64` + pid, noclobber) around every Godot launch; table lock `build/yard-table.lock` around the temporary table edit.

## Work
Seed 42, `--at=27.9,19.9` (flags after `--` go to yard_film, see `project/dev/prologue_yard/yard_film.gd` and `evidence/yard30/span_shadow_windows.txt`), pick 2 ticks inside 7026..7564 where Rivet stands on the bend span (try 7300 first). Render `--ppm=64 --still` at those ticks twice: after = HEAD; before = `arched_line.span_shadow` key removed by a temporary edit of `project/data/tables/prologue_yard_dressings.json` (restore byte-identical, `git diff --quiet` it). Compose before | after crops (about 640x640 around Rivet, label each) to `evidence/yard30/span_shadow_play_64ppm.png`; LOOK at it and say plainly how visible the blot is. Copy it to `C:/Users/kazda/kiro/gtai-masters/n30/yard/span_shadow_play_64ppm.png` and add an entry after `span_shadow_before_after_64ppm.png` in that folder's `frames.json` (valid JSON, keep 15 entries at most). Commit only `evidence/yard30/span_shadow_play_64ppm.png` with `git commit -m "Yard n30: span shadow in play at 64 px/m (seed 42)" -- <path>`. Delete scratch pngs you made in build/.

## Allowed
`evidence/yard30/span_shadow_play_64ppm.png`, the temporary table edit (restored), `C:/Users/kazda/kiro/gtai-masters/n30/yard/**`, `build/**`. Everything else forbidden (incl. JOURNAL.md, REPORT.md, docs/, other worktrees). No `git add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push, `--no-verify`. Kill only PIDs you started.

## Report (final message, then END)
Sha, ticks used, what you saw.
