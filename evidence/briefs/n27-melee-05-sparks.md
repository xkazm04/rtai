# Brief n27-melee-05-sparks: the stun sparks read as current, not as ink glyphs; the last stills and films

Lane `melee`, branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadlines are given at the end of this brief (wall clock).** At the hard stop write your report
and END, even mid-task. Never stop to ask: at a fork pick what best serves the owner's words, write it in your report,
go on. Fix lint and format findings in your own edit and go on. No amend, no rebase.

## Why
The previous call (m4, `34c12865c`) moved every wreck arc to `ElectricArc` (`project/features/combat/kills/electric_arc.gd`).
But the cream, ink-rimmed "zig-zag glyphs" the owner sees beside a robot at 64 px/m are not wreck arcs. They are
`ShockJolt._spark` (`project/features/combat/react/shock_jolt.gd:97`): a 6 px ink polyline with a 2.5 px cream one on top,
used by `ShockJolt.arcs` (body arcs and spits, drawn by `ShockArcsView` over every electro-stunned body). Compare
`C:/Users/kazda/kiro/gtai-masters/n27/melee/stills/claw_arcs_before_64.png` with `claw_arcs_after_64.png`, panels 1-2: identical.

## What
A. **`_spark` reads as current.** Restyle the stroke only, in the `ElectricArc` look: a thin bright core (`Ink.CREAM` or
   `ElectricArc.CORE`, 1.5-2.5 px), a soft amber halo (`ElectricArc.HALO`, two passes at low alpha like `ElectricArc._stroke`),
   and **no solid ink rim**. On the cream factory floor the halo alone may wash out: if it does, add ONE faint dark under-halo
   (ink at alpha <= 0.35, width <= the halo) for contrast, never a solid rim. Reuse `ElectricArc`'s constants (make a small
   static stroke helper public there if needed; do not copy its maths). Keep everything else: the hashed points, `KINKS`,
   re-pick every 2 ticks, `counts`, `stun_crowd`, the spits' lengths, `--soft-shock`, the jolt pose. Widths stay in screen
   pixels. Colour law: never teal (souls), never red (blood), never vermilion; amber = heat/overload is allowed.
