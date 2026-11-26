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

## Numbers

PENDING (being measured).
