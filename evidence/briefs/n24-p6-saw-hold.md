# Brief n24-melee P6: the chainsaw holds its victim without an electric stun look

Lane `melee`, branch `n24-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Hard stop HARDSTOP wall clock** (check `date`). **Commit deadline COMMITBY.** One small change, one commit.

## The defect (director, from your P4 chainsaw-64.png)
During the chainsaw's grind a white zigzag / star crackle sits on the victim (ticks 42 to 57 of the `melee:chainsaw`
shot; also on main). Cause, read by the director: `melee_weapons.json` `chainsaw_drive` (and `chainsaw_1`) carry
`stun_ticks: 16`; `melee_contact.gd:24-25` applies every hit stun through `PlayerShock.stun_on(...)`, which sets the
victim's `FighterFx.stun_ticks`; the shared renderer `project/features/combat/weapons/fight_areas_art.gd:36` then
draws `WeaponFxElectro.stun` sparks on ANY stunned hostile. A saw is not electric.

## Wanted
A non-electric melee hit holds its victim exactly as long as before, without the electric stun look. Suggested
(verify it first): a row value per hit or weapon (e.g. `stun_look: "electric" | "hold"`, default `electric` so the
baton keeps its look; chainsaw `hold`), and for `hold` the contact holds the victim through the same path
`MeleeShutdown._hold` uses for the AI (`mind.stun_until`) rather than the FighterFx stun. The victim must still not
walk or shoot during the hold (prove it with a unit test). Warm sparks and blood from the saw stay as they are.
If the hold cannot be separated from the FighterFx stun without touching `fight_areas_art.gd` (not ours): stop and
report a NEED with the exact line.

## Acceptance
- Before/after at the same ticks (42, 46, 50, 57) at 32 and 64 px/m: `C:/Users/kazda/kiro/gtai-masters/n24/melee/kills/p6/`.
  Look at them: no white zigzag on the saw's victim; the baton still shows its arcs (render the baton shot too).
- `node tools/tests/run_unit.mjs --changed`, scenarios `rivet_chainsaw` and `rivet_baton` (or whatever names the
  chainsaw/baton scenarios carry) pass; no tape, parity or bake digest moves (if one moves: stop and report why).
- `node tools/gate/quick.mjs` before the commit (the `rig_clips.gd` standalone cascade is pre-existing on b3f4727c0).
- `node tools/mutate/mutate.mjs --file=project/features/player/melee_contact.gd --max=20` on changed lines; quote it.

## Setup
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` before EVERY Godot or gate run;
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time in this lane. Windowed: `--position 0,1440`. `--rendering-driver d3d12`. Free your own
processes by PID, never by name.

## Files you may edit (allowlist; any other path: stop and report a NEED)
`project/features/player/melee_*.gd`, `player_melee.gd`, `player_shock.gd`, `project/data/tables/melee_weapons.json`
+ its schema, tests named for these files, existing tests that break because of this change (name them).
**Forbidden**: `fight_areas_art.gd`, `combat_arena.gd`, `enemies.json`, `weapons.json`, `combat.json`,
`input_actions.json`, `features/combat/ai/**`, `features/gauntlet/**`, `features/souls/**`, `features/characters/**`.

## Repo law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer, 5 params max;
`Log` not `print`. Stage per path, one commit; no `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase,
no reset --hard, never push. Fix lint and format findings in your own edit and go on.

## Report (final message)
Commit sha + files, the before/after paths with one line on what reads, tests, quick gate, mutate score.
