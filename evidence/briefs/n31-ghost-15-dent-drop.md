# n31 ghost 15 - Dent: one press, a short wind-up with the lane scraped on the ground, then the ram along Rivet's aim

Builder tag: `g15-dent`. **First commit within 25 minutes; hard stop 55 minutes after launch** (last commit START 15 min before; hook ~12 min). Report and END.
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -20`, `evidence/n31/ghost/measure-others-main.md` (Dent's before), `evidence/briefs/n31-ghost-10-ohm-drop.md` + `git show --stat 48d6fbc37` (how Ohm got the drop fields: the pattern to copy), `project/features/souls/ghost_deploy_strike.gd` `_dent` (~:149-170), `ghost_attacks.gd` (`DeployRow`, `drops()`, `charge_ticks`), `ghost_deploy.gd` (`_drops`).

## Why
Owner: the hold-to-aim placement is unnecessary; deploy animations and effects are too instant ("expecting the same issue will be for other ghosts"). Dent (key 1) on main: hold to aim with a marker, release, an instant capsule `ram_half_m` 0.9 from Rivet's side to the spot (range 8), `jab_damage` 1, a 0.4 m shove. Main play (10 seeds x 3 waves): 53 deploys, mean 1.81 hits, median 2, 35 % of the foes within 9 m, 11 % hit nobody.

## Director decision (do not reopen)
One press, no marker: the lane runs from Rivet's side along the CURRENT aim to the aim point clipped to `range_m` (the mouse already shows the direction; the lane is the ram, not a placement). A wind-up `charge_s` **0.25 s** (15 ticks, one data value: Dent is a charger; Ohm 0.3, Tonnage 0.45), nothing hit during it; on the ram tick every exposed live hostile whose BODY is within `ram_half_m` of the segment (victim radius added, like Tonnage's victims) takes jab_damage and the shove. The lane is frozen at the press (foes can step out during the wind-up: that is the counterplay). Rivet is never hit.

## Do
1. Dent row -> `press_mode` "drop", `charge_s` 0.25, lane frozen at press; strike counts the victim radius in drop mode (hold mode unchanged). Marker gone for Dent in drop mode. Tests `project/tests/unit/test_dent_drop.gd`: one press is ACTIVE with no aiming; nothing hit before the ram tick; a foe that leaves the lane during the wind-up is not hit; one inside (incl. exactly at ram_half_m + body radius) is, +0.05 m is not; Rivet is not hit. Pin `press_mode = &"hold"` for dent in every existing test that assumes the hold flow (grep `dent` across `project/tests/unit/` and `integration/`: at least `test_ghost_deploy.gd`, `test_ghost_deploy_attacks.gd`, `test_ghost_deploy_bot.gd`, `test_ghost_bond_input.gd`, `test_ghost_number_keys.gd`, `test_ghost_deploy_mastery.gd`, `test_ghost_apparition.gd`, `test_boss_bot_ghost.gd`, `test_gauntlet_bot_brain.gd`; run them and fix only what the flip breaks). Commit.
2. Width: Dent play measure, `node tools/ghost/deploy_measure.mjs --mode=play --form=dent --seeds=10 --waves=3` on the live tree at `ram_half_m` 0.9, 1.3, 1.6 (temporarily edit the row value per run, or add a `--half=` what-if to the dev strike if quicker; revert any temp edit). Pick the smallest with play mean hits >= 2.5 AND zero-hit <= 8 %; above 2.0 m: stop, keep 0.9, report it as a call. Set it. Table to `evidence/n31/ghost/measure-dent-head.md` (main row beside it). Commit with ONE `docs/decisions.md` line (`- [2026-11-26] DECISION ghost n31 Dent drop: one press, lane along the aim, charge 0.25 s, ram_half_m 0.9 -> X (play mean 1.81 -> Y, zero-hit 11 % -> Z %), why`).
3. Full unit suite once (`node tools/tests/run_unit.mjs`) and the scenarios once (the documented runner, ~10 min). A moved digest: re-pin once with a dated decisions line naming "n31 ghost Dent drop". Commit.
4. If time: mutate the changed strike lines `--max=10 --tests=test_dent_drop`.

Not in this call: Dent's drawn wind-up and ram beats, the gauntlet film.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot command. Lane Godot lock `build/n31/godot.lock` per run (`g15-dent <pid>`; delete only yours). Godot only through the repo tools (runGodot).
- Allowlist: `project/features/souls/{ghost_deploy.gd,ghost_deploy_strike.gd,tonnage_dump.gd,ghost_attacks.gd,ghost_deploy_marker.gd}` (+ a small new souls helper if a file would pass 200 lines), `project/data/tables/ghost_attacks.json` + schema, `project/tests/unit/test_dent_drop.gd` and the existing test files named in step 1 (only the hold pin / what the flip breaks), scenario digest files the runner names, `project/dev/ghost_n31/ghost_n31_strike.gd` (a what-if only), `evidence/n31/ghost/**`, `build/n31/**`, `docs/decisions.md` (lines as above). NOT `project/features/combat/**`, `project/dev/gauntlet/**`, the view/effects files (`ghost_deploy_body.gd`, `ghost_deploy_effects.gd`, `*_marks.gd`), other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New `.gd` -> `--import` via runGodot, commit the `.uid`. Before each commit: `node tools/tests/run_unit.mjs --select=<the tests you touched>,test_ohm_drop,test_tonnage_drop`.
- Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard, --no-verify. Commit messages end with a blank line then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Commits, the width table, tests, suite + scenarios result (digests moved?), mutate score, NEED lines.

## Added 01:04 (director, launch) - overrides the above where they differ
- Launched ~01:04; the director's session ends at 01:59 and you die with it. **Hard stop 01:48; start your last commit by 01:35.** First commit (step 1: flip + tests) by 01:30.
- Scope this call: step 1, then step 2 if the Godot lock allows. Steps 3-4 (full suite, scenarios, mutate) are the next call's: say in the report what is left. If step 1 is committed with the row still `press_mode` hold (because the sweep is not done), that is fine: ship the code + tests with the row flipped ONLY if its tests and every hold pin are green.
- Builder `g14-ohm-take` runs films at the same time and holds the lane Godot lock for long runs; wait for it (never delete it). Its files are `project/dev/ghost_n31/ghost_n31_take*`: do not touch them. Only you append to `docs/decisions.md` in this window.
- Ohm is now a drop too (`649a17523`): `test_ghost_deploy_view.gd` also pins hold for ohm; pin dent the same way where the flip breaks it (added to your allowlist).
