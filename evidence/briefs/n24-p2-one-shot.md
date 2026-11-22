# Brief n24-melee P2: a human hit by a melee weapon dies in one swing, brutally, per enemy type

Lane `melee`, branch `n24-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Hard stop 19:50 wall clock** (check `date`). **Commit deadline 19:45**.

## The owner's words (verbatim)
"we need on unique swing per weapon, with unique brutal animation per human enemies as it should
one-shot them." P1 (already committed on this branch, read `git log -5` and its tests) made one click
one swing per weapon. This package: the kill.

## Setup
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` before EVERY Godot or gate run;
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- One Godot process at a time in this lane. Windowed: `--position 0,1440`. Rendering: `--rendering-driver d3d12`.
  Free your own processes by PID, never by name. After new scripts or art: one `--import` before commit.

## The rule (decided by the director; build it so each choice is one data value)
1. In each melee weapon's row (`melee_weapons.json`; the claw in `rivet_melee.json`) a field
   `kills_human` (bool). Shipped: `true` for `chainsaw`, `electro_baton`, `katana`, `plasma_sword`;
   `false` for the claw (hands are the quick claw: owner said "melee weapons"; the claw stays as it is).
   A landed swing of a `kills_human` weapon on a living hostile whose body is human (`Fighter.body_class`
   / the archetype `body: "human"`, NOT `machine`, NOT `body: "robot"`) is lethal in that one swing,
   whatever its hp. Every human in the arc dies (one swing, several kills: the arc is the weapon's
   `cone_dot` + reach from P1).
2. **Mulroney** (`sergeant_mulroney`) and any boss-owned fighter: never one-shot. He "falls last" by his
   fight rules (`project/boot/prologue/prologue_battle.gd`, `bosses.json` `mulroney`): a melee hit on him
   deals the weapon's normal damage. Find how the fight protects him and keep it.
3. **A raised riot shield** (`riot_cop`, the front arc where `shield_front_mult < 1`) is the one thing
   that may stop a swing. Per weapon, a field `vs_shield`: `"blocked"` | `"through"`.
   Shipped: `katana: blocked` (sparks, the cop is shoved back and his shield knocked aside for
   `shield_break_ticks` ~40, so the next cut kills: skill = flank or break), `plasma_sword: through`
   (melts the shield and the man), `chainsaw: through` (the grind saws the shield then the man; its
   kill comes on the grind's end, not its first bite), `electro_baton: through` (the shock conducts
   through the metal shield). From behind or the side every `kills_human` weapon kills.
4. Numbers live in the weapon rows only. Do NOT edit `enemies.json` (pressure's numbers / cast's art)
   or `combat.json`.
5. Find the damage paths the waves really use (`CombatArena.damage` -> `Fighter`, and
   `EnemyPit.hurt` in `project/features/combat/ai/enemy_pit.gd`, which is pressure's file: a one-line
   call site there only, named in your report) and apply the rule in a NEW file of yours,
   `project/features/player/melee_lethal.gd` (`MeleeLethal`), called from `player_melee.gd`.

## The kill, per weapon class and per human type
The waves' humans: `patrol_cop`, `riot_cop`, `swat`, `contractor`, `rocket_trooper` (and
`appliance_warden` if it appears in waves; check `gauntlet.json` / `pit_waves`). Weapon classes: cut
(katana, plasma_sword), saw (chainsaw), shock (electro_baton). Each (weapon, type) pair gets its own kill
that fits the weapon, using the systems that exist first: `project/features/combat/kills/**`
(`signature_kills.json` rows `katana_split`, `plasma_sword_split`, `chainsaw_grind`, `baton_overload`,
styles split / cook / shred / gib / snap / throw ... , `SignatureKillTable` looks up by weapon only),
`human_reactions.json`, `features/combat/react/**`.
- Extend `signature_kills.json` with optional per-victim variants (e.g. a row field `victim:
  <archetype id>` or a `variants` map), lookup `(weapon, archetype)` falling back to the weapon row, so
  each pair differs on screen: cut angle and where the body parts (head, waist, diagonal shoulder ->
  hip), what flies (the riot cop's helmet and shield halves, the SWAT's rifle, the rocket trooper's
  tube), how the halves fall, spray amount and direction; saw = shredded chunks along the drive and a
  long grind; shock = the cook (seizure, smoke, char) with a different collapse per type (the heavy
  SWAT drops to his knees, the light contractor is thrown). Red is blood only; amber allowed for
  heat/overload; teal never (souls only); vermilion never.
