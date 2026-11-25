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
