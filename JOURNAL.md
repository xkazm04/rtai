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
