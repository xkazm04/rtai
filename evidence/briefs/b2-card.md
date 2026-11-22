# Brief b2-card: quest 1 help card follows the control mode, and the swing counter

Lane `controls`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n23-controls`. The wheel is now the default (`ControlsMode`, earlier commits on this branch).
**Hard stop: 03:20 wall clock (check `date`). Commit deadline: 03:15.**
Read `evidence/briefs/n23-controls-common.md` first: environment and repo law bind this brief.

## Part 0 (first, its own commits): finish b1 cleanly
- **Revert the vendored addon edit.** Commit `c9499ca02` added an `--controls` option to `project/addons/gut/cli/gut_cli.gd`. `addons/` is third-party only (VENDORS.md): restore that file to `76111adec` byte for byte. Forward the mode another way: `run_unit.mjs` sets an env var (e.g. `GTAI_CONTROLS=wheel|legacy`) on the GUT child, and the existing pre-run hook `project/tests/support/gut_pre_run.gd` (`.gutconfig.json` `pre_run_script`) applies it to `LaunchArgs` before any test (or `ControlsMode` reads the env only under tests: pick the one that keeps release code free of test hooks and say why). Update `run_unit_controls.test.mjs` to assert the env, not the `--` arg. Prove it: one unit test that asserts `ControlsMode.id()` equals the mode the runner was given, run once with `--controls=legacy` and once without (`--select=` that test).
- If b1's work is not all committed (`git status`), commit it now in logical commits (flip; fixtures; replay mode on tapes; pinned/twinned tests), each green under `node tools/gate/quick.mjs`.
- Append one line to `docs/decisions.md`: `- [2026-11-22] DECISION controls: ...` stating the wheel is the default, legacy stays as `--controls=legacy`, and replay tapes now carry an optional `controls` (and `wheel_start`) field; a tape without it replays on legacy; no digest moved.
- Fill the Pending rows of `evidence/controls-flip/counts.md`: full scenario suite with `--controls=legacy` and with no flag; `node tools/tests/run_unit.mjs` with no flag and with `--controls=legacy` (passed/failed/skipped). Commit `evidence/controls-flip/`.

## Part 1 (commit): quest 1 help card (`project/boot/quest1_card.gd:12-20`)
- The `CONTROLS` / `CONTROLS_PAD` text follows `ControlsMode`. Wheel (keyboard/mouse): WASD/arrows move, mouse aims, left mouse swings or fires, right mouse guards, mouse wheel changes weapon, Space is the quick claw, E use, Esc pause. Legacy keeps today's text exactly. Pad text for the wheel: read the real pad bindings from `project/data/tables/input_actions.json` / `PlayerActions` and say what they do; do not invent bindings.
- Every string through `QuestText`/`tr()` like the existing text (LOC-01); if a translation catalogue holds these keys, add the new keys.
- Unit test: both modes produce their text (wheel names guard on right mouse and the quick claw on Space; legacy still says electroshock). Use the LaunchArgs override mechanism other tests use.
- Allowlist: `project/boot/quest1_card.gd`, a helper beside it if size demands (`project/boot/quest1_controls_text.gd`), the loc catalogue, `project/tests/unit/test_quest1_card*.gd`, `project/dev/controls/**`.
- Evidence: a still of the title card in each mode: `C:\Users\kazda\kiro\gtai-masters\n23\controls\card_wheel.png` and `card_legacy.png` (d3d12, `--position 0,1440`; a small dev script under `project/dev/controls/` if no render path exists).

## Part 2 (commit): StagePilot swing counter
`project/boot/collect_call/stage_pilot.gd:98-100` (`_attacks`): `melee_swings` increments while `combo.buffered` stays true, so a held primary counts one start as five swings (film ticks 56-60). Count the difference in `melee.combo.starts` across both `press()` and `melee.step()` so a deferred start counts once (see `evidence/guard-flip/blockers.md`, section Film telemetry). Readers: `arena_claw_cops.gd:119`, `scenario_rivet_deflect.gd:54`, `arsenal_turn_rec.gd:97`, `guard_film_beats.gd`: check each still holds. This edit in `stage_pilot.gd` is allowed (keep it to `_attacks`). Unit test: a held primary over 10 ticks counts one swing, two separate presses count two. Confirm `melee_swings` is not in replay state and the 60 s replay digest is unchanged.

## Part 3 (code only if no digest moves): the blast ring one tick old
`ArenaStage.step` (`project/features/arena/arena_stage.gd:95-96`) culls before `super.step` updates `arena.tick`; `RivetBlast.burst` stamps the ring with that clock. Find out whether passing the impact tick from the stage/cull path changes ANY replay digest or scenario tape (run `replay_60s` and the arena and quest scenarios). If none moves, fix it in `project/features/combat/rivet_blast.gd` plus a one-line call site in `arena_stage.gd`, with a test, and commit. If any moves, do not commit: write the finding (which digest, why) in `evidence/controls-flip/blast-ring.md`.

## Allowlist for Part 0
`project/addons/gut/cli/gut_cli.gd` (revert only), `tools/tests/run_unit.mjs` and its node tests, `project/tests/support/gut_pre_run.gd`, `project/features/player/**`, a unit test under `project/tests/unit/`, everything b1 left uncommitted (its brief: `evidence/briefs/b1-flip.md`), `docs/decisions.md` (append one line), `evidence/controls-flip/**`.

## Report
Commits (sha, files), tests run and results, the two stills' paths, the Part 3 verdict, mutate score on `quest1_card.gd` (or the helper).
