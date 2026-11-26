# Brief b4h-stalk-gait (lane foes, run n31): a 64 px/m clip that shows the two moves on one cop

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 40 min after launch:
report and END.** Commit the code part by 20 min in, the take JSON by 35.

## Why
Owner: "1. Slower backwards movement with ability to shoot 2. Faster (as is) movement in case of urgent retreat or
chasing without ability to shoot." Item 2 built it (`project/features/combat/squad/foe_gait.gd`,
`foe_gait_drive.gd`; FIGHT = 0.45 x speed, may fire; TRAVEL = full speed, no fire; Rivet inside `danger_m` 4 m =
urgent TRAVEL). The 64 px/m take `gait64_patrol` (8295f0f52) cannot show it: the bot kills wave 1 in ~15 s and
`play_take.gd` `_aim()` re-picks the NEAREST patrol cop every frame, so the camera jumps cop to cop.

## Do
1. `project/dev/foes_n31/play_take.gd` (ours, 197 lines: keep <= 300; split a helper file beside it if needed):
   - sticky follow: pick the nearest `--follow` foe once (at the first capture tick) and keep it until it dies;
     only then pick the next.
   - `--stalk` (new own flag, add to its `KNOWN` after OWN_FIRST and to `_valid`): Rivet is driven by a scripted
     input instead of the bot: walk straight at the followed cop at walk speed, never attack (no swing, no fire,
     no ghost), stop at 2.0 m and hold for 3 s, then walk away to 10 m, repeat. Read how the gauntlet bot drives
     Rivet (`project/features/gauntlet/bot/gauntlet_bot.gd`, `bot_brain.gd`) and feed the same input path with a
     move vector and no buttons; do not touch the bot files beyond what a disabled-attack hook needs (they are
     ours, but keep the default bot unchanged: default takes must stay byte-identical).
   - per second in the take JSON: for the followed cop its FoeGait mode (FIGHT/TRAVEL, duck-typed via `get()`
     so `rev:ba8e470b0` still compiles and reports "none"), its mean speed m/s, its distance to Rivet, rounds it
     fired.
   - `tools/gauntlet/play_takes.mjs`: pass `--stalk` through; its node tests (if any) stay green.
2. `node tools/godot/check.mjs res://dev/foes_n31/play_take.gd`, lint on your files, commit.
3. Shoot: `node tools/gauntlet/play_takes.mjs --seed=3 --wave=1 --seconds=20 --ppm=64 --follow=patrol_cop --stalk
   --name=gait64_stalk --left=rev:ba8e470b0 --right=rev:<your commit>` (main left; right = your tool commit, which
   carries the final game setting 9b3730e36 unchanged) into `C:\Users\kazda\kiro\gtai-masters\n31\foes\`.
   ffprobe (1920x1080, 60 fps, 20 s). Bar from the JSON (right side): >= 3 s in FIGHT with rounds fired and speed
   <= 1.5 m/s while Rivet is 4-14 m away, and >= 1 s in TRAVEL with 0 rounds and speed >= 2.5 m/s while he is
   inside 4 m. Left (main) shows the old one-speed backpedal while firing. Extract stills every 2 s, Read them,
   one honest sentence per side.
4. Commit `evidence/n31/foes/takes/gait64_stalk.json`; add a frames.json entry in the masters folder (re-read right
   before writing, keep every entry, valid JSON; ppm 64, before "gait64_stalk_left.mp4").

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` before every Godot run; Godot only through runGodot
(the tools do it); one Godot in the lane. Owned: `project/dev/foes_n31/**`, `tools/gauntlet/**`,
`project/features/gauntlet/bot/**`, `evidence/n31/foes/**`; any other path: stop and report a NEED. If a flag
must go in `project/boot/launch_args.gd` KNOWN_FLAGS, append one line and accept the debt with
`node tools/debt/debt.mjs --update --accept-regression="--stalk for n31 foes"`. Typed GDScript, Log not print,
functions <= 40 lines, stage per path, no amend/rebase/stash/--no-verify, fix lint and format findings in your own
edit. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, commands with result lines, the per-second followed-cop rows (right and left), the bar verdict,
what the stills show.
