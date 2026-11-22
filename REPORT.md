# REPORT n24 lane `pressure` (DRAFT, filled at 01:40)

Branch `n24-pressure` in `C:\Users\kazda\kiro\gtai-wt\n23-loop`. Merged: `n24-motion` at `b0a9c4c09` (dash).
Gate: TODO (`node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path).

## What works

### Before / after table (3 skill levels x 5 seeds, 40 waves, greedy picks, wheel controls)

| batch | rev | novice (6) | average (12) | expert (20) | censored |
|---|---|---|---|---|---|
| base-main | `b3f4727c0` | 13 (11-20) | 40 (40-40) | 40 (40-40) | 9 / 15 |
| after-gaps (x2 damage, no in-wave repair, 45 s timer, gaps, rocket) | `032f6de91` | 5 | 10 (5-15) | 12 (3-32) | 0 / 15 |
| after-deflect (+ 50 % pass, 12 deg) | `a9e8adc78` | 5 (5-5) | 5 (3-5) | 7 (5-9) | 0 / 15 |
| arm-rocket14 (+ rocket cooldown 1.4, 13 m/s) | `a9e8adc78` + 2 sets | 5 (5-5) | 6 (5-11) | 5 (5-10) | 0 / 15 |
| final | TODO | | | | |

Median death wave (P25-P75); targets in brackets. Reports: `evidence/n24-pressure/base-main/report.md`,
`evidence/n24-pressure/after-gaps/report.md`, `evidence/n24-pressure/after-deflect/report.md`,
`evidence/n24-pressure/arm-rocket14/report.md`.

### Enemy fire: rounds per second and hits on a moving Rivet (30 s, 10 m, seed 1)

| enemy | RPS before | RPS after | hits standing before -> after | hits circling before -> after |
|---|---:|---:|---:|---:|
| patrol_cop (rifle) | 2.133 | 4.033 | 36 -> 60 | 0 -> 27 |
| swat | 2.133 | 4.033 | 27 -> 51 | 0 -> 38 |
| robot_gunner | 2.133 | 4.033 | 29 -> 56 | 0 -> 30 |
| contractor | 2.133 | 4.033 | 35 -> 59 | 0 -> 25 |
| rocket_trooper | 0.333 | 0.600 (cooldown 0.55; final 1.4: TODO) | 10 -> 18 | 0 -> 9 |
| sentry_turret | 2.100 | 3.900 | 7 -> 18 | 0 -> 0 |
| war_machine | 0.400 | 0.400 | 12 -> 12 | 0 -> 0 |

`evidence/n24-pressure/fire-gaps/before.md`, `evidence/n24-pressure/fire-gaps/after.md`. Circling without skill went from
never hit to hit 25-38 times in 30 s by every rifle.

### Deflect: half through, the rest scattered

Share of RETURNED rounds that still hit their shooter, guard / plasma bat (`evidence/n24-pressure/deflect/share.md`):

| distance | 6 deg | 12 deg (shipped) | 20 deg |
|---|---:|---:|---:|
| 6 m | 84 / 96 % | 42 / 52 % | 24 / 31 % |
| 12 m | 41 / 44 % | 19 / 20 % | 10 / 11 % |
| 20 m | 23 / 23 % | 10 / 10 % | 7 / 7 % |

Bonus rows to add later (not added; each one value in a future equipment table read by `DeflectRule`):
`deflect_plating` (armour: `pass_ratio_k` x0.8, so 40 % pass), `mirror_edge` (blade mod: `spread_deg` x0.5, returns
find their shooter about twice as often at 12 m), `reflex_servo` (perk: guard drain x0.75 on a pass).

### Rivet's rocket and Gloria's nail

- Rocket (`a5332156f`): amber exhaust on the round-colour canvas, steel casing kept; after a wheel switch to hands a
  rocket in flight now keeps its casing and exhaust (before: a thin black dash). Stills
  `C:/Users/kazda/kiro/gtai-masters/n24/pressure/gauntlet-rocket_launcher-64ppm-flight-t91-pair.png` and the
  `-hands-flight-` and `-blast*` pairs at 32 and 64 px/m. No ice blue was found on Rivet's own rocket on any path
  (casing RGB 159,144,146): see Calls.
- Nail (`678f0ad72`): Gloria's round 47.2 x 12.8 -> 16.05 x 4.35 px at 32 px/m, now the smallest of every player
  round (58 % of the next shortest, 65 % of the next narrowest): `evidence/n24-pressure/rounds/sizes-before.md`,
  `evidence/n24-pressure/rounds/sizes-after.md`. Stills `C:/Users/kazda/kiro/gtai-masters/n24/pressure/gauntlet-gloria-32ppm-flight-t91-pair.png`
  and `-64ppm-`.

## What does not

TODO

## What blocked or slowed you

- Hook failure on a merge commit (`tools/merge/clash.test.mjs` under the hook's git env): ~15 min.
- First Astra launch through Git Bash `nohup &` hung the tool call: ~6 min.

## Calls for the owner

1. **Which rocket is "blue"?** Rivet's own rocket is warm steel with a red tip and now an amber exhaust; nothing blue was
   found on it. The `rocket_trooper`'s rocket is ice blue (the n23 keep for enemy large rounds). If the owner meant the
   trooper's, one value draws the enemy rocket as a casing with an ice-blue rim instead. Pair: TODO
   `rockets_rivet_vs_trooper-32.png`.
2. **Deflect spread 12 deg vs 20 deg.** At 12 deg a returned round still hits a shooter at 6 m about half the time
   (42 / 52 %), at 20 deg a quarter. Shipped 12 (the brief's start); 20 if the owner wants the return to be a gamble.
3. **Rocket rest 1.4 s vs 0.55 s.** 0.55 killed 6 of 15 test runs before wave 6; 1.4 keeps the trooper dangerous while
   moving (he leads by 0.8 and relocates) without a rocket wall. Speed 13 m/s so a dash after a human reaction (15 ticks)
   clears a 5 m shot.
4. **Prologue / quest rifle cadence.** The SWAT / Mulroney `assault_rifle` rest went 1.4 -> 0.61 s (the shortest at which
   both prologue scenarios pass: 30 to 36 ticks fail at least one); quest 1's digest moved one tick (Dock 9 kill
   13301 -> 13302, same pay and kills). If the prologue should be harder, its scenarios' expectations change, not ours.
5. **Nail size: `projectile_k` 0.68 (shipped) vs 1.0.** At 64 px/m the new nail reads as a small nail; at 32 px/m it is a
   16 px sliver that is hard to follow in a fight. `weapon_art.json` gloria `projectile_k` 1.0 gives about 24 x 6 px,
   still the smallest round in both axes. One value.
6. **Expert far below 20.** The test player at expert dies early because it does not dodge like an expert (no dash until
   brief 06 task D); the game numbers are tuned against the average target, not the expert one. TODO after final.

## Merge notes

- Merged `n24-motion` at `b0a9c4c09` (dash); motion's later commits not merged. `n24-melee` and `n24-ghost`: not merged
  (no `MILESTONE ready` from melee; ghost's deploy bot lands on its own branch with one line in `bot_brain.gd` `_pack`).
- Expected conflicts for the Director: root `JOURNAL.md` / `REPORT.md` (add/add, keep each lane's),
  `tools/debt/baseline.json` (`node tools/debt/merge_baseline.mjs`), `project/data/schemas/gauntlet_run.schema.json`
  (keep every lane's optional fields), `docs/decisions.md` (append-only: keep both).
- Digest moved on purpose: quest 1 `a113296dbccc` -> `c211ee9720fc` (enemy rifle cadence; `docs/decisions.md` 2026-11-22
  "quest assault rifle cooldown 0.61"). `replay_60s` and the legacy guard tape unchanged.
- Files outside the lane's list edited (no lane owns them, no lane branch touches them, checked 23:07):
  `project/features/combat/weapons/art/weapon_fx_art.gd` (rocket exhaust call), `project/boot/collect_call/view/fx_view.gd`
  (one line), `project/tests/scenarios/scenario_quest1_input.gd` (the pinned digest), and `project/data/tables/weapon_art.json` (gloria `projectile_k`).

## Next steps

TODO

## Astra ledger

| call | minutes | verdict |
|---|---:|---|
| numbers-gaps | 64 | accepted |
| gaps | 74 | accepted |
| rocket-gap | 45 | accepted |
| deflect | 59 | accepted |
