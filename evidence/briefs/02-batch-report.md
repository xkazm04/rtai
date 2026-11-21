# Brief 02 (lane loop, n22): the batch tool and the report

Wall-clock: you start about 01:00. **Commit deadline 02:05, hard stop 02:12** (finish what you have, commit it, report). Small commits as each piece lands; never amend, never rebase.

## Context (read, do not re-derive)
Lane `loop` builds the test player (`project/features/gauntlet/bot/`, landed in the previous call: read its files and `docs/gauntlet-loop.md` first), then the batch tool, the report and the tuner for the combat gauntlet. Design: `C:\Users\kazda\kiro\gtai\.spark\Spark\ideas\combat-gauntlet.md` (read only). The gauntlet scene itself belongs to lane `street` and may or may not be merged into this branch when you start: check `ls project/dev/gauntlet/` and `git log --oneline -20`. Build everything so it runs offline on result files first.

The run result file (wire contract, producer street, consumer you), schema `gtai.gauntlet-run/1`:
```
{schema, seed, profile, controls, wave_reached, death{wave, by}, waves[{n, seconds, enemies{<id>: count}, damage_taken, guard_deflects, rolls, form_seconds{<form>: s}, shots, hits}], picks[{wave, offered[3], taken}], mods{<stat>: k}}
```
`profile` is `"human"` when no bot plays. **A value that was not measured is omitted, never 0**: every consumer must treat a missing key as "not measured" and never average it in as zero. The launcher (owner street): `node tools/dev/run.mjs gauntlet --seed=N [--bot=novice|average|expert] [--pick=random|greedy] [--waves=N] [--result=<abs json>] [--controls=wheel|legacy]`. Bonus rows (`project/data/tables/gauntlet_bonuses.json`, owner street): `{id, kind: "weapon"|"stat"|"ghost", ref, k, min_wave, weight}`. Target: 15 s per wave for the `average` profile.

Measured: a headless arena fight runs about 13.6 sim s per wall s per Godot (4 s boot) on this shared machine.

Reuse the repo's statistics: `tools/perf/paired.mjs` (`bootCi`, `signP`, `median`, `paired`), `tools/perf/stats.mjs` (`quantile`, `mean`, `medianSpread`, `verdict`). Read them and their tests first.

## Goal (in this order)

## -1. First of all: land the previous call's probe
The previous call left `project/dev/test_player/bot_pit_probe.gd`, `bot_pit_trial.gd`, `project/tests/unit/test_gauntlet_bot_probe.gd` and their `.uid` files uncommitted because the debt ratchet saw `dev_loc` 26600 -> 26780. Accept it through the tool: `node tools/debt/debt.mjs --update --accept-regression="test player pit probe for n22 loop"`, and commit `tools/debt/baseline.json` together with the probe files (that is the only way you may touch the baseline). The director has merged `n22-guard-iface` and `n22-street-iface` into this branch: the `guard` action and `Shot.size` now exist (guard lane, read `project/features/player/controls_mode.gd`, `guard_tuning.gd`, `player_actions.gd`, `project/features/combat/shot.gd`). Re-run the probe once (average, seed 20261103, both `--controls` values if the probe can pass it, else the default) and say whether guard ticks are now above zero; if the guard bit exists but does nothing yet (the guard lane builds it later tonight), say so. Run `node tools/tests/run_unit.mjs --changed` once after the merge to see the branch is green before you add anything.


