# REPORT: lane enemy-ai (branch `e-enemy`), evening run 2026-11-03

Written 23:40-23:50 (REPORT phase, nothing new built). Working log: `JOURNAL.md`. Masters
evidence: `C:\Users\kazda\kiro\gtai-masters\eve\enemy-ai\` (written `M/` below). Lane evidence:
`evidence/enemy-ai/` (written `E/`). All performance and timing numbers are CONTENDED.

**The short version:** enemy brains, archetypes, squad tokens, telegraphs, suppression, waves
and the cast-rig fight scene all work in a dev pit. Rivet in that pit is still a scripted dummy
that fires nails, not the real pistol or claw. The robot thug borrows King's skeleton. There
is no clip from the city block, and the pit is not hooked into the arena scene yet. Because of
the owner's 21:25 rule (re-ask only with a real-time clip in the final look), no difficulty ask
is open.

## What works (claim -> proof)

| # | Claim | Evidence / command |
|---|---|---|
| 1 | Five archetypes as data: patrol cop (pistol), riot cop (shield + baton), SWAT (rifle, cover, flank), robot thug (claw, heavy, sparks), robot gunner. Each has a body class, hp, speed, weapon, aggression, an accuracy curve by range, reaction_s, telegraph_s, turn rate, stagger_s and hit_fx. Squad limits are in the same table. | `project/data/tables/enemies.json`, `project/data/schemas/enemies.schema.json`; decision line in `docs/decisions.md` (DECISION enemy-ai) |
| 2 | Brains on the 60 Hz tick, using the `enemy_ai` RNG stream for shot spread only. States: PATROL ALERT ENGAGE WINDUP FIRE RECOVER COVER FLANK PANIC DOWN DEAD, plus stagger and flinch. Senses: a sight cone, hearing a shot, line of sight against cover, cover spots, a corner detour. | `project/features/combat/ai/enemy_{agent,brain,senses,motor,squad,roster,pit}.gd`; `tests/unit/test_enemy_ai.gd` |
| 3 | Squad layer: attack tokens with a lease (max_shooters 2, max_melee 2, token_hold_s 2.5). Six cops, at most 2 attacking; with the fault planted (cap off) all 6 attack and the scenario catches it. SWAT flank spread is 111 deg, and they stay hidden 78 % of their waiting time. | `project/tests/scenarios/scenario_enemy_pit.gd` -> `E/enemy-pit.json`; clip `M/pit_six_cops_two_shooters_dodge.mp4` (debug draw, superseded look) |
| 4 | Telegraphs: every gun shot has a windup. The aim tracks, then locks aim_lock_s 0.2 before the shot, so moving after the lock dodges. Measured: hit rate 0.50 standing, 0.24 reading tells, 0.34 with the lock off. On the rig the tell is a vermilion aim line from the muzzle (thin while tracking, thick once locked). Melee shows a windup arc. | `scenario_enemy_pit.gd` (planted fault: aim lock off caught); still `M/rig_fight_cop_gun_tell.png`, `M/rig_fight_thug_windup.png` |
| 5 | Melee threat: the robot thug's claw lunges along the locked aim (lunge_m 3, lunge_mps 9) and never homes in after the lock. A 2.6 m sidestep gives 0 hits; a Rivet who stands still is caught. | `tests/unit/test_enemy_lunge.gd`; clip `M/rig_fight_lunge_32ppm.mp4` (10 s, 30 fps real time), stills `M/rig_fight_thug_swing_dodged.png`, `M/rig_fight_thug_lunge_into_rivet.png` |
| 6 | Hit stagger: a hit that does not kill cancels the windup and hands the token back. The thug shrugs hits off (stagger 0). A riot shield blocks from the front but not from behind. `EnemyPit.stun()` is the hook for the electroshock. | `tests/unit/test_enemy_ai.gd`; `M/pit_stagger_thug_shrugs_t0600.png`, `M/pit_mixed_squad_fight_stagger.mp4` |
| 7 | Suppression: a nail passing within 0.6 m of a human enemy makes it flinch, with no flash and no blood, so a miss reads unlike a hit. A flinch during the tell breaks the tell. Robots and a front-facing shield never flinch. There is a 45-tick refractory. With the fault planted (`plant_no_flinch`) the scenario catches it. | `features/combat/ai/enemy_suppress.gd`, `tests/unit/test_enemy_suppress.gd`, `scenario_enemy_pit.gd`; `M/rig_fight_cop_flinch_f291.png`, `M/rig_fight_three_pairs_flinch_32ppm.mp4` |
| 8 | Aim lead: guns lead a strafing Rivet while tracking (squad.aim_lead 0.8). Salted A/B over 20 fights at a 70 % tell-read share: cop hit rate 10.7 % -> 11.4 %, damage 13.6 -> 15.9 per 25 s fight. **The tell decides the hit; the lead is a small dial.** | `tests/unit/test_enemy_aim_lead.gd`; `E/aim_lead_ab_salted{,_read0,_read1}.json`; `project/dev/enemy_ai/aim_lead_ab.gd` |
| 9 | Squad volume sweep: max_shooters 1 / 2 / 3 gives damage 10.9 / 13.6 / 14.4 (lead 0). More shooters means more shots, not much more damage. | `E/aim_lead_ab_salted_shooters1.json`, `E/aim_lead_ab_salted_shooters3.json` |
| 10 | Waves as data: curves gentle / standard / steep; gates east, north and south interleaved; a 3 s breather; a 0.6 s spawn gap. The scenario checks that waves clear and never overlap and that the replay digest is equal. Planted fault (overlap) caught, max_alive 7 > 5. Pit default is steep. | `project/data/tables/enemy_waves.json`, `features/combat/ai/{pit_waves,wave_run}.gd`, `tests/unit/test_enemy_waves.gd`, `scenario_enemy_waves.gd` -> `E/enemy-waves.json`; clips `M/pit_waves_standard_1-3.mp4`, `M/pit_waves_steep_1-3.mp4` (debug draw) |
| 11 | Enemies drawn by the cast rigs in the D5 look at 32 px/m, never circles. Cops are CharacterRigs rows from `EnemyRigFeed`. The robot thug is a CutRig on `KingPlan(1.05)` with the collar cleared. The full chain shows: aim line, muzzle star, tracers, HIT clip shoved along the blow, blood and a pool on a human death, sparks and oil on robots, a kill hold, camera shake. | `features/combat/ai/enemy_rig_feed.gd`, `tests/unit/test_enemy_rig_feed.gd`, `project/dev/enemy_ai/enemy_rig_fight{,_run}.gd`; lead clip `M/rig_fight_three_pairs_lead_32ppm.mp4` (25 s, 30 fps real time) and its A/B partner `M/rig_fight_three_pairs_nolead_32ppm.mp4`; stats in `E/rig_fight_three_pairs_*_stats.json` |
| 12 | Behaviour bugs the clips and waves found, all fixed: corner flip, corner re-pick stall, a body pinned on a box face, blind-corner ping-pong, morale counting earlier waves' dead, and a dummy that dodged with zero reaction. | JOURNAL iterations 1-4; commits ddae36f, 924f532, 354ba63, f3d4f432 |
| 13 | Arena station in the arena lane's format. | `project/data/tables/arena_stations/enemy-ai.json` |
| 14 | Gates (iteration 9, 23:32, on 0fe0841; nothing under project/ has changed since f9366b9, which is dev-only): lint 13/13, unit 560/560 (the first run's single failure was the known `test_noir_shadows` flake, and the re-run was clean), scenarios 21/21 exit 0. Replay and parity goldens are untouched (no sim change since the last bless on main). | `node tools/lint/lint.mjs`; `node tools/tests/run_unit.mjs`; `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` |

The owner's frame page: `M/frames.json` (15 entries; I checked at 23:33 that every file exists).

### Numbers of record
- Archetype runs (3 of one kind vs the perfect-reader dummy, seed 7, iteration 1): patrol 14.4 s
  to clear, 0 dmg; riot 17.5 s, 24 dmg; SWAT 22.8 s, 0; thug 13.2 s, 0; gunner not cleared in
  40 s (it holds 11 m and the dummy only fires inside 10 m).
- Waves (seed 31, human-like dummy that reads 70 % of tells, after the fixes, iteration 2): standard
  14.5 / 18.3 / 25.7 s to clear, 0 / 0 / 16 dmg; steep 15.9 / 21.9 / 24.7 s, 0 / 0 / 0. After the
  dummy fix (iteration 4) every curve draws damage (gentle 6 / 12 / 4).
- Clip i (lead 0.8, n=1, **do not quote as the effect of the lead**): cops 13 shots 2 hits, thug
  2 swings 1 hit, Rivet damage 32, 6 kills.

## What does not work / is not done
1. **Rivet in the pit is `PitDummy`** (scripted, fires nails), not gunplay's pistol or
   rivet-motion's claw combo. So no clip meets the owner's 21:25 bar ("final look, real hit
   reaction"), and no difficulty ask is open.
2. **Pressure at range is low.** A player who reads 70 % of tells is hit about 1 shot in 10. More
   shooters and the lead barely move this (rows 8-9). The dials still to sweep are accuracy by
   range (`--acc`, not built) and aim_lock_ticks. Not tuned, by the owner's 21:25 direction.
3. **There is no robot plan.** The thug is King's skeleton at 1.05. A robot `BodyPlan.Kind`
   would mean editing shared `features/characters` files, so it was not done mid-run.
4. **The flinch is only a sideways shove.** There is no duck or crouch clip; RigClips is a
   d5-cast/rivet-motion file.
5. **Not in the arena scene.** The pit is its own 40 x 28 m dev layout, while the arena's pit is 36 x 26 m. There is no `ArenaHook` yet.
   `project/data/schemas/enemy-ai.schema.json` is a verbatim copy of e-arena's station schema so
   this branch's lint passes. It becomes an orphan after the merge and should be deleted then.
6. **No city-block proving clip** (owner decision 1).
7. A nail hit tints the robot rig vermilion-orange for a few frames (CutRig's hit tint). Vermilion
   is reserved for danger, so this is a note for d5-cast/gunplay.
8. A knockdown from the tackle is not wired to the bodies lane's knockdown result. `EnemyPit.knock`
   exists, and robots ignore the tackle as the brief asks.
9. **Waves ask withdrawn.** Ask enemy-ai-2 (difficulty curve) was withdrawn at 21:53 because its
   clips were debug draw. Steep is my call for the pit default. Ask enemy-ai-1 (toughness) was
   answered A, as a placeholder.

## What blocked me, and for how long
- **Owner direction at 21:25** (no judging on numbers or debug draw): this reshaped iterations 2-3
  toward the rigs, at a cost of about 20 min of reworked clips and one withdrawn ask. It was the right call, not a
  bug.
- **test_save_slots** in iteration 1 (about 15 min): it failed because every worktree shares one
  user:// folder. I fixed it from iteration 4 on with a per-lane `APPDATA`
  (REQUEST 2 -> Director/int: give the tests a per-worktree scratch dir).
- **Small friction, under 10 min each:** lint DAT-03 needs a schema per table basename
  (REQUEST 1 -> arena); CRLF from Python broke the canonical JSON; `--check-only` cannot see
  autoloads; one wasted clip run when the spots order slipped.
- **Iterations 7-11 were no-op closes.** Each session started 5-7 min before freeze or report,
  too little time to land and gate a change.

## Requests to other lanes
- REQUEST 1 -> arena: one shared station schema plus a lint rule for `arena_stations/`.
- REQUEST 2 -> Director/int: a per-worktree scratch dir for test_save_slots.
- REQUEST 3 -> gunplay: one hit-feel call (pos, dir, hit_fx, killed) that `EnemyPit.hurt()` can
  make, and whether the gun tell wants the tracking/locked phase as its own signal.
- Note -> d5-cast: a ROBOT BodyPlan.Kind, a flinch or duck clip, and the robot hit tint colour.

## Next steps (night run, in order)
1. Re-read answers.json. After the merge, swap `PitDummy` for Rivet's real pistol and claw. Then
   re-cut the lead clip and re-ask enemy-ai-1 and the lead with a real-time clip in the final look.
2. Build an `ArenaHook` for the pit (`features/combat/ai/enemy_pit_hook.gd`), and feed
   `EnemyRigFeed.row` into `ArenaRigs._put` (e-arena 05c1b48). Add `script` back to the station
   file and delete the orphan schema.
3. Pressure at range: add an `--acc` knob and an aim_lock_ticks sweep to `aim_lead_ab.gd`, salted at
   a 70 % tell-read share. Then one clip per candidate.
4. A robot thug plan and art, a ROBOT body kind, and a flinch duck clip (with d5-cast).
5. The city-block clip (`dev/showcase/city_fight.gd` as host). Wire the tackle knockdown to the bodies lane.
