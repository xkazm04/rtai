# Brief b4p-wave6 (lane foes, run n31): wave 6 take main | final

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 35 min after launch:
report and END.** Commit the take JSON as soon as it is checked. Never end with a commit in the pre-commit hook
(inert evidence-only commits skip lint and are fast).

## Why
Item 4 of the lane: the owner judges by real play. `wave1_side`, `wave3_side`, `callb_wave3`, `gait64_hold` exist
(see `evidence/n31/foes/takes/*.json`). Missing: the wave 6-7 mix, main | final.
main = `ba8e470b0`. final = `9b3730e36` (HEAD's game code is identical to it).

## Do
1. `node tools/gauntlet/play_takes.mjs --seed=3 --wave=6 --seconds=30 --name=wave6_side --left=rev:ba8e470b0
   --right=rev:9b3730e36` (exactly as b4n ran wave3_side: read `evidence/briefs/b4n-waves-callb.md` and
   `evidence/n31/foes/takes/wave3_side.json`; output into `C:\Users\kazda\kiro\gtai-masters\n31\foes\`).
   If a side does not reach wave 6 on seed 3 (the bot dies), retry once with `--seed=4`; if that fails too,
   try `--wave=5` once on seed 3 and say so.
2. ffprobe each clip (1920x1080, 60 fps, ~30 s, <= 25 MB per side); stills of the right and left clips at
   5, 12, 20 s (ffmpeg into `build/n31/stills/b4p/`), Read them yourself; one honest sentence per side (how many
   fire, from how far, who waits), quoting the take JSON's mean alive / fired per second and Rivet's health.
3. Re-read `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` right before writing; the tool may already have
   added the row; keep every entry, valid JSON. Commit `evidence/n31/foes/takes/wave6_side.json` (stage per path).

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every
run; Godot only through the tool (runGodot). Lane lock `build/n31/godot.lock`: the tool writes its own tag; another
builder of this lane (b4q, unit tests) may hold it: wait, never delete a lock that is not yours. `mem-budget:
waiting` means the machine is full, not a hang. Owned: `tools/gauntlet/**` (only if the tool needs a fix, node
tests green, committed alone), `evidence/n31/foes/takes/**`, the masters folder above; any other path: stop and
report a NEED. Do not edit game code, JOURNAL.md, REPORT.md, `docs/decisions.md`. Stage per path, no
amend/rebase/stash/--no-verify, no `git add -A/./-u`, fix lint and format findings in your own edit and go on.
Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, the commands with result lines, ffprobe lines, the per-side sentences with the means, what you
could not do.
