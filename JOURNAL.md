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
