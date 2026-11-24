# Brief n27-melee-04-wreck-arcs: each robot wrecks as itself; the claw's discharge reads as current, not as glyphs

Lane `melee`, branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadlines are given at the end of this brief (wall clock).** At the hard stop write your report
and END, even mid-task. Never stop to ask: at a fork pick what best serves the owner's words, write it in your report,
go on. Fix lint and format findings in your own edit and go on. No amend, no rebase.

## Why (n26 REPORT "What does not", `docs/day/2026-11-23/n26-melee/REPORT.md:116`)
1. **Thug and gunner wreck alike.** Under the electro gun (and the claw) finish, `ElectricWreckFx._copy` calls
   `ElectricChassis.fit_core` for both `robot_thug` and `robot_gunner`, which pins the SAME two plates on each
   (`FoeShieldView.TORSO` + `FoeTurretView.HEAD`, `project/features/combat/kills/electric_chassis.gd:31`): two
   different robots end as the same borrowed frame.
2. **The claw's discharge arcs read as white zig-zag glyphs at 64 px/m**: thick, static, cream/white branched
   strokes with an ink rim (see `C:/Users/kazda/kiro/gtai-masters/n27/melee/stills/claw_shock_64.png`, panels 1-2),
   not as live current. Code: `electric_wreck_fx.gd` `_arc`, `_clamp`, `_lift_arc`, `_core_burst`, and possibly
   `kill_shock_fx.gd` `_arcs`/`_burst` (find out which draws the shapes in panels 1-2 and say so in your report).

## What
A. **Each robot wrecks as itself.** The wreck of the robot thug and of the robot gunner is built from THAT robot's own
   live drawn art (its rig's textures as they are on screen at the kill: chest/torso, head/visor, its weapon or fists),
   not from shield/turret plates. Find where each robot's rig gets its textures (grep `robot_thug`, `robot_gunner` under
   `project/features/characters/**` and `project/features/combat/**`; `ElectricChassis.card_of` already does this for
   the shield robot and turret from the live card). Reason it must read the live rig and not a fixed texture path: the
   cast lane is redrawing the robot gunner (navy plates) and the robot thug tonight in its own branch; reading the live
   art makes the wreck follow their redraw at the merge with no change. **No new art and no generated images**: if a
   robot's rig exposes no usable texture, keep today's path for that robot and report which. Keep the shield robot and
   turret path byte-for-byte as is.
B. **Arcs read as current.** At 64 px/m: thin bright core (1.5-3 px) inside a soft wider halo, jagged with 4-7 kinks,
   re-jagged every 2-3 ticks (hash on tick and serial, no RNG, no global randf), one or two short side forks, no ink
   rim on the arc itself. Colours: keep the existing palette constants (white/cream core, AMBER halo = overload heat);
   never teal (souls only), never red (blood only), never vermilion. Reduced motion: no flicker (hold one shape).
   Keep durations, tick timings, the clamp, lift, core burst and smoke the same; only how the arc strokes are drawn.

