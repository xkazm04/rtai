# JOURNAL: lane king (n7-king), night 2026-11-05/06

## Iteration 1 (18:53-19:53), BUILD

Read: AGENTS.md, BOSSES.md + `img/boss_king.jpg`, enemy-ai REPORT (aim lock 0.2 s, windup arcs,
thug lunge along the locked aim), `ArenaHook` / `ArenaStage` / `CombatArena` / `Fighter`.

Target read (boss_king.jpg): the 90-degree view is a long black stretch car with gold trim,
the throne mid-car (vermilion cape + white fur trim spread behind, gold crown with orange gem),
the hood cannon forward, four gang bots at the corners. Top-down the car is about 3x the length of
a city car's width; King himself is a gold-and-grey disc with a vermilion fan. Gang: grey bots,
gold chains, black shades.

Note: `BossBrain` is taken (quest 1's quartermaster Mertz). The framework uses `Boss*` names
under `features/bosses/` (framework) and `features/bosses/<id>/` (one boss each).

### REQUEST 1 -> servo: the boss framework interface (king owns it; reply here or in yours)
- **Boss ids:** `king`, `servo` (keys of `bosses` in `project/data/tables/bosses.json`,
  schema `gtai.bosses/1`, `project/data/schemas/bosses.schema.json`). Add your row there.
- **Boss record:** `hp`, `radius_m`, `move_mps`, `arena` (an `arenas` key), `rng` (the named RNG
  stream, `boss_<id>`), `script` (optional `res://features/bosses/<id>/<file>.gd` extending
  `BossMoves`: your boss's own movement and attack effects), `phases` [..], `attacks` {..}.
- **Attack record** (`attacks.<id>`): `shape` (`line` | `cone` | `circle` | `charge` | `none`),
  `windup_s` (tell), `aim_lock_s` (aim stops tracking this long before active; enemy-ai rule,
  scaled up), `active_s`, `recovery_s`, `punish_s` (the open window at the start of recovery:
  damage taken x `punish_k`), `cooldown_s`, `damage`, `range_m`, `width_m` (line/charge),
  `arc_deg` (cone), `radius_m` (circle), `move_mps` (charge), `min_m` / `max_m` (picked only when
  Rivet is in that band), `weight`, `adds` (optional `{archetype, count}`), `doc`.
- **Phase record** (`phases[i]`): `id`, `hp_below` (enter when hp fraction <= it; phase 0 = 1.0),
  `attacks` [ids], `gap_s` (idle between attacks), `transition_s` (invulnerable, plays the phase
  change), `adds` (optional `{archetype, count, every_s}`), `doc`.
- **Phase events** (signals on `BossFight`, mirrored to `Events`): `phase_changed(index, id)`,
  `attack_windup(attack_id)`, `attack_active(attack_id)`, `attack_recovered(attack_id)`,
  `adds_wanted(archetype, count)`, `defeated()`. A phase change never cuts an active attack: it
  waits for the attack to end, then plays `transition_s`. Hits never cancel an active attack.
- **Adds:** the boss asks (`adds_wanted`), the hook spawns: `BossHook` puts `count` hostiles of
  `archetype` (an `enemies.json` id or a boss-folder archetype) at the arena's `add_spawns`.
- **Arena record** (`arenas.<id>`): `area` (ArenaPlan area id the fight runs in), `boss_at`,
  `rivet_at`, `add_spawns` [[x,y]..] (metres from the area's centre), `doc`.
- **Flags:** `--boss=<id>` (`--phase=N`, 1-based) jumps into the fight in the dev arena;
  `--bot=boss --boss=<id>` plays it (dodging bot; `--bot-stand` the standing one).

### MILESTONE 19:00: framework core committed (243f216b)
`bosses.json` + schema, `BossAttack` / `BossSpec` / `BossFight` / `BossZone` / `BossMoves`,
`KingMoves`; `tests/unit/test_boss_fight.gd` 10/10 incl. the planted no-lock fault (a dodge after
the lock is safe: 0 dmg; with the lock planted off the same dodge is hit: 10 dmg).

### MILESTONE 19:15: a King fight runs in the arena end to end
- `BossHook` (station `arena_stations/bosses.json`, live only under `--boss`), `BossBot`
  (`--bot=boss`, `--bot-stand`), `BossTellView` (vermilion zone from BossZone's own numbers: thin
  while tracking, filled at the lock), `BossBar` (name, phase ticks, trail, "1 / 3"), `BossView` +
  `KingBodyView` (FIRST PASS drawn shapes: throne-car top-down with the gold trim, cannon, cape,
  four gang; King on foot). Shots: `evidence/king/shots/first_t100.png`, `first_t330.png` (32 px/m).
- Shared edits (small): `Fighter.brain_owned`; CombatArena skips it, `_drop` no longer assumes a
  tazer for any BOSS (crashed on King's kill), `announce_boss` / `announce_tell` (Events emitter
  rule: features/combat); ArenaRigs / ArenaRobotRigs skip brain-owned bodies.
- FRICTION: the D4 item material has no gold ink (gold printed vermilion): body on the actor layer
  without it (DECISION in docs/decisions.md).
- First numbers (CONTENDED, n=1, seed fixed, `evidence/king/bot-{dodge,stand}-it1.json`, 90 s cap):
  dodging bot: King down at tick 4109 (68.5 s), boss dealt 128 to Rivet; tries/landed ram 2/1,
  coin_fan 8/7, charge 4/0, decree 1. Standing bot: not down in 90 s (hp 7 %), dealt 254; coin_fan
  14/14, ram 2/1, press_slam 2/1. **Not balanced:** the coin fan (50 deg, 14 m, 0.3 s lock) is
  not dodgeable sideways from 8 m (it needs ~3.7 m in 0.7 s). Also Rivet strayed into the pit's own
  guard waves (deaths 2): the boss floor must be clean.

Rules applied: enemy-ai REPORT telegraph rule (aim tracks then locks; the tell draws the real
zone); registry subjects still to read before tuning: encounter-balance-simulation,
combat-pacing-and-dramatic-arc (next iteration, before any number changes).

### MILESTONE 19:28: moveset doc, clean boss floor, roll-aware bot, first readable numbers
- `docs/bosses/king.md`: the moveset (3 phases, 5 attacks with tell / active / recovery /
  counterplay / punish, ghosts and weapons, defeat beat, the fight's envelope, DECISION throne-car =
  boss-owned vehicle).
- Registry rules applied (encounter-balance-simulation, combat-pacing-and-dramatic-arc): the bot
  fights in the real arena path (one kernel: CombatArena.damage, Rivet's real roll i-frames); a
  reference hit for every survivability figure (Rivet 100 hp, no hit over 30 %); duration is a
  two-sided envelope (a boss: 60-120 s for a reader); per-attack attribution; n stated.
- `BossHook` clears the floor under `--boss` (station dummies out, the pit's waves off); a hit
  rolled through (Rivet not exposed) counts as `rolled`, not `landed`.
- `BossBot` rolls when still in the zone 8 ticks before the active window; `--bot-stand` holds the
  same 8 m band but never strafes or dodges.
- DECISION coin fan 50 deg / 14 m / lock 0.3 s -> 36 deg / 13 m / lock 0.5 s, windup 1.1 s: by
  the dodge rule lock >= reaction 0.25 s + (half-width at 8 m + Rivet r) / walk 6.75 m/s it was not
  dodgeable (7/8 hits on the dodging bot). Alternative (coins as travelling projectiles, dodged
  by their flight time) is the better read; it is a later item.
- Numbers (CONTENDED, seed fixed, n=1 each, 120 s cap; `evidence/king/bot-{dodge,stand}-it1b.json`):
  | bot | King down | King's hits on Rivet (landed/tries) | Rivet dmg (all sources) | deaths |
  |---|---|---|---|---|
  | dodging | 71.2 s (tick 4274) | ram 0/2, coin_fan 0/9 (+1 rolled), charge 1/3, press_slam 0/1 | 121.8 | 1 |
  | standing | not in 120 s (11 %) | ram 1/3, coin_fan 13/14, charge 2/10 | 64.8 (+ boss 260 dealt) | 2 |
  The dodging bot's death is the **adds**: phase 2's gang spawns as the pit's contractor guards
  (assault rifles, GuardBrain). They must be the melee gang. n=1: no rate here is a verdict yet.

### MILESTONE 19:25 (wall clock; the "19:28" above was a mis-stamp, it was 19:17): adds as rows
- DECISION adds: an add is a one-phase `bosses.json` row (`king_gang`) run by its own `BossFight`
  (`BossAdds`), so it follows the same tell rules (0.8 s windup, 0.2 s lock, 3 m lunge = enemy-ai's
  thug claw) and its tell is drawn by the same view. Rejected: the pit's contractor guards (rifles,
  GuardBrain: they killed the dodging bot) and EnemyPit's agents (a separate world, not arena
  hostiles). Servo's drones can be rows the same way. A row with no `bosses.json` entry still
  falls back to contractor guards.
- The boss and its adds leak oil, not red (robot ids told to the view's `CombatBlood`). King rules
  from the stalled car in phase 2 and steps down for phase 3.
- Numbers (CONTENDED, seed fixed, n=1, 120 s cap; `evidence/king/bot-{dodge,stand}-it1c.json`):
  | bot | King down | King landed/tries | gang landed/tries | deaths |
  |---|---|---|---|---|
  | dodging (perfect reader, 0.3 s reaction) | 77.4 s | 0 / 20 (+1 rolled) | 0 / 16 | 0 |
  | standing (holds 8 m, never dodges) | 81.8 s | 11 / 17 (coin 8/9, charge 2/2, ram 1/3) | 15 / 18 | 1 |
  Both ends bracket a fight that is readable (every attack 0 % on the reader) and threatens a
  non-reader. The middle is unmeasured: a human-like bot that reads ~70 % of tells (enemy-ai's
  salted share) is the next instrument, n >= 10 seeds, before any tuning call.
- Gates at 0dd8d7b2: lint 13/13; unit 1120/0 (`evidence/king/unit-it1b.log`); scenarios 52/0 at
  a3e5d11e (`evidence/king/scenarios-it1.log`); `test_boss_adds.gd` 3/3 (new).

NEXT (iteration 2, in order):
1. Check servo's JOURNAL for a reply to REQUEST 1; merge nothing from them (they merge us).
2. Combat no-regress: `--bot=reel --reel=director` on this branch (not run yet this iteration;
   scenarios include `scenario_showcase_director` 52/0).
3. Human-like bot (`--bot-read=0.7`, its own named RNG stream) + an n-seed runner writing
   `evidence/king/boss-numbers.json` (TTK spread, Rivet dmg, per-attack hit rate and damage
   share). Then tune against the envelope in docs/bosses/king.md.
4. Ohm's stun on a boss (cancel a tell, 0.6 s daze), the decree's gang buff, the phase
   transition beats (car stall, step-down), the defeat beat (crown falls, power-down), boss
   music (boss_loop_01 / boss_stinger_01).
5. The body: King part sheets (image lock, codex image_gen) on KingPlan; the rich gang on the
   thug rig; the throne-car art. The arena: a boulevard + plaza (city block or a new area).
6. Clips into `gtai-masters/n7/king/` + frames.json; target hstack.

### REPLY to servo REQUEST 2 (19:31): all three landed
1. `BossMoves.tick(f, target, target_r) -> float`, called by `BossFight.step()` every tick in
   every state but DEFEATED, before the state's step; its damage is added to what step() returns.
   `BossFight.hit_id()` credits a hit to the active attack, else to the boss id (a late hit).
   Unit `test_moves_tick_lands_in_every_state_but_defeated`.
2. `BossMoves.bind(f, rng: RngRegistry)`, called once by `BossHook.setup` right after the fight is
   built (before `start()`). Adds (`BossAdds`) are not bound: they run their row's default moves.
3. `evidence/king/write_bosses.mjs` now reads the table and sets only `bosses.king`,
   `bosses.king_gang`, `arenas.king_boulevard`; other rows are kept. It still writes the schema
   (one shared schema: tell me if you need a field and I add it, or add it yourself and I merge).
Also new since your merge: `BossAdds` (adds are one-phase bosses.json rows; your drones could be
rows too, or stay ServoSwarm), `keep_m` (optional per row), `BossHook` / `BossBot` / views, and
`Fighter.brain_owned`. Your next merge of n7-king brings them.
