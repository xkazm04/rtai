# Follow-up a1b (resume): route around the foes-owned enemy loader

Good stop. Do NOT edit `features/combat/ai/enemy_roster.gd` or `enemy_pit.gd`. Instead resolve the size of enemy rounds in
guard-owned code. Same hard stop 01:20, part A commit + tag `n22-guard-iface` by 00:55 (or as soon as possible), part B by 01:15.

Design (decided):
- New file `project/features/combat/enemy_rounds.gd`, `class_name EnemyRounds extends RefCounted`: a cached static lookup
  over the `weapons` block of `enemies.json`, weapon id -> `round` (`StringName`, absent = `&"small"`, other value = load error
  via `Log.error` and treat as small), plus `splash_radius_m` and `splash_damage` (floats, absent = 0.0; the same key names
  `weapons.json` uses; nothing sets them on existing rows tonight, the foes lane will set them on its new rows).
  API: `static func size_of(weapon: StringName) -> StringName`, `static func splash_m(weapon: StringName) -> float`,
  `static func splash_damage(weapon: StringName) -> float`. Read the table the way other features read `enemies.json`
  (find the repo's JSON table loader; no `ConfigFile`, no `str_to_var`).
- In `project/features/combat/arena_projectiles.gd` `step_shots` (guard owns this file): for a hostile shot with
  `s.spec == null`, set `s.size = EnemyRounds.size_of(s.weapon)` before anything reads it (once per shot is enough: e.g. a
  `size_known` bool on Shot, or just every tick: a dictionary lookup; pick one). Shots built from `WeaponSpec` and
  `CombatTuning.Weapon` get the size at construction as in the original brief.
- Add `"round"`, `"splash_radius_m"`, `"splash_damage"` as optional keys to the weapons block in `enemies.schema.json`
  (only those keys; foes owns the rest of the schema). Set `"round": "large"` on `cannon` in part B as planned.
- Test in `test_guard_iface.gd` or `test_round_size.gd`: `EnemyRounds.size_of(&"cannon")` is large after part B,
  `&"pistol"` small, an unknown id small; a hostile cannon Shot stepped once through `ArenaProjectiles.step_shots` is large.

Allowlist additions: `project/features/combat/enemy_rounds.gd` (+ `.uid`), `project/features/combat/arena_projectiles.gd`.
Everything else from the original brief stands (allowlist, forbidden list, law, report). Go.
