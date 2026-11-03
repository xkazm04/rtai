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

NEXT:
1. Re-read answers.json (enemy-ai-1).
2. PitDummy reaction delay (react N ticks after the tell starts, not at the lock), then
   measure lock 0.12/0.2/0.3 s; maybe an ASK on the tell timing with clips.
3. Hit reactions and stagger: a hit during WINDUP interrupts (stagger_s per archetype); robots
   shrug off. Wire the tackle (EnemyPit.knock) to the bodies lane's knockdown.
4. Waves: data rows in enemies.json (or waves table), spawner in the pit, clip of waves 1-3 +
   damage per wave -> ASK difficulty curve (brief item 6).
5. The cutout rig: map pose() to rig clips (d5-cast rig); readable at 32 px/m.
6. Spacing: idle cops bunch up near each other at the wait ring (six-cops clip); spread them on
   the ring by slot. The dummy needs wall sense (it ends against the pit wall).
7. Align the pit size with the arena lane (36 x 26 m) and move into the arena scene via the
   station file once the arena is on this branch; a city-block proving run.