- Do not draw new character frames in this package unless an existing system cannot show the kill;
  if a type clearly needs frames, say so in the report with a still (new frames go through the Codex
  image pipeline, a later package).
- `--gore=reduced` keeps working (no dismemberment, standard death).

## Tests and evidence
- Unit tests (`project/tests/unit/test_melee_lethal*.gd`): each kills_human weapon kills each human type
  in one swing from the front, side and back; the claw does not; a robot (`robot_thug`) and a machine
  (`shield_robot`) are NOT killed by a blade swing; Mulroney is not; katana vs a raised riot shield
  from the front is blocked and breaks the shield, the next cut kills; three humans in a plasma sweep
  all die; the kill variant lookup falls back to the weapon row.
- `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit; scenarios
  and replays: list any moved tape/golden with a reason, one dated `docs/decisions.md` line
  (`- [2026-11-22] DECISION n24 melee: ...`, append-only). No sim, parity or bake digest moves.
- `node tools/mutate/mutate.mjs --file=project/features/player/melee_lethal.gd --max=20` and quote the score.
- Films: `node tools/film/kill_reel.mjs --out=C:/Users/kazda/kiro/gtai-masters/n24/melee/kills --weapons=katana,plasma_sword,chainsaw,electro_baton`
  (read `tools/README.md`: weapons x victim kinds, 32 and 64 px/m, a sheet per weapon), plus one live
  32 px/m tilt 70 clip per weapon of a single swing killing a cop in the arena (`tools/film/film.mjs`,
  `--rev=HEAD`). Look at the frames yourself.

## Files you may edit (allowlist; any other path: stop and report a NEED)
`project/features/player/melee_*.gd` (incl. the new `melee_lethal.gd`), `player_melee.gd`,
`player_shock.gd`, `rivet_swipe_view.gd`, `project/data/tables/melee_weapons.json`, `rivet_melee.json`,
`melee_marks.json`, `signature_kills.json`, `human_reactions.json`, their schemas,
`project/features/combat/kills/**`, `project/features/combat/react/**`, `project/features/combat/robo_tazer.gd`,
new files under `project/dev/melee/`, tests named for these files, existing tests that break because of
this change (fix the expectation, say which), one-line call sites in `combat_arena.gd` / `enemy_pit.gd`
(name them), one appended `docs/decisions.md` line, `KNOWN_FLAGS` one line if you need a flag
(`node tools/debt/debt.mjs --update --accept-regression="<flag> for n24 melee"`).
**Forbidden**: `enemies.json`, `weapons.json`, `combat.json`, `input_actions.json`, `rivet_wheel.gd`,
`stage_pilot.gd`, `player_motion*.gd`, `player_deflect.gd`, `player_guard*.gd`,
`features/gauntlet/**`, `features/souls/**`, `features/characters/art/**`, `features/bosses/**`,
`prologue_*` files, `bosses.json`.

## Repo law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer,
5 params max; `Log` not `print`; no global RNG (registry streams only), sim on `SimClock.TICK_DT`.
Stage per path, one commit per change; no `git add -A/./-u`, no `commit -a`, no stash, no amend, no
rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on.

## Report (final message)
The rule as built (where it hooks), per weapon x type the kill you gave it, the shield results, commits
(sha + files), tests / quick gate / mutate score, film paths, moved tapes, what needs drawn frames, and
for the pressure lane's test player: the new reach and tick numbers per weapon (I write the NEED).

## Follow-up from the P1 review (do first, its own commit)
The plasma sword's single sweep has `cone_dot: -1` (a full 360 degree spin: it hits behind Rivet). Once
it one-shots, that is a free kill ring. Make it a wide FRONT sweep: `cone_dot` about -0.2 (~200 degrees),
check its drawn sweep matches the arc, keep its deflect window (active ticks 6) as it is. Update the
tests and the `rivet_*` scenario expectations it moves.
P1 also noted the baton's contact reads horizontal facing right: leave it (a drawn frame, later).
