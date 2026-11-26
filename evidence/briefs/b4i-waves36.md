# Brief b4i-waves36 (lane foes, run n31): wave 3 and wave 6 play takes, main | final

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 30 min after launch:
report and END.** Commit each take's JSON as soon as it is checked (the first by 15 min in).

## Why
Item 4 of the lane: the owner judges by real play. `wave1_side` exists (3519f232e). The wave 3-4 mix and the wave
6-7 mix are missing. The final game setting is `9b3730e36` (item 2 gait + item 3 levers: shooter share 0.5, own
guns). main = `ba8e470b0`.

## Do
1. `node tools/gauntlet/play_takes.mjs --seed=3 --wave=3 --seconds=30 --name=wave3_side --left=rev:ba8e470b0
   --right=rev:9b3730e36` into `C:\Users\kazda\kiro\gtai-masters\n31\foes\` (read the tool's arg parser first:
   `tools/gauntlet/play_takes.mjs`; use the options it really has, the wave1_side take JSON
   `evidence/n31/foes/takes/wave1_side.json` shows what a finished take records). Then the same with `--wave=6
   --name=wave6_side`. Each side's wave must start at the same tick (the JSON says it); if a side cannot reach the
   wave (Rivet dies before it), say so and try `--seed=4`, one retry only.
2. ffprobe each output (1920x1080, 60 fps, 15-40 s, <= 25 MB per 30 s side).
3. Extract 4 stills per side clip (ffmpeg, at 3, 8, 14, 22 s, into `build/n31/stills/`), Read them yourself. One
   honest sentence per side: how many enemies fire, from how far, who waits; quote the take JSON's mean alive /
   fired per second per side.
4. Upsert `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json`: re-read it right before writing, keep every
   entry, valid JSON, ppm 32, `before` = the left clip, a note with seed, ticks and the two means. Commit
   `evidence/n31/foes/takes/wave3_side.json` and `wave6_side.json` (stage per path).

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` before every Godot run; Godot only through runGodot
(the tool does it). Lane lock `build/n31/godot.lock` (content `b4i <pid>`; wait while another tag holds it;
delete yours when each run ends). Owned: `tools/gauntlet/**`, `project/dev/foes_n31/**`, `evidence/n31/foes/**`,
the masters folder above; any other path: stop and report a NEED. Do not edit game code, JOURNAL.md, REPORT.md,
`docs/decisions.md`. If the tool needs a fix, fix it in `tools/gauntlet/**` (its node tests stay green) and commit
it alone. Stage per path, no amend/rebase/stash/--no-verify, no `git add -A/./-u`, fix lint and format findings
in your own edit. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, the commands with result lines, ffprobe lines, the per-side sentences with the means.
