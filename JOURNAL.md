# JOURNAL: lane servo (branch `n7-servo`), night 2026-11-05/06

Masters: `C:\Users\kazda\kiro\gtai-masters\n7\servo\` (`M/`). Evidence: `evidence/` (`E/`).

## Iteration 1 (18:53-19:53), BUILD

- 18:53 read: BOSSES.md, `img/boss_servo.jpg` (looked at it: walker on two long legs, two
  hover-pad arms with hazard stripes, a glass cargo belly showing crates on a conveyor, a visor
  head with a vermilion slit, and two big drone-rack wings across the back; the top view is a
  wide bar of rack cells with the slim body in the middle and the two round pads hanging at the
  sides, the most important panel), enemy-ai REPORT (aim lock 0.2 s, windup arcs, stagger rules),
  ghost-powers REPORT (Dent seize/ride, Kerf blink-and-slice, Ohm forked bolt within 3 m, Tonnage
  slam), STANDARDS via AGENTS.md, `core/rng/rng_registry.gd`, `core/clock/sim_clock.gd`,
  `core/events/events.gd` (`boss_engaged` exists), `DataTable`.
- 18:58 n7-king's JOURNAL does not exist yet; its branch is still at main 763f8fba. I post the
  interface REQUESTs first (below) so we agree it in iteration 1.
- Registry rules applied (`combat-pacing-and-dramatic-arc`, `encounter-balance-simulation`):
  duration is a two-sided envelope stated per encounter class (I set the boss class at 60-150 s,
  each phase 20-60 s; a Rivet death inside 5 s of an attack's tell = punishing); breathers are
  authored (the dock/reload window after each wave) and dead zones are measured on the raw event
  stream; report rates as counts ("hit 3 of 10 dodging"); a single dominant damage source is
  named; numbers are judged only against a stated reference hit (Rivet 100 hp, regen 10/s after 3 s).

### REQUEST to n7-king (the shared boss framework interface), 18:58
Proposed; if you built it differently, your shape wins and I adapt; write the answer in your JOURNAL.
1. **Boss ids:** `king`, `servo` (StringName, = the character id in `Events.boss_engaged`).
2. **Table:** `project/data/tables/bosses.json` (`gtai.bosses/1`), rows by id. Boss row: `hp`,
   `poise` (heavy hits a windup can absorb before it staggers; 0 = never), `stagger_s`,
   `arena` (arena id), `music` / `stinger` (audio ids), `name_key` (Loc), `phases` (array).
   Phase: `id`, `from_hp_frac` (enters when hp <= this; phase 1 = 1.0), `attacks` (ids),
   `pick` (`cycle` | `weighted`), `gap_s` (rest between attacks), `transition_s` (invulnerable
   beat on entry).
   Attack record (under the boss row, `attacks.{id}`): `windup_s`, `active_s`, `recovery_s`,
   `punish_s` (part of recovery where the boss takes `punish_k` x damage), `punish_k`,
   `cooldown_s`, `weight`, `damage`, `aim_lock_s` (aim tracks during windup, locks this long
   before active, the enemy-ai rule scaled up), `range_m`, `telegraph` (a kind id the framework's
   telegraph helper draws: `line`, `lane`, `ring`, `arc`, `none`), `adds` (optional:
   `{ "kind": <boss-folder add id>, "count": n }`). Anything else boss-only goes in
   `extra: {}` which the framework passes through untouched.
3. **Phase / attack events** (Events signals, so HUD, music and the bot listen without coupling):
   `boss_phase_changed(boss, phase: int)`, `boss_attack_stage(boss, attack, stage)` with stage
   in `windup|active|recovery|done`, `boss_health_changed(boss, hp, max_hp)`,
   `boss_defeated(boss)`. Keep `boss_engaged` and `attack_telegraphed`.
4. **Adds:** the framework never knows what an add is. The boss's own body script in
   `features/bosses/<id>/` implements a small hook set the framework calls on the tick:
   `on_attack_stage(attack: StringName, stage: StringName)`, `on_phase(phase: int)`,
   `adds_alive() -> int`, `step(tick)`. Servo's drones live in `features/bosses/servo/`
   (`ServoSwarm`, RNG stream `&"servo_swarm"`); King's gang in his folder.
5. **Arena record:** `project/data/tables/boss_arenas.json` (or a block in bosses.json), rows by
   id: `size_m` (Vector2), `rivet_spawn`, `boss_spawn`, `walls` (rects), `props` (a list of
   `{kind, pos, size, rot}` where kind is free text resolved by the boss folder's arena script),
   `camera_ppm`. Servo's arena id: `depot`.
6. **Damage into the boss:** one entry `BossBrain.take_hit(amount, kind, from: Vector2)` that
   applies poise/punish and emits health; ghosts and weapons call it like `EnemyPit.stun()` is
   called today. A `stun(seconds)` scaled by a boss row `stun_k` (I propose 0.33).

Until the framework lands, Servo's swarm and attacks run standalone in `features/bosses/servo/`
with their own data table `servo.json` (`gtai.servo/1`); the attack rows there use the field
names above, so they move into `bosses.json` with a copy.

- 19:00 MILESTONE 110e8708: the drone swarm standalone (`features/bosses/servo/`: ServoTuning,
  ServoRack, ServoDrone, ServoParcels, ServoSwarm; `data/tables/servo.json` + schema). Unit
  `test_servo_swarm` 6/6. FRICTION: GUT silently skips a test file that fails to parse (a
  discarded return value is a warning-as-error): the full-suite "1110 passed" did not include my
  file. Always run the new file alone with `-gselect=<name>` and look for its test names.
- 19:04 MERGE n7-king 243f216b (framework core: bosses.json, BossFight, BossZone, BossMoves,
  BossSpec) into n7-servo as cc4446ba. Conflict only in JOURNAL.md (each lane keeps its own: ours).
  King's interface (their JOURNAL REQUEST 1) differs from my proposal; **theirs wins**, I adapted:
  phases `hp_below`, attack `shape`, per-boss `script` extending `BossMoves`, `arenas.<id>`.
- 19:11 MILESTONE 49bff207: Servo's row in bosses.json (written by
  `evidence/servo/write_servo_row.mjs`, which only sets `bosses.servo` and `arenas.depot`) and
  `ServoMoves`. Unit `test_servo_moves` 4/4.
  - Measured a dead zone and fixed it: the rotor dash (14 m) ended on top of Rivet, inside every
    attack's `min_m`, and the default walk only closes in, so Servo stood idle for 25 s of a 30 s
    run (2 attacks). ServoMoves.idle_step holds a band (9 +- 2 m, backs off): now 7 attacks / 30 s.
  - First rough phase-1 numbers (30 s, seed 7, the unit test's crude bot, NOT the bot): standing
    took 178 (would die: Rivet has 100), a 6 m sidestep at each lock took 60. To be measured by the
    real bot.
- DECISION servo-mark: every drone attack drops on the MARK = where Rivet stood when the tell
  locked (the scanner beam does no damage itself). Moving after the lock dodges, as the enemy-ai
  rule. Rejected: re-aiming drones in flight (homing drops are undodgeable at 32 px/m).
- DECISION servo-wave-shape: a wave is one drone on the mark plus a ring spread_m (1.9 m) out;
  the union of the rings + blast (1.6 m) is about 4 m round the mark, so a dodge is a real step
  (~0.6 s of Rivet's walk), not a shuffle. One data value (`phases[].spread_m`) to tighten.

### REQUEST 2 to n7-king (19:12): three small generic hooks Servo needs
1. **A per-tick hook every state:** in `BossFight.step()`, before the state match (not when
   DEFEATED), `var extra: float = moves.tick(self, target, target_r)` and add `extra` to the
   returned damage. Default `BossMoves.tick()` returns 0. Why: Servo's parcels and kamikaze drones
   land after the attack's active window (King's coin hail landing late would use it too).
   `ServoMoves.tick(f, target, target_r) -> float` already exists with that signature.
2. **Seeding the boss's own sub-systems:** `BossMoves.bind(f: BossFight, rng: RngRegistry)`,
   called once by whoever builds the fight (the hook), so a boss script can take its own named
   stream (Servo: `ServoSwarm.STREAM` = `servo_swarm`). Until then I call
   `ServoMoves.setup_swarm(reg.stream(ServoSwarm.STREAM))` myself.
3. **Your `write_bosses.mjs` keeps other rows:** read the existing table and set only
   `bosses.king` / `arenas.king_boulevard`, or regenerating drops Servo's row. Mine
   (`evidence/servo/write_servo_row.mjs`) already does that for `servo` / `depot`.
- 19:18 MILESTONE c60ac868: dev graybox of the fight (`dev/servo/servo_fight_run.gd`, windowed
  d3d12; stand-in shapes, NOT the rig). Looked at the 48 px/m keys
  (`M/frames/servo-graybox-wave-keys-48ppm.png`): the thin tracking beam, the lock ring, the three
  dashed drop rings (they overlap into one pill-shaped zone), drone rotor crosses over ink shadows,
  rack cells going dark at the wing tips as drones launch: all read. Weak: the rings show from
  launch, ~3 s before the drop at 9 m/s cruise; raised cruise to 12 m/s (data).
  - MEASURED (graybox, seed 7, 30 s phase 1, a perfect-reader stand-in that steps 5 m off the
    mark at the lock; not the real bot, Rivet's real reaction is later): standing 178 damage (4
    blast hits of 9 drones, 3 dashes of 3); dodging 0 (0 of 9 drones, 0 of 3 dashes). Too easy for
    a perfect reader by design; the real bot must react with Rivet's reaction delay.
  - Clips: `M/servo-graybox-p1-dodge-32ppm.mp4`, `M/servo-graybox-p1-stand-32ppm.mp4`,
    `M/servo-graybox-wave-48ppm.mp4`; `M/frames.json` (4 entries).
- 19:20 gates: lint 13/13 every commit; unit 1130 passed / 0 failed (`E/unit-it1.log`, includes
  test_servo_swarm 6, test_servo_moves 4, king's test_boss_fight 10).
- 19:21 image job `servo_core_a` started under `gtai-n5/image.lock` (runner copied to
  `gtai-n7/scratch/servo/tools/gen.mjs`; round `M/gen/r1/`): an edit of the n5-cast 3x2 layout
  template (`gen/r1/refs/sheet.png`, the d4 core sheet) with the Servo target: TL kept as the
  scale reference, TM visor head, TR hover pad, BL walker pelvis, BM cargo-belly torso, BR one
  drone-rack wing (2x3 bays with docked drones). Neutral visor (the game tints it vermilion only
  during a tell).
- Calls for the owner (collect for REPORT):
  1. **When the drop rings appear.** Default built: from the drone's launch (~2-3 s of warning).
     Option: only over the hover (hover 0.7 + fall 0.35 = 1.05 s), the mark ring alone before.
     To build as one flag next iteration (`servo.json drone.ring_from_launch`); see
     `M/servo-graybox-wave-48ppm.mp4`.
  2. Should a CS crate landing on Rivet hurt (today only bombs do; crates block and cover)?
