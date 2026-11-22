# Brief 01 `null-floor`: the tuner's noise floor from a neutral change (lane loop, n23)

Hard stop: 02:15 wall clock. Commit deadline: 02:10. Whatever is not committed by then is lost; commit each step as it lands.

## Goal

Last night the tuner's A/A floor paired DIFFERENT seeds of the before batch (`tools/gauntlet/tune_confirm.mjs` `noiseFloor`, seed 1 vs 2, 3 vs 4 ...). That measures how two different runs differ (12.6 to 41 s) and rejected every change, including `war_machine.hp` 60 -> 48 with a paired gain of 13.7 s (CI95 4.75 to 19.08). The owner's pick: "measure noise with a neutral change on the same seeds".

The sim is deterministic: the same seed and build give a byte-identical result. So a same-seed pair's difference is the change's effect plus the chaos it sets off. The floor must measure that chaos: re-run the SAME seeds with a perturbation that does not change difficulty, and pair seed s (before) with seed s (null).

**The neutral change (decided): a bot salt.** The test player draws its own luck from private streams (`project/features/gauntlet/bot/`: `test_player_aim` in `bot_brain.gd:42`, `test_player_defence` in `bot_defence.gd:34`, `test_player_forms` in `bot_forms.gd:20`; `test_player_pick` in `gauntlet_bot.gd`/`bot_pick.gd`). Salting those streams resamples the player's luck from the same distributions (same aim error range, same roll chance, same tells read): the game and the profile are unchanged, so expected difficulty is unchanged, but the run diverges. It lives entirely in the lane's own files and moves no shipped replay or tape (the bot exists only in the gauntlet). The world's RNG is NOT touched. Decide yourself whether `test_player_pick` is salted too (greedy picks do not draw from it; random picks do): salt it, it is the player's luck too, and say so in the doc.

## Work, in order (commit each)

1. **`--bot-salt=<uint>`** (default 0 = today's streams exactly, so every existing result stays byte-identical). The bot's private RngRegistry seeds become a function of (seed, salt) that equals today's value when salt is 0. Read the flag in `GauntletTestPlayer.configure` (`project/features/gauntlet/bot/gauntlet_bot.gd`) through `LaunchArgs`, or pass it in, whichever keeps layers lint green. Required one-line edits outside the lane (allowed, name them in your report): add `"--bot-salt"` to the KNOWN list at `project/dev/gauntlet/gauntlet.gd:5` (that line only), and append `"--bot-salt"` with a `# n23-loop:` comment to `KNOWN_FLAGS` in `project/boot/launch_args.gd`, then `node tools/debt/debt.mjs --update --accept-regression="--bot-salt for n23 loop"`. The result file must record the salt when it is non-zero: if the bot can write a field into the run result through its own files (`BotStreetStats`, the run object it holds), add optional `bot_salt` (int) to `project/data/schemas/gauntlet_run.schema.json` (your field only, optional) and to `tools/gauntlet/contract.mjs`; if it cannot without editing street's files, the batch manifest records the salt instead and you say so.
   - Test (GUT, `project/tests/unit/test_gauntlet_bot_salt.gd` or the existing bot test file): salt 0 gives the same streams as before; salt 1 gives different draws for the same seed.
2. **`tools/gauntlet/batch.mjs --salt=<n>`** passes `--bot-salt=<n>` to every run (omitted when 0) and records `salt` in `batch.json`. Node test in `batch.test.mjs`.
3. **The floor.** In the tuner (`tools/gauntlet/tune_confirm.mjs`, `tune.mjs`, `night.mjs`): a floor mode `"null-salt" | "cross-seed"` (data value / flag, default `null-salt`). In `null-salt` mode the A/A pairs are (before run seed s, null run seed s) from a second batch given as `--null=<batch.json>`; the rest of the verdict rule stays (`aggregate > floor && ci[0] > floor` keeps). `cross-seed` keeps last night's code path exactly. The ledger (`tune-ledger.md/json`) prints BOTH floors per change side by side when both are computable, and which one decided. `night.mjs` runs the null batch (same seeds, `--salt=1`) right after the before batch. Add `tune.mjs floor --before=<batch.json> --null=<batch.json> [--out=<md>]` that prints, per metric the tuner uses (wave time per wave stratum, wave reached), the null-salt floor and the cross-seed floor of the same before batch, the pair counts, and how many of the null runs differ from their before run (byte compare of the result, or result sha). Node tests in `tune.test.mjs` for: null pairing by seed, mode switch, both-floors ledger, the differ count. Keep every file under 200 lines where it is today (tune_git.mjs is at 197: put new code in a new file such as `tools/gauntlet/tune_floor.mjs`).
4. **Prove it on a small real batch**: average, greedy, wheel, `--waves=8`, seeds 1-6, salt 0 and salt 1 (`--jobs=1`), under `build/n23/null-proof/` (git-ignored). Show that the salt-1 runs differ from salt-0 on at least most seeds, and that salt-0 runs are byte-identical to a re-run of seed 1 (one re-run is enough). Run `tune.mjs floor` on them and quote its output in your report.
5. Update `docs/gauntlet-loop.md` only in the tuner section: the floor mode, why the bot salt is neutral, the commands. Two short paragraphs.

## Acceptance (I will re-run these)

- `node --test "tools/gauntlet/*.test.mjs"` all green.
- `node tools/tests/run_unit.mjs --changed` green.
- `node tools/lint/lint.mjs` green. Fix lint and format findings in your own edit and go on.
- `node tools/gate/quick.mjs` before each commit if it fits; the pre-commit hook must pass (never `--no-verify`).
- A dev run with `--bot-salt=0` reproduces a run without the flag byte for byte.
- After committing the GDScript change: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/bot/gauntlet_bot.gd --max=20 --lines=<your changed lines>` and quote killed/(killed+survived).

## Machine rules

- Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop` and `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`.
- I am running a long baseline batch (one Godot at a time) in this worktree under `evidence/n23-loop/base-greedy/`: **do not touch that folder, and run at most ONE Godot process yourself at any time** (batch `--jobs=1`). Do not kill any process you did not start; free your own by PID.
- Windowed runs (you should not need any): `--position 0,1440`.

## Files

Allowlist: `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `docs/gauntlet-loop.md`, `project/data/tables/test_player.json`, new tests named for the bot salt under `project/tests/unit/`, your own optional field in `project/data/schemas/gauntlet_run.schema.json`, the one line in `project/dev/gauntlet/gauntlet.gd:5`, one appended line in `project/boot/launch_args.gd` KNOWN_FLAGS, `tools/debt/baseline.json` through the debt tool only. Any other path: stop and report a NEED. Forbidden: anything else under `project/features/gauntlet/**` (street's), `project/features/player/**`, `combat.json`, `enemies.json`, `gauntlet.json`, `gauntlet_bonuses.json`, other lanes' worktrees, `JOURNAL.md`, `REPORT.md`, `evidence/n23-loop/base-greedy/`.

## Repo law

Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, at most 5 parameters, `Log` not `print`, no global RNG (streams from the registry). One commit per step, staged per path: no `git add -A/./-u`, no `git commit -a`, no `git stash`, no `reset --hard`, no amend, no rebase, never push. Commit `.uid` files with new `.gd` files (run a Godot `--import` after adding scripts). Determinism: salt 0 must change nothing; no sim, parity, bake or replay digest may move.

End with: files changed, commits (sha + subject), commands run and results, the floor numbers from step 4, anything not done and why.
