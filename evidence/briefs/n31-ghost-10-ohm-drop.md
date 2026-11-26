# n31 ghost 10 - Ohm: one press, a short charge, a full-circle discharge that clears a group

Builder tag: `g10-ohm`. **First commit within 25 minutes of launch; hard stop 50 minutes after launch: commit what passes, report, END.** Never end with a commit sitting in the pre-commit hook (~12 min).
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -15`, `evidence/n31/ghost/measure-others-main.md` (Ohm's before), `evidence/n31/ghost/measure-head.md` (how Tonnage was measured).

## Why
Owner: "The animation of ghost deployment and effect needs more detailed work - expecting the same issue will be for other ghosts". Tonnage (item 2, `d7db0eb24` + `0f81d27dd`) is now one press -> 27-tick charge -> full-circle dump with the victim radius added, no marker. Ohm (key 4) is the next ghost: on main it is hold-to-aim with the marker, an instant full circle of r 3.5 m at the spot (centre distance only), bolt_damage 2, machines short-circuited 2 s. Main lab: share hit of an 8-cop cluster 45 % (3.6 of 7.7), 12-cop 40 %: too small for a group.

## Known (director)
- The drop path is row-driven already: `GhostAttacks.DeployRow.drops()` (`press_mode` "drop"), `drop_at`, `charge_ticks` (`ghost_attacks.gd:21-30,68-69`), `ghost_deploy.gd:49-62,124-126` (`_drops(id)`), `TonnageDump` (`tonnage_dump.gd`: arm/count/press/step/_land, `victims()` with the victim radius, `push_dir`). The strike's `_ohm` (`ghost_deploy_strike.gd:88-105`) uses centre distance; the tonnage branch (`:108-120`) uses `TonnageDump.victims`. The marker (`ghost_deploy_marker.gd:41-52,77-86`) draws per form.
- Ohm kills already die as `OhmStage.KILL_KIND` "electrocuted" (`ghost_deploy_strike.gd:181`): check in a still that the shock death plays (not the bullet fall); if it does not, find why and report.
- `node tools/ghost/deploy_measure.mjs --mode=lab --form=ohm [--radius=4.5,5,5.5] [--full=only] [--charge=<ticks>]` measures the lab on the live tree (read its header lines 1-20).

## Do
1. Ohm row -> `press_mode` "drop", `drop_at` "aim", `charge_ticks` from a new `charge_s` (start **0.3 s** = 18 ticks: Ohm is the quick caster; Tonnage 0.45), full circle centred on the spot with the victim radius added (reuse `TonnageDump.victims`; if you rename/generalise `TonnageDump`, keep Tonnage's behaviour and tests identical). The marker is gone for Ohm in drop mode (as for Tonnage). Rivet is not hit. The short-circuit and bolt damage stay. Tests: extend or copy `test_tonnage_drop*.gd` patterns into `project/tests/unit/test_ohm_drop.gd`: one press is ACTIVE with no aiming, no damage before the dump tick, a foe that leaves the circle during the charge is not hit, one inside (incl. at rim + body radius) is, a machine inside is shorted. Fix `test_ghost_number_keys.gd` the way g05 did for Tonnage if key 4 expectations break (pin hold explicitly or assert the drop). Commit.
2. Radius: lab sweep with charge 18: `--form=ohm --mode=lab --radius=3.5,4.5,5,5.5 --charge=18`. Pick the smallest radius with 8-cop share hit >= 75 %; > 7 m = stop, keep 3.5 and report it as a call. Set `radius_m` to it. Write the table to `evidence/n31/ghost/measure-ohm-head.md` (main row from measure-others-main.md beside it). Commit with ONE `docs/decisions.md` line (`- [2026-11-25] DECISION ghost n31 Ohm drop: press_mode drop, charge 0.3 s, radius 3.5 -> X m (lab 8-cop 45 % -> Y %), why`). `git diff docs/decisions.md` must show only your line.
3. Run the scenarios once (`node tools/tests/run_scenarios.mjs` or the documented runner; ~10 min). A moved digest: re-pin it once with a decisions line naming item "n31 ghost Ohm drop". Commit.
4. If time remains: mutate the changed lines of the strike/dump file `--max=10 --tests=test_ohm_drop,test_tonnage_drop`.

Not in this call: Ohm's drawn charge and discharge beats (next call), the gauntlet film.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot command. Lane Godot lock `build/n31/godot.lock` per run (wait, write `g10-ohm <pid>`, delete yours after, never another's).
- Allowlist: `project/features/souls/{ghost_deploy.gd,ghost_deploy_strike.gd,tonnage_dump.gd,ghost_attacks.gd,ghost_deploy_marker.gd}` (+ a small new souls helper if a file would pass 200 lines), `project/data/tables/ghost_attacks.json`, `project/data/schemas/ghost_attacks.schema.json`, `project/tests/unit/test_ohm_drop.gd`, `project/tests/unit/test_ghost_number_keys.gd`, `project/tests/unit/test_tonnage_drop*.gd` (only if a rename forces it), scenario digest files the runner names, `evidence/n31/ghost/**`, `build/n31/**`, `docs/decisions.md` (lines as above). NOT `project/features/combat/**`, `project/dev/gauntlet/**`, `ghost_deploy_effects.gd`/`tonnage_drop_marks.gd`/`ghost_form_view.gd` (other builders), other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New `.gd` -> `--import` via runGodot, commit the `.uid`. Before each commit: `node tools/tests/run_unit.mjs --select=test_ohm_drop,test_tonnage_drop,test_tonnage_drop_edge,test_tonnage_drop_bot,test_ghost_number_keys`.
- Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard; never skip the hook. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Commits, the radius table, tests, scenarios result (digests moved?), whether the shock death plays, mutate score, NEED lines.
