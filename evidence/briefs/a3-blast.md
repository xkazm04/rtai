# Brief a3-blast: enemy blasts hurt Rivet, solid props stop them (lane `guard`, run n22, item 4)

Wall-clock HARD STOP: 02:50 local. Commit by 02:40. If short of time, commit what is green and report what is left.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Windowed: `--rendering-driver d3d12 --position 0,1440`. Never kill by name, only your own PIDs.

## Part 0 (5 minutes, its own commit `guard: restore pilot and damage() doc comments`)
Your commit 8a8a0d93c deleted explanatory doc comments in `project/boot/collect_call/stage_pilot.gd` (the class header, the
`stop()`, `_move`, `_ghosts`, `_pick_melee` comments) and `project/features/combat/combat_arena.gd` (the two `##` lines over
`damage()`, now a trailing comment after `) -> void:`). The views commit did the same in `project/features/arena/arena_rigs.gd` (`_add_hand_views`, `_rivet_clips`, `_gun_shown`). Restore them from `git show 8a8a0d93c^:<path>` (for arena_rigs from the commit before your views commit) (comments only; keep
any new sentence about the guard). If a file then passes the line budget, say so and keep the comments anyway.
Also `foes` already has hostile splash rows on its branch (`rocket`, `war_cannon`, `stomp` in its enemies.json): do not merge
it; your test seam stands in for them, and `RivetBlast.burst` is the entry foes will call for a stomp.

