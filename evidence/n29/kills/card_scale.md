# n29 combat 06: a killed card foe keeps its card size

Brief: `evidence/briefs/n29-combat-06-kill-card-scale.md` (cast NEED, `C:/Users/kazda/kiro/gtai-wt/n23-prologue/JOURNAL.md` 03:33).

## Step 1: who reaches the path (not void)

Card foes reach it. The chain on this branch (n29-combat):

- `project/features/arena/arena_rigs.gd:70` attaches `FoeCastView` to every arena rig host.
- `project/features/combat/squad/foe_cast_view.gd:54` gives a non-machine fighter whose row is on
  (`CastCards.current`) a `CastCardPose`; `:76` / `:156` bind it to the pooled rig's head card and `:163-164`
  step `StreetWalkerCards`, whose `_build` (`project/features/characters/street_walker_cards.gd:144`) sets the
  `ON` meta, so `StreetWalkerCards.hides_parts` (`:54-55`) is true for the card foe.
- A whole-body kill style (`project/features/combat/kills/kill_new_styles.gd:6-8`: snap, stitch, pin, shred,
  cook, torch, throw, rake) calls `KillFallCells.attach` (`kill_new_styles.gd:70`; the gate is `hides_parts`,
  `kill_fall_cells.gd:19`) and `KillFallCells.height_px` for any rig (`kill_new_styles.gd:80`).
- On this branch the rows on are `sergeant_mulroney` (body_scale 1.11), `appliance_warden` (1.1), `contractor`,
  `rocket_trooper` (1.0); the machines (`robot_gunner`, `shield_robot`, `war_machine`, `sentry_turret`) are
  skipped by FoeCastView (`foe_cast_view.gd:54`, `h.machine`) and drawn by their own `foe_*_card_view.gd`
  nodes, not the rig's head card, so they never pass the `hides_parts` gate with a card pose.

