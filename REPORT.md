# REPORT - lane `guard`, run n22 (2026-11-21): the held guard, the weapon wheel, round sizes, blasts

Branch `n22-guard`, interface tag `n22-guard-iface` (82bb7a4f5). Last code commit 13d97df81; everything after it is
`JOURNAL.md`, `REPORT.md` and briefs (inert).

**Final gate** (`node tools/gate/run.mjs --rev=HEAD` on 13d97df81, 05:39 to 05:49): `gate: PASS;
build/gate/13d97df81258/gate.json` (git-ignored, on this worktree). Lint 19/19 over 1844 GDScript files; unit 3481 passed /
0 failed / 2 skipped; scenarios 65 passed; parity bit for bit over 1200 steps, planted mutation caught at step 629; selftest
pass; export audit (release compile) 829 loaded / 0 failed. `--reels` was not run: this session ends at 07:10, before the
07:30 freeze.

Numbers below are from Astra's reports and my own reruns, as logged in `JOURNAL.md`.

## What works

| Item | Evidence | Number |
|---|---|---|
| Interface: action `guard` (wire bit 30), `Shot.size` (`Shot.SMALL` / `Shot.LARGE`), `"round"` key (absent = small), `combat.json` `guard` block (7 keys + `melee_drain`), `--controls=wheel\|legacy` (legacy default) | 82bb7a4f5, `project/features/player/controls_mode.gd`, `project/features/combat/shot.gd` | scenarios 65 passed, 60 s replay `cbeb734ff9b97c41` unchanged |
| Round sizes: rockets, thrown weapons, the enemy cannon are `large`; everything else small; the plasma sword's `bat()` still deflects all | e3d5799e8, `project/features/combat/enemy_rounds.gd` | |
| Held guard with a meter: front arc, walk at `move_k`, no attack while up, roll drops it, small rounds deflected back as Rivet's, large rounds pass, break -> stagger -> refill after a delay, front melee drains `melee_drain` | 8a8a0d93c, 57a72ca0f, `project/features/player/player_guard.gd` | mutate `player_guard.gd` on HEAD (05:50, `--max=20`, sampled from 97): 19/20 = 95.0 %; the one survivor is the initial `_up = false` -> `true` (line 22), which the first tick overwrites. (Was 15/20 = 75.0 % before the survivor tests.) |
| Guard pose, deflect spark, amber break flash, meter readout | 123ec794d, `project/features/player/player_guard_view.gd` | |
| Hostile blasts hurt Rivet with falloff through `CombatArena.damage()`, stopped by `wall_high` / `cover_high` on the segment, `cover_low` only in the cover stance, roll i-frames, Tonnage 0.3x | 97352761e, 7445d8fd5, `project/features/combat/rivet_blast.gd` | 18 blast tests; mutate `rivet_blast.gd` 18/20 = 90.0 % (both survivors then killed) |
| Weapon wheel (wheel controls only): hands first, melee then guns in pick-up order, scroll cycles, 1-4 jump, LMB uses the slot, RMB guard only, Space a claw strike keeping the selection, readout | 35b75625e, 19eec5c03, `project/features/player/rivet_wheel.gd` | mutate `rivet_wheel.gd` 14/20 = 70.0 % before survivor tests |
| Hash neutral at rest: an untouched guard, wheel and implicit carry write zero pilot bytes, so a wheel run that never uses them hashes as legacy | af073cf1c, `project/tests/unit/test_rivet_wheel_rest.gd` | quest 1 input replay under wheel `37bf8deacaad2f48` = legacy (38,100 bytes); was `7cb7efb9c1c6253c` before |
| Wheel readout: 20 px cream on ink, holds 0.6 s then fades | 371ccf9fe, 043f5b53c, `project/features/player/wheel_readout_view.gd` | mutate 11/20 = 55 % (9 survivors are pixels only) |
| Wheel start alternative `--wheel-start=hands\|drawn` (absent = hands), off | e58e503bf, 13d97df81, `project/tests/unit/test_rivet_wheel_start.gd` | wheel blockers 16 -> 5 under `drawn` |
| Legacy unchanged | legacy pilot state bytes pinned over a fixed 64-tick input (`project/tests/unit/test_rivet_wheel_pilot.gd`) | 60 s replay `cbeb734ff9b97c41` after every commit; on 043f5b53c: lint 19/19, unit 3477 passed / 0 failed / 2 skipped, scenarios 65 ran / 0 failed |

## What does not