## What exists
Your earlier commits on this branch: `Shot.size`, `EnemyRounds` (per enemy weapon row: `round`, `splash_radius_m`,
`splash_damage`, `melee`), `PlayerGuard` (deflects small rounds only), `ArenaWalls` (solid props as boxes:
`wall_high`, `cover_high`, `cover_low`; `blocks(a, b)`), `ArenaDodges.cull` (stops shots in props; a Rivet rocket that hits
a wall lands its splash there), `FightAreas._splash` (Rivet's splash: loops hostiles only, no occlusion).
`CombatArena.damage()` is the one chokepoint: it already applies `victim.damage_k` (Tonnage's 0.3, `hauler_stage.gd:62`) and
skips a victim that is not `exposed` (the roll's i-frames).

## The rule (decided)
1. New `project/features/combat/rivet_blast.gd` (`class_name RivetBlast extends RefCounted`), one public entry other lanes
   can call for any hostile blast (the foes lane's rocket trooper rocket, the war machine's shell and stomp):
   `static func burst(arena: CombatArena, at: Vector2, weapon: StringName, by_id: int) -> float`: the radius and damage come
   from that weapon's row (`EnemyRounds.splash_m(weapon)`, `EnemyRounds.splash_damage(weapon)`; a stomp is just a weapon row
   with splash keys), so balance stays data. Returns the damage dealt to Rivet (0 if none).
   Damage = `splash_damage * (1 - dist / radius_m)` (linear falloff, like
   `FightAreas._splash`), measured to Rivet's centre minus his radius (an edge touch counts), through
   `arena.damage(arena.rivet, amount, by_id, weapon, &"blown")`. Set `arena.hit_dir` (centre -> Rivet) first.
2. **Occlusion**: no damage if the segment blast centre -> Rivet crosses a `wall_high` or `cover_high` box; a `cover_low` box
   blocks only when Rivet is in the cover stance (`StagePilot.motion.cover.spot != null` or however the cover stance is exposed;
   find the cleanest read that does not make core code name a dev class). The walls come from a field on the arena:
   add `var walls: ArenaWalls = null` to `CombatArena` (one line) and set it where `ArenaStage` builds its walls (one line).
   `ArenaWalls` needs the kind of each box: add a parallel `kinds: Array[String]` filled in `from_stations` and a
   `blocks_kinds(a, b, kinds: Array[String]) -> bool` (keep `blocks()` unchanged). A box that CONTAINS the blast centre does
   not occlude (the rocket hit that wall's face from Rivet's side: test the segment from the centre nudged 0.05 m toward Rivet).
3. **Where hostile blasts start**: a hostile shot whose weapon has `EnemyRounds.splash_m(weapon) > 0` bursts where it ends:
   on striking Rivet (the burst replaces the direct damage: direct hit = full burst damage at dist 0; do not double count),
   on running out of range, and when `ArenaDodges.cull` stops it in a prop (burst at the stop point; the prop it hit then
   shields what is behind it, by rule 2). A guard does not stop a blast and does not deflect a large round.
4. Roll i-frames avoid a blast (they already do through `exposed`; test it). Tonnage's 0.3 applies (test it).
5. Rivet's own blasts (`FightAreas._splash`) still never hurt him. Hostile blasts do not hurt other hostiles tonight.
6. A view: a hostile blast leaves the same blast ring Rivet's rockets leave (`FightAreas.blasts` or its view); a blocked one
   shows the ring stopping at the wall is NOT needed; the ring alone is fine.
7. For tests and the film only: there are no hostile splash rows yet (foes adds them on its own branch). Tests must build their
   own data: give `EnemyRounds` a test seam (e.g. `static func override_for_test(id, round, splash_m, splash_damage)` + `reset()`),
   or test `RivetBlast.burst` directly. Do not add splash to existing enemy rows.

Tests `project/tests/unit/test_rivet_blast.gd`: open ground damage with falloff (centre, half radius, edge, outside = 0);
`wall_high` between = 0; `cover_high` between = 0; `cover_low` between: damage when standing, 0 when in the cover stance
behind it; the wall that the rocket struck shields Rivet behind it, and the same rocket landing in the open hurts him;
rolling (not exposed) = 0; Tonnage (`damage_k` 0.3) takes 0.3 of the open-ground amount; Rivet's own rocket splash never
hurts him; a guarded Rivet takes the blast. Plus one `ArenaProjectiles.step_shots` test with a hostile splash round
ending on Rivet (full damage once, not twice).
Then `node tools/gate/quick.mjs`, `node tools/tests/run_unit.mjs --changed`, the scenario suite once (quote the summary; the
60 s replay and quest 1 unchanged: no existing row has hostile splash, so nothing should move). Commit:
`guard: hostile blasts hurt Rivet unless a solid prop stands between`. Then
`node tools/mutate/mutate.mjs --file=features/combat/rivet_blast.gd --max=20`, quote the score, add tests for real survivors
in a small second commit.

## Allowlist (any other path: stop, report a NEED)
`project/features/combat/rivet_blast.gd` (new), `project/features/combat/enemy_rounds.gd`, `project/features/combat/arena_projectiles.gd`,
`project/features/arena/arena_dodges.gd`, `project/features/combat/weapons/fight_areas.gd`, `project/features/player/**`,
`project/features/combat/combat_arena.gd` (the `walls` field + Part 0 comments), `project/boot/collect_call/stage_pilot.gd` (Part 0 comments; a cover-stance read only if needed), `project/features/arena/arena_rigs.gd` (Part 0 comments only), `project/features/arena/arena_walls.gd` (`kinds` + `blocks_kinds`),
`project/features/arena/arena_stage.gd` (the one line setting `arena.walls`), new tests `project/tests/unit/test_rivet_blast*.gd`
(+ `.uid`), `docs/decisions.md` (append one line).
Forbidden: `project/features/gauntlet/**`, `project/dev/gauntlet/**`, gauntlet tables, `project/features/combat/ai/**`,
`project/features/combat/squad/**`, enemies.json rows, `project/features/bosses/**`, `project/features/souls/**`,
`tools/gauntlet/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, native/.

## Law
Never delete or reword an existing comment you did not need to change; a comment you change keeps its facts (lane rule).
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions <= 40 lines, <= 5 params; `Log` not `print`; no global RNG; `SimClock.TICK_DT`. `.uid` with new scripts (`--import` once).
One commit per change, staged per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase,
`reset --hard`, push. Fix lint and format findings in your own edit and go on. No existing number changes. Mutate `--max=20`.

## Report
Commits (SHA + files), call sites outside your own files, the scenario summary line, the mutate score, what you could not do.
