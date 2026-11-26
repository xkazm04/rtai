# Brief b4n-waves-callb (lane foes, run n31): wave 3 / wave 6 takes main | final, and the call-B take

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 40 min after launch:
report and END.** Commit each take's JSON as soon as it is checked (the first by 15 min in). Never end with a
commit in the pre-commit hook (it takes up to 10 min here; inert evidence-only commits skip lint and are fast).

## Why
Item 4 of the lane: the owner judges by real play. `wave1_side` (3519f232e) and `gait64_hold` (72a09deee) exist.
Missing: the wave 3-4 mix and the wave 6-7 mix, main | final, and the clip for the owner's call on setting B.
main = `ba8e470b0`. final = `9b3730e36` (HEAD's game code is identical to it). B = `c825715e8` (shooter share 0.75,
pistol 1.5 / rifle 1.5 Rivet hp per round: idle 55 -> 43 %, damage waves 1-4 71.3 -> 75.1, not kept).

## Do (in this order; stop at the hard stop with what is committed)
1. `node tools/gauntlet/play_takes.mjs --seed=3 --wave=3 --seconds=30 --name=wave3_side --left=rev:ba8e470b0
   --right=rev:9b3730e36` (read the tool's arg parser first, L1-90; output into
   `C:\Users\kazda\kiro\gtai-masters\n31\foes\` as the earlier takes; `evidence/n31/foes/takes/wave1_side.json`
   shows what a finished take records). Both sides' wave must start at the same tick (the JSON says it); if a side
   cannot reach the wave, say so and try `--seed=4`, one retry only.
2. `--wave=3 --name=callB_wave3 --left=rev:9b3730e36 --right=rev:c825715e8` (same seed as step 1).
3. `--wave=6 --name=wave6_side --left=rev:ba8e470b0 --right=rev:9b3730e36`.
4. For each take: ffprobe (1920x1080, 60 fps, ~30 s, <= 25 MB per side); 3 stills of the right and left clips at
   5, 12, 20 s (ffmpeg into `build/n31/stills/b4n/`), Read them yourself; one honest sentence per side (how many
   fire, from how far, who waits), quoting the take JSON's mean alive / fired per second and Rivet's health at
   the end per side.
5. Upsert `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` (the tool may already add rows: re-read right
   before writing, keep every entry, valid JSON, ppm 32, `before` = the left clip, a note with seed, ticks, means).
   Commit `evidence/n31/foes/takes/<name>.json` per take (stage per path).

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every
run; Godot only through the tool (runGodot). Lane lock `build/n31/godot.lock`: content `b4n <pid>`; wait while
another tag holds it; delete only your own. `mem-budget: waiting` means the machine is full, not a hang. Owned:
`tools/gauntlet/**`, `project/dev/foes_n31/**`, `evidence/n31/foes/takes/**`, the masters folder above; any other
path: stop and report a NEED. Do not edit game code, JOURNAL.md, REPORT.md, `docs/decisions.md`. If the tool
needs a fix, fix it in `tools/gauntlet/**` (its node tests stay green) and commit it alone. Stage per path, no
amend/rebase/stash/--no-verify, no `git add -A/./-u`, fix lint and format findings in your own edit and go on.
Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, the commands with result lines, ffprobe lines, the per-side sentences with the means, what you
could not do.
