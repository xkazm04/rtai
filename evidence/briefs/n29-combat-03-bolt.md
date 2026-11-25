# Brief n29-combat-03-bolt: the in-flight electro bolt in the halo look, and an in-game chain hop take

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) first, briefly.

## Why (owner, 2026-11-25)
"The in-flight electro bolt in the halo look." n28 moved the electro gun's chain hop and daze to live current
(`WeaponFxElectro.chain()` / `stun()` in `project/features/combat/weapons/art/weapon_fx_electro.gd`, strokes from
`ElectricArc` `project/features/combat/kills/electric_arc.gd`: 2 px cream core, amber halo 4.5 px a0.5 + 9 px a0.18,
screen px, hashed kinks re-jagged every 3 ticks, no RNG; `--electro-cells` = the old cells). The bolt in flight is still
the thick ink-rimmed `arc` cell zigzag: `project/features/combat/weapons/art/weapon_fx_art.gd` around line 88-93
(`WeaponSpec.Kind.BOLT:` -> `WeaponFxElectro.ink_under(...)`, `_cell_v(ci, &"arc", ...)`, `_cell(ci, &"spark", ...)`).
See n28's before/after stills `C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/electro_*` and notes
`evidence/n28/electric/notes.md`.

## What
A. **Restyle.** In the BOLT branch, when `WeaponFxElectro.cells` is false (default): draw the bolt as live current: one
   jagged stroke from the tail (`at - dir * len_m`) to the head (`at`) through `WeaponFxElectro`'s plan path (add a
   `bolt_plan(tail, head, tick)` beside `chain_plan` if needed, kinks from a hash of the bolt's identity / spawn and the
   3-tick cell, NOT of its moving position, so it does not boil every frame beyond the 3-tick re-jag) plus a small
   current star at the head (`star_plan`, 3-4 forks). No `ink_under`, no cells on the new path. `cells == true`
   (`--electro-cells`) keeps the old three draws exactly. Presentation only: no sim state, replay and parity unchanged.
   Tests in `project/tests/unit/test_weapon_fx_electro*.gd`: the bolt plan has no opaque ink stroke, the core is the
   narrowest at alpha 1.0 and <= 2.5 px, the head star has 3-4 forks, same inputs -> same plan, the plan is the same at
   ticks t and t+1 inside one 3-tick cell. `run_unit.mjs --changed` green, `node tools/gate/quick.mjs` green, commit A
   with ONE appended `docs/decisions.md` line:
   `- [2026-11-25] DECISION n29 combat: the electro bolt in flight drawn as ElectricArc live current (jagged cream/amber stroke tail to head + a forked star at the head, no ink rim) like its chain hop; --electro-cells = the old arc/spark cells.`
B. **The in-game take** (the owner's ask from n28: no shipped take put two targets in hop range). Add an item to the
   owner take (`tools/film/owner_take.gd` + `owner_takes.mjs`; keep `owner_take.gd` under 300 lines: a small helper file
   beside it if needed) or a new dev take under `project/dev/gauntlet/`, where Rivet fires the electro gun at a thug
   and a **second thug stands inside hop range** (`weapons.json` electro gun `chain_radius_m` 4, `chain_hops` 3), so the
   bolt flies, lands and hops. Prove the hop in the log (the chain event / the second thug's stun). Render it at
   **32 px/m, 1920x1080, 60 fps, 15-40 s** twice: default and with `--electro-cells`, plus a side-by-side
   (`C:/Users/kazda/kiro/gtai-masters/n29/combat/films/electro_bolt_pair_32.mp4`, cells left, labelled), and
   **64 px/m stills** at the same tick of the bolt in flight and of the hop (`stills/electro_bolt_{cells,current}_64.png`
   + pair). ffprobe every film. LOOK at the stills and at 3 frames of the film yourself: the bolt must read as moving
   current at 32 px/m, amber/cream only (never teal, red or vermilion). Add entries to
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames.json` (re-read before writing; keep other entries). Commit the
   take + notes `evidence/n29/electric/bolt.md` (commands, ticks, hop proof).
C. Mutate: `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/art/weapon_fx_electro.gd --max=20 --lines=<your changed lines> --tests=test_weapon_fx_electro,test_electric_arc`
   (budget 12 min); quote the score in `evidence/n29/electric/bolt.md` and commit.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000` (600 headless).
  `--rendering-driver d3d12` for renders; windowed at `--position 0,1440`, never the main display. Godot only through
  `tools/dev/run.mjs` / `runGodot` / film tools; one Godot at a time for the whole lane (another builder may run one:
  you queue); never kill a process you did not start, never by name. `mem-budget: waiting` = the 16 GB cap: wait.
- `node tools/gate/quick.mjs` before every commit; the pre-commit hook takes up to ~12 min. If it fails on
  `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again. Never skip the hook.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every
  new `.gd`, Godot `--import` after new scripts. Stage per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
  `reset --hard`, amend, rebase, push. Commit trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/combat/weapons/art/weapon_fx_electro.gd`, `weapon_fx_art.gd` (the BOLT branch only), a new helper
beside them (+ `.uid`), `project/tests/unit/test_weapon_fx_electro*.gd` (+ `.uid`), `tools/film/owner_take*.gd`,
`tools/film/owner_takes.mjs`, `project/dev/gauntlet/**` (a new take), `docs/decisions.md` (one line),
`evidence/n29/electric/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: every PNG, every table, `project/boot/**`, the HUD files, the sim (`fight_areas.gd`, `projectile_sim.gd`,
`impact.gd`, `player_*.gd`), other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the bolt look in numbers; hop proof; film/still paths + ffprobe; how it reads; unit/quick gate; mutate score;
what was left.

## Notes from the director (session 2)
- **The print eats translucent colour.** The shipped look prints every non-ink colour to its nearest palette ink
  (`look_d4_item.gdshader`); amber's nearest used to be vermilion. c2a (12b7c141b) gave the FX view's print an amber ink
  (`PrintStage.fx_material()`, `look_profiles.json` `fx_amber_ink` true), and c2e found that ElectricArc's a0.5 / a0.18
  halo strokes dissolve in the print: only the cream core survived on the collect-call views, so CurrentLook got an
  opaque amber mid stroke. **Check on screen first** (a 64 px/m still of today's chain hop under the shipped look) whether
  the weapon chain hop / stun current prints cream+amber or cream only. If the halo dissolves there too, the bolt plan
  (and, only if it is one shared constant, the chain plan) gets an opaque amber mid stroke (alpha 1.0, wider than the
  core, narrower than the 4.5 px halo); say which in the decisions line. Look at the result at 32 px/m: the bolt must
  read amber/cream, never vermilion.
- Quick gate's standalone parse of `weapon_fx_electro.gd` / `weapon_fx_art.gd` fails even unchanged (Log autoload chain):
  compare against the base commit and do not chase it.
- `--electro-cells` is already a KNOWN flag (n28). Do not add flags.
- Another builder (sword hilt PNGs) may run in parallel; one Godot for the lane: check `tasklist` for a Godot you did
  not start and wait; batch your Godot runs.
- c2e (collect-call electric) may still be running mutate (a temp worktree, one Godot) until ~03:15: queue behind it.

## Wall clock (binding)
Started 02:59. The director's session (and you) stop at 03:50. Commit A (restyle + tests + decisions line) by **03:30**.
Then B: write the take and commit the take file + `evidence/n29/electric/bolt.md` (commands, hop proof from the log) by
**03:45** even if the films are not rendered (say so in the note: the next call renders them). HARD STOP **03:47**:
report and END, committed. C (mutate) is for the next call.
