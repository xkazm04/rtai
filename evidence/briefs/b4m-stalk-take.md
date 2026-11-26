# Brief b4m-stalk-take (lane foes, run n31): the gait clip on the new stalk phases

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 35 min after launch:
report and END.** Commit the take JSON as soon as it is checked (by 25 min in). Never end with a commit in the hook.

## Why
Item 2 of the lane (owner: "1. Slower backwards movement with ability to shoot 2. Faster movement in case of urgent
retreat or chasing without ability to shoot"). The 64 px/m gait clip needs one patrol cop followed while Rivet
(scripted, no attacks) approaches and HOLDS at 6 m for 240 ticks (the cop should backpedal slowly and FIRE), then
RUSHES to 2 m (the cop should turn and RUN without firing), then walks AWAY to 12 m. The pilot phases landed in
`6b849d94c` (`project/dev/foes_n31/stalk_pilot.gd`); the earlier take `evidence/n31/foes/takes/gait64_stalk.json`
(eca66b198) used the old 2 m hold. Another builder (b4j) is changing the game rules at the same time in this tree:
never shoot the live tree, only `rev:` sides.

## Do
1. Read `tools/gauntlet/play_takes.mjs` (arg parser L1-90) and `evidence/n31/foes/takes/gait64_stalk.json`
   (`args` and the per-second `probes`/followed rows) so you use the real options.
2. One take: `node tools/gauntlet/play_takes.mjs --seed=3 --wave=1 --seconds=20 --ppm=64 --stalk --follow=patrol_cop
   --name=gait64_hold --left=rev:ba8e470b0 --right=rev:6b849d94c` (out dir `C:\Users\kazda\kiro\gtai-masters\n31\foes\`
   as the earlier take; check the dev scene used on the main side is this branch's pilot, as f9b5a356f says).
3. Judge from the JSON's per-second followed rows (right side), and print a short table s | phase | mode | speed m/s
   | dist m | rounds:
   - FIGHT bar: >= 3 s in FIGHT, firing (>= 3 rounds total), at <= 1.5 m/s, 4-14 m from Rivet;
   - TRAVEL bar: >= 1 s in TRAVEL, 0 rounds, >= 2.5 m/s, inside 4 m.
   Same table for the left (main) side (no mode there: speed, dist, rounds).
4. ffprobe the right and side clips (1920x1080, 60 fps, ~20 s). Extract 5 stills of the right clip at the HOLD
   middle, the RUSH start, +1 s, +2 s and AWAY (ffmpeg, into `build/n31/stills/b4m/`), Read them yourself: is the
   followed cop visible, gun up while backing off, running while Rivet is close? One honest sentence.
5. Upsert `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` (re-read right before writing, keep every entry,
   valid JSON, ppm 64, before = the left clip, note with seed, ticks, the two bars' result). Commit
   `evidence/n31/foes/takes/gait64_hold.json` (stage per path).
If a bar fails, do NOT change game code: say which phase failed and why (from the rows: e.g. the cop is TRAVEL
while walking to cover in range). The director decides.

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` before every Godot run; Godot only through runGodot
(the tool does it). Lane lock `build/n31/godot.lock`: content `b4m <pid>`; while another tag holds it (b4j), wait;
delete yours when each run ends; never delete another's. Owned: `tools/gauntlet/**`, `project/dev/foes_n31/**`,
`evidence/n31/foes/takes/**`, the masters folder above; any other path: stop and report a NEED. Do not edit game
code, JOURNAL.md, REPORT.md, `docs/decisions.md`. If the tool needs a fix, fix it in `tools/gauntlet/**` or
`project/dev/foes_n31/**` (node tests stay green, `node tools/godot/check.mjs res://dev/foes_n31/play_take.tscn`
ok) and commit it alone. Stage per path, no amend/rebase/stash/--no-verify, no `git add -A/./-u`, fix lint and
format findings in your own edit and go on. Commit messages end with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, commands with result lines, ffprobe lines, both tables, the bars' verdict, the sentence.
