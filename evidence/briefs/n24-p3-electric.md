# Brief n24-melee P3: robots, electric weapons finish a machine the way a blade finishes a human

Lane `melee`, branch `n24-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Hard stop HARDSTOP wall clock** (check `date`). **Commit deadline COMMITBY**.

## The owner's words (verbatim)
"For robot enemies we will need electric weapons to have similar effect" (similar to the melee one-shot
on humans, built in P1/P2 on this branch: read `git log -10`, `melee_lethal.gd`, its tests).

## Setup
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` before EVERY Godot or gate run;
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- One Godot process at a time in this lane. Windowed: `--position 0,1440`. Rendering:
  `--rendering-driver d3d12`. Free your own processes by PID. After new scripts or art: `--import`.

## The rule (decided by the director; each choice one data value in the weapon's row)
A blade (`katana`, `plasma_sword`, `chainsaw`) is NOT a one-shot on any robot: normal damage, as now.
An electric melee weapon (row field `electric: true`; shipped on `electro_baton` only) on robots:
1. A light robot (`body: "robot"` and NOT `machine: true` in `enemies.json`: `robot_thug`,
   `robot_gunner`): one landed swing shuts it down outright (lethal), like a blade on a human.
2. A machine (`machine: true`: `shield_robot`, `sentry_turret`): one swing overloads it: a long stun
   (`machine_stun_ticks`, ~150), it cannot move or fire; a second electric swing on an overloaded
   machine executes it (lethal, the shut-down). The baton's arc conducts through the shield robot's
   metal shield (front arc), as it does through the riot shield.
3. `war_machine`: never one-shot, never executed: an electric swing deals its normal damage and a
   short stun (`heavy_stun_ticks`, ~30). Listed in the weapon row (`never_finish: ["war_machine"]`)
   so the rule never names an enemy number. Bosses and boss-owned fighters: never finished.
Numbers live in the weapon rows only; do NOT edit `enemies.json` (read `machine` and `body` only).
Put the rule in your own file (`melee_lethal.gd` or a new `melee_shutdown.gd`).

## The shut-down animation (its own, not the human cook)
Arcs crawling over the frame (reuse `features/combat/react/shock_arcs_view.gd`, `kill_shock_fx.gd`),
a seizure (tick-locked jerks of the rig/card, no RNG outside the registry), an amber overload glow
building at the joints and the eye/sensor going dark, then the collapse (the frame slumps forward or
folds at the knees, sparks and a smoke puff, a scorch on the ground). Amber is allowed for overload;
teal never (souls only); red never (blood only; robots do not bleed); vermilion never. The overloaded
(stunned) machine shows a steady amber crackle so the player sees it is ready for the execute. Use the
existing kill systems (`project/features/combat/kills/**`, `signature_kills.json` with a robot/machine
variant row, `features/combat/react/**`) before anything new; no new character frames in this package
(if a robot clearly needs frames, say so with a still).

## Tests and evidence
- Unit tests: baton shuts a robot_thug and a robot_gunner down in one swing; a katana does not; the
  baton overloads a shield_robot (stunned, alive), the second swing executes it; the shield does not
  stop the baton; war_machine survives any number of baton swings beyond its normal damage and is only
  short-stunned; `electric: false` = the old behaviour.
- `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit; scenarios
  and replays: list any moved tape/golden with its reason; one dated `docs/decisions.md` line.
- `node tools/mutate/mutate.mjs --file=<your rule file> --max=20` and quote the score.
- Films to `C:/Users/kazda/kiro/gtai-masters/n24/melee/electric/`: the baton finisher on a robot thug
  and the overload + execute on a shield robot, live in the arena, 32 px/m tilt 70 1080p60 (15 to 40 s,
  check with ffprobe), and a 64 px/m close-up of each. Look at your frames.

## Files you may edit (allowlist; any other path: stop and report a NEED)
`project/features/player/melee_*.gd`, `player_melee.gd`, `player_shock.gd`, `rivet_swipe_view.gd`,
`project/data/tables/melee_weapons.json`, `rivet_melee.json`, `melee_marks.json`, `signature_kills.json`,
`human_reactions.json`, their schemas, `project/features/combat/kills/**`, `project/features/combat/react/**`,
`project/features/combat/robo_tazer.gd`, new files under `project/dev/melee/`, tests named for these
files, existing tests that break because of this change (say which), one-line call sites in
`combat_arena.gd` / `enemy_pit.gd` (name them), one appended `docs/decisions.md` line.
**Forbidden**: `enemies.json`, `weapons.json`, `combat.json`, `input_actions.json`, `rivet_wheel.gd`,
`stage_pilot.gd`, `player_motion*.gd`, `player_deflect.gd`, `player_guard*.gd`, `features/gauntlet/**`,
`features/souls/**`, `features/characters/art/**`, `features/combat/squad/**`, `features/bosses/**`.

## Repo law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer,
5 params max; `Log` not `print`; RNG through the registry only, sim on `SimClock.TICK_DT`. Stage per
path, one commit per change; no `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no
reset --hard, never push. Fix lint and format findings in your own edit and go on.

## Report (final message)
The rule as built, commits (sha + files), tests / quick gate / mutate score, film paths, moved tapes,
which other weapons should count as electric (electro_gun, the claw's charged shock, ...) and why.
