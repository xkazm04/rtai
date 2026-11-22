# Brief 05 `controls-moves`: merge controls and moves, the bot uses the moves and spares itself, off/on table (lane loop, n23)

DRAFT by session 3 (03:50). The launching director fills HARDSTOP/COMMITBY, the SHAs, and the self-blast radius line from controls' `NEED loop`.

Hard stop: HARDSTOP wall clock (the call is stopped at 75 min). Commit deadline: COMMITBY. Commit each step as it lands.
Fix lint and format findings in your own edit and go on.

## Goal

The lane `loop` tunes the combined gauntlet with a test player (bot). Two lanes have finished parts the bot must use:
- **controls** (`n23-controls`, ready at CONTROLS_SHA): the wheel is the default everywhere, and Rivet's own blasts now hurt him (`combat.json` block `blast`, `self_k` 1.0). The bot must not kill itself with its own blasts. Controls' note: SELF_BLAST_NEED_LINE
- **moves** (`n23-moves`, ready at MOVES_SHA): four new moves in `combat.json` block `moves`, each with `enabled` (true): `ohm_short_circuit`, `tonnage_armour_crack`, `kerf_blink_behind`, and the weapon effect `overkill_carry` (bonus card; second ranks end `_2` in `gauntlet_bonuses.json`). The bot must use each when its condition holds (below, verbatim from moves' JOURNAL). Note: moves' branch already contains prologue's iface commit `c7f139b95` (two `enemies.json` rows); that is expected.

## Work, in order (commit each)

1. **Merge** `git merge --no-edit n23-controls`, then `git merge --no-edit n23-moves` (two merge commits). Conflict rules: root `JOURNAL.md`/`REPORT.md` keep ours; append-only shared lists (`project/boot/launch_args.gd` KNOWN_FLAGS, the KNOWN line in `project/dev/gauntlet/gauntlet.gd`, `docs/decisions.md`, `project/data/schemas/gauntlet_run.schema.json`) keep both sides' lines; `tools/debt/baseline.json`: `node tools/debt/merge_baseline.mjs`, commit, then `node tools/debt/debt.mjs --update`; any other conflict outside loop's files: `git merge --abort` and report. Then `node tools/tests/run_unit.mjs --changed` and `node --test "tools/gauntlet/*.test.mjs"`; fix only lane-owned breakage, report the rest as a NEED.
2. **Self-blast safety in the bot** (`project/features/gauntlet/bot/**`): the bot does not fire a blast weapon (rocket and any weapon with a splash radius; read the radius from the weapon/`blast` table, never a literal) when the predicted impact point (its target, or the first wall on the line) is within that radius plus Rivet's radius plus a margin from Rivet. Profile-dependent margin in `project/data/tables/test_player.json` (novice small, expert large; schema updated). Unit test: a target 1 m away with a rocket selected -> no fire; 10 m -> fire.
3. **The bot uses the four moves** (`bot/**`), each gated on its row's `enabled` and its condition:
   - Ohm short circuit: MOVES_NEED_OHM
   - Tonnage armour crack: MOVES_NEED_TONNAGE
   - Kerf blink behind: MOVES_NEED_KERF
   - Overkill carry: MOVES_NEED_OVERKILL
   Profiles: expert uses every move whenever its condition holds; average with a probability from `test_player.json` (start 0.6); novice 0.25. Draw from the bot's own streams (the salted ones), never global RNG. One unit test per move: condition true -> the bot's intent picks the move; `enabled` false -> never.
4. **Off/on measurement tooling.** `tools/gauntlet/ablate.mjs --set=<file>#<pointer>=<true|false>` accepts booleans for boolean fields (refuse a bool on a number field and vice versa; tests). The report (`tools/gauntlet/report*.mjs`) gains a "Moves" section: per move, uses per wave (from each wave's optional `moves{<id>: count}`), and the median seconds of waves that contain the enemy the move answers (sentry_turret for Ohm, war_machine for Tonnage, shield_robot for Kerf, all waves for overkill) beside waves without it. `tools/gauntlet/compare.mjs` or a new `tools/gauntlet/move_table.mjs --off=<batch.json> --on=<batch.json> --move=<id>`: paired by seed, the difference in those wave times with a CI95, plus the death wave difference. Node tests.
5. **Knobs.** Add the moves' numeric fields (durations, multipliers: whatever each `moves.<id>` row holds besides `enabled` and `doc`) and the self-blast `blast.self_k` to `tools/gauntlet/knobs.json` with bounds; `enabled` is not a knob. Knob tests pass; `baseline.json` gains the new ids only through `tune.mjs propose`'s append (do not hand-edit it).
6. **Smoke** (one Godot): `node tools/gauntlet/batch.mjs --profile=all --pick=greedy --seeds=2 --jobs=1 --controls=wheel --out=evidence/n23-loop/moves-smoke`; report per run: death wave, moves counts per wave, self damage. At least one run shows a use of each of Ohm/Tonnage/Kerf, or say which condition never held and why.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` green; `node tools/tests/run_unit.mjs --changed` green (quote the line).
- Mutate on the main bot file you changed: `node tools/mutate/mutate.mjs --file=features/gauntlet/bot/<file>.gd --max=20 --lines=<changed lines>` (path relative to `project/`, commit first); quote killed/(killed+survived).
- The scenario tapes and the 60 s replay are not moved by your bot edits (the bot runs only in the gauntlet): `node tools/tests/run_unit.mjs --select=<the replay test if mapped>` or say what you ran.

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. At most ONE Godot process of yours; the director runs batches alongside from a snapshot worktree. Never kill a process you did not start. Never touch another lane's worktree. Windowed runs (none needed): `--position 0,1440`.

## Files

Allowlist: merge commits of `n23-controls` and `n23-moves`; `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `project/data/tables/test_player.json` + its schema, `docs/gauntlet-loop.md`, one appended line in `docs/decisions.md`, `tools/debt/baseline.json` through the debt tools, `evidence/n23-loop/moves-smoke/**`. Any other path: stop and report a NEED. Forbidden: `combat.json`, `enemies.json`, `gauntlet*.json` and every other table except `test_player.json`; `project/features/combat/**`, `project/features/player/**`, `project/features/souls/**`, the rest of `project/features/gauntlet/**`; other worktrees; `JOURNAL.md`, `REPORT.md`, `evidence/n23-loop/base-*`.

## Repo law

Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, 5 parameters max, `Log` not `print`, no global RNG, `.uid` with every new `.gd`, run a Godot `--import` before committing new scripts. Staged per path; no stash / `add -A` / `commit -a` / `reset --hard` / amend / rebase / push / `--no-verify`. No sim, parity, replay or bake digest moves.

End with: files changed, commits, commands and results, anything not done and why.
