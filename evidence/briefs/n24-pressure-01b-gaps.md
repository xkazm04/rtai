# Brief n24-pressure-01b (resume): commit the fire-gap tool, the street rifle's damage, then shorter gaps

You are resuming your brief-01 session for lane `pressure`. Everything in `evidence/briefs/n24-pressure-01-numbers-gaps.md`
("Machine rules", "Git law", the forbidden list) still binds, except the allowlist additions below. You are the only
Godot user of this lane now: no waiting on the baseline.

**Wall clock: hard stop 19:45. Last commit by 19:40.** Commit each task as it lands.

Your report was read: tasks 1-3 accepted. Good finding on the street rifle. Answers to your NEEDs:

## Allowlist additions (only these)

- `tools/debt/baseline.json` through the debt tool only:
  `node tools/debt/debt.mjs --update --accept-regression="dev/gauntlet fire_gaps probe for n24 pressure"` (never by hand)
- `project/data/tables/combat.json` `weapons` block: the `assault-rifle` row's enemy-fire numbers only
  (`damage_vs_rivet`, `cooldown_s`, `burst`, `burst_gap_s`, a new `aim_lead` key if you add one) and
  `project/data/schemas/combat.schema.json` for a new key in that row. Nothing else in `combat.json` (`moves` is lane
  ghost's, `robo_tazer` is lane melee's).
- `project/features/combat/guard_brain.gd` (the street riflemen's trigger, fire timing only).

## Task A - commit task 4 (first, one commit)

Run the debt update above, then commit the fire-gap tool, its test, `.uid` files, `evidence/n24-pressure/fire-gaps/before.{json,md}`
and the baseline. Quick gate first.

## Task B - the street rifle's damage and two follow-ups (one commit)

- `combat.json` `weapons.assault-rifle.damage_vs_rivet` 0.6 -> 1.2: the owner's doubling must reach the street
  riflemen (patrol_cop, swat, robot_gunner, contractor fire this row). Leave `robo_tazer`, `bosses.json`, `servo.json`,
  `prologue_stage.json` alone (I record them as NEEDs).
- `gauntlet_street.gd` `wave_timeout_ticks`: `wave_timeout_late_s` 0 must mean "late rule off: the wave keeps
  `wave_timeout_s`", not "no timer"; fix it and `test_zero_late_timeout_leaves_wave_six_open_without_reinforcements`.
- `docs/decisions.md`: append one dated `DECISION pressure:` line each: enemy damage x2 (`db2043604` plus this commit:
  game-wide, `enemy_damage_k` stays 1, no digest moved), no in-wave repair (`02bec2b14`, `rivet.repair_in_wave`), the 45 s
  late timer (`624e58248` + this fix).
Unit tests + scenarios, as in task 1 of brief 01.

## Task C - shorter gaps (one commit: tables/code + `evidence/n24-pressure/fire-gaps/after.{json,md}`)

Task 5 of brief 01, with what you measured: (1) street riflemen: 21 s of 30 in `cooldown_s` 1.4 between bursts of 4,
and no lead (the `GuardBrain` trigger never reads `aim_lead`); (2) the rocket trooper: about 18 s of 30 repositioning;
(3) the turret's traverse and the war machine's alignment (bosses' designs stay: do not change the war machine's
behaviour, only report it).

- Riflemen: wire the existing linear lead into the street rifle trigger, with a tunable share in the table (the
  `assault-rifle` row `aim_lead`, 0 = today's behaviour; start at the share that hits a circling Rivet at 10 m, measured),
  and shorten `cooldown_s` (suggest 1.4 -> 0.8; keep the burst).
- Rocket trooper: let it fire from where it stands when it has line of sight and the cooldown is up, instead of
  repositioning first (a table value in `enemies.json` if the rule needs one; 0/false = today's behaviour). Its tell
  stays (`telegraph_s`); never below 0.30 s; say which number you kept and why.
- `enemy_fire` (`weapons.json`) `rest_s` 1 -> 0.5 for the range drill path.
- Targets: rounds per second for each ranged type up by 1.5x-2x versus `before`; circling at 10 m is hit at least once
  per 3 s by a single patrol_cop and gets non-zero hits from the rocket trooper; standing is still hit more than circling.
- Replays: a shipped tape that holds rifle fire will move: list each with a reason (and one decisions line); a scenario
  that now FAILS its pass condition: report it, do not weaken it.
- Re-run the tool, commit `after.{json,md}` with the change. Mutate `guard_brain.gd` (`--max=20 --lines=<changed>`).

## Report

Per task: sha, files, checks with result lines, the before -> after rounds/s and circling hits per type, moved
digests, NEEDs.
