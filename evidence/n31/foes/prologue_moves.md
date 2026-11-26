# n31 foes b5: the yard patrol's two moves (NEED ground patch)

Patch: `evidence/n31/foes/prologue_moves.patch` (made at `636587d8e`, `git apply --check` clean on
`n31-foes`; not applied here: `project/boot/prologue/**` is lane ground's).

## What it changes

- `project/boot/prologue/prologue_panic.gd`: each inside officer runs its own `FoeGait` (the
  `EnemyAgent.gait` the squad already gives every member, through `arena.squad_ai.mind_for(h)`):
  - Rivet inside the patrol_cop row's `danger_m` (4.0, enemies.json through `EnemyAgent.arch`) or a
    morale break (`SquadMind.motion == PANIC`): TRAVEL, `_escape` at `retreat_mps` 6.65, no round,
    switched at once (FoeGait `now`).
  - Rivet between `danger_m` and `retreat_gap_m` 8.8: FIGHT, `_escape` at `fight_speed_k` 0.45 x 6.65 =
    2.99 m/s, facing him, may fire.
  - Rivet past the gap: walking to a mark more than `FoeGait.ARRIVED_M` away, or Rivet out of pistol
    range: TRAVEL at 6.65, no round; at the mark: FIGHT (fires as before).
  - `FoeGait.update` with the squad table's `gait_min_mode_s` 0.6 and `gait_settle_s` 0.25 (the same
    `EnemyRoster.gait_min_ticks` / `gait_settle_ticks` the gauntlet uses); a round needs
    `FoeGait.may_fire`.
  - `--foe-moves=legacy` (or squad.gait "legacy") keeps the old single gait (`_legacy`), the same code
    as main.
  - Facing stays on Rivet in both modes (the existing
    `test_frightened_officer_opens_a_gap_from_an_approaching_player` asserts it); `FoeGaitDrive.gun_down`
    already lowers the gun of a TRAVEL member, which now covers the yard patrol too.
  - No data change (no `prologue_stage.json` edit); quest 1's script and lines untouched.
- `project/tests/unit/test_prologue_panic_gait.gd` (new): no round inside danger_m at 6.65 m/s,
  rounds while backing off at 2.99 m/s between 4 m and 8.8 m.

## Shots (one take per seed, main vs patched)

Headless, the prologue bot (`res://dev/bots/prologue_bot.gd`) on the default dressing, same seed, same
loop as `scenario_prologue_pilot`, stepped until wave one (the yard patrol) is cleared. A round is
counted when a `ProloguePanic` member's `EnemyAgent.shot_tick` changes; the band is Rivet's distance
from that officer after the tick. Main = `git show HEAD:project/boot/prologue/prologue_panic.gd`
swapped into the same throwaway tree, everything else identical.

| seed | main <4 m | main 4-8.8 m | main >8.8 m | patched <4 m | patched 4-8.8 m | patched >8.8 m | wave one cleared tick main / patched |
|---|---|---|---|---|---|---|---|
| 7 | 14 | 20 | 28 | **0** | **10** | 4 | 5215 / 4261 |
| 3 | 25 | 27 | 50 | **0** | **14** | 2 | 6957 / 4237 |
| 11 | 2 | 17 | 37 | **0** | **16** | 2 | 4770 / 4247 |
| 21 | 18 | 19 | 25 | **0** | **10** | 7 | 5187 / 4687 |
| 42 | 14 | 22 | 28 | **0** | **9** | 17 | 5193 / 4855 |

Bars: inside 4 m = 0 on every seed (main 2-25); 4-8.8 m > 0 on every seed (9-16): they still shoot
while backing off. Main seed 3 includes one Rivet death and the checkpoint retry (bands summed over
both attempts; `pistol_rounds` 40 is the retry only).

Side effect to judge (gameplay): the patrol fires far fewer rounds in all (patched 14-26 vs main
40-64 counted) and wave one clears 300-2700 ticks sooner. Most of the drop is past 8.8 m: an officer
whose mark (`_centre + offset`, which drifts as the bunch moves) is more than `ARRIVED_M` 0.6 m away
is TRAVEL and holds its round, then needs 0.6 s hold + 0.25 s settle. If ground wants the yard
as hot as before past the gap, the lever is a larger "arrived" radius for the yard marks (for
example 1.5 m) in `step()`'s `moving`; that is ground's tuning call, not part of this patch.
