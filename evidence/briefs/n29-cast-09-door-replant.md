# Brief n29-cast-09: the door carrier's sole re-plant after the view's rescale (a placement bug), + the eight switch lines

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 04:58 local** (check `date +%H:%M` often). **Start commit 1 by 04:38, your last commit by 04:46** (hook ~12 min).
Never end with finished work uncommitted. Then report and END.

## What the door8 builder found (commit `fac845dd9`, read `git show fac845dd9` and `tools/film/cast_door_films.mjs`)
`FoeShieldCardView.update_fighter` (`project/features/combat/squad/foe_shield_card_view.gd` ~line 72) sets
`scale = HEIGHT_M * body_scale * PX_PER_M / BODY_PX` (0.824 px/texel at 64 px/m) **after** the card was placed by its
anchors at its base scale (0.584 at p70). So every anchored sole lands 1.41x (p55 1.2x) too far from the pivot and slides.
`SOLE_PATCH` in `tools/film/cast_door_films.mjs` re-plants the sole after the rescale; in the builder's `keep` probe it
roughly halved the shipped four's slide (p70 right 5.08 -> 2.42, p55 right 3.29 -> 2.03, tool's 32 px/m unit).

## Scope
1. **Ship the re-plant** in `foe_shield_card_view.gd` (port `SOLE_PATCH`/`SOLE_FUNC` as real code, typed, <= 40 lines per
   function, file <= ~200 lines). `WALK` stays `FOUR`. The door's height on screen must not change: re-measure with
   `project/dev/cast/cast_size_beside.gd` (shield_robot was 111 px at 64 px/m after `51de13fb6`; bar: within 2 px).
2. **The two switch lines** in `project/features/characters/cast_card_kinds.gd` the door builder named (rows(): test
   `CastDoorAnchors.FOUR` not `SHEET` for the `return 4` case; cell_ratio(): 1.0 when the file is `FOUR` or `EIGHT`), so that
   flipping `WALK` to `EIGHT` in `cast_door_anchors.gd` is truly one value. Remove the now-unneeded `EIGHT_PATCH` lines from the
   film tool only if trivial; else leave it.
3. **Measure** the shipped four with the fix in the game (`node tools/film/cast_door_films.mjs <dir> feet` after the fix is in
   the tree, both walks), table before (from `fac845dd9`'s audit section) / after per pitch and facing (sole, body jump, bars
   sole <= 2, jump <= 12) and append it under the n29 door section of `docs/art/cast-audit.md` ("re-plant shipped"). Also say,
   by reading `foe_gunner_card_view.gd`, `foe_war_card_view.gd`, `foe_warden_card_view.gd`, `foe_turret_card_view.gd` and
   `foe_thug_card_view.gd`, whether any other card view rescales after its anchored placement the same way (file:line); do not
   change them in this call.
4. `project/tests/unit/test_cast_door.gd`: one test that pins the re-plant (sole world x/y at the anchored contact is the same
   before and after the rescale within 0.5 px). One Godot `--import` if a `.uid` is new. `node tools/tests/run_unit.mjs
   --changed` (quote the line), `node tools/gate/quick.mjs`, commit. Then `node tools/mutate/mutate.mjs
   --file=project/features/combat/squad/foe_shield_card_view.gd --lines=<your lines> --max=12 --tests=test_cast_door` only if it
   can finish by 04:55; quote killed/(killed+survived).

## Repo law (binding)
- Godot only through runGodot (`tools/dev/run.mjs`, film tools, gate, mutate); before it
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **Lane Godot lock** (shared with a films builder running now): `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15;
  done` before any Godot launch, `rmdir build/lane-godot.lock` right after (also on failure); older than 25 min = stale.
- `mem-budget: waiting` = machine full: wait, do not kill. Kill only your own PIDs. Never delete anything you did not create.
- Typed GDScript, ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Replay digests, quest 1 and
  prologue tapes must not move (rendering only).
- Stage per path, `git commit -- <your paths>`. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend,
  rebase, branch switches, push. Never skip the hook (`kill_reel_*.break.test.mjs` red: import, commit again; only
  `step_guard.break.test.mjs` red: run it alone, if it passes commit again). Debt red: `node tools/debt/debt.mjs --update`
  (with `--accept-regression="door re-plant for n29 cast"` if it rises), include `tools/debt/baseline.json`.
- Fix lint and format findings in your own edit and go on. No image generation. Never fake a number.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/combat/squad/foe_shield_card_view.gd`, `project/features/characters/cast_card_kinds.gd` (the two lines),
`project/features/characters/cast_door_anchors.gd` (only via `tools/art/cast_door_soles.py` if regeneration is needed),
`tools/film/cast_door_films.mjs`, `tools/art/cast_door_*.py`, `project/tests/unit/test_cast_door.gd`, `docs/art/cast-audit.md`
(append), `tools/debt/baseline.json` (debt tool only), scratch `build/film/door9-*`, `build/look/n29-door9/`.
**Forbidden** (the films builder's or others'): `project/dev/cast/cast_size_beside*` (run it, do not edit),
`project/dev/cast/cast_flash_fight*`, `tools/film/cast_n29_*`, `evidence/n29-cast/**`, `cast_cards.json`, every shipped PNG,
`project/features/souls/**`, `project/features/combat/kills/**`, `docs/decisions.md`, root `JOURNAL.md`, `REPORT.md`,
`evidence/briefs/**`, other lanes' files.

## Report (then END)
Commit sha, the feet table before/after (both walks), the size number, the other views' finding (file:line), the
`run_unit --changed` line, quick gate line, mutate score (or why not), what you could not do.
