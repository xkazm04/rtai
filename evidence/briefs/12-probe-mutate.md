# Brief 12 `probe-mutate` (lane move, n19): score the files that decide "is this a solid", close real gaps

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Never kill processes by name. Stage per path, no `git add -A`, no stash.
**Hard stop: your last commit lands by 07:15** (the freeze is 07:30). Commit each closed gap as it lands.
Commit subjects start with `move: ` (your last three, 6e52beaba..49166f1ce, did not: leave them, just use the
prefix from now on).

## Why
The lane's headline judgement is "zero ways to end up inside a solid". The fuzz scenarios (`moves_fuzz`,
`moves_street`, `rivet_vault`) say 0 overlaps, but the two files that decide what a solid and a vault target ARE
have never had a mutation score: `project/features/player/vault_probe.gd` and
`project/features/player/vault_city.gd`. A surviving mutant there is a way the fuzz could be blind.

## Work (tests only unless a test exposes a real bug)
1. `node tools/mutate/mutate.mjs --file=features/player/vault_probe.gd --max=20 --json > build/mutate/probe-initial.json`
   (the default oracle runs the mapped tests; if the mapping misses the fuzz scenarios that is fine, unit tests
   are the oracle here). Same for `--file=features/player/vault_city.gd --max=15`.
2. For each survivor: one line, equivalent mutant or test gap. Close each real gap with a focused unit test in
   `project/tests/unit/` (red against the mutant, green at HEAD: show both). Prefer cases about solids: the
   landing check, the height/depth limits, the airborne target exception, the city prop ownership.
3. If a test exposes a real behaviour bug (not just a gap), fix it in `features/player/**` with that test red
   first, then re-run `scenario_moves_fuzz`, `scenario_moves_street`, `scenario_rivet_vault`
   (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=moves_fuzz,moves_street,rivet_vault`).
4. Re-run both mutations after the tests (`build/mutate/probe-final.json`, `city-final.json`) and write
   `build/mutate/probe-survivors.md` (initial and final killed/(killed+survived) for each file, one line per
   survivor). Then `node tools/gate/quick.mjs` and `node tools/tests/run_unit.mjs --changed`; quote both.

## Not yours
Everything outside `project/features/player/**` and `project/tests/**`. No golden or digest file. No data
change, no `docs/decisions.md` (unless a real bug fix changes behaviour: then ONE appended line).
