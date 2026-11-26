# n31 foes b5 + b5b: the yard patrol's two moves (NEED ground patch)

Patch: `evidence/n31/foes/prologue_moves.patch` (b5b: remade at `0a509f960`; b5 made it at `636587d8e`, `git apply --check` clean on
`n31-foes`; not applied here: `project/boot/prologue/**` is lane ground's).

## b5b (this revision): the step() rule

b5's `step()` made an officer TRAVEL (no round) whenever its drifting mark was more than
`FoeGait.ARRIVED_M` away past the gap, so the yard fired 14-26 rounds instead of main's 56-102. b5b
replaces that with the owner's rule (TRAVEL = chase, relocation, urgent retreat; FIGHT = fighting):

    var travel: bool = dist > range_m or not arena.guard_map.sight_line(h.pos, player)
    var g: FoeGait = _gait(mind, arena, dist, travel)

- Rivet beyond pistol range or out of sight: TRAVEL at `retreat_mps` 6.65, no round.
- Rivet inside `danger_m` 4.0 or a morale break (`SquadMind.motion == PANIC`): urgent TRAVEL, at once
  (unchanged, `_gait` / `FoeGait.urgent`).
- Otherwise FIGHT at `fight_speed_k` 0.45 x 6.65 = 2.99 m/s, may fire: backing off between 4 m and
  8.8 m, and walking to its mark (any distance) with Rivet in range and in sight.
- `--foe-moves=legacy` unchanged: measured identical to main on all 5 seeds (table below).
- Unit test `test_walking_to_a_mark_with_rivet_in_range_the_officer_fires` (new): mark held 3 m off
  (`_centre` pinned), Rivet 10 m away in range and in sight, 120 ticks: rounds > 0, mode FIGHT, step =
  fight pace. It fails on b5's rule (TRAVEL, no round).
- Tried and rejected: `travel = dist > range_m` (no sight check): totals 28-38, below the sight rule.

## Rounds per band, b5b (`res://dev/foes_n31/yard_rounds.gd`, one process, 5 seeds)

`node tools/dev/run.mjs res://dev/foes_n31/yard_rounds.gd --out=<abs.json> [--foe-moves=legacy]` in a
throwaway worktree at `0a509f960` + the patch. main = `--foe-moves=legacy` (bands and clear ticks equal
b5's main column, which swapped HEAD's `prologue_panic.gd` in). Band = Rivet's distance after the tick.

| seed | main <4 / 4-8.8 / >8.8 = total | b5 <4 / 4-8.8 / >8.8 = total | b5b <4 / 4-8.8 / >8.8 = total | b5b / main | cleared tick main / b5 / b5b |
|---|---|---|---|---|---|
| 7 | 14 / 20 / 28 = 62 | 0 / 10 / 4 = 14 | **0 / 8 / 30 = 38** | 61 % | 5214 / 4260 / 4796 |
| 3 | 25 / 27 / 50 = 102 | 0 / 14 / 2 = 16 | **0 / 15 / 27 = 42** | 41 % | 6956 / 4236 / 5838 |
| 11 | 2 / 17 / 37 = 56 | 0 / 16 / 2 = 18 | **0 / 13 / 20 = 33** | 59 % | 4769 / 4246 / 5463 |
| 21 | 18 / 19 / 25 = 62 | 0 / 10 / 7 = 17 | **0 / 8 / 28 = 36** | 58 % | 5186 / 4686 / 4797 |
| 42 | 14 / 22 / 28 = 64 | 0 / 9 / 17 = 26 | **0 / 16 / 17 = 33** | 52 % | 5192 / 4854 / 5514 |

Bars: inside 4 m = 0 on every seed: **met** (b5b 0 everywhere). Total >= 80 % of main per seed: **not
met** (b5b 41-61 % of main; b5 16-41 %; main seed 3 counts one Rivet death and the retry). b5b more than doubles b5's fire and puts the clear tick back
near main (4796-5838 vs main 4769-6956), but main's own count includes 2-25 rounds inside 4 m that the
rule forbids; 80 % of main asks for more rounds outside 4 m than main itself fired on seeds 3, 7, 21
(main outside 4 m: 48 / 77 / 44 vs 80 % = 50 / 82 / 50). What still costs rounds: the FoeGait hold
after each urgent switch (0.6 s min mode + 0.25 s settle before a round) and the 2.99 m/s FIGHT pace
that lets Rivet close to 4 m again. Ground / the owner must judge whether the 80 % bar is meant over
main's total or over main's rounds outside 4 m.

## What it changes

- `project/boot/prologue/prologue_panic.gd`: each inside officer runs its own `FoeGait` (the
  `EnemyAgent.gait` the squad already gives every member, through `arena.squad_ai.mind_for(h)`):
  - Rivet inside the patrol_cop row's `danger_m` (4.0, enemies.json through `EnemyAgent.arch`) or a
    morale break (`SquadMind.motion == PANIC`): TRAVEL, `_escape` at `retreat_mps` 6.65, no round,
    switched at once (FoeGait `now`).
  - Rivet between `danger_m` and `retreat_gap_m` 8.8: FIGHT, `_escape` at `fight_speed_k` 0.45 x 6.65 =
    2.99 m/s, facing him, may fire.
  - (b5, replaced by b5b's rule above) Rivet past the gap: walking to a mark more than
    `FoeGait.ARRIVED_M` away, or Rivet out of pistol range: TRAVEL at 6.65, no round.
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

## Shots, b5 (one take per seed, main vs b5; superseded by the b5b table above)

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

## Tests and scenarios, b5b (throwaway worktree at `0a509f960` + this patch)

- `node tools/tests/run_unit.mjs --select=test_prologue_panic_gait,test_prologue_spawns,test_foe_gait,test_prologue_encounter,test_prologue_game`:
  `unit-tests: 24 passed, 0 failed, 0 skipped (GUT, headless)` (24.2 s; the 3 gait tests incl. the new
  walking-to-a-mark case, and `test_frightened_officer_opens_a_gap_from_an_approaching_player`).
- `node tools/tests/run_scenarios.mjs --only=prologue_pilot,prologue_checkpoint,prologue_handover`:
  `prologue_handover ok, 7.7 s`, `prologue_checkpoint FAIL, 1.9 s`, `prologue_pilot FAIL, 86.8 s`
  (`scenario-tests: exit 1, 105.2 s, 2 of 3 failed`).
  - **prologue_checkpoint: `unexpected death at tick 5999`** (new with b5b; b5 passed). The scenario
    forces exactly one death per checkpoint and treats any other death as a failure; with the yard
    firing again the bot takes a natural death in wave one. A real consequence of the hotter yard
    for ground to judge (the bot or the scenario's no-natural-death assumption), not re-pinned here.
  - prologue_pilot: pin moves on every dressing, plus one run that no longer finishes (below).
- Lint on the patched files: gdformat / gdlint / gd-size clean (`prologue_panic.gd` 133 lines).

## What ground must re-pin (`project/tests/scenarios/scenario_prologue_pilot.gd`), NOT done in the patch

Not re-pinned in the patch: torn_line / plain seed 42 does not finish, and prologue_checkpoint fails,
so a re-pin would be a fake green. Values measured with b5b:

| dressing | seed 7 | seed 3 | seed 11 | seed 21 | seed 42 |
|---|---|---|---|---|---|
| arched_line (default) / raised_line ticks (`RAISED_LINE_TICKS`) | 10833 | 11734 | 10930 | 11356 | 10783 |
| line_fire ticks (`LINE_FIRE_TICKS`) | 12666 (4 deaths) | 10578 | 10172 | 11735 (2 deaths) | 9728 (1 death) |
| torn_line / plain sha (`LEGACY`) | `ef2c823f...6f356b` (11141, 1 death) | `764c3fa2...f4957` (10086) | `9d5095a8...b06` (11837, 1 death) | `30050272...c3d4` (10931) | **does not finish** |

`COVER_SEED_7` (arched / raised) -> `643fc004efd5d90b5d710f142f257c8767b87275f56190494d8115e6d33991d6`;
line_fire seed 7 gives `3b3384e86ce91898da97081505bcfdf816711734f549b8dd23d33f0ae10518a8`, but the
scenario checks one `COVER_SEED_7` for all three dressings, so ground must split that pin or accept that
line_fire seed 7 no longer matches arched (4 deaths there).
Full `LEGACY` shas: 7 `ef2c823f19e23767ab49d183271a1a907bcc029ce4839e9011dab9782a6f356b`,
3 `764c3fa20cfbd77050221165449efe503799a5ba1a2732e1b388bb8dfb3f4957`,
11 `9d5095a89ed28cbaacd20ba5cd306033834a2445c7a53ebc9a050e086e6f5b06`,
21 `30050272a18e8035247acdad138eec3f24d575bb01867a948d2ac343f307c3d4`.

## Finding: torn_line / plain seed 11 now finishes, seed 42 no longer does

b5's finding (seed 11 torn_line / plain stuck in `Phase.BEAT_TWO`) is gone with b5b: seed 11 finishes in
11837 ticks with 1 death. Seed 42 torn_line / plain now fails the same way: 12 deaths, the 300 s
budget expires in encounter phase 2 (`BEAT_TWO`, wave two, code this patch does not touch) with Rivet
at (1.16, 16.83). Same reading as b5's: the changed wave-one exit state puts the pilot into a beat-two
checkpoint it loses on every replay; a pilot / wave-two weakness, not the patrol (0 rounds inside 4 m).
