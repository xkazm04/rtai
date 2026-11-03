# JOURNAL: lane enemy-ai (branch e-enemy), evening run 2026-11-03

## Iteration 1 (20:52-21:37), BUILD

Read: AGENTS.md, features/combat (GuardBrain, CombatArena, WaveDirector, Shot, CombatTuning),
bodies.json (body classes human/robot/boss), RngRegistry, the scenario harness, arena-1 ask (the
arena lane's pit is 36 x 26 m; mine is 40 x 28: align when the arena lands on this branch).
answers.json: empty at 20:52.

Registry applied: agent-behaviour-authoring. Followed: coordination is a scarce, leased claim
(attack tokens), not a commander; competence is a named dial per class (reaction_s, accuracy
curve by range, telegraph_s, turn_deg_s, accel). Deviation: the token registry lives in
EnemySquad over all pit agents, not on the defender (one defender today: same result; revisit
when enemies can target others). Not yet done: a decision trace per agent, knowledge decay,
perception latency beyond the alert reaction time.

- MILESTONE 591c460: enemies.json + schema (five archetypes, squad limits, weapons), arena
  station data/tables/arena_stations/enemy-ai.json.
- FRICTION: lint DAT-03 wants a schema per table basename, so arena_stations/<lane>.json needs
  data/schemas/<lane>.schema.json (added enemy-ai.schema.json). REQUEST 1 -> arena: one shared
  arena_station schema, plus a lint rule for the arena_stations/ subfolder, would avoid
  seven per-lane schemas.
- MILESTONE 6db5864: brains. EnemyRoster, EnemyAgent (states PATROL ALERT ENGAGE WINDUP FIRE
  RECOVER COVER FLANK PANIC DOWN DEAD; pose() = idle run aim windup shoot swing hit flee down
  getup die), EnemySenses (sight cone, hearing a nail, LOS vs cover boxes, cover spots, corner
  detour), EnemySquad (tokens), EnemyMotor (accel and turn-rate limits, separation, arrival),
  EnemyBrain, EnemyPit, PitDummy (a scripted Rivet: stand / dodge / fight), PitLayout.
  scenario_enemy_pit: green, planted faults (squad off, aim lock off) caught.
- MILESTONE ddae36f: the corner detour fix (a riot cop flipped between two box corners from
  11 s on, seen in the clip) + dev/enemy_ai/enemy_pit_view.tscn (32 px/m debug draw, one tick
  per frame) + evidence/enemy-ai/.
- Numbers (scenario, seed 7, 3 of one archetype vs PitDummy FIGHT nailing inside 10 m):
  patrol 14.4 s to clear / 0 dmg; riot 17.5 s / 24 dmg; SWAT 22.8 s / 0; thug 13.2 s / 0;
  gunner not cleared in 40 s (holds 11 m, the dummy fires inside 10 m). Squad: 6 cops, at most
  2 attacking (planted: 6). Hit rate standing 0.50, dodging tells 0.24, with the aim lock off
  0.34. SWAT flank spread 111 deg, hidden 78 % of their waiting time. 4 of 6 down: 2 cops
  panic, 0 robots.
- FINDING: PitDummy reacts perfectly (the moment a lock starts), so the aim-lock length barely
  moves its numbers (lock 6/12/18/24 ticks -> 0.18/0.24/0.18/0.24). The lock window can only
  be tuned against a human-like reaction delay (about 0.2-0.25 s after the tell starts).
- ASK enemy-ai-1 (enemy toughness), default A (as built).
- Gates: lint 13/13; scenarios 20/20 (full suite); unit: only test_save_slots fails (254
  assertions), and it fails in the shared user://test_save folder that every worktree's unit
  run writes (all lanes' Godot runs share one user:// for this project name). FRICTION, not
  this lane's code (no save code touched); re-run alone on a quiet machine.
- Evidence: gtai-masters/eve/enemy-ai/ (2 clips, 5 stills, frames.json).
- MILESTONE 3023c4a: hit stagger. enemies.json `stagger_s` (patrol 0.45, riot 0.3, SWAT 0.35,
  gunner 0.25, thug 0 = shrugs), a hit that does not kill cancels the windup and returns the
  token; `EnemyPit.stun(e, ticks)` is the hook for the electroshock (melee lane). pose() adds
  `stagger`. tests/unit/test_enemy_ai.gd 6/6 (table, accuracy curve, token cap, stagger, robot
  shrugs hit + tackle, riot shield front vs back). scenario_enemy_pit still green.
- FRICTION test_save_slots: also 16/16 failing when selected on its own
  (`-gconfig= -gdir=res://tests/unit -gselect=test_save_slots`), and its scratch dir
  %APPDATA%/RTAI Uprising/test_save is shared by every worktree (custom_user_dir_name); another
  lane wrote test_page_age_params.json there in the same minute (21:22), so "alone" was not
  alone. This lane touches no save code. REQUEST 2 -> Director/int: check test_save_slots on
  main on a quiet machine; if it is the shared dir, give tests a per-worktree scratch dir.

- REQUEST 3 -> gunplay: the enemy gun tell is the windup (telegraph_s per archetype, 0.5-0.9 s)
  with the aim locking aim_lock_s 0.2 before the shot; EnemyPit emits
  Events.attack_telegraphed(weapon id) at windup start and Events.player_hit(weapon id) on a
  hit. Each archetype carries hit_fx (blood | sparks) for your hit-feel module: please expose
  one call (position, direction, hit_fx, killed) that EnemyPit.hurt() can make, and say if your
  tell art (aim line or muzzle glint) wants the locked/tracking phase as a separate signal.
- Clip 3 (stagger build): gtai-masters/eve/enemy-ai/pit_mixed_squad_fight_stagger.mp4, 5 kills
  in 20 s, 24 shots, 0 hits on the perfect dummy.

NEXT:
1. Re-read answers.json (enemy-ai-1).
2. PitDummy reaction delay (react N ticks after the tell starts, not at the lock), then
   measure lock 0.12/0.2/0.3 s; maybe an ASK on the tell timing with clips.
3. Stagger is in (3023c4a); still to do: wire the tackle (EnemyPit.knock) to the bodies
   lane's knockdown result, and a clip showing a stagger cancelling a windup.
4. Waves: data rows in enemies.json (or waves table), spawner in the pit, clip of waves 1-3 +
   damage per wave -> ASK difficulty curve (brief item 6).
5. The cutout rig: map pose() to rig clips (d5-cast rig); readable at 32 px/m.
6. Spacing: idle cops bunch up near each other at the wait ring (six-cops clip); spread them on
   the ring by slot. The dummy needs wall sense (it ends against the pit wall).
7. Align the pit size with the arena lane (36 x 26 m) and move into the arena scene via the
   station file once the arena is on this branch; a city-block proving run.

## Iteration 2 (21:27-22:12), BUILD

answers.json at 21:27: only rivet-motion-1 (not mine); enemy-ai-1 still open (default A holds).
Registry applied: encounter-balance-simulation's habit (measure the curve against a scripted
player profile, publish the profile with the numbers); difficulty-design: the curve is one
data value so the owner's answer is a one-line switch.

- MILESTONE 924f532: waves. `data/tables/enemy_waves.json` + schema (curves gentle / standard /
  steep, gates east/north/south as [x, y], breather_s 3, spawn_gap_s 0.6), `PitWaves` (loader,
  interleaves the gates), `WaveRun` (BREATHER -> SPAWNING -> FIGHTING per wave, report per wave:
  start, seconds, damage, shots, hits, max_alive), `PitLayout.wave_fight`,
  `scenario_enemy_waves` (live curve clears, no overlap, breather holds, replay digest equal;
  planted fault: overlapping waves caught, max_alive 7 > 5).
- FIX (found by the wave runs, same commit): EnemySenses.detour (1) re-picked the corner the
  walker already stood on (zero velocity forever: a cop parked at a box corner for 200 s);
  (2) tested the line to a corner against the bare box, so a body on a box face aimed through
  its own push-out zone and stayed pinned (two SWAT stuck on the east face of the low wall).
  Now: corners within 0.3 m are skipped and reachability uses the box grown by the body
  radius - 0.05. scenario_enemy_pit still green; its evidence numbers moved (movement changed).
- PitDummy human profile: react_ticks (dodges N ticks after a tell starts), read_frac (share
  of tells noticed, a low-discrepancy pick per tell, no RNG), aim_err_deg (nail spread, a fixed
  golden-ratio sequence, no RNG: the dummy never touches the fight's streams).
- Numbers (scenario seed 31, human profile, fire inside 16 m; identical in the view clips):
  standard 7.9 / 18.2 / 20.5 s, dmg 0 / 0 / 0; steep 16.9 / 19.6 / 26.4 s, dmg 0 / 4 / 20;
  gentle 8.2 / 16.6 / 15.4 s, dmg 0. FINDING: enemies barely hurt even a 70 %-reader: the
  dummy one-shots cops at 16 m before they reach their 14-20 m firing range, where their
  accuracy is 25-35 %. Per-archetype danger is the next knob (not the wave count).
- Aim lock vs a reacting dodger (react 0.25 s, reads every tell, 3 shooters): lock 0.12 s ->
  hit rate 0.237, 0.20 -> 0.211, 0.30 -> 0.0. With a 0.5 s patrol tell, a 0.3 s lock starts
  before the player has reacted, so a reacting player always escapes; 0.2 keeps a sliver of
  tracking. Keep 0.2 (as built).
- ASK enemy-ai-2 (first difficulty curve), default B = steep, applied in data.
- Evidence: gtai-masters/eve/enemy-ai/pit_waves_standard_1-3.mp4 (58 s), pit_waves_steep_1-3.mp4
  (74 s), 3 stills, clip stats JSON; frames.json now 12 entries. Seen: in the steep clip a SWAT
  idles at the north edge at t 45 (probably waiting for a token out of sight; check next).
- MILESTONE e369543: the pit view runs a curve (--curve, --human=1, --every=2 for a 30 fps
  real-time clip).
- MILESTONE 604fec8: unit tests test_enemy_waves (curves load, gates interleave, a wave waits
  for the clear plus the breather). Caught: an Array[StringName].sort() is not alphabetical
  (sorts by interned pointer); curve_ids sorts by String now.
- MILESTONE 354ba63, two more behaviour bugs the waves surfaced:
  (1) MORALE counted every enemy the pit ever spawned, so from wave 2 on patrol cops (morale
  0.5) broke after the first death (wave 1's dead counted). EnemyAgent.squad (the wave index)
  + EnemyPit.fallen_frac(squad). Unit test added.
  (2) CORNER PING-PONG: a corner the target is still hidden from was costed as if the line went
  on through the box, so two corners took turns winning and a SWAT oscillated 0.3 m behind the
  north-west crate for 200 s. Blind corners now rank last (+100 m).
  The pit view's tag shows pose/brain-state (how the alert SWAT was spotted).
- Numbers after the fixes (seed 31, human profile): standard 14.5 / 18.3 / 25.7 s, dmg
  0 / 0 / 16; steep 15.9 / 21.9 / 24.7 s, dmg 0 / 0 / 0 (99 enemy shots); gentle 8.2 / 14.2 /
  11.5 s, dmg 0. Clips re-rendered (wave 3 cut ~2 s before its clear).
- ANSWER enemy-ai-1 (owner, 21:25 via answers.json): A as a placeholder; "not judgeable in
  this state - no weapon design, no final animation, no opponent hit reaction"; stop tuning on
  numbers, re-ask only with real-time clips in the final look (common.md, Owner direction
  21:25). Recorded in docs/decisions.md.
- WITHDRAWN ask enemy-ai-2 (difficulty curve): its clips are debug circles with no hit chain,
  so under the 21:25 rule 4 it is not a valid ask; deleted the file at 21:53. The curve is my
  call: steep stays the pit default (most pressure; the arena is a stress test).
- DIRECTION CHANGE (common.md 21:25): depth before breadth; enemies must be the cast rigs, not
  circles; the 00:00 sample is a patrol cop and a robot thug with full hit reactions and
  deaths, against Rivet's pistol and claw combo, in the arena, one 20-40 s clip per lane.
- Scouted for that: features/characters (CutRig.drive/hit(from_dir, strength); RigClips SHOOT,
  HIT, DEATH, knockdown fall/rise), dev/showcase/d5_arena_run.gd (Rivet vs two cops on the rig,
  on King's arena floor, the closest template), KingPlan (the robot boss on Rivet's skeleton,
  SIZE_K 1.3: a candidate base for the robot thug until a thug plan exists).
- Gates at 354ba63: lint 13/13; unit 543/543 at e369543 (+4 new enemy-wave tests green since);
  scenarios: full suite 21/21 green at 530fb96 (21:58).
- Housekeeping: gtai-masters/eve/enemy-ai/fr_steep/ (raw frames, ~44 MB) could not be deleted
  (it was the session's cwd); delete it next session.

NEXT:
1. Re-read answers.json. Delete gtai-masters/eve/enemy-ai/fr_steep/.
2. The 21:25 sample, enemy half: an EnemyRigView that drives CutRig cops (patrol cop first)
   from EnemyAgent each tick: facing + velocity -> drive(), pose() -> RigClips (shoot -> SHOOT
   recoil, windup -> a raised-gun aim hold, hit/stagger -> HIT with from_dir, die -> DEATH,
   down/getup -> the bodies lane's fall/rise). Start from d5_arena_run.gd's setup, at 32 px/m,
   D5 look, real-time clip.
3. The robot thug on a rig: KingPlan scaled down (or a thug plan), the claw windup as a pose,
   sparks on hit (hit_fx). Then the gun tell in the final look (coordinate with gunplay).
4. Full scenario suite + run_unit before the freeze; then the 20-40 s lane clip for 00:00.