- **Wheel is not the default.** Under `--controls=wheel` 49 of 65 scenarios pass, 16 fail (legacy 65 / 0). The 60 s replay
  (`cbeb734ff9b97c41`) and quest 1 (`37bf8deacaad2f48`) are byte-identical in both modes. The 16 fail because their bot tapes
  were written for legacy: the wheel opens on hands, so a tape that holds `fire` with a gun punches instead (arena city / pit /
  range / squad, brutality, city scare, moves replay, react line, rivet cover, showcase director / reel); `melee` (Space) is a
  claw strike under wheel, not the drawn blade (rivet katana / chainsaw); pickups no longer auto-equip (rifle rack, rivet pickup);
  cycling includes hands (rivet switch). Also blocking: the quest 1 help card (`project/boot/quest1_card.gd:14`) still says
  right click is electroshock; `tools/tests/run_unit.mjs` and `run_scenarios.gd` do not accept `--controls=wheel`, so a full
  wheel unit run was not done. Full table with the pin per file: `evidence/guard-flip/blockers.md`, all 65 digests:
  `evidence/guard-flip/flip-table.md`.
- Telemetry, not our files: `StagePilot._attacks` (`project/boot/collect_call/stage_pilot.gd:100`) counts one buffered claw
  start as five `melee_swings` while the primary is held; `ArenaStage.step` (`project/features/arena/arena_stage.gd:95`) culls
  shots before the arena clock advances, so a wall burst is stamped one tick early (view age and repair timing).
- A blast stopped by a wall still draws its smoke ring across the wall in play (the film stages the wall wide enough that it
  reads). Clipping the ring to the launcher's side needs the wall-face normal at the draw call in
  `project/features/combat/weapons/fight_areas_art.gd:45` and `project/features/combat/weapons/art/weapon_fx_art.gd:149`
  (shared weapon art, outside this lane's files tonight).
- The dev film's rocket launcher is a cop rig firing through the `EnemyRounds` seam (foes owns the rocket trooper).

## What blocked or slowed me

- a1: the first brief's allowlist missed that enemy weapons load in foes' `ai/enemy_roster.gd`; Astra stopped correctly; a
  guard-side resolver (`EnemyRounds`) replaced the edit. About 5 min.
- a3: restoring two doc comments Astra had deleted tripped the debt ratchet and Astra stopped the whole call on it; resumed
  with the debt tool allowed. About 5 min.
- I overwrote an old night's tracked brief (`evidence/briefs/a5-films.md`) with a new draft and restored it. About 2 min.
- The scenario and unit runners reject `--controls=wheel`; Astra measured the wheel suite on a scratch copy. About 10 min of
  its call.

## Films and stills (`C:/Users/kazda/kiro/gtai-masters/n22/guard/`, `frames.json` 13 entries, best first)

- `guard-film-32ppm.mp4`: 40.00 s, 1080p60, 32 px/m (dev scene `project/dev/guard/guard_film.gd`): three blue cops fire pistols
  into the raised guard (white spark, the round flies back as Rivet's), the meter empties and breaks (amber), refills; a rocket
  passes the guard and hits (100 -> 72 HP); a rocket bursting on a wall face with Rivet behind it (100 HP) and one in the open
  (-28 HP); the wheel going Hands, Katana, Pistol with the readout.
- Before/after at the same tick: `before-legacy-t85.png` (legacy: hands down, 94 HP) / `after-wheel-t85.png` (guard up, 100 HP,
  meter 88 %); `wall-stopped-before-t137.png` (a5 staging) / `wall-stopped-t137.png`.
- 64 px/m close-up: `guard-closeup-64ppm.png`.
- What I looked at myself: the t85 pair, the break, the impact pair t113 / t351, the readout crop at t163, the wall aftermath
  t137 / t371.

## Calls for the owner

1. **Wheel opens on hands, or on the weapon the stage hands Rivet?** Your words were "hands melee as first native choice": the
   default reads that as slot 0 AND the opening selection. The alternative is built and off: `--wheel-start=drawn` (hands
   stays slot 0, one scroll away). Measured under `--controls=wheel` (`evidence/guard-flip/wheel-start-drawn.md`): hands
   49 passed / 16 failed, drawn 60 passed / 5 failed, no new failure; 60 s replay `cbeb734ff9b97c41` and quest 1
   `37bf8deacaad2f48` unchanged in all three columns. The 5 left (rifle rack, rivet chainsaw / katana / pickup / switch) are real
   behaviour changes their tapes must learn (Space = claw, no auto-equip on pickup, hands in the cycle).
   Still: `gtai-masters/n22/guard/wheel-hands-t441.png`.
2. **Make wheel the default** once the tapes are re-pinned (list in `evidence/guard-flip/blockers.md`) and the quest 1 help
   card is rewritten per control mode.
3. Rivet's own blasts never hurt him (self-damage off). One flag value away if you want rocket-jump risk.
4. The guard pose: forearms in front, collar visible; at 64 px/m it reads as a block mainly through the white spark
   (`gtai-masters/n22/guard/guard-closeup-64ppm.png`).
5. Space under wheel is a quick claw strike that keeps the selection (not a switch to hands).

## Merge notes

- Measured at 06:02 with `git merge-tree` against the lane heads. **Code conflict with n22-foes** in
  `project/features/combat/combat_arena.gd` `damage()`: guard adds `if guard != null and guard.blocks_melee(self, victim,
  killer_id, weapon, kind): return`, and foes adds `amount *= FoeArmor.impact(self, victim, kind, killer_id, weapon)` on the same
  line. Keep both, guard first: a blocked melee hit returns before any armour maths, then foes' armour scales what is left,
  then `victim.damage_k`. `tools/debt/baseline.json` conflicts with all three lanes: `node tools/debt/merge_baseline.mjs`, commit,
  then `--update`. `JOURNAL.md` / `REPORT.md` add/add with street and loop: keep each lane's own. Auto-merged, worth
  a look: `project/boot/launch_args.gd` (KNOWN_FLAGS lines from several lanes), `project/features/arena/arena_rigs.gd`,
  `project/features/arena/arena_stage.gd`, `project/data/tables/enemies.json` (guard's `round` on the existing `cannon`).
- Street: street's project/dev/gauntlet/gauntlet.gd (on n22-street, not on this branch) must pass `--controls=wheel` itself (at street `a3a06df84` it only reads
  `ControlsMode.id()`), otherwise `StagePilot.guard` is null in the gauntlet. `GauntletWaveStats.append_guard_deflects`: snapshot
  `stage.pilot.guard.deflects` at wave start, write the delta at finish, omit under legacy.

- Street wires `StagePilot.guard.meter_k = StatMods.value(&"guard_meter")` and reads `meter()` / `broken()` into
  `GauntletHud/Status/GuardMeter`; the guard exists only under `--controls=wheel` (`StagePilot.guard` is null under legacy).
- Foes: any hostile shot whose `enemies.json` weapons row has `splash_radius_m` > 0 bursts through `RivetBlast.burst` at contact,
  range end or a wall face. Foes' own `ArenaSquad.rockets.burst` seam exists on their branch: check a rocket does not burst twice
  after merging both.
- Nit: `RivetWheel.carry_for` reads `CombatArena._rng` (a private field); `CombatArena` needs a public accessor (not our file).
- Nit: the cover stance is read through a `set_meta` weakref on Rivet's Fighter (not hashed state).

## Next steps

1. Owner's Call 1 (wheel's opening selection), then re-pin the 16 tapes per `evidence/guard-flip/blockers.md`, rewrite the
   quest 1 help card per control mode, teach `run_unit.mjs` / `run_scenarios.gd` to pass `--controls=wheel`, flip the default.
2. Clip a wall-stopped blast's drawing to the launcher's side (`fight_areas_art.gd:45`, `weapon_fx_art.gd:149`).
3. Count melee swings from combo starts (`stage_pilot.gd:100`) and stamp wall bursts with the impact tick (`arena_stage.gd:95`).
4. Give `CombatArena` a public RNG accessor so `RivetWheel.carry_for` stops reading `_rng`; replace the cover stance meta weakref
   with a typed field.
5. Loop's tuner: every guard number is in `combat.json` `guard` (arc 120, move_k 0.45, meter 100, drain 12, refill 40/s after
   0.6 s, stagger 0.8 s, melee_drain 20).

