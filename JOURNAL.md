# JOURNAL - lane pressure (n24, 2026-11-22), branch `n24-pressure` in `C:\Users\kazda\kiro\gtai-wt\n23-loop`

## Session 1 (17:22 - 18:52)

- 17:23 read: no JOURNAL yet, no astra.lock, no astra-calls.jsonl for pressure. Other lanes: no `NEED pressure`.
  motion wrote `MILESTONE iface` (its 17:30 line): dash = row bit 18 / wire bit 31; ghost_deploy = bit 19 / wire bit 32 (mask widened to 48 bits).
- 17:24 Godot `--import` in the lane: exit 0, 14 s (`evidence/n24-pressure/import-s1.log`).
- 17:25 MILESTONE baseline started: `tools/gauntlet/ablate.mjs --name=base-main --rev=b3f4727c0` (no edits, temp worktree, so
  builder edits in the lane cannot leak into it), greedy wheel, seeds 1-5 x 3 profiles, 40 waves, jobs 1 ->
  `evidence/n24-pressure/base-main/`. This is the lane's one Godot until it finishes.
- 17:26 DECISION pressure: the owner's "double their damage" goes into `enemies.json` `weapons` (damage and splash) and
  `weapons.json` `enemy_fire.damage_scale` (0.25 -> 0.5), game-wide, not only through the gauntlet's `enemy_damage_k`
  (stays 1): the owner played the game, not only the gauntlet. Tapes that hold an enemy hit move: listed in REPORT.
- 17:26 DECISION pressure: the 45 s timer from wave 6 and "repair between waves only" are new `gauntlet.json` values
  (`wave_timeout_late_s`, `wave_timeout_late_from`, `rivet.repair_in_wave`), so the old behaviour is one value away.
- 17:26 ASTRA RUNNING numbers-gaps since 17:26 (brief `evidence/briefs/n24-pressure-01-numbers-gaps.md`, lock pid 29104, hard stop 18:55)
- 17:44 MILESTONE baseline main `b3f4727c0` done (19 min wall, 15/15 ok; `evidence/n24-pressure/base-main/`, `report.md`):
  novice deaths 5/5 at waves 9, 11, 13, 20, 22 (median 13; rocket 3, shield_robot 1, stomp 1);
  average 1 death (wave 20, stomp), 4 censored alive at 40 (median >= 40);
  expert 0 deaths, 4 alive at 40, 1 STALLED to the 216000-tick cap at wave 21 (expert-2: the stall, item 6).
  In-wave repair undoes 85-100 % of each wave's damage (median per wave: damage 7.5-54, repaired 4-48 HP).
  Targets 6 / 12 / 20: novice 7 waves too deep, average and expert not measurable at 40.
- 17:56 MILESTONE damage x2 `db2043604` (Astra task 1): every `enemies.json` `weapons` damage + splash x2, melee
  archetypes' `production_damage` x2 (the squad melee hit, `foe_attacks.gd:50`), `enemy_fire.damage_scale` 0.25 -> 0.5.
  Read the diff: 18 numbers, all doubled, nothing else. Astra ran unit (exit 0) and scenarios 67 ran / 0 failed
  (prologue, quest 1, replay_60s ok): no digest or tape moved. Missing: a `docs/decisions.md` line (follow-up).
- 17:59 MILESTONE no in-wave repair `02bec2b14` (Astra task 2): `gauntlet.json` `rivet.repair_in_wave` false;
  `GauntletCombat.can_repair()` gates `_repair` on `wave_live` (set at a wave's first spawn, cleared at the block clear,
  `gauntlet_waves.gd:75,136`); the bot and the walker stop waiting for repair while it is unavailable. Read: accepted.
- 18:12 MILESTONE 45 s timer from wave 6 `624e58248` (Astra task 3): `wave_timeout_late_s` 45 / `wave_timeout_late_from` 6,
  `GauntletStreet.wave_timeout_ticks(wave)`, stacked-wave test (wave 5 90 s, stacked wave 6 45 s), `--wave-timeout`
  overrides both. Read: accepted, with one fix sent forward: a late value of 0 means "no timer at all" in Astra's
  build, my brief meant "late rule off, 90 s": task 0 of brief 02, together with the three missing decisions lines.
