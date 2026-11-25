# n31 melee 02 part 2.2 - drawn reach and lunge (flag on only)

First ESTIMATE from code. Builder 01c's pixel-measured `01-volumes/before/drawn_ticks.json` appeared at 22:39,
mid-run, uncommitted and partial (electro_baton and katana only, 3 facings). It was NOT used: its masks
reach 2.52 m (baton) and 3.39 m (katana) already at k 0, before the press, so the mask is not the blade
alone yet; its cutting-tick reach (baton 2.43 m, katana 3.41 .. 3.60 m, ground distance from Rivet's
start) is LONGER than the table reach to the centre (2.00, 2.55), the opposite of this rig estimate. Until
01c's numbers are final the flag stays off and the chosen sweep reaches below are provisional: the flip
call re-chooses them from 01c (NEED).

Grip offset at the strike's full reach (rig code, not pixels): the gun shoulder sits at rig (-6, +-158),
the arm is `upper_len + fore_len` = 159 + 182 = 341 rig px x arm_k 0.85 (`rivet_plan.gd` ARMS base) and
`rig_arm.gd` puts the striking claw at (sh.x + reach x 0.99, sh.y x 0.2) = (281, 32) rig px = 283 rig px
from the body's centre; the rig draws at `CutRig.SC` 0.1 x size_k 0.89 = 0.089 world px per rig px at
32 px/m -> **0.79 m**. Drawn blade = grip offset + `length_m` (the held part, origin on the grip). The
claw's drawn cut is `rivet_swipe_view.gd`'s crescent, radius clamp(reach_m, 1.1, REACH_MAX_M 1.35).
Caveat: the live figure draws from d9 strip cells at `PlayerScale.k` 1.5 (render only) and 01a found the
blades of four weapons in strip pixels only, so the drawn blade may be longer than this rig estimate.

All reaches to the body's EDGE (the sweep adds the victim's 0.45 m radius; "to centre" = + 0.45).

| weapon | hit (single swing) | table reach_m (to centre) | drawn estimate | chosen sweep reach (to centre) | how |
|---|---|---|---|---|---|
| claw | claw_rake | 1.40 (1.85) | crescent 1.35 (clamp) | 1.40 (1.85) | table is right: crescent clamp lifted to the hit's reach, flag on only (`RivetSwipeView.reach_max_m`) |
| chainsaw | chainsaw_drive | 1.65 (2.10) | 0.79 + 0.90 = 1.69 | 1.65 (2.10) | art shows the table reach: unchanged |
| electro_baton | electro_baton_crack | 1.55 (2.00) | 0.79 + 0.70 = 1.49 | 1.50 (1.95) | `sweep_reach_m` 1.5 |
| katana | katana_cut | 2.10 (2.55) | 0.79 + 1.00 = 1.79 | 1.80 (2.25) | `sweep_reach_m` 1.8 |
| plasma_sword | plasma_sword_sweep | 2.20 (2.65) | 0.79 + 1.10 = 1.89 | 1.90 (2.35) | `sweep_reach_m` 1.9 |

Katana lunge: `katana_cut` has `lunge_m` 0.55 and no `lunge_ticks`, so `MeleeCombo.lunge_step_m` spread it
over windup + active (7 + 4 ticks): only 7/11 = 0.35 m had arrived at contact (tick_in 7). With the flag on
`sweep_lunge_ticks` 4 puts the whole 0.55 m on tick_in 3..6 (the n17 lunge_ticks path), arrived at contact.
The chainsaw already has `lunge_ticks` 4; the claw rake and the other swings have no lunge.

Where it lives: optional `sweep_reach_m` / `sweep_lunge_ticks` / `sweep_recovery_ticks` on a hit row of
`melee_weapons.json` / `rivet_melee.json` (both schemas), read by `MeleeSweep.adopt` from
`MeleeTable._read_hit` only when `MeleeSweep.on`; with the flag off the table's reach_m, lunge_ticks and
recovery_ticks are what every path reads (no digest moves).

Tests (`project/tests/unit/test_melee_sweep.gd`): reach per weapon is the table's with the flag off and the
chosen sweep reach with it on; the katana's whole lunge arrives before contact with the flag on (before:
under 70 %); a body 2.4 m from the katana (past the drawn blade, inside the table reach) is missed with the
sweep and hit without it; the crescent's clamp reaches the claw's 1.4 m only with the flag on.
