# Brief b2-gait (lane foes, run n31): two ways of moving for ranged enemies

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`.
Hard stop: **60 minutes after launch, report and END**. First commit (the rule + its unit tests) within
**30 minutes**; commit each finished part as soon as its checks pass. Never end with uncommitted work or a
commit stuck in the pre-commit hook (budget ~12 min for the hook on this machine).

## The owner's words (build exactly this)
"Enemies need two types of movement: 1. Slower backwards movement with ability to shoot 2. Faster (as is)
movement in case of urgent retreat or chasing without ability to shoot."

## What the code does today (verified by the director on this branch)
- Gauntlet wave members are driven by `project/features/combat/squad/arena_squad.gd`: `step()` gets a desired
  velocity from `shield_cover.velocity(...)` -> `SquadMind.velocity()` (`squad_mind.gd`: PANIC walk, COVER
  walk, FLANK walk, or `_strafe` -> `EnemyBrain.strafe(e, rivet, ring)`; else route walk), adds separation, then
  `EnemyMotor.steer(e, desired, rivet_pos, pit)` (`ai/enemy_motor.gd`: caps at `speed_mps` (x1.6 in PANIC),
  faces Rivet except in PANIC/PATROL), then `_ranged()` fires through `GuardBrain.trigger` (token + clear line
  + dist <= attack_m) or, for `explicit_spawn` kinds (Mulroney), `FoeAttacks.trigger`.
- `EnemyBrain.strafe` (`ai/enemy_brain.gd` ~L120): radial `clamp(dist - ring, -1, 1) * speed_mps` + sideways
  `strafe_mps`: inside the ring an enemy backpedals at FULL speed while firing. Panic fires too.
- Kinds: ranged non-explicit = patrol_cop, swat, contractor, robot_gunner; explicit ranged = sergeant_mulroney
  (shotgun). rocket_trooper, sentry_turret, war_machine, shield_robot have their own minds (walker/turret/
  rocket/shield branches in `step()`): leave them unchanged. Melee kinds (riot_cop, robot_thug,
  appliance_warden): unchanged.

## Build
1. **A small gait rule** in a new `project/features/combat/squad/foe_gait.gd` (class `FoeGait`, RefCounted,
   one per `SquadMind`, e.g. `mind.gait`), pure and unit-testable:
   - Modes `FIGHT` and `TRAVEL`; `mode_since_tick`; `settle_until_tick`.
   - Wanted mode each tick: TRAVEL when the mind is in PANIC (morale broke), or moving to cover (COVER) or
     flanking (FLANK) or route-walking (not `_strafe`), or Rivet is beyond `attack_m`, or there is no clear
     line, or Rivet is inside the archetype's `danger_m` (urgent retreat). FIGHT otherwise (in range, clear
     line, strafing/holding). Expose what SquadMind needs (e.g. a `strafing()` getter) rather than duplicate.
   - Hysteresis: a mode is held at least `min_mode_s` (0.6 s = 36 ticks) before switching, EXCEPT a switch
     into TRAVEL caused by a morale break (PANIC) or by Rivet inside `danger_m`, which is immediate.
   - Leaving TRAVEL for FIGHT starts `settle_s` (0.25 s = 15 ticks): no round may be fired before it ends.
   - `may_fire(tick)`: mode == FIGHT and tick >= settle_until.
   - `speed_cap(arch)`: FIGHT -> `arch.fight_speed_k * arch.speed_mps`; TRAVEL -> as today (speed_mps, x1.6
     in PANIC).
2. **Wire it** for the five ranged kinds above (gate: not melee, and not walker/turret/rocket/shield):
   - In `ArenaSquad.step` (or a helper so `arena_squad.gd` stays under 200 lines; it is 198 now: move code
     out, do not grow it): update the gait before steering; cap the desired velocity at the gait's speed cap
     (the cap must also hold through `EnemyMotor.steer` easing; add an optional cap parameter to `steer` or
     limit `want` before it; do not change the pit's own callers' behaviour).
   - In FIGHT the enemy faces Rivet (as today); in TRAVEL it faces where it runs (velocity, like PANIC does
     in `steer`).
   - In `_ranged`: when `not gait.may_fire(tick)` treat it like "not ready" (keep the paused-rounds logic, no
     round, no WINDUP/FIRE state). Same gate before `FoeAttacks.trigger` for Mulroney.
3. **Data** (`project/data/tables/enemies.json` + `project/data/schemas/enemies.schema.json` + the parser
   `project/features/combat/ai/enemy_roster.gd`): per archetype `fight_speed_k` (0.45 for the five kinds;
   default 1.0 when absent so other kinds are unchanged) and `danger_m` (4.0 for patrol_cop, swat,
   contractor, mulroney; 3.0 for robot_gunner; default 0 = never); in `squad`: `gait_min_mode_s` 0.6,
   `gait_settle_s` 0.25. Keep the table's sorted-keys style.
4. **A legacy switch for before/after on one build**: launch flag `--foe-moves=legacy|split` (default
   `split`); `legacy` = today's behaviour bit for bit (the gait is not consulted). Find how gauntlet flags
   reach the arena (grep `ArenaArgs`, `LaunchArgs`, an existing arena flag such as one read in
   `project/features/arena/` or `combat/`), read it in an owned file if possible (e.g. a static in
   `FoeGait` set from where `ArenaSquad` is built is NOT owned: if the only way needs a non-owned file,
   use an env-free alternative: a `squad` data value `gait: "split"|"legacy"` plus the flag read inside an
   owned file via `LaunchArgs.has/value`). Append the flag to `project/boot/launch_args.gd` KNOWN_FLAGS
   (one line) and run `node tools/debt/debt.mjs --update --accept-regression="--foe-moves for n31 foes"`.
5. **Gun down in travel (pose)**: find what draws gauntlet guards' aim. `project/features/arena/arena_rigs.gd`
   ~L200 sets `GUN_OUT | AIMING` for every armed fighter (NOT your file); cast cards go through
   `project/features/combat/squad/foe_cast_view.gd` `attack_row()` (yours). If the travel pose (no aim row,
   the existing walk/run cells) can be shown from `foe_cast_view.gd` alone, do it; for `arena_rigs.gd` write
   the exact patch (unified diff) into `evidence/n31/foes/need_gun_down.patch` and do NOT apply it.
6. **Tests** (`project/tests/unit/test_foe_gait.gd`, GUT): hysteresis (no switch inside 36 ticks except panic
   and danger); settle (no fire for 15 ticks after TRAVEL->FIGHT); speed cap in FIGHT = 0.45 x speed;
   an integration-level test over a few hundred ticks of a real `ArenaSquad` (see how existing tests build
   one, e.g. grep `ArenaSquad.new` in `project/tests` and `project/dev/enemy_ai/foe_duel_trial.gd`): on
   every tick a wave member produced a Shot its speed was <= fight cap + 0.01 and its gait was FIGHT;
   `legacy` reproduces the old trace exactly.
7. **Digests**: gauntlet / scenario / replay digests that pin enemy motion WILL move. Run the full unit suite
   and the scenarios (AGENTS.md commands), re-pin exactly the digests this change moves, nothing else, and
   append ONE line to `docs/decisions.md`:
   `- [2026-11-25] DECISION foes n31 two moves: ... (values) ... digests re-pinned: <list>; rejected: ...`.
   Quest 1's script, the native city sim and the parity digest must NOT move; if one does, stop and report.

## Acceptance (numbers)
- `node tools/tests/run_unit.mjs --changed` then the full `node tools/tests/run_unit.mjs` green; scenarios
  green (`node tools/dev/run.mjs` or the AGENTS scenario command through a runGodot user).
- `node tools/lint/lint.mjs` green; `node tools/gate/quick.mjs` before each commit if it exists.
- After commit: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_gait.gd --max=20
  --tests=test_foe_gait` and quote killed/(killed+survived).