- 18:14 read ghost's `NEED pressure` (n23-moves JOURNAL 17:35): the bot's `power_hauler` transform presses go dead with
  `transform_unlocked` false; the bot must hold/release `ghost_deploy`. Served as task 2b of brief 04 (after the
  n24-ghost merge). Without it the post-ghost-merge batches measure a bot with no ghost powers: do not merge
  n24-ghost before brief 04 can run.
- 18:30 ASTRA numbers-gaps 64 accepted (tasks 1-3 committed; task 4 built, uncommitted: the debt ratchet,
  `dev/gauntlet` 526 -> 923 lines; task 5 not started). Its fire-gap table (`evidence/n24-pressure/fire-gaps/before.md`,
  uncommitted until 01b task A): a Rivet CIRCLING at 10 m takes 0 hits from every enemy type in 30 s (standing: rifles
  27-36 of 64, rocket 10/10). Riflemen (patrol_cop, swat, robot_gunner, contractor) fire `combat.json`
  `weapons.assault-rifle` through `GuardBrain` (21 of 30 s in its 1.4 s cooldown, no lead); rocket trooper 18.75 of 30 s
  repositioning; turret 8.6 s traverse; war machine 15 s aligning.
- 18:30 FRICTION brief 01: the riflemen's damage to Rivet is `combat.json` `weapons.assault-rifle.damage_vs_rivet` 0.6,
  outside `enemies.json`, so task 1's doubling missed the most common enemy. Fixed in 01b task B.
- 18:30 DECISION pressure: the street rifle row in `combat.json` `weapons` (`damage_vs_rivet`, `cooldown_s`, new
  `aim_lead`) and `features/combat/guard_brain.gd` fire timing are pressure's tonight: they are the riflemen's enemy
  fire numbers (the contract gives pressure enemy fire), no other lane lists them; `robo_tazer` stays melee's.
- 18:30 NEED melee: `combat.json` `robo_tazer.damage` 46 is an enemy attack on Rivet (Astra's reading); the owner's
  "double their damage" would make it 92: your call, it is your block.
- 18:30 not doubled, recorded for REPORT: `prologue_stage.json` shotgun / catch pole (prologue), `bosses.json`,
  `servo.json` (boss designs), `impact.gd` range-drill splash/burn.
- 18:31 ASTRA RUNNING gaps since 18:31 (resume of numbers-gaps, brief `evidence/briefs/n24-pressure-01b-gaps.md`, lock
  pid 9736, hard stop 19:45, commit by 19:40).

NEXT (session 1 end, 18:3x; Astra `gaps` is running until <= 19:45):
1. Check `C:\Users\kazda\kiro\gtai-n24\logs\pressure\astra.lock` and the last line of `astra-calls.jsonl`; read
   `evidence/briefs/n24-pressure-01b-gaps.out.txt` when it ends. Review tasks A (fire-gap tool + debt), B (rifle
   `damage_vs_rivet` 1.2, late-0 fix, three decisions lines), C (gaps: rifle lead + cooldown, rocket fires from where
   it stands, `rest_s` 0.5; `fire-gaps/after.md`). Bounce anything short of the targets in 01b task C.
2. Then launch brief 02 (deflect; fill HARDSTOP / COMMITBY), then 03 (rocket + nail), then 04 (stall, dash after the
   n24-motion merge, ghost deploy after the n24-ghost merge). Between Astra calls, run the after-numbers batch
   (same args as base-main, on HEAD, `--out=evidence/n24-pressure/after-numbers`), but only while no Astra call
   needs Godot (one Godot per lane): run it while the builder is still reading / editing, as session 1 did.
3. Grep motion's JOURNAL for `MILESTONE dash`, ghost's for `MILESTONE ready`; merge `n24-motion` at its dash milestone
   (`git merge --no-edit n24-motion`, record it), never while an Astra call runs.
4. Films (pressure): deflect half through / rest scattered; Rivet's rocket and Gloria's nail before beside after;
   an average fight where standing still is punished. Commit the last new work by 00:00, final gate by 00:15.
