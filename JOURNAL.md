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
- 20:08 read motion `MILESTONE dash 9f4ce27a9` (18:50: `dash` bit 18 / wire 31 on Shift, sprint keys [], mask 48 bits,
  `rivet_motion.json` dash {distance_m 4.5, ticks 10, cooldown_ticks 40, iframe_ticks 0, enabled true}; gauntlet
  `dashes` per wave `ca2ada5f2`). Their director still owes a review (double `rest_tick`?). Merge plan: after
  `rocket-gap` ends and before brief 02 starts: `git merge --no-edit n24-motion` (record the sha; JOURNAL/REPORT
  add/add: keep ours), then unit `--changed` + scenarios once. The after-gaps batch goes through ablate `--rev=<pre-merge
  HEAD>` in a temp worktree, so the merge does not leak into it. Ghost: merge `n24-ghost` (>= 8d1d6fef1) before brief 04.
NEXT (unchanged order): rocket-gap review -> merge n24-motion -> after-gaps batch (rev = pre-merge HEAD) -> brief 02.

## Session 3 (20:04 - 21:34)

- 20:06 start. astra.lock pid 63052 alive (node, `rocket-gap` since 20:00, hard stop 20:45); out file empty. Uncommitted
  Astra edits so far: enemies.json/schema, fire_gap_clock, enemy_weapon, foe_rocket + its two tests.
- 20:45 ASTRA rocket-gap 45 accepted. D `1d0dc5624`: rocket trooper fires from where it stands, relocates after
  `relocate_after_shots` 2 (0 = old rule), `aim_lead` 0.8, cooldown 0.85 -> 0.55, speed 9 -> 16 m/s, tell 1.0 -> 0.8 s
  (kept >= 0.6: readable, dash/step aside). Rocket rounds/s 0.33 -> 0.60; hits in 30 s standing 10 -> 18, circling 0 -> 9,
  strafing 5 -> 2. E `56b0caa1c`: dock bound "full magazine < half Rivet" (36 < 50), rifle burst-aim test. Mutate
  guard_brain 1/1 (1 of 14 done), foe_rocket 2/3 (3 of 20; `forget_site()` survivor -> sight-loss test written,
  UNCOMMITTED in `test_foe_rocket_sites.gd`, unverified). Unit --changed 3776/0. Quest 1 identical.
- 20:45 BLOCKED-ish: full scenarios 67 ran / 5 FAILED at 56b0caa1c (were 67/0 after db2043604 damage x2): arena_squad
  (no flank tick), gunplay_fire (standing Rivet took 17/30 machine-pistol rounds < 60% floor), prologue_checkpoint
  (death at tick 6207), prologue_pilot (budget expired encounter 2), rivet_city_melee (faulty bot control still drops
  five). Suspects: 01b rifle cadence 1.4 -> 0.5 s + lead + x2 rifle damage (prologue deaths), lead on a near-still Rivet
  (gunplay_fire). Goes into brief 02 as task 4 (after deflect) with decision rules.
- 20:50 merge `n24-motion` (6ab9195d2) into the lane: only JOURNAL.md add/add (kept ours). The hook failed 2 tool tests
  (`tools/merge/clash.test.mjs` :110, :125, "string argument undefined"); alone they pass 7/7 (261 s): the hook's git
  env during a merge. FRICTION ~15 min. Retried the merge commit through the hook at 21:03.
- 21:02 MILESTONE after-gaps batch started (detached): `ablate.mjs --name=after-gaps --rev=032f6de91` (pre-merge HEAD:
  x2 damage, no in-wave repair, 45 s timer, gaps, rocket) same args as base-main -> `evidence/n24-pressure/after-gaps/`,
  log `evidence/n24-pressure/after-gaps.out`. This is the lane's Godot until it ends (~21:25); brief 02 says GODOTFREE.
- 21:06 MILESTONE merge n24-motion `b0a9c4c09` (motion head 6ab9195d2, dash `9f4ce27a9` + `099db00f4` one cooldown
  step per tick); retried hook passed 19/19. Unit/scenarios on the merge: Astra runs them in brief 02 (after 21:30).
