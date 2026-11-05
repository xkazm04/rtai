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
