# Brief n29-cast-10: the robot hit flash on the LIVE path (no dev scene driving it), re-filmed

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 06:00 local** (check `date +%H:%M` often). **Start commit 1 by 05:25, your last commit by 05:45** (hook ~12 min).
Never end with finished work uncommitted. Then report and END.

## The fault (found 04:51)
Commit `7ca036a93` makes the door carrier and robot gunner cards wear the tint material while their rig `is_tinted()`
(`project/features/characters/cast_far_card.gd` `sync_tint`). A rig is tinted only by `RigClips.sample` while
`hit_t > HIT_TINT_FROM` (`project/features/characters/rig_clips.gd:150`), and `hit_t` is set only by `RigClips.hit()` or a
feed `Clip.HIT` row (`arena_rigs.gd:212` does that for cops). Robots go through
`project/features/arena/arena_robot_rigs.gd` `_react` (line ~101), which calls only `rig.hit(away, HIT_SHOVE)` (a 40 px shove):
`hit_t` never rises, so no robot card flashes in a real fight. The film `flash_street_32.mp4` (`bdad87c60`) only flashes
because `project/dev/cast/cast_flash_fight.gd` `_flinch` calls `rig.clips.hit(...)` itself.

## Scope
1. Confirm with a grep that no other live path tints a robot rig (gauntlet, arena, street; `RigClips.hit`, `Clip.HIT`,
   `set_tint`, every host that owns robot rigs, e.g. `rig_for` on `robots`). Say which hosts drive robot cards in the game.
2. The smallest fix in `arena_robot_rigs.gd` `_react`: the hit lights the flash for `RigClips.HIT_S` while the shove stays the
   robot's own 40 px (do not switch to `RigClips.hit`, that shoves 90). If it needs a one-line helper on `RigClips`
   (e.g. `func flash() -> void: hit_t = HIT_S`), add it there with a doc comment. Check what the HIT clip does to a robot rig's
   pose while `hit_t > 0` (`RigClips.sample`): if it flinches the robot rig in a way the cop does not, say so with a still.
   Every robot card (door, gunner, the off thug row, turret/war/pile-driver if they sync tint) follows; quote which ones.
3. A unit test (extend `project/tests/unit/test_cast_door.gd` or a new `test_arena_robot_flash.gd`): a robot fighter's
   `hurt_tick` rises -> after `_react` the rig `is_tinted()` within the flash window and clears after it. One Godot
   `--import`, `node tools/tests/run_unit.mjs --changed` (quote the line). Commit 1 (fix + test).
4. Remove the `_flinch` driving from `cast_flash_fight.gd` (keep the scene otherwise), re-film with
   `tools/film/cast_n29_films.mjs` -> `C:\Users\kazda\kiro\gtai-masters\n29\cast\flash_street_32.mp4` (overwrite; 1920x1080,
   60 fps, 15-40 s, 32 px/m tilt 70, `ffprobe` it) and one 64 px/m still `flash_live_64.png` (door + gunner, a flashed frame
   beside an unflashed one). Extract three flashed frames per foe, look at each (Read tool): count flashes per foe in the clip
   (bar: >= 3 each), no red, no teal. Update the two entries in `C:\Users\kazda\kiro\gtai-masters\n29\cast\frames.json`
   (valid JSON array; say in the note "live path, no scene driving"). Commit 2.
5. If time remains (not before commit 2): `node tools/mutate/mutate.mjs --file=project/features/arena/arena_robot_rigs.gd
   --lines=<your changed lines> --max=10 --tests=<your test basename>` within 15 min holding the lane lock; quote the score.

## Repo law (binding)
- Godot only through runGodot (`tools/dev/run.mjs`, film tools, gate, mutate); before it
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **Lane Godot lock** (shared with another builder): `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` before
  any Godot launch, `rmdir build/lane-godot.lock` right after (also on failure); older than 25 min = stale, remove it.
- `mem-budget: waiting` = machine full: wait, do not kill. Kill only your own PIDs. Never delete anything you did not create.
- Typed GDScript, ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`.
- Stage per path, `git commit -- <your paths>`. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend,
  rebase, branch switches, push. Never skip the hook (`kill_reel_*.break.test.mjs` red: import, commit again; only
  `step_guard.break.test.mjs` red: run it alone, if it passes commit again). The quick gate's Godot parse step failed on
  untouched files last session: `node tools/gate/quick.mjs --no-godot` plus GUT is accepted; say so. Debt red:
  `node tools/debt/debt.mjs --update` (`--accept-regression="robot flash for n29 cast"` if it rises), include the baseline.
- This is rendering only: no sim, replay or parity digest may move. If a scenario or golden pins robot rig pixels, say which.
- Fix lint and format findings in your own edit and go on. No image generation. Never fake a frame or a number.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/arena/arena_robot_rigs.gd`, `project/features/characters/rig_clips.gd` (one helper only),
`project/tests/unit/test_cast_door.gd` or new `project/tests/unit/test_arena_robot_flash.gd` (+ `.uid`),
`project/dev/cast/cast_flash_fight*`, `tools/film/cast_n29_films.mjs`, `tools/debt/baseline.json` (debt tool only),
`evidence/n29-cast/**`, outputs in `C:\Users\kazda\kiro\gtai-masters\n29\cast\`, scratch `build/look/n29-flash/`.
Forbidden (another builder works on them now): every `robot_thug_*` file, `cast_thug_*`, `tools/art/**`, `project/dev/cast/cast_thug_*`,
`tools/film/cast_thug_*`, `steam/**`; also `cast_cards.json`, `docs/**`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`,
other lanes' files.

## Report (then END)
Commits, the hosts that drive robot cards, the diff in two lines, the test, the `run_unit --changed` line, clip path +
ffprobe, flash count per foe, what you saw in the frames, the mutate score, NEEDs, what you could not do.
