# Brief n28-combat-03-electric: the electro gun's arc and spark cells redrawn in the halo look

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see the end of this brief (wall clock). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase.

## Why (owner, 2026-11-24)
"Redraw the electric atlas cells (spark, arc) in the halo look." Last run moved the wreck arcs (`ElectricArc`,
`project/features/combat/kills/electric_arc.gd`: 2 px cream core `CORE` in a 4.5 px and 9 px amber halo `HALO`, screen
pixels, hashed kinks re-jagged every 3 ticks, no RNG, held under reduced motion) and the stun body sparks (`ShockJolt.spark_plan`)
to that look. What still reads as cream comic glyphs with a thick ink rim: `WeaponFxElectro`
(`project/features/combat/weapons/art/weapon_fx_electro.gd`): `chain()` draws the `arc` cell (`project/features/combat/weapons/art/fx/arc_{0,1,2}.png`,
stretched from a to b, with an 8-way ink outline `ink_under`) and a `spark` cell (`fx/spark_{0,1,2}.png`, the cream
"spider") where it lands; `stun()` draws two `spark` cells circling a stunned head. Note: these cells are separate PNGs
under `weapons/art/fx/`, not cells of `project/features/fx/art/fx_atlas.png` (the lane brief's wording); fx_atlas cells
20-23 (`fx.json` kind `crackle`, the melee crackle) are NOT this pick: list them in your report only.

## Decision already taken by the director
Draw the current live with `ElectricArc` strokes instead of re-painting PNGs: the look is then exactly the wreck arcs'
the owner already saw (one source of the look: `ElectricArc.strokes`), thin at every zoom (cells blur at 64 px/m), and no
image-tool rolls are spent. The old cells stay one flag away.

## What
A. **Before** (current tree, before any edit), 64 px/m, fixed ticks: (1) a patrol cop stunned by the electro gun
   (daze sparks round the head); (2) a chain hop of the electro gun between two targets; (3) a deflect spark (guard
   return). Use `tools/film/electric_stills.gd`, `node tools/film/owner_takes.mjs <dir> 64 claw_shock` and the takes
   `evidence/n27/films/films.md` lists (say which you used). Save to
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/electro_{stun,chain,deflect}_before_64.png`.
B. **Restyle** (`weapon_fx_electro.gd`, + `electric_arc.gd` only for a small public helper if needed, never copying its
   maths):
   - `chain(ci, a, b, phase)`: one `ElectricArc`-look stroke from a to b (jagged by `ElectricArc.shape`, kinks from a hash
     of the ends/phase, no RNG, re-jag on the same 3-tick cell), and at `b` a small star of current: 3 to 4 short forks
     (`FORK_M`-scale) radiating from the landing point, same strokes. No ink outline: `ink_under` is not called on the new
     path. Widths in screen px as `ElectricArc` does.
   - `stun(ci, at, tick, sparks)`: the two circling daze marks become two small stars of current (same helper), same
     orbit (`STUN_RING_M`, `STUN_LIFT_M`, turn rate). Readable on cream paving at 32 px/m: if the amber halo washes out,
     add ONE faint ink under-halo (alpha <= 0.35, width <= the halo) like `ShockJolt.spark_plan`, never a solid rim.
   - Colour law: core cream/white, halo amber (`ElectricArc.HALO`). Never teal (souls), never red, never vermilion.
   - Old look one flag away: static `cells: bool = false` in `WeaponFxElectro`, set by a launch flag
     `--electro-cells` declared in `project/boot/launch_args.gd` `KNOWN_FLAGS` (append ONE line; then
     `node tools/debt/debt.mjs --update --accept-regression="--electro-cells for n28 combat"`). Read it where
     `--arc-ink=off` is read (same style). `--weapon-fx=shapes` keeps working.
   - The electro bolt's own `ink_under` in `weapon_fx_art.gd:91` (the projectile in flight) and `WeaponFxRay`'s
     `ink_cell` are NOT changed.
   - The deflect's `_spark` (`project/features/player/player_deflect.gd:65-70`) goes through `chain_arcs` too, so it turns
     into current with this change. Keep it so (amber = heat of the bat is allowed), film it, and say how it reads; the
     director puts it to the owner.
   - Presentation only: no sim state, the 60 s replay and parity must not move.
C. **Tests** (`project/tests/unit/test_weapon_fx_electro.gd` or beside the existing electric tests): make the draw a
   testable plan like `ShockJolt.spark_plan` / `GhostBondRing.plan()` (a list of strokes: points, colour, width), then pin:
   default chain = no stroke in opaque ink, the core is the narrowest, alpha 1.0, <= 2.5 px; the star at `b` has 3-4 forks;
   same inputs -> same plan (determinism); `cells = true` -> the old cell path. `node tools/tests/run_unit.mjs --changed`
   green. Commit B+C by the commit deadline, with ONE appended `docs/decisions.md` line:
   `- [2026-11-24] DECISION n28 combat: electro chain arcs and daze sparks drawn live in ElectricArc's halo look (thin cream core, amber halo, no ink outline) instead of the arc/spark cells; --electro-cells = before. Rejected: repainting the cells by the image tool (cells blur at 64 px/m and would drift from the wreck arcs' look).`
D. **After**: the same three stills at the same ticks (`electro_{stun,chain,deflect}_after_64.png`), plus one side-by-side
   per pair (`..._pair_64.png`, before left). Look at each yourself at full size: the current must read at 32 px/m too
   (make one 32 px/m crop of the stun). Mutate: `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/art/weapon_fx_electro.gd --max=15 --lines=<changed lines> --tests=<your test>,test_electric_arc,test_shock_spark`
   (budget 12 min); quote the score.
E. **Films** (32 px/m, 1920x1080, 60 fps, 15-40 s, ffprobe each) to `C:/Users/kazda/kiro/gtai-masters/n28/combat/films/`:
   re-take the claw film `claw_shock_robots.mp4` and `electro_gun_wrecks.mp4` as `evidence/n27/films/films.md` says
   (before = `C:/Users/kazda/kiro/gtai-masters/n27/melee/films/claw_shock_robots.mp4`, `electro_gun_wrecks.mp4`).
   Add stills and films to `C:/Users/kazda/kiro/gtai-masters/n28/combat/frames.json` (keep existing entries).

## Checks
`node tools/gate/quick.mjs` before every commit; budget about 12 min for the pre-commit hook. If it fails on
`tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again (never skip the hook). If a scenario or
the kill reel tests read the electro cells, run them (`node tools/tests/test_map.mjs project/features/combat/weapons/art/weapon_fx_electro.gd`).