- 21:09 ASTRA RUNNING deflect since 21:09 (brief `evidence/briefs/n24-pressure-02-deflect.md`: task 0 commit the
  rocket sight-loss test, 1 deflect block + rule, 2 passed-round spark, 3 hit-share tool/table, 4 the five red
  scenarios; lock pid 62596, hard stop 22:20, commit by 22:08, Godot free for it from 21:30).
- 21:09 FRICTION the first launch (Git Bash `nohup ... &` followed by a slow `ls $TEMP`) hung the tool call; its
  timeout would tree-kill nohup -> Astra. Killed my own tree by PID at 3 min (no edits made), removed the dead lock,
  relaunched with PowerShell `Start-Process node ... -RedirectStandardOutput <out> -WindowStyle Hidden -PassThru`
  (parent = nobody of the tool). Use that form for every launch. ~6 min lost.
- 21:18 MILESTONE after-gaps batch done (16 min, 15/15 ok, rev 032f6de91: x2 damage, no in-wave repair, 45 s timer,
  shorter gaps, rocket; deflect still 100%, no dash in the bot). `evidence/n24-pressure/after-gaps/report.md`.
  Median death wave before (base-main) -> after-gaps: novice 13 -> 5 (target 6), average 40 (4 censored) -> 10 (target
  12, P25-P75 5-15), expert 40 (5 censored) -> 12 (target 20, 3-32). Censored 9/15 -> 0/15. Separation: avg->expert gap
  2 (below target). Killers: war machine (wave-5 boss) 10 of 15 deaths (stomp 7, war_cannon 3), rocket 4, patrol_cop 1.
  Every novice dies at wave 5 to the stomp. Stomp row: damage 48 AND splash 48 in 3.5 m (Rivet max_hp 100): check
  whether one stomp lands both (96): if so it is a double count, not design. Expert's losses are stomp/rocket = things
  a skilled player steps or dashes out of: brief 04 (bot dash out of rocket path and stomp radius) is the main lever
  for expert; then knobs. Deflect at 50% (brief 02) will push all three down further.
- 21:20 DECISION pressure: keep the owner's doubling. If after deflect + bot dash the average still dies before 6 or
  expert sits far below 20, move non-owner knobs (war machine wave slot or stomp tell/radius are boss design: NOT ours;
  ours: street budget, counts, `enemy_fire`, rocket cooldown/relocate, rifle `aim_lead`) and say so in REPORT.

NEXT (session 3 end 21:3x; Astra `deflect` RUNNING since 21:09, lock pid 62596, hard stop 22:20, out
`evidence/briefs/n24-pressure-02-deflect.out.txt`; launched with PowerShell Start-Process: do the same):
1. Wait for `deflect` (do not start another call while pid 62596 is node). Review: `deflect` block (pass_ratio 0.5,
   pass_ratio_k 1.0, spread_deg 12, basic_rounds [small]), RNG stream `&"deflect"`, both paths (guard + bat), the
   passed-round spark (not teal/red), hit-share table `evidence/n24-pressure/deflect/`, task 4 (five red scenarios:
   arena_squad, gunplay_fire, prologue_checkpoint, prologue_pilot, rivet_city_melee) and any `NEED director` on the
   prologue pilot. Run `node tools/tests/run_unit.mjs --changed` yourself; mutate score on player_deflect.gd.
2. Launch brief 03 (rocket + nail; fill HARDSTOP = start+60, COMMITBY = start+48, GODOTFREE = start+20) and in its
   first 20 min run the re-measure batch on HEAD (after deflect): `ablate.mjs --name=after-deflect --rev=<HEAD>` same
   args -> `evidence/n24-pressure/after-deflect/` (then `report.mjs --batch=... --out=<dir>` writes into `<dir>/report.md/`:
   pass the DIRECTORY, then it is `<dir>/report.md`; this session passed a file path and had to move it).
