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

- 18:37 MILESTONE fire-gap tool `ace15ca16` (01b task A): `project/dev/gauntlet/fire_gaps.gd` (+ arena, clock, test),
  `evidence/n24-pressure/fire-gaps/before.{json,md}`, debt baseline through the tool (dev_loc 30712 -> 31109, reason
  recorded). Read: accepted. Astra `gaps` still running on tasks B and C.

- 18:46 Astra `gaps` on task B (uncommitted: `combat.json`, `gauntlet_street.gd`, `test_gauntlet_wave_timer.gd`,
  `docs/decisions.md`, and `project/tests/unit/test_dock_waves.gd`: check WHY a dock test moved with the rifle damage
  before accepting). ASTRA RUNNING gaps since 18:31, lock pid 9736, hard stop 19:45.

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

## Session 2 (18:47 - 20:17)

- 18:47 start. astra.lock pid 9736 alive (node, `gaps` since 18:31, hard stop 19:45); out file empty until it ends.
  Uncommitted Astra edits (task B): `combat.json` rifle 1.2, `gauntlet_street.gd`, two tests, decisions, gauntlet-loop.
  grep `NEED pressure`: ghost 17:35 (served in brief 04 task 2b), melee 18:39 (info: n24-melee one swing per click,
  melee kills humans in one landed swing from P2: re-measure after merging n24-melee; nothing for the bot to change
  unless its melee relied on the chained 2nd hit). Ghost `MILESTONE ready 8d1d6fef1` (18:38). Motion: no
  `MILESTONE dash` yet (dash resume running since 18:33).
- 18:47 review note on task B: `test_dock_waves.gd` "weak rounds" (`< max_hp * 0.25`) replaced by an exact 36.0:
  that drops the test's meaning. Ask for a bound that still says "weaker than Rivet" instead of a pinned value.
- 18:52 DECISION pressure: `project/features/combat/squad/foe_rocket.gd` (the rocket trooper's trigger and
  reposition, logic not view) is pressure's tonight: it is enemy fire timing; cast owns only the `foe_*view*.gd` files
  in squad/, and no lane has touched `foe_rocket.gd` since main (`git log main..HEAD` in all four worktrees: empty).
  Granted to Astra in the follow-up when it reports the NEED.
- 19:46 ASTRA gaps 75 accepted (tasks A `ace15ca16`, B `4e516c297`; C staged, hook cut at 19:40). Read C's diff:
  rifle `cooldown_s` 1.4 -> 0.5 + `aim_lead` 0.9 (gauntlet `StreetSquad._ranged` -> `GuardBrain.street_aim`, lead held
  through the 4-round burst), `turret_gun` cooldown 1.5 -> 0.75 / burst gap 0.065, turret `telegraph_s` 0.9 -> 0.6,
  `rocket` cooldown 2.2 -> 0.85, `enemy_fire.rest_s` 1 -> 0.5; quest 1 input digest 37bf8deacaad -> a113296dbccc (the
  shared rifle cooldown; decisions line present). Accepted.
- 19:50 MILESTONE gaps `eb5e0600e` (director committed Astra's staged C through the hook: lint 19/19, tool-tests ok,
  ~10 min). Rounds/s per type before -> after (`evidence/n24-pressure/fire-gaps/{before,after}.md`): patrol_cop / swat /
  robot_gunner / contractor 2.13 -> 4.03; turret 2.10 -> 3.90 standing (circling 1.50 -> 2.60); rocket trooper 0.33 ->
  0.33; war machine 0.40 (boss design, unchanged). Hits on a Rivet circling at 10 m in 30 s: rifles 0 -> 25-38, rocket
  0 -> 0, turret 0 -> 0. Standing still is hit about twice as often as circling (patrol_cop 60 vs 27 hits).
  Tells: rifle none (bursts), turret 0.6 s, rocket 1.0 s, drill `tell_s` 0.35 kept.
- 19:50 FRICTION the pre-commit hook takes ~10 min on a table commit (tool-tests read the tables): Astra's 19:40 cutoff
  cut it. Briefs: last commit 10 min before the hard stop.
- 20:00 ASTRA RUNNING rocket-gap since 20:00 (resume; brief `evidence/briefs/n24-pressure-01c-rocket-gap.md`: rocket
  trooper fires from where it stands + lead, dock test bound, mutate guard_brain; lock pid 63052, hard stop 20:45).

NEXT (session 2 end, 20:1x; Astra `rocket-gap` running until <= 20:45):
1. Check `astra.lock` / last line of `astra-calls.jsonl`; read `evidence/briefs/n24-pressure-01c-rocket-gap.out.txt`.
   Review task D (foe_rocket.gd: fire from where it stands, `relocate_after_shots`, rocket lead; rocket rounds/s >= 0.5,
   circling hits > 0) and E (dock bound, mutate scores). Bounce short work into brief 02 as task 0 rather than a new call.
2. Right after it ends: the after-gaps batch (Godot is free between calls; ~20 min):
   `node tools/gauntlet/ablate.mjs --name=after-gaps --rev=HEAD -- --profile=all --pick=greedy --controls=wheel --seed0=1 --seeds=5 --waves=40 --jobs=1 --out=<abs>/evidence/n24-pressure/after-gaps`
   (check ablate's own usage first). Compare with base-main: if average dies before wave 6, keep the owner's doubling
   and plan budget/count knobs (brief 05).
3. Then launch brief 02 (deflect; fill HARDSTOP/COMMITBY = start + 75 min / start + 65 min; last commit 10 min before
   the stop because of the hook). Then 03, then 04 (after merging n24-motion at `MILESTONE dash` and n24-ghost
   `8d1d6fef1`). Brief 05 (not written): films (deflect, rocket/nail, average fight punished) + tuning knobs.
