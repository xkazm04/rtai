# n31 ghost 12 - Ohm's drop drawn in beats: on the spot, a creeping telegraph to the radius, a discharge ring, a scorch that stays

Builder tag: `g12-ohm-beats`. **First commit within 25 minutes; hard stop 60 minutes after launch: commit what passes, report, END.** Never end with a commit sitting in the pre-commit hook (~12 min).
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -15`, the prep `C:\Users\kazda\kiro\gtai-art\ghost-n31\ohm-beats\state.md` (chain, cells, jobs), and Tonnage's finished pass as the pattern: `git show --stat b8e1739eb f12b3726f 16ccdb99b`, `project/features/souls/tonnage_drop_marks.gd`, `tonnage_drop_beats.gd`, `ghost_deploy_body.gd` (`_drops`, `_beats`).

## Why
Owner: "The animation of ghost deployment and effect needs more detailed work - expecting the same issue will be for other ghosts". g10 made Ohm one press -> 18-tick charge -> full circle radius 5 m (check `git log` for whether the shipped row is already `press_mode: drop`; if g10 left the flip as a NEED, do the flip FIRST, as its own commit, with its tests and the `test_ghost_number_keys` fix it names). Today a dropped Ohm stands 5 m off the spot (`ghost_deploy_body.gd:91-95`, main's near-quadrant offset), nothing marks the circle during the charge, and nothing remains after he goes.

## Director decisions (JOURNAL 00:22; do not reopen)
Row-0 body lock in drop mode (as Tonnage); Ohm stands ON the spot in drop mode; `life_ticks` 48 -> 66; the bolts stay teal; every ground effect is amber current (#FFB000-ish) + ink + soot, never teal; scorch holds 2 s + 1 s fade from a record that outlives the ghost (reuse Tonnage's record pattern).

## Beats (P = press, D = P + 18)
- arrival P..P+5: fade in on the spot + rise ~0.5 m, small ink shadow.
- charge P..D-1: act c0 held; the amber creep (`fx-creep-ring`) revealed outward from his feet, its front reaching radius_m exactly on D (the telegraph; the crack-reveal code of `TonnageDropMarks` is the pattern).
- discharge D..D+12: act c1 + the existing bolts; the arc ring (`fx-arc-ring`) expanding to radius_m; the camera kick (generalise `TonnageDumpKick` to Ohm with the row's own shake id, e.g. `dump_shake: "boss_hit"`, or a lighter camera.json id; read the ids in `camera.json`).
- aftermath: c2 held to the fade; the scorch ring (`fx-scorch-ring`, outer edge = radius_m) + burn core (`fx-scorch-core`) under the spot, 2 s + 1 s fade.
Art: the images are in `C:\Users\kazda\kiro\gtai-art\ghost-n31\ohm-beats\out\` (chroma green; pack with `tools/ghost/drop_pack.py` like Tonnage's; measure each texture's rim radius in px like `TonnageDropMarks` constants do). If an image is missing or unusable, draw that beat in code (arcs/lines in amber + ink) and say so.

## Also
- The sheet warning (`ghost_sheet: .../p70/ohm_spec_hover.png needs five rows of square pose cells`): apply the prep's fix (state.md section 2: skip the cols-0 probe in `GhostSheet.walk_of` when `<name>_spec_cells.json` exists); a unit test that loading Ohm logs no such warning, or that walk_of returns null without probing.
- Move g09's `dump_shake`/`dump_hitstop` into `GhostAttacks.DeployRow` (TonnageDumpKick.shipped() reads the table directly today).

## Evidence (in this call)
A 64 px/m still strip of the four beats (P+3, D-6, D+2, D+60) through a dev probe (copy `project/dev/ghost_n31/ghost_n31_beats.gd`'s approach for Ohm with a `--form=ohm` flag, or a new `ghost_n31_ohm_beats.gd`), and the drawn radius measured in the D+2 frame (bar: within 0.25 m of radius_m). Look at every still (Read the png) before its commit. To `C:\Users\kazda\kiro\gtai-masters\n31\ghost\` + `frames.json` entries. Provenance lines for each shipped image in `steam/ai-provenance/2026-11.jsonl` (copy g03's lines' format). One `docs/decisions.md` line.

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Lane Godot lock `build/n31/godot.lock` per run (`g12-ohm-beats <pid>`; never delete another's). `node tools/dev/run.mjs` refuses `--rendering-driver` for some probes: then the default driver.
- Allowlist: `project/features/souls/**` (Ohm view/effects/body, ghost_sheet, ghost_attacks.gd, tonnage_dump_kick.gd), `project/features/souls/art/**` (new pngs + .import), `project/data/tables/ghost_attacks.json` + schema, `project/tests/unit/test_ohm_*.gd`, `test_ghost_sheet*.gd`, `test_tonnage_dump_kick.gd`, `test_ghost_number_keys.gd`, `project/dev/ghost_n31/**`, `tools/ghost/**`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (one line), `tools/debt/baseline.json` via the debt tool, `evidence/n31/ghost/**`, `build/n31/**`, masters ghost folder. NOT `project/features/combat/**`, `project/dev/gauntlet/**`, other lanes' files. Any other path: STOP, report a NEED.
- Typed GDScript, ~200 lines/file (hard 300), <= 40 lines/function, <= 5 params, `Log` not `print`. New files -> `--import` via runGodot, commit `.uid`/`.import`. Before each commit `node tools/tests/run_unit.mjs --select=<the ohm/tonnage/ghost tests you touched>`.
- Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard; never skip the hook. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Commits, the beat strip paths and what you saw, the measured radius, the sheet-warning fix, NEED lines.

## Added 00:48 (director, after g10's report) - overrides the above where they differ
- Part 0, its own commit FIRST: ship the Ohm drop. `ghost_attacks.json` ohm row -> `press_mode` "drop", `radius_m` 5 (g10's lab: 8-cop 45 % -> 83 %, `evidence/n31/ghost/measure-ohm-head.md`), `life_ticks` 66. In the same commit pin `deploy[&"ohm"].press_mode = &"hold"` (and the old radius where a rim test needs it) in `test_ghost_deploy_attacks.gd` (rim check :107-120), `test_ghost_deploy_bot.gd`, `test_ghost_deploy_tally.gd`, `test_ghost_bond_input.gd` (10 tests assume the hold flow), and drop the two drop-row override lines in `test_ohm_drop.gd` `before_each`. These four test files are added to your allowlist. Run the full unit suite (`node tools/tests/run_unit.mjs`) and the scenarios once after part 0; a moved digest is re-pinned once with a dated decisions line naming "n31 ghost Ohm drop".
- View timing (g10): `ghost_deploy_body.gd:116` `_drops` is Tonnage-only, so a dropped Ohm would play its strike cells from the press (start_tick) while `ghost_deploy_effects.gd` draws the bolts from release_tick (18 ticks later). Generalise `_drops` to every drop row so the body holds c0 until D (deploy_age negative during the charge, like Tonnage), then c1 on D with the bolts.
- Ohm deploy kills: the shock death (`ohm_shock`) is keyed by weapon `ohm_bolt` (`signature_kill_table.gd:29-32`); deploy kills pass `deploy_ohm`. Do NOT change the strike's weapon (the contact list in `ghost_deploy_effects.gd` reads it). Write the patch `evidence/n31/ghost/ohm_deploy_kills.patch` (`"also_weapons": ["deploy_ohm"]` on the `ohm_shock` row of `signature_kills.json`, git diff format, NOT committed) and report `NEED melee`.
- Allowlist addition: `project/tests/unit/test_ghost_deploy_attacks.gd`, `test_ghost_deploy_bot.gd`, `test_ghost_deploy_tally.gd`, `test_ghost_bond_input.gd`, `test_ohm_drop.gd`.