C. **The mastery card has a picture (do this FIRST, it is on screen in the owner's bond film).** Today a `mastery` offer
   card draws a blank band where the picture goes (`films/bond_mastery.mp4` at 18 s, `stills/bond_offer_64.png`):
   `project/dev/gauntlet/gauntlet_pick_card.gd` `_ready` matches `"stat"`, `"weapon"`, `"ghost"` but not `"mastery"`.
   Give `mastery` the same ghost figure as the `ghost` kind for its `ref`, plus that ghost's chip ring drawn FULL with
   the crown diamond in teal behind/around the figure (reuse `GhostBondRing`'s drawing or constants, do not copy its
   maths), so it reads as "this ghost, mastered". Keep the card size, title, kind label and focus as they are. Then
   re-render the bond film with the existing entry (`evidence/n27/films/render_bond.mjs` / `films.md` say how: seed 2,
   `--bond-prefill=6`) over `films/bond_mastery.mp4` and `stills/bond_offer_64.png` (keep the old ones as
   `films/bond_mastery_blankcard.mp4` / `stills/bond_offer_blankcard_64.png` and set them as `before` in frames.json).
   ffprobe the new film (15-40 s). A unit test: a `mastery` card has a non-null illustration / drawn ghost.
   Commit C by 25 minutes after launch.

## Acceptance (numbers up front)
- Same-tick before/after stills at 64 px/m for: claw on robot thug (ticks 100, 112, 124, 140 as the 4-up sheet in
  `tools/film/owner_takes.mjs` take `claw_shock`), electro gun on robot thug and on robot gunner (the `electric_robots`
  take or `tools/film/electric_stills.gd`). Save to `C:/Users/kazda/kiro/gtai-masters/n27/melee/stills/`
  (`wreck_thug_vs_gunner_before_64.png` / `_after_64.png` side by side thug | gunner; `claw_arcs_before_64.png` /
  `_after_64.png`) and add entries to `frames.json` there (keep every existing entry; `before` = the before still).
  Look at them yourself and say in one line each what changed. The thug and the gunner wreck must differ at a glance
  (different silhouette and plates), and each must match the robot as it stood alive one tick before the kill.
- A 32 px/m film of the electro gun finishing a thug then a gunner (re-render `electric_robots` take to
  `films/electro_gun_wrecks.mp4`, 15-40 s, ffprobe line) and re-render `films/claw_shock_robots.mp4` after B.
- Unit test(s) in `project/tests/unit/` that fail if the thug and gunner wrecks are built from the same textures, and
  that pin the arc re-jag cadence (shape at tick t != shape at t+3; same at t and t with the same serial).
- Determinism: the 60 s replay and parity do not move (these are presentation only); run
  `node tools/tests/run_unit.mjs --changed` and `node tools/gate/quick.mjs` before each commit; if any scenario names
  these files, run `node tools/tests/run_scenarios.mjs --only=<names>` (or the scenario runner in AGENTS.md).
- Mutate after the commit: `node tools/mutate/mutate.mjs --file=project/features/combat/kills/electric_chassis.gd --max=20`
  (budget 20 min, quote killed/(killed+survived)).

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for renders; windowed only at `--position 0,1440`, never on the main display. One Godot
  process at a time; kill only your own PIDs, never by name.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every new
  `.gd`, Godot `--import` after new scripts before committing. `node tools/gate/quick.mjs` before every commit. Stage per
  path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. If the pre-commit hook
  fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again.
- Colour law: red is blood only; teal only for souls; vermilion only for danger and Rivet's collar; amber = heat/overload.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/combat/kills/**`, `project/tests/unit/test_electric*.gd` and new `project/tests/unit/test_*wreck*.gd` /
`test_*arc*.gd`, `tools/film/owner_take.gd`, `tools/film/owner_takes.mjs`, `tools/film/electric_stills.gd` (+ tests
beside them), `project/dev/gauntlet/gauntlet_pick_card.gd` (part C only; the pressure lane owns the rest of `project/dev/gauntlet/**`),
`project/dev/ghost-forms/**`, `evidence/n27/films/**`, `project/tests/unit/test_gauntlet_pick_card*.gd`,
`evidence/n27/wreck/**`, the masters dir `C:/Users/kazda/kiro/gtai-masters/n27/melee/`.
Forbidden: character art and rigs (`project/features/characters/**`: cast lane), `cast_cards.json`, `enemies.json`,
`weapons.json`, `combat.json`, the rest of `project/dev/gauntlet/**`, the keys lane's souls HUD files, other worktrees, root
`JOURNAL.md` / `REPORT.md`. If reading a robot's textures needs a new accessor in a characters file: `NEED cast` in your
report and use what is reachable from the rig node (meta, children) instead.

## Order and commits
0. C (mastery card picture) first; commit; re-render the bond film and offer still.
1. B (arcs) next: smaller, self-contained; commit; stills; re-render claw_shock film.
2. A (wrecks); commit; stills; electro gun film.
Write commands, ffprobe lines and findings to `evidence/n27/wreck/notes.md` (commit it).

## Report and END (short)
Commits; which code drew the glyphs; per robot what the wreck now uses; stills/films paths + ffprobe; unit + quick gate
lines; mutate score; what failed or was left.

## Times (wall clock)
Launched about 05:45. **Commit C by 06:10**, B by 06:30. **Hard stop 06:55: report and END.** A wrecks part
not committed by then: leave it uncommitted, say so.

## Known, not yours
`test_ghost_form_hud.test_deploy_hint_follows_the_rebound_key` fails on this branch (expects 249.2, gets 120). The keys lane
fixed it on its branch (`3f2bb5c2e`); it clears at the Director's merge. Do not touch it; ignore it in `--changed` runs.
