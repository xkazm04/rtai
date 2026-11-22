# Brief b3-selfblast: Rivet's own blasts hurt him

Lane `controls`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n23-controls`. Owner: "let his own blasts hurt him". Decided: self damage can kill (hurt, not spared).
**Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY.**
Read `evidence/briefs/n23-controls-common.md` first: environment and repo law bind this brief.

## What exists
- Rivet's splash: `project/features/combat/weapons/fight_areas.gd` `land()` -> `_splash()` (~line 151) hits hostiles only.
- A hostile blast reaching Rivet: `project/features/combat/rivet_blast.gd` `RivetBlast.burst` (falloff `1 - d/r` using Rivet's radius; walls: `ArenaWalls.SOLID` when in cover else `HIGH`; then `arena.damage(..., &"blown")`).
- `arena.damage` (`combat_arena.gd:179`) applies guard, `FoeArmor.impact` and `victim.damage_k` (Tonnage's reduction should be that `damage_k`; verify).

## Build
1. `project/data/tables/combat.json`: new block `blast` with `self_k` = 1.0, in the schema `project/data/schemas/combat.schema.json` like the other blocks; keys sorted. Do not touch the `guard` block or any `moves` block.
2. In `rivet_blast.gd` (or a new `project/features/combat/rivet_self_blast.gd` if size demands): after Rivet's own splash, Rivet takes the base amount a hostile at that distance would get, times `self_k` (state in the report whether `hp_scale` applies and why), with the same falloff and the same wall rule as `RivetBlast.burst`. Guard does not stop a blast: check `guard.blocks_melee` never blocks `blown`; the self-hit must land when guarding. Tonnage's `damage_k` applies. Roll i-frames as for a hostile blast. A self-kill ends the run like any death; the killer is Rivet's own id and weapon: check death attribution, the HUD and the gauntlet `death` row do not crash or mislabel on killer == rivet.
3. Call site: one line in `fight_areas.gd` `land()` after `_splash`, only for shots from Rivet (name it in the report).
4. Gauntlet result: each wave gets `self_damage` (float, rounded like `damage_taken`). One-line call site in `project/features/gauntlet/gauntlet_wave_stats.gd` `finish()` calling your helper; the helper keeps the per-wave baseline itself. Add the optional `self_damage` field to `project/data/schemas/gauntlet_run.schema.json` (that field only). Run one gauntlet (`node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=5 --result=<abs json>`) and quote the per-wave `self_damage`.
5. Unit tests `project/tests/unit/test_rivet_self_blast.gd`: point blank (full x self_k), edge of radius (~0), behind a wall (0), in Tonnage (reduced by his damage_k), self_k = 0 gives 0, guard up still takes it, a self-blast can kill.
6. Replays: run `replay_60s` and the full scenario suite (default, then `--controls=legacy`). A shipped scene's replay stays identical if it has no self-hit; if one moves, find the self-hit tick and list it (scenario, digest old -> new, one-line reason) in `evidence/controls-flip/self-blast-digests.md`; re-pin only with that reason.
7. Write Rivet's blast weapons' splash radius and damage (from `combat.json` weapons) to `evidence/controls-flip/self-blast-radii.md`.
8. Film: a dev script `project/dev/controls/self_blast_film.gd` (or `tools/film/` if it fits; read `tools/README.md`) in the arena: Rivet fires a rocket at a target close by and his HP visibly drops; then the same shot with a wall between him and the impact and he takes nothing. 32 px/m, tilt 70, 1080p60, 15 to 25 s, to `C:\Users\kazda\kiro\gtai-masters\n23\controls\self_blast.mp4`, plus a still of each beat (`self_blast_hit.png`, `self_blast_wall.png`).

## Allowlist
`combat.json` (`blast` block) and its schema, `rivet_blast.gd`, `project/features/combat/rivet_self_blast*.gd`, one line in `fight_areas.gd`, one line in `gauntlet_wave_stats.gd`, `gauntlet_run.schema.json` (`self_damage` only), tests named for these, `project/dev/controls/**`, `evidence/controls-flip/**`, scenario goldens only with a listed reason.

## Report
Commits, tests, digests (unchanged or moved with reason), the radii table, the film and still paths, mutate score on the self-blast file.
