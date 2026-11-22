# Brief 03 `street-score`: merge street, death-wave score, knob list, targets (lane loop, n23)

DRAFT written 02:10 by session 1; the next director session checks the facts marked CHECK and fills HARDSTOP/COMMITBY.

Hard stop: HARDSTOP wall clock. Commit deadline: COMMITBY. Commit each step as it lands.

## Goal

Street (lane `n23-street`) changed the wave rules: a wave that reaches the 90 s timer no longer ends the run, the next wave starts on top (`gauntlet.json` `"on_timeout": "next_wave"`, result wave rows `timed_out: true`), a live cap `max_alive`, and the budget in tenths of a tier (`budget.unit` = 10, `budget{base, per_wave}` and every enemy `cost` as ints in tenths). Runs now end in death; the score for a profile is **the wave it dies on**. The tuner must follow.

## Work, in order (commit each)

1. **Merge** (the director may already have done it; CHECK `git log --merges -3`): `git merge --no-edit n23-street`. Conflicts: root `JOURNAL.md`/`REPORT.md` keep ours; `tools/debt/baseline.json` via `node tools/debt/merge_baseline.mjs` then commit, then `node tools/debt/debt.mjs --update`. Then `node tools/tests/run_unit.mjs --changed` and `node --test "tools/gauntlet/*.test.mjs"`; fix only lane-owned breakage (`tools/gauntlet/**`, `project/features/gauntlet/bot/**`), report anything else as a NEED.
2. **Knob list** `tools/gauntlet/knobs.json` (+ `tune_state.mjs`): read `budget.unit` from `gauntlet.json` and never assume 1 (a knob step on an int in tenths rounds to the nearest int, and a step that rounds to no change is refused with a reason); add the per-enemy `cost` map entries (one knob per enemy, by row id, not array index), `max_alive`; drop every knob whose pointer no longer resolves (the tuner must fail loudly on a dead pointer, with a test). If street landed the `rivet {repair_per_s, repair_delay_s}` block in `gauntlet.json` (CHECK: loop's NEED street at 01:06), add both as knobs (`repair_per_s` may only go down, `repair_delay_s` only up, tonight).
3. **Knob groups.** One change may move a named group of knobs by one shared factor, committed and confirmed as one change: `enemy_damage` = every `enemy_weapon.*.damage`, `enemy_weapon.*.splash_damage` and `*.production_damage` knob. The clamps apply per number (0.8..1.25 per night, 0.5..2.0 of `tools/gauntlet/baseline.json`). Node tests.
4. **Death-wave score.** In `tune_propose.mjs` / `tune_confirm.mjs`: metric `{type: 'death', profile, target}` = the wave the run dies on (a run alive at the tick cap counts as censored at its wave and is reported as such; the median uses it as a lower bound, say so in the ledger). Targets come from a data file `tools/gauntlet/targets.json` (`gtai.gauntlet-targets/1`): `death_wave {novice: 6, average: 12, expert: 20}`, `wave_seconds {average: 15}`, `boss_wave_seconds [25, 30]`, `boss_every: 5`, `separation {min_wave_gap: 3, min_seed_share: 0.75}` (profile B separated from A when B's median death wave is at least `min_wave_gap` deeper and B dies later on at least `min_seed_share` of the shared seeds). A profile dying later than its target proposes `enemy_damage` x factor (clamped) first, then `budget.per_wave`; earlier proposes the inverse. The confirm verdict for a death metric uses the paired same-seed difference of death waves against the null-salt floor of death waves (needs the `--null` batch). Ledger rows say target, before, after, floor, verdict. Node tests with fixtures.
5. **Report**: per profile, death wave median and spread, deaths / capped, separation against `targets.json` (gap and seed share), timed-out waves per run, waves running at once when Rivet died.
6. `docs/gauntlet-loop.md`: a "Targets" section that names `targets.json` and says these are the owner's call; a "Score" paragraph (death wave, censoring).

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/tests/run_unit.mjs --changed` green; `node tools/lint/lint.mjs` green. Fix lint and format findings in your own edit and go on.
- `node tools/gauntlet/tune.mjs propose ... --dry-run` (or the equivalent) on `evidence/n23-loop/base-street/batch.json` (CHECK it exists) prints at least one `enemy_damage` proposal tied to a death-wave miss.

## Machine rules

- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` before any Godot run. At most ONE Godot process of yours; the director runs batches alongside. Never kill a process you did not start.

## Files

Allowlist: `tools/gauntlet/**`, `project/features/gauntlet/bot/**`, `docs/gauntlet-loop.md`, `project/data/tables/test_player.json`, `tools/debt/baseline.json` through the debt tools, merge commits of `n23-street`. Any other path: stop and report a NEED. Forbidden: all tables except `test_player.json` (the tuner edits tables only on its `n23-tune*` branches, never here), the rest of `project/features/gauntlet/**`, `project/features/player/**`, other worktrees, `JOURNAL.md`, `REPORT.md`, `evidence/n23-loop/base-*`.

## Repo law

As in briefs 01-02: typed, small files and functions, staged per path, no stash / add -A / commit -a / reset --hard / amend / rebase / push, `.uid` with new `.gd`, no digest moves.