3. Before brief 04: `git merge --no-edit n24-ghost` (JOURNAL add/add: keep ours; if the hook fails on
   tools/merge/clash.test.mjs, run that test alone, then retry: it is the hook's env in a merge). Brief 04 hard stop
   <= 00:05, commit by 23:52; add to it: "check whether a stomp lands damage AND splash on Rivet (96 of 100)".
4. 00:00 last new work; 00:15 final gate `node tools/gate/run.mjs --rev=HEAD`; then films (deflect, rocket/nail, average
   fight punished) and REPORT. The after-* batches give the before/after table (base-main vs final).
- 21:24 peek at `deflect` (uncommitted, in progress): new `DeflectRule` called from `combat_arena.gd` `write_state`
  first line (one-line call site; the class doc line "only the `combat` RNG stream" was removed to stay at the cap: it
  is no longer true, fine). REVIEW: `DeflectRule.write_state` must write NOTHING on a tape with no deflect, else every
  replay digest moves (check `replay_60s` digest and quest 1 `a113296dbccc` unchanged in Astra's scenario line).
  Also touched: `gauntlet_combat.gd`, guard tests, `test_gauntlet_wave_stats.gd`, `test_live_deflect.gd`.
- 21:25 ASTRA RUNNING deflect since 21:09 (lock pid 62596, hard stop 22:20). Session 3 ends; NEXT above (21:20) stands.

## Session 4 (21:24 - 22:54)

- 21:25 start. `deflect` still running (pid 62596 = node, hard stop 22:20). NEED pressure grep: ghost 21:16 (ghost
  builds the deploy bot itself, `GhostDeployBot` + ONE call site in `bot_brain.gd` `_pack`: ACCEPTED, brief 04 task 2b
  replaced by "not yours, keep `_pack` stable"); melee 18:39 / 21:08 (one swing per click, melee one-shots humans,
  electro baton shuts robots down: re-measure after merging n24-melee; no `MILESTONE ready` from melee yet).
- 22:08 ASTRA deflect 59 accepted. fcbe724b5 (rocket sight-loss test), 45acfc887 (deflect block pass_ratio 0.5 /
  pass_ratio_k 1 / spread_deg 12 / basic_rounds [small]; `DeflectRule` on registry stream `&"deflect"`, both guard and
  plasma bat; guard pass = half drain + full damage; bat still returns large rounds exactly = today's rule; mutate
  12/14), e1dba38eb (passed round: rim splits into two white fragments, 2/2), 41bf76e7d arena_squad, d314d9861
  gunplay_fire, a9e8adc78 rivet_city_melee (bounds re-set for the new cadence, each claim argued). Hit share of RETURNED
  rounds on the shooter, guard/bat: 6 m 42/52% at 12 deg (84/96% at 6 deg, 24/31% at 20), 12 m 19/20%, 20 m 10/10%.
  Keep 12 deg. Replay digests unchanged (legacy guard tape pinned, replay_60s pass). Probe `deflect_share.gd` and
  `evidence/n24-pressure/deflect/` uncommitted (debt metric dev/gauntlet 919 -> 1087): brief 03 task 0a commits it with
  `--accept-regression`. Still red: prologue_pilot, prologue_checkpoint (SWAT + Mulroney 34-39 HP/s; combat.json
  `assault_rifle.cooldown_s` 1.4 -> 0.5 from 01b is the cause; 1.4 passes).
- 22:10 DECISION pressure: the prologue's fights must keep passing (its script is not ours); brief 03 task 0b finds the
  shortest `assault_rifle.cooldown_s` (0.8 / 1.0 / 1.2) at which both prologue scenarios pass; damage x2 and lead stay.
- 22:13 ASTRA RUNNING rocket-nail since 22:12 (pid 46936, --resume, hard stop 23:26, commit by 23:14; tasks 0a probe commit, 0b prologue rifle cooldown, 0c rocket speed for motion's 5 m dash test, 1 rocket look, 2 nail). MILESTONE after-deflect batch started 22:13 (pid 24268, ablate --rev=a9e8adc78 -> evidence/n24-pressure/after-deflect/), Godot handed to Astra at 22:34.
- 22:12 unit --changed after deflect: 3814 passed, 1 failed: motion's test_player_motion_dash_dodge.gd:60 (rocket from 5 m: our 16 m/s rocket lands in 19 ticks, before reaction 15 + dash). DECISION pressure: the rocket must stay dashable after a human reaction (owner: dash dodges major projectiles): highest speed at which motion's test passes (brief 03 task 0c); motion's test is not edited.
- 22:20 MILESTONE after-deflect batch (rev a9e8adc78, 7 min, 15/15 deaths): median death wave novice 5 (target 6),
  average 5 (12; P25-P75 3-5), expert 7 (20; 5-9). Censored 0/15. Killers: rocket 6, stomp 5, sentry, contractor,
  shield_robot, swat 1 each. Average dies at waves 3-5: the 01c rocket (cooldown 0.55, 16 m/s, 32 + 20 splash, lead 0.8)
  plus deflect at 50% overshoot. `evidence/n24-pressure/after-deflect/report.md`.
- 22:21 arm-rocket14 started (ablate --set rocket cooldown_s 1.4, speed_mps 13; same seeds; pid 46028) inside my Godot
  window (to 22:34): does a slower rocket bring average back toward 12 before the bot learns to dash?
- 22:27 arm-rocket14 (rocket cooldown 1.4, speed 13): median death novice 5, average 6 (P25-P75 5-11), expert 5 (5-10,
  max 25). Rocket deaths 6 -> 1. Wave 5 (war machine) is now the wall: stomp 6 of 15, + sentry/contractor. The stomp is
  NOT a double count: `foe_walker.gd:96` lands `splash_damage` 48 only (two stomps kill). DECISION pressure: rocket
  cooldown 1.4 (brief 04 task 0; speed from brief 03 task 0c); the stomp lever is the bot stepping/dashing out of the
  0.8 s tell (brief 04 task 2/2c), not the boss's numbers. Expert at 5 < novice is noise of 5 seeds + no dash.
- 22:32 REPORT.md drafted (before/after table so far, RPS table, deflect share). Brief 04 times set: hard stop 00:08,
  commit by 23:55, Godot Astra's from its start (adjust if 03 ends early: launch = 03 end + review; hard stop never
  later than 00:08).

NEXT (session 4 end; ASTRA RUNNING rocket-nail since 22:12, pid 46936, hard stop 23:26, out
`evidence/briefs/n24-pressure-03-rocket-nail.out.txt`; Astra was committing 0a at 22:30, so my JOURNAL/REPORT/brief 04
edits are UNCOMMITTED: commit them with `git commit -- <paths>` when Astra's index is clean):
1. On rocket-nail's end: review 0a (probe + baseline), 0b (assault_rifle.cooldown_s value, prologue scenarios pass,
   quest 1 digest), 0c (rocket speed, motion's dash test green), rocket look (no ice blue on Rivet's rocket; enemy large
   stays `EnemyRoundLook.LARGE_*`), Gloria smallest round + `evidence/n24-pressure/rounds/sizes-{before,after}.md`;
   LOOK at the stills in `C:\Users\kazda\kiro\gtai-masters\n24\pressure\` at 32 and 64 px/m. Mutate scores quoted?
2. Launch brief 04 (`evidence/briefs/n24-pressure-04-bot-stall-dash.md`, `--resume`, PowerShell Start-Process as in
   22:12) right after: task 0 rocket cooldown 1.4, 1b damage_by, 2/2c dash + stomp step-out, 1 no-progress guard.
3. ~23:55-00:10 when 04 commits: `node tools/gate/run.mjs --rev=HEAD` (Godot is mine; Astra must be done). Then the final
   batch `ablate.mjs --name=final --rev=<HEAD> -- <same args> --out=<abs>/evidence/n24-pressure/final` (+ report.mjs
   --out=<dir>), then brief 05 (films; fill HARDSTOP 01:25, COMMITBY 01:15, GODOTNOTE "Godot is yours alone") with
   `--resume`. Merge n24-melee if `MILESTONE ready` appears before 23:30 only (else Merge notes: not merged).
4. REPORT: fill final row, Calls (deflect 12 deg vs 20; rocket cooldown 1.4 vs 0.55; prologue rifle cadence; expert
   far below 20 = the bot, not the game?), bonus rows (e.g. `deflect_plating` pass_ratio_k 0.8, `mirror_edge` spread
   x0.5, `reflex_servo` guard drain x0.75), ledger; `node tools/evidence/cites.mjs REPORT.md`.

## Session 5 (22:41 - 00:11)

- 22:43 start. rocket-nail still running (pid 46936 = node, hard stop 23:26; at 22:42 on task 0b, prologue rifle
  cadence, 0a staged not yet committed). No `MILESTONE ready` from melee. Ghost: g5 builds `GhostDeployBot` + one
  `_pack` call site (MILESTONE ready by 23:40); brief 04 keeps `_pack` stable. Plan unchanged (session 4 NEXT).
- 23:00 ASTRA rocket-nail 47 accepted (partial). 35341ab19 (0a deflect probe + share evidence; mutate 0/20: a dev probe
  no test maps, accepted as evidence code), e160b1eb1 (0b quest/prologue `assault_rifle.cooldown_s` 0.61 = 37 ticks, the
  shortest at which both prologue scenarios pass (30-36 fail); 0c rocket 13 m/s: the dash after a 15-tick reaction clears
  the 5 m blast by 0.18 m, 14 m/s deals 1.5). Quest 1 digest a113296dbccc -> c211ee9720fc (Dock 9 kill of actor 3 tick
  13301 -> 13302; still 1500 paid, 49 kills, 0 deaths; new tape replays identical). Rocket look + nail NOT done: Astra's
  arena fixture shows Rivet's rocket grey with a vermilion tip (no blue), and Gloria's nail is 47.2 x 12.8 px at 32 px/m
  (bigger than the Gatling's 48.6 x 6.7 by width): `evidence/n24-pressure/rounds/sizes-before.md`. I looked at
  `gloria-64ppm-t46-before.png`: the nail is a big dagger-like spike; the "64" still looks like 32 (sent back).
- 23:07 DECISION pressure: quest 1 digest move accepted (enemy rifle cadence is the changed behaviour; owner note 10);
  pin `scenario_quest1_input.gd:90` updated as a one-line change by pressure. `weapon_fx_art.gd` and `weapon_art.json`
  are owned by no lane and touched by no lane branch (git diff b3f4727c0..n24-{motion,melee,ghost,cast} empty, 23:07):
  pressure edits them for notes 1 and 2 (the round's drawn look). fx_view.gd: one call-site line allowed if needed.
- 23:02 ASTRA RUNNING finish since 23:02 (pid 54604, --resume, hard stop 00:08, last commit start 23:55; brief
  `evidence/briefs/n24-pressure-06-finish.md`: 0 rocket cooldown 1.4 + quest pin, R1 rocket look (find the blue in the
  real gauntlet), R2 nail smallest, D bot dash, E damage_by if time). Brief 04's stall task dropped.
- 23:10 4a1305bef task 0 (rocket cooldown 1.4; quest pin c211ee9720fc). 23:17 a5332156f R1: amber exhaust drawn on the
  round-colour canvas (`ShotDraw.launcher_exhaust`, the ink shader maps amber to vermilion otherwise), and fx_view.gd:268
  one line: the bare-hands path now tries `WeaponFxArt.shot` first (before: after a wheel switch to hands a rocket in
  flight drew as a thin black dash). LOOKED at `gauntlet-rocket_launcher-{32,64}ppm-flight-t91-pair.png` and the hands
  pair: the casing is warm grey (RGB 159,144,146, a red tip), NOT blue, before and after; no ice blue on Rivet's rocket
  anywhere (Astra searched every path). DECISION pressure: Rivet's rocket stays steel + amber exhaust; the owner's "blue
  rocket" may be the trooper's ice-blue enemy rocket (kept by the n23 verdict): Call for the owner with a side-by-side still
  (brief 05 Still 3 added). Brief 05 times filled (hard stop 01:25, commit by 01:15).
- 23:32 678f0ad72 R2 nail: `weapon_art.json` gloria `projectile_k` 0.68 + the nail drawn at native rig scale (no
  fx_draw_scale enlargement) in `weapon_fx_art.gd` `_cell_v`; Gloria 47.2 x 12.8 -> 16.05 x 4.35 px at 32 px/m, the
  smallest round (58 % of the molotov's length, 65 % of the Gatling's width); `evidence/n24-pressure/rounds/sizes-after.md`.
  LOOKED at `gauntlet-gloria-{32,64}ppm-flight-t91-pair.png`: at 64 px/m a small clean nail; at 32 px/m a speck that is
  hard to read in a fight. DECISION pressure: ship 0.68 (the owner asked for small), Call for the owner: 1.0 (about 24 x 6
  px, still the smallest in both axes) if it vanishes in play. No more commits for it tonight (00:00 rule).
- 23:41 802d01351 D: `BotDash` (dash out of a large round's path and a telegraphed stomp; `test_player.json`
  dash_chance 0.2/0.6/0.9, dash_read_ticks 30/16/8; `dashes` per wave via `gauntlet_wave_stats.gd`; `test_bot_dash.gd`).
  `_pack` / `_view` / `intent` / `_profile` kept (ghost's one line still fits). Astra goes on to E (damage_by).
- DECISION pressure: n24-melee and n24-ghost NOT merged by pressure tonight (melee wrote no `MILESTONE ready`; ghost's
  deploy bot lands on its own branch with its one `_pack` line; a merge now would put an unreviewed sim into the final
  gate). Merge notes say so; the final batch is pressure + motion only.

NEXT (session 5 end; ASTRA RUNNING finish since 23:02, pid 54604, hard stop 00:08, out
`evidence/briefs/n24-pressure-06-finish.out.txt`):
1. Wait for pid 54604 to exit (`tasklist //FI "PID eq 54604"`). Review E (damage_by) if committed: schema field, report
   section, digest untouched. Read Astra's report for mutate scores (D, R1, R2) and NEEDs; log `ASTRA finish <min> <verdict>`.
2. At once (Godot is yours): final batch, 7 min:
   `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/pressure; node tools/gauntlet/ablate.mjs --name=final --rev=HEAD -- --profile=all --pick=greedy --controls=wheel --seed0=1 --seeds=5 --waves=40 --jobs=1 --out=C:/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n24-pressure/final`
   (detached, out file `evidence/n24-pressure/final.out`). Fill the REPORT "final" row from `evidence/n24-pressure/final/report.md`
   (median death wave per level, P25-P75, censored, killers, dashes per wave, damage by source if E landed).
3. Then `node tools/gate/run.mjs --rev=HEAD` (start by 00:20 at the latest); quote its line + gate.json path in REPORT.
4. Then fill brief 05 (already timed 01:25 / 01:15) and launch it `--resume`, tag `films`, via PowerShell Start-Process as
   at 23:02. Look at its stills; check ffprobe lines. Still 3 (rocket pair) feeds Call 1.
5. REPORT: remaining TODOs (gate, final row, rocket RPS at 1.4, Call 1 pair, Call 6 expert after final, What does not,
   Next steps, ledger rows rocket-nail 47 accepted-partial / finish / films), then `node tools/evidence/cites.mjs REPORT.md`,
   commit JOURNAL + REPORT with `git commit -- <paths>`.
- 23:53 ASTRA finish 51 accepted. Mutate: R1 1/14 (exhaust geometry survives: a look, judged by the stills), R2 3/3,
  D 8/20 (`bot_dash.gd`), task 0 table-only. E (damage_by) NOT started (23:40 condition passed during D's hook): the
  judging table's "damage by source" comes from the batch report's killers only. Stall cause unverified (move holding
  squad attack slots suspected). Smoke: expert seed 7 cleared 6 waves dashing 0,0,0,1,1,3 per wave.
- 23:55 MILESTONE final chain started detached: `C:/Users/kazda/kiro/gtai-n24/logs/pressure/final-chain.sh` = final batch
  (`evidence/n24-pressure/final/`, out `evidence/n24-pressure/final.out`) THEN `node tools/gate/run.mjs --rev=HEAD`
  (out `C:/Users/kazda/kiro/gtai-n24/logs/pressure/gate-final.out`); chain log `.../final-chain.log`. Do not start Godot
  while it runs. NEXT (23:41) stands, steps 2 and 3 are this chain: read its outputs, then brief 05 films.