## Repo law (binding)
- Memory budget: the lane sessions hold the 8 GB cap near 6.2 GB, so the default 1200 MB estimate waits up to 30 min a run. Export `GTAI_GODOT_EST_MB=600` for headless runs and `GTAI_GODOT_EST_MB=1000` for rendered runs (measured in call 01b, `evidence/n28/bond/memory.txt`). A `mem-budget: waiting` line is still not a hang: wait; never bypass the cap.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  `--rendering-driver d3d12` for renders; any windowed run at `--position 0,1440`, never the main display. One Godot
  process at a time; kill only your own PIDs, never by name. 8 GB machine cap: `mem-budget: waiting` is not a hang.
- Typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every
  new `.gd`, Godot `--import` after new scripts before committing. Stage per path; banned: `git stash`, `add -A/./-u`,
  `commit -a`, `reset --hard`, amend, rebase, push.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/combat/weapons/art/weapon_fx_electro.gd` (+ a new helper file beside it with `.uid`),
`project/features/combat/kills/electric_arc.gd` (a small public helper only), `project/tests/unit/test_weapon_fx_electro*.gd`,
`project/tests/unit/test_electric*.gd` (+ `.uid`), `project/boot/launch_args.gd` (one appended `KNOWN_FLAGS` line),
`tools/debt/baseline.json` (through the debt tool only), `tools/film/**` (take/still helpers only), `docs/decisions.md`
(one appended line), `evidence/n28/**`, `C:/Users/kazda/kiro/gtai-masters/n28/combat/`.
Forbidden: art PNGs, `fx.json`, `fx_atlas.png`, `weapon_fx_art.gd`, `weapon_fx_ray.gd`, the sim (`fight_areas.gd`,
`projectile_sim.gd`, `impact.gd`, `player_*.gd`), `rivet_motion.json`, `input_actions.json`, `cast_cards.json`, character
art, `project/boot/prologue/**`, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the stroke look in numbers (widths, colours, alphas, forks); still/film paths + ffprobe lines; how the deflect
reads now; unit + quick gate lines; mutate score; what was left.

## Session note (director, 19:24): part A is DONE, start at part B
The before stills exist (call 03a): `C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/electro_{stun,chain,deflect}_before_64.png`
(+ `electro_deflect_before_full.png`). Chain = take `electro_gun_wrecks` seed 20261109 t106 (thug -> metal prop), the
`arc` cell zigzag; stun = `electric_stills` patrol_cop struck t114, still t144; deflect = pressure take guard seed 19 t62.
The after renders at the SAME ticks (helpers are git-ignored under `build/dev/`, read them first):
- stun: `node build/dev/n28-electric-takes.mjs 64 electro_gun patrol_cop` (take `patrol_cop-stun-plus30.png`)
- chain: `node tools/film/owner_takes.mjs build/n28electric/takes 64 electro_gun_wrecks`, then crop `0106.jpg` with ffmpeg `crop=700:400:620:250`
- deflect: `node build/dev/n28-deflect.mjs guard 19 62`, crop `560:340:460:350`
Rendered runs: `GTAI_GODOT_EST_MB=1000`.

## Wall clock (binding)
- Builder is an in-session subagent: it dies with the director's session at 20:52. **HARD STOP 20:38: report and END.**
- **Commit B+C by 20:05** (the quick gate + hook take ~12 min: start them by 19:52). Then D (after stills + pairs, look at
  them), then mutate (12 min budget, `--max=15`), then E films if time is left; whatever is not reached, list it.
- Commit evidence (stills are outside the repo; `evidence/n28/electric/*.md` notes inside) as its own commit before 20:35.