- A headless gauntlet smoke: `node tools/dev/run.mjs gauntlet --seed=1 --bot=average --pick=greedy
  --controls=wheel --waves=4 --result=build/n31/b2-smoke.json` exits 0 (and once with `--foe-moves=legacy`).

## Repo law (read AGENTS.md first)
- Typed GDScript, warnings are errors, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`, no global RNG, sim steps on `SimClock.TICK_DT`. New `.gd` -> commit its `.uid` (run one
  Godot `--import` before committing).
- Stage per path, `git commit -- <paths>`. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
  `reset --hard`, amend, rebase, push, `--no-verify`. Message ends with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Fix lint and format findings in your own edit and go on. If the hook fails on a
  `kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import`, commit again.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  Godot only through `tools/lib/godot.mjs` users. **One Godot at a time for the whole lane**: another builder
  (b1, measurement) runs gauntlet batches in this lane right now. Hold the lane lock `build/n31/godot.lock`
  (create it exclusively with content `b2 <pid>`; while it exists with another tag, wait and re-check every
  30 s; delete it when your Godot exits; never delete a lock that is not yours). `mem-budget: waiting` means
  the machine is full: wait.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. No Codex, no API keys.

## Owned files (allowlist; any other path: stop and write a NEED in your report)
- `project/features/combat/squad/**` except `*_card_view.gd`; `project/features/combat/ai/**`;
  `project/data/tables/enemies.json` (existing rows: AI fields only) + `project/data/schemas/enemies.schema.json`;
  `project/tests/unit/test_foe_gait.gd` (+ `.uid`) and existing tests/scenario pins that this change moves;
  one line in `project/boot/launch_args.gd` KNOWN_FLAGS; `tools/debt/baseline.json` via the debt tool;
  one appended line in `docs/decisions.md`; `evidence/n31/foes/**`.
- Forbidden: `project/dev/foes_n31/**` and `tools/gauntlet/waiting*` (b1 is writing them), player,
  prologue (`project/boot/prologue/**`), souls, kills, weapons, `combat.json`, `weapons.json`, hurt/hit radii,
  melee reach, wave composition, `cast_cards.json` art/anchors/scale, any `*_card_view.gd`.

## Report (your final message)
Files, commits (hash + subject), commands with their result line, mutate score, digests re-pinned, the NEED
patch path if any, what you could not do and why.
