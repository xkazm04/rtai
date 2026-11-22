# Brief 04 (street lane, n23): the shove wedge at full reach

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. Write your final report BEFORE the mutate run; mutate is last and capped.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Anything that renders: `--rendering-driver d3d12`; any window `--position 0,1440` (secondary screen, never the main display). One Godot process at a time. Never kill processes by name; only a PID you started. Read `tools/README.md` for the film kit (`tools/film/film.mjs`, `compare.mjs --a=<commit> --b=<commit>` for same-tick before/after, `sheet.mjs`).

## Merge note (read before editing)
The `moves` lane changes line 35 of `foe_shield_view.gd` (`view.draw_set_transform(at, h.facing.angle(), Vector2.ONE * LOOK_SCALE)` becomes `FoeStunView.place_shield(view, at, h, mind, tick)`) and `foe_ordnance_view.gd` `_draw()`. Never touch line 35 of `foe_shield_view.gd` nor `foe_ordnance_view.gd`; keep your change inside `_shove_lane()`, its call line and new functions so the morning merge is clean. The tell start position can be derived without new state (during the lunge the carrier moved `aim * speed_mps * TICK_DT` per elapsed lunge tick), or kept in the sim only if that changes no digest.

## Part 0 (first, ~15 min): enemy rounds drawn while Rivet is on hands
Commit 90bad0b11 recoloured enemy rounds (`ShotDraw`, `EnemyRoundLook`), but its stills were staged with a table pistol in Rivet's hand. In the gauntlet Rivet starts on hands (`project/features/player/rivet_carry.gd:151` sets `arena.gun = null`), and then `project/boot/collect_call/view/fx_view.gd` `_shots()` (line ~271) falls through to `draw_line(..., Ink.INK if s.from_rivet else Ink.VERMILION, 4.0)`: every enemy round is still a vermilion dash. Change ONLY that one line so an enemy round uses the size colour (`ShotDraw.core(s)`, or the helper 90bad0b11 made for exactly this; Rivet's own rounds stay `Ink.INK`). That file belongs to no lane tonight; this one line is the only edit allowed in it. Prove: (a) seed 7 average gauntlet `--waves=10` result cmp identical to before; (b) scenario suite unchanged pass count and the 60 s replay digest `cbeb734ff9b97c41`; (c) a still at 32 px/m tilt 70 of an enemy round in flight while Rivet is on hands (gauntlet, any early tick with a cop shooting), before and after, to `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-hands-{before,after}-32.png`. Look at it and say what colour the round is. Do not touch `project/features/souls/plate_sparks.gd` (moves lane; the director filed a NEED). Commit 0.

## The task: the shove wedge at full reach (owner: "draw the wedge to the full reach")
`project/features/combat/squad/foe_shield_view.gd` `_shove_lane()` draws the shield robot's shove mark from the carrier's CURRENT position, `reach_m` long (1.8 m), 13 to 23 px wide. The real hit (`project/features/combat/squad/foe_shield.gd`, end of `_lunge`) is tested at the END of a lunge of `LUNGE_TICKS` (15) ticks at `arch.speed_mps` along the locked `e.aim`: Rivet is hit when `0 <= forward <= reach_m + rivet.radius_m` and `|lateral| <= rivet.radius_m + SLAB_HALF_M` (0.32), measured from the lunge's end position. So the drawn mark is shorter (no lunge distance) and slides with the carrier.
1. Add one pure static function (in `foe_shield.gd` or a new `project/features/combat/squad/foe_shove_zone.gd`, class `FoeShoveZone`) that returns the danger zone polygon in world metres for Rivet's BODY: from the tell's start position along `aim`, covering the lunge then the reach, `SLAB_HALF_M` half width, so that Rivet's body touching the zone == the hit test true (allowing that the hit test is on Rivet's centre; work out the exact shape, e.g. a strip from the lunge end back ... to lunge + reach, and say what you chose). Use the same numbers the hit uses (`reach_m`, `speed_mps`, `LUNGE_TICKS`, `SLAB_HALF_M`, `TICK_DT`): one source. If walls can stop the lunge early, use the full lunge (the mark may only ever be larger than the danger, never smaller).
2. The view draws exactly that zone (fill + vermilion rails; the vermilion is right here: danger), anchored at the world position where the tell started (not sliding during the lunge), shown from the tell through the lunge. Keep a wedge / arrow read at the far end if you can do it INSIDE the zone. Vermilion stays for danger.
3. Unit test `project/tests/unit/test_foe_shove_zone.gd`: for a few aims and speeds, sample Rivet centre positions whose body is just outside the zone (0.05 m clear of it on each side and past the far end) -> the real hit test says miss; positions just inside -> hit. Call the real hit predicate: put it as a pure static in the new `FoeShoveZone` (e.g. `FoeShoveZone.connects(delta: Vector2, aim: Vector2, reach_m: float, rivet_r: float) -> bool`) and make `foe_shield.gd` `_lunge` call it in place of its inline `forward`/`lateral` test (the smallest possible diff there: `foe_shield.gd` is the moves lane's file). No behaviour change: prove with the scenario suite and the replay staying green and seed 7 average gauntlet result byte-identical to before (cmp).
4. Stills: shield robot telegraphing a shove, before and after, 32 px/m tilt 70 and a 64 px/m close-up, to `C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/`. Look at them and report.
Commit B. Then `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_shield.gd --max=20 --lines=<changed lines>` and quote killed/(killed+survived).

## Acceptance checks (quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --changed` green.
- scenario suite summary line, unchanged pass count.
- `node tools/debt/debt.mjs --check`; on `tighten:` run `--update` and commit the baseline.
- New `.gd` files: run `"$GODOT_BIN" --headless --path project --import` once and commit the `.uid`.

## Commit
Staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Allowlist (edit only these)
the one enemy-round line in `project/boot/collect_call/view/fx_view.gd` (Part 0 only), `project/features/combat/squad/foe_shield_view.gd`, new `project/features/combat/squad/foe_shove_zone.gd` (+ `.uid`), new `project/tests/unit/test_foe_shove_zone.gd` (+ `.uid`), and in `project/features/combat/squad/foe_shield.gd` ONLY the hit condition at the end of `_lunge` replaced by one call to `FoeShoveZone.connects(...)` (that file belongs to the `moves` lane: no other line in it may change). Both: `C:/Users/kazda/kiro/gtai-masters/n23/street/**`, `evidence/street/**`, `tools/debt/baseline.json` through the debt tool, `.uid` files of new scripts.
Forbidden: `project/features/player/**`, `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `project/data/tables/enemies.json`, `combat.json`, `gauntlet_bonuses.json`, `project/features/combat/combat_arena.gd`, `project/features/combat/ai/**`, `project/features/souls/**`, `project/boot/**` (except the Part 0 line), tapes and goldens, JOURNAL.md, REPORT.md. Any other path: stop and report a NEED.

## Notes from the director
- `C:/Users/kazda/kiro/gtai-masters/n23/street/` holds only films, stills and `frames.json`. Capture scripts, logs, patches and JSON results go under `build/street/` (git-ignored) or `evidence/street/`, never in gtai-masters.
- Mutate: run from this worktree exactly as `node tools/mutate/mutate.mjs --file=<project-relative .gd> --max=20 --lines=<a-b>`; it makes its own temp worktree at HEAD (commit first). Do not pass a scratch or root directory.
- The quick gate's standalone parse check of `arena_combat_lights.gd` failed last call with an allocator shutdown message that was byte-identical before and after; if it shows again, quote it and go on.