B. **The old look stays one value away.** `ShockJolt` gets a static `ink_rim: bool = false`, plus a launch flag
   `--ink-sparks` that sets it true, declared in `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; accept the
   debt rise with `node tools/debt/debt.mjs --update --accept-regression="--ink-sparks for n27 melee"`). Wire the flag
   where `--soft-shock` is read (grep `soft-shock`, same place, one line). Add a `docs/decisions.md` line (append one line):
   `- [2026-11-24] DECISION n27 melee: electro stun sparks drawn as a thin core in an amber halo, no ink rim (ShockJolt._spark); --ink-sparks = before.`
C. **Tests.** In `project/tests/unit/test_shock_jolt.gd` (or a new `test_shock_spark.gd`): with a recording CanvasItem
   double or by checking the stroke list (follow `GhostBondRing.plan()` if a plan function is the cleanest), pin that the
   default spark draws no stroke with the opaque ink colour and that the core is the widest-alpha 1.0 stroke <= 2.5 px; with
   `ink_rim` true it draws today's two strokes (ink 6, cream 2.5). `node tools/tests/run_unit.mjs --changed` green
   (ignore `test_ghost_form_hud.test_deploy_hint_follows_the_rebound_key`: keys' test, fixed on their branch).
   Mutate after the commit: `node tools/mutate/mutate.mjs --file=project/features/combat/react/shock_jolt.gd --max=15 --lines=<your changed lines> --tests=test_shock_jolt,test_shock_spits` (budget 15 min), quote the score.
   **Commit A+B+C by 07:25.**
D. **Stills (same tick, 64 px/m), to `C:/Users/kazda/kiro/gtai-masters/n27/melee/stills/`:**
   1. `claw_sparks_after_64.png`: the `claw_shock` 4-up sheet again (`node tools/film/owner_takes.mjs C:/Users/kazda/kiro/gtai-masters/n27/melee 64 claw_shock`, as in `evidence/n27/films/films.md`); before = `claw_arcs_after_64.png` (keep it).
   2. `ohm_stun_sparks_before_64.png` / `_after_64.png`: a human stunned by Ohm or the electro gun at 64 px/m, same tick,
      before with `--ink-sparks`, after without (use `tools/film/electric_stills.gd` or an owner_take loadout; say which).
   3. `bond_offer_64.png` re-rendered with the mastery card picture (it is still the blank-card image; `bond_offer_blankcard_64.png`
      is the before, already in frames.json): `node evidence/n27/films/render_bond.mjs <out> 64 2 6 2430 2480` then crop as
      films.md says (top: the three-card hand, bottom: the two-card hand). Update its frames.json note (drop "no illustration").
   Look at each yourself; one line each in `evidence/n27/wreck/notes.md` on what changed.
E. **Films (32 px/m, 1080p60, 15-40 s, ffprobe each):** re-render `films/claw_shock_robots.mp4` (keep the current one as
   `films/claw_shock_robots_inkspark.mp4`, `before` in frames.json); if `films/electro_gun_wrecks.mp4` does not exist yet,
   render it (the `electric_robots` take: the electro gun finishing a thug then a gunner).
   frames.json: keep every entry, add the new ones, keep 8-15 entries best first (merge or drop scratch entries rather than
   exceed 15; delete scratch renders it does not reference).

F. **After E, if time remains (commit by 07:50):** (1) `node tools/godot/check.mjs res://features/combat/kills/electric_wreck_fx.gd`
   reported FAIL in the last call ("dependency cascade, same on HEAD"): run it on HEAD and on `a3b3f1466`'s copy of the file
   (`git show a3b3f1466:<path>` to a temp file is not enough; check out nothing: just compare the two check outputs as text) and
   say whether this lane made it worse; fix it if it did. (2) `electric_chassis.gd` mutate was 7/20: the survivors are plate
   size, z order, cap offset and the shield apron copy. Pin plate width, z and cap offset in `test_robot_wreck_plates.gd`,
   re-run mutate `--max=20` on the same file, quote the score.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for renders; windowed only at `--position 0,1440`, never on the main display. One Godot
  process at a time; kill only your own PIDs, never by name.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every new
  `.gd`, Godot `--import` after new scripts before committing. `node tools/gate/quick.mjs` before every commit. Stage per
  path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. If the pre-commit hook
  fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again.
- Determinism: presentation only; the 60 s replay and parity must not move. If a scenario names `shock_jolt`, run it.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/combat/react/shock_jolt.gd`, `project/features/combat/react/shock_arcs_view.gd` (only if the stroke call
needs it), `project/features/combat/kills/**`, `project/tests/unit/test_shock_*.gd` (+ `.uid`), `project/tests/unit/test_electric*.gd`,
`project/boot/launch_args.gd` (one appended `KNOWN_FLAGS` line), the one place that reads `--soft-shock` (one line),
`docs/decisions.md` (one appended line), `tools/debt/baseline.json` (through the debt tool only), `tools/film/owner_take.gd`,
`tools/film/owner_takes.mjs`, `tools/film/electric_stills.gd` (+ tests beside them), `evidence/n27/**`, the masters dir
`C:/Users/kazda/kiro/gtai-masters/n27/melee/`.
Forbidden: character art and rigs (`project/features/characters/**`), `cast_cards.json`, `enemies.json`, `weapons.json`,
`combat.json`, `project/dev/gauntlet/**`, the keys lane's souls HUD files, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the spark stroke before/after in numbers (widths, colours, alphas); stills/films paths + ffprobe lines; unit +
quick gate lines; mutate score; what failed or was left.

## Times (wall clock)
Launched about 06:58. **Commit A+B+C by 07:25.** Stills by 07:40. **Hard stop 07:55: report and END.** Anything not
committed by then: leave it uncommitted and say so. The lane's last commit is 08:00.
