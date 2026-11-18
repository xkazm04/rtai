# Brief 03 `cover-core` (lane move, n19): Rivet takes cover, behind a flag

Before ANY Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs `--position 0,1440`. Never kill processes by name.

## Goal
Next to a low or high solid, a press snaps Rivet to it. From cover he moves along it, peeks out at an end and
shoots, and leaves by moving away (or pressing again). Cover protects only through the EXISTING shot-stop rule
(no damage multiplier, no invulnerability flag). Off by default behind flags; byte-identical replays and
digests with it off. Engine behaviour plus tests and a scenario; the view pose and frames are the next package.

## What is true today (I scouted it; verify)
- Shots stop in solids only in the arena: `features/arena/arena_dodges.gd::cull()` erases any non-thrown shot
  whose next tick crosses an `ArenaWalls` box (`wall_high`, `cover_high`, `cover_low`), Rivet's AND the enemies'
  ("cover works both ways"). A low box stops shots too, so **Rivet cannot shoot over low cover**: the only way to
  shoot from cover under the existing rule is to lean out past an END of the cover (a corner peek). City cells
  (`StageCells`) stop no shots at all.
- DECISION (mine): cover is offered only on solids whose shots-stop rule exists: the arena-station boxes (arena
  and the city proving block's stations). City props/buildings are NOT offered as cover tonight (they would
  protect nothing). The query API still reports them with `protects=false` so the ai lane can see why.
- Vault work from packages 01/02 is in `features/player/` (read it): `VaultProbe.stations(source, base)` fills
  `boxes: Dictionary[Rect2, String]` (box -> station kind), `clear_at(p, r)`, `contacts()`; `PlayerVault._bind`
  binds a stage's stations/cells; `PlayerVault.drive()` is the pilot hook; `CollectCallStage.collide_preview()`
  is public; flags read in `apply_flags()`. Reuse the box reader (factor a shared `StageSolids` out of it if
  cover and vault both need it; keep the vault's tests green and its digests identical) rather than a second one.
  Remember the stage re-collides Rivet after body resolution (`collect_call_stage.gd:109`): cover positions
  must be ground-clear, so that pass leaves them alone.
- Input: `data/tables/input_actions.json` rows; bits 0..15 are taken, `TickInput.buttons` has room. Add a row
  `cover` at bit 16 (keyboard `C`, and a gamepad button that is free: check the rows, choose, and say which).
  Adding a row must not change any replay: old logs never set bit 16.
- Quest 1's hide (`boot/collect_call/view/hide_peek.gd`, `stage.hidden_in`, `intent.move_to`, the p55 peek card
  `rivet_hide_<pitch>`) is a bin he climbs into, driven by quest 1's interact. **Do not change quest 1's
  behaviour or replay.** In your report say whether the hide could be expressed as a cover spot later and what it
  would take; do not do it now.

## Build
1. `features/player/cover_query.gd` (`CoverQuery`, small, static, typed): the API the ai lane will call for its
   enemies, with no player state in it:
   - `near(point: Vector2, radius_m: float, solids) -> Array[CoverSpot]`: candidate spots along each solid face
     within radius, sorted by distance (stable tie-break, deterministic);
   - `CoverSpot` (inner class or own file): `box: Rect2`, `at: Vector2` (standing point, Rivet's/a fighter's
     radius off the face), `normal: Vector2` (out of the face, toward the side the stander is on), `tangent`,
     `low: bool`, `edge_a/edge_b: Vector2` (the peek points past each end), `protects_shots: bool`;
   - `protects(spot, threat: Vector2) -> bool`: true when the segment threat -> spot.at crosses the box under the
     same geometry `ArenaWalls.blocks` uses (call it, or the same math).
   `solids` is whatever shape your vault reader already gives (arena boxes with kind). Document it in the class
   doc string as the API for enemies.
2. `features/player/player_cover.gd` (`PlayerCover`), PlayerMotion delegates to it like the vault: phases
   SNAP (a few ticks onto the spot), IN (stick projected on the tangent at `move_mps`, clamped to the face's
   length; facing out from the wall unless aiming), PEEK (at an end: holding an aim that points past the end, or
   the fire button, leans out `peek_m` past the edge in `peek_ticks`; fire allowed only once leaned out),
   LEAVE (stick pushes away from the face beyond `leave_dot` for `leave_ticks`, or the press again; a roll press
   leaves cover with a roll). Fire while IN but not at an end: refused (the shot would stop in the cover); say
   if you choose otherwise. Never inside a solid: every cover position goes through the same clear test as the
   vault.
3. Data: a `"cover"` object in `rivet_motion.json` + schema: `enabled` (false), `snap_reach_m`, `snap_ticks`,
   `move_mps`, `peek_m`, `peek_ticks`, `edge_m` (how close to an end the peek is offered), `leave_dot`,
   `leave_ticks`. Sensible numbers; say them.
4. Flags `--cover` / `--no-cover` appended to `KNOWN_FLAGS` (one line each), default from data, same pattern as
   the vault.
5. `write_state()`: cover fields only while in cover: byte-identical when off.
6. Pilot call sites in `boot/collect_call/stage_pilot.gd` small and named in the commit message.

## Tests (first-author, red before green; say so)
`project/tests/unit/test_rivet_cover.gd` (+ `test_cover_query.gd`):
- the query returns spots on each face of a cover_low box, sorted, with normals pointing at the asker;
- `protects`: a threat on the far side is blocked, a threat on the near side is not;
- press next to a box: Rivet snaps; moves along it; is clamped at the ends; never in a solid;
- an enemy shot from the far side (a real `Shot` through `ArenaDodges.cull`) stops in the cover while he is IN;
  the same shot hits him while he is PEEKing out at the end (the existing rule decides, nothing else);
- Rivet's own shot from PEEK reaches a target past the cover; fire while IN mid-face is refused;
- leaving by moving away; leaving by the press; a roll leaves;
- flag off: no snap, and `write_state` bytes of a scripted run equal the bytes with the cover code absent.

## Scenario
`project/tests/scenarios/scenario_rivet_cover.gd`: on the arena, scripted input: walk to a cover, snap, slide,
peek, shoot a dummy past the end, leave; twice: identical digests and positions. A fuzz over the arena: 300+
seeded cover presses/slides/peeks/leaves from random spots, a per-tick no-solid-overlap assert, and the counts
(snaps, peeks, leaves, refused). Register it like package 01's scenario.

## Repo law (binding)
As brief 01: AGENTS.md + STANDARDS.md, typed, functions <= 40 lines, files ~200 (hard 300), <= 5 params, `Log`,
no global RNG, `SimClock.TICK_DT`, `.uid` files committed. Touch only: `features/player/**`, `rivet_motion.json`
+ schema, `input_actions.json` (+ schema if a field is needed), your test/scenario files and their registration,
`dev/rivet_motion/**`, small `stage_pilot.gd` call sites, one line per flag in `launch_args.gd`. Never
features/arena, combat, city, characters, native, goldens. Stage per path, no stash/add -A/reset --hard, no push.
Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I run them after you)
quick gate + lint clean; `run_unit.mjs --changed` then `--fast` green; your scenario + the vault scenario + the
quest 1 / replay scenarios green; `git status` clean. Report commits, numbers, the chosen gamepad button, fuzz
counts, the quest 1 hide answer, and anything left.