## Astra ledger

| Call | Minutes | Verdict | What it did / what I would brief differently |
|---|---:|---|---|
| a1-iface | 1 | bounced | stopped at the allowlist (enemy weapons load in foes' files). Brief: scout the loaders before writing the allowlist. |
| a1b-iface | 29 | accepted | interface + round sizes |
| a2-guard | 60 | accepted | guard logic, survivors, views. Brief: forbid deleting comments up front (it did). |
| a3-blast | 3 | bounced | a comment restore tripped the debt ratchet and it stopped everything. Brief: name the debt tool in every brief. |
| a3b-blast | 41 | accepted | hostile blasts with occlusion |
| a4-wheel | 33 | accepted | the wheel |
| a5-films | 33 | accepted | wheel survivors, dev film scene, film + stills |
| a6-flip | 61 | accepted | hash-neutral at rest, decisions, flip measured, legacy kept |
| a7-polish | 25 | accepted, one test left red | readout, film staging; the blast view was outside my allowlist. Brief: allow a lane's own tests named for the file under change. |
| a8-green | 15 | accepted | fixed the red assertion; full lint, unit, scenarios green on 043f5b53c |
| a9-wheel-start | 22 | accepted | `--wheel-start=drawn` flag (off) + measured 16 -> 5 blockers; changed-line mutate 2/3 and 1/7 (adoption path thin: flag off) |