Headless check (probe in `project/tests/unit/test_kill_card_scale.gd` before it became the test, combo view, actor
id 1, crowd build 0.8549): every one of the four reached `attach` with a fall grid (row `cop/head_swat`).
Before the fix the fall grid scale was `0.242229` for all four (crowd jitter only); the living card's
`global_scale` was `0.268874` for Mulroney and `0.266452` for the warden, so a kill shrank Mulroney to 0.90 and
the warden to 0.91 of their living card on the first fall frame. The contractor and the trooper (body_scale 1.0)
were already equal. `height_px` (the track's standing height) had the same error.

The kill files that size a dying body by the crowd jitter: only `kill_fall_cells.gd` (`_scale` and
`height_px`); `grep StreetCrowdCards.vary|SCALE_VAR project/features/combat/kills/` finds nothing else.

## The seam

`KillFallCells.victim_scale(rig: CutRig) -> float` in `project/features/combat/kills/kill_fall_cells.gd`:
a rig with a `CastCardPose` returns what `StreetWalkerCards.place` draws his living card at on this branch
(`StreetCrowdCards.body_scale(id) * pose.sheets.body_scale`, `street_walker_cards.gd:168-169`); any other rig returns
`StreetCrowdCards.body_scale(id)`, the same value as the old inline `1 + SCALE_VAR * vary(id, 3)`. `_scale` and
`height_px` both go through it. `place` has no callable scale function on this branch (the product is inline and
`street_walker_cards.gd` is cast's file), so the seam names the same two sources and the test measures the
live `place` output instead of trusting the arithmetic.

## Post-merge line for the Director (after merging n29-cast)

n29-cast (31df5170f) changes `place` to `k = pose.sheets.scale_of(rig.actor_id)`. In
`project/features/combat/kills/kill_fall_cells.gd` `victim_scale`, replace the last line with:

    return k if pose == null else pose.sheets.scale_of(rig.actor_id)

`test_kill_card_scale.gd::test_a_card_victim_falls_at_his_live_card_scale` measures the live card through
`StreetWalkerCards.place` (scale with the pose over scale without it, times the crowd build), so a merge that
keeps the stale line fails there (Mulroney 1.23 x 0.85 against 1.23) rather than on screen.

## Test

`project/tests/unit/test_kill_card_scale.gd`, 4 tests, green (`node tools/tests/run_unit.mjs
--select=test_kill_card_scale,test_claw_card_victims,test_kill_new_styles`: 16 passed, junit suites
checked: the three files only):
- `test_a_card_victim_falls_at_his_live_card_scale`: Mulroney, the warden and the contractor on a near
  FoeCastView rig; `victim_scale`, `height_px(64)` and the attached fall grid's scale all equal the build
  measured from `StreetWalkerCards.place`.
- `test_a_sized_card_is_not_drawn_at_the_crowd_build`: Mulroney's (1.11) differs from the crowd build.
- `test_a_street_walker_keeps_his_crowd_build`: ped actor 7 pinned at 1.066937056534676 (the old
  inline value), height_px with it.
- `test_the_same_id_draws_the_same_size`.

## Evidence: stills (n29 combat 07)

Finding: the kill reel already films it with existing flags plus one dev line. `kill_lab_turn.gd` `melee_victim` now
returns a single `--foe-mix=<archetype>` for a gun lab too (before: blades only), so the solo guard of a gun kill
is Mulroney. Two traps: the dev arena starts on the wheel/hands controls (a01c1e530) and takes the lab's gun away
(0 kills in every reel), so pass `--controls=legacy`; molotov and pistol kill but their frames were not used.
Command (after = HEAD; before = the same tree with `kill_fall_cells.gd` from 49befa075 copied in for one reel,
then `git checkout HEAD --` it, tree clean):

    node tools/film/kill_reel.mjs --out=build/n29/cardkill/<before|after> --weapons=machine_pistol --ppm=64 --dirs=90       -- --controls=legacy --foe-mix=sergeant_mulroney

Style: machine_pistol = stitch (fall grid). Same seed 20261109, kill at tick 174. Pair
`gtai-masters/n29/combat/stills/card_kill_pair_64.png` (before left, rows t172 alive, t180, t194 down). Measured
(blue-pixel bbox, px at 64 px/m): living 54 x 78 in both; fallen 61 x 47 before, 69 x 53 after (length x1.13,
fallen/living length 0.78 -> 0.88). Seen: the body lies visibly bigger, same pose and place; the standing figure
is the same size in both. No contractor arm rendered (time); the headless table below stands for it.

Headless numbers (combo view, p70, actor id 1, crowd build 0.8549, fall grid `molotov_torch`, which
has no own cells, so the generic `cop/head_swat` fall grid):

| foe | living card global_scale | fall grid scale before | after | before / living |
|---|---|---|---|---|
| sergeant_mulroney (1.11) | 0.268874 | 0.242229 | 0.268875 | 0.901 (fails the 3 % bar) |
| appliance_warden (1.1) | 0.266452 | 0.242229 | 0.266452 | 0.909 |
| contractor (1.0) | 0.242229 | 0.242229 | 0.242229 | 1.000 |
| rocket_trooper (1.0) | 0.242229 | 0.242229 | 0.242229 | 1.000 |

(The living walk strip and the fall grid are both 192 px cells, so the two scales compare directly.)

## Mutate

`node tools/mutate/mutate.mjs --file=features/combat/kills/kill_fall_cells.gd --max=15 --lines=74-94
--tests=test_kill_card_scale` at 6d1fa395: **score 87.5 % = killed 7 / (killed 7 + survived 1)**, 408 s.
The survivor is `kill_fall_cells.gd:74` `path.get_slice("/", 0)` -> `1` (an older line inside the range):
equivalent under p70, where the default height and the p70 height are both 1.7 m; only a p55 case
(HEIGHT_BY_ART 2.0) would kill it.

## Units reached

`node tools/tests/test_map.mjs project/features/combat/kills/kill_fall_cells.gd` names 13 test files; all 13
`--select`ed at d924402d2: **65 passed, 0 failed** (junit: 13 suites). `--changed` in this shared worktree
maps the other builder's uncommitted weapon files, not this change (it ran 93 weapon tests, green).