## 0. First: plug the test player into street's gauntlet scene (merged on this branch by the director before you start)
Street's scene `project/dev/gauntlet/gauntlet.gd` loads `res://features/gauntlet/bot/gauntlet_bot.gd` for `--bot` and needs it to **extend `GauntletPilot`** (`project/features/gauntlet/gauntlet_pilot.gd`, read it) with a **zero-argument constructor**: `configure(profile, pick_policy, seed)`, then `bind(run: GauntletRun, session: ArenaSession)`, then `sample(tick)`, and `pick(offered: Array[StringName]) -> int` (an index into the offer). Write `gauntlet_bot.gd` (pick a class_name that does not collide with the existing `GauntletBot` in `bot_brain.gd`, e.g. `GauntletTestPlayer`) as a thin adapter: load the profile row, build the view on the bound session (reuse `BotViewArena` if the session exposes the same stage; otherwise a `BotViewGauntlet` beside it), delegate `sample` to the brain and `pick` to `BotPick` (map the returned id to its index; the bonus rows come from `project/data/tables/gauntlet_bonuses.json`). Also hand the bot's counters to the run result if `GauntletRun` offers a hook for it; if it does not, write `NEED street: GauntletRun <hook> to carry guard/roll/cover/form counters` in your report. Do not edit street's files. Street's scene may still be a skeleton (zero waves): if so, make the adapter work and prove it loads and is configured, and say what the scene does not do yet. Accept: `node tools/dev/run.mjs gauntlet --seed=3 --bot=average --pick=greedy --result=<abs json>` exits 0 with the test player driving (prove it: the result or log shows the bot's profile and its inputs moved Rivet), and the same command twice gives a byte-identical result file.

### 1. `tools/gauntlet/batch.mjs`
`node tools/gauntlet/batch.mjs --seeds=N [--seed0=S] --profile=<novice|average|expert|all> --pick=<random|greedy> [--waves=N] [--jobs=N] [--out=<dir>] [--runner=gauntlet|pit] [--controls=wheel|legacy] [--dry-run] [--from=<dir of existing result files>]`
- Per (profile, seed) it runs one headless Godot through `tools/dev/run.mjs` (import its launcher helpers from `tools/lib/` where they fit; one Godot per job), with `--result=<out>/runs/<profile>-<seed>.json`. `--runner=gauntlet` (default) calls the street launcher above; `--runner=pit` calls the test player's arena-pit probe (`project/dev/test_player/`), which must then also write a `gtai.gauntlet-run/1`-shaped file: extend the probe so it does (pit waves as waves, no picks, `controls: "legacy"`, only measured keys). This is tonight's fallback when the gauntlet scene is not merged.
- `--jobs` default 1, maximum 2 (refuse more with one line: the machine is shared by four lanes). Every run's log path, exit code and wall seconds are recorded; a failed run is listed, not dropped silently, and does not stop the batch.
- `--from=<dir>` skips Godot and aggregates existing result files (the offline path used by the tests).
- Writes `<out>/batch.json`, schema `gtai.gauntlet-batch/1`: `{schema, created, git{sha, branch, dirty}, args, tables{<table file>: sha256} (enemies, weapons, combat, gauntlet, gauntlet_bonuses, test_player; a missing table is omitted), runs[{profile, seed, pick, file, exit, wall_s, ok}], results[<the run objects>], speed{sim_s, wall_s, sim_per_wall}}`. Validate each run against the contract (missing required keys: run marked `ok:false` with the reason).
- Prints one summary line per profile: runs ok/total, median wave reached, median seconds per wave.

### 2. `tools/gauntlet/report.mjs`
`node tools/gauntlet/report.mjs --batch=<batch.json> [--baseline=<batch.json>] [--out=<dir>]` writes `report.md` and one **self-contained** `report.html` (inline CSS and inline SVG charts, no network, no external files) with:
- per wave and per profile: n, median and spread (p25..p75, min..max) of `seconds` against the 15 s target (mark waves where the `average` median misses by more than 20 %);
- the death-wave distribution per profile and the top killers (`death.by`);
- per enemy id: how often it is the killer, and its share of wave time (waves where it was present: median seconds vs waves without it);
- per bonus id and per weapon ref: runs that **took** it vs runs that were **offered it and declined** it: waves survived after the pick, and median wave seconds after it. Use a bootstrap CI95 (`bootCi`) on the difference and a noise floor computed from an A/A split (random halves of the decliners by seed parity, or of all runs): a difference whose CI includes 0 or is inside the noise floor is labelled `noise`, not a finding;
- guard deflects, rolls, form seconds per form, shots and hit rate per wave and profile (only where measured; show "not measured" otherwise);
- "unusual winning runs": the runs that went deepest with an atypical pick sequence or weapon/form mix (define a simple rarity score, document it), each with seed, profile, picks and the exact replay/film command line (`node tools/dev/run.mjs gauntlet --seed=<s> --bot=<p> --pick=<m> ...`);
- with `--baseline`, a before/after column for the per-wave medians.
Follow the repo's chart style if `tools/` already has an HTML report you can copy (grep for an existing `.html` writer under `tools/`); colour law for the page: no red except blood (use amber for misses), teal only for ghost forms.

### 3. Fixtures and tests
- `tools/gauntlet/fixtures/`: a small set of hand-written / generated sample `gtai.gauntlet-run/1` files (12 to 30 runs over the three profiles, with picks, deaths, a missing-key case, one malformed run). A deterministic generator script `tools/gauntlet/fixtures/make.mjs` is fine; commit its output.
- `tools/gauntlet/*.test.mjs` with `node:test`: batch arg parsing (jobs cap, profile all), `--from` aggregation, contract validation (missing keys, omitted-not-zero), the report numbers on the fixtures (a known median, a known take-vs-decline difference, a noise label), the HTML is self-contained (no `http`, no `src=` to files). Run: `node --test "tools/gauntlet/*.test.mjs"`.
- Add `"tools/gauntlet/*.test.mjs"` to the Node tooling test command wherever the repo lists those globs (grep for `tools/selftest/*.test.mjs` in `AGENTS.md`, `justfile`, `tools/gate/`, `tools/evidence/`); if that file is outside your allowlist, report it as a NEED instead.
- `docs/gauntlet-loop.md`: fill the batch and report sections (commands, what each number means, the seeds-per-night arithmetic at the measured speed).

### Then, only if time remains and Godot is free
Run `node tools/gauntlet/batch.mjs --runner=pit --seeds=3 --profile=all --pick=random --out=<lane>/evidence/loop/batch-pit-1` and the report on it; quote the summary lines.

## Files you may create or edit (allowlist; any other path: stop and report a NEED)
`tools/gauntlet/**`, `tools/debt/baseline.json` (through the debt tool only), `project/features/gauntlet/bot/**`, `project/dev/test_player/**`, `project/tests/unit/test_gauntlet_bot*.gd`, `project/data/tables/test_player.json` + its schema, `docs/gauntlet-loop.md`, `evidence/loop/**`.
Forbidden (other lanes): `project/dev/gauntlet/**`, `project/features/gauntlet/*` outside `bot/`, `project/features/player/**`, `project/features/combat/**`, `project/features/arena/**`, `project/data/tables/enemies.json`, `weapons.json`, `combat.json`, `input_actions.json`, `gauntlet*.json`, `project/core/replay/tick_input.gd`.

## Acceptance (quote results)
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`. Only one Godot process at a time. Headless only.
1. `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` clean (fix lint and format findings in your own edit and go on).
2. `node tools/gauntlet/batch.mjs --from=tools/gauntlet/fixtures --profile=all --pick=random --out=build/gauntlet/fixture-batch` then `node tools/gauntlet/report.mjs --batch=build/gauntlet/fixture-batch/batch.json --out=build/gauntlet/fixture-batch`: quote the summary; open nothing, but check the HTML has no external reference.
3. `node tools/gauntlet/batch.mjs --dry-run --seeds=2 --profile=all --pick=greedy` prints the six exact commands it would run.
4. If you touched GDScript: `node tools/tests/run_unit.mjs --changed` green, `--import` before committing new scripts, `.uid` files committed.

## Repo law
Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push, do not merge other branches. Node tools are ES modules like the rest of `tools/` (look at `tools/perf/fight_gate.mjs` for the house style). No network. End with a short report: files, commits, numbers, NEEDs, what you could not do.
