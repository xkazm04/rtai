# n22-street brief 02: the run loop and the wave composer (headless 10 waves)

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`, branch `n22-street`. You (or a previous
session of you) already committed the interface (`StatMods`, `GauntletPilot`, `GauntletRun`, the two tables,
the scene) and the seeded street (`GauntletStreet`). Read `git log --oneline -10` and those files first. Never
rename anything from the interface commit (other lanes build on it).

**Wall-clock hard stop: 02:15. Commit deadline: 02:10.** Commit each item when it works (small commits).
Fix lint and format findings in your own edits and go on. Never amend, never rebase. No `git stash`, no
`git add -A/./-u`, no `commit -a`, no `reset --hard`, no tags. Stage per path. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
(`--rendering-driver d3d12` for rendering, `--position 0,1440` on any windowed run). One Godot process at a
time; free your own by PID. Mutate: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed>`.

## Allowlist (any other path: stop that item and report `NEED <owner lane>: <file> <why>`)
Same as brief 01: `project/dev/gauntlet/**`, `project/features/gauntlet/**` except `bot/**` (lane loop's:
never touch), `gauntlet.json`, `gauntlet_bonuses.json` + schemas, `project/tests/unit/test_gauntlet_*.gd`,
`test_stat_mods.gd`, one appended line in `docs/decisions.md` per decision. Forbidden: `project/features/player/**`,
`project/features/combat/**`, `arena_projectiles.gd`, `arena_dodges.gd`, `enemies.json`, `weapons.json`,
`combat.json`, `input_actions.json`, `TickInput`, `tools/gauntlet/**`. You call arena/combat classes; you do
not edit them.

## Items, in order
0. **Merge the other lanes' interface tags first** (no Godot running): `git merge --no-edit n22-guard-iface`,
   and `git merge --no-edit n22-foes-iface` if that tag exists (`git tag --list 'n22-*'`). On a conflict in
   `docs/decisions.md` or `tools/debt/baseline.json` keep both sides' lines (for the baseline run
   `node tools/debt/merge_baseline.mjs`, then `--update`); on `JOURNAL.md`/`REPORT.md` keep ours. Any other
   conflict: keep theirs for their files, ours for ours, and say so. After the merge: Godot `--import`, lint,
   `node tools/tests/run_unit.mjs --changed`. guard's tag brings `ControlsMode` (`--controls` is now in
   `LaunchArgs.KNOWN_FLAGS`): make the scene's `--controls` agree with `ControlsMode.id()` and do not parse it
   twice in contradicting ways. If foes's tag brings `tier` on `enemies.json` rows, the composer uses it.
1. **The run** (`GauntletRun` + the scene's driver; keep files under 200 lines, split a `gauntlet_waves.gd` /
   `gauntlet_driver.gd` as needed). A wave starts when Rivet crosses into a new segment (the street adds one
   ahead then); its enemies spawn at that segment's spawn points (ahead and flanks); the wave is cleared when
   all its enemies are down; then a pick happens (for now: the pilot's `pick()` on three offered ids from a
   simple seeded draw; brief 03 builds the real draw and screen, so keep the draw behind one function); then
   the next segment's way is open (if you gate it, gate it with an invisible line, not a wall on a crossing).
   Leftover enemies from a wave are never abandoned: if Rivet walks on, they keep chasing (they stay in
   `CombatArena.hostiles` and their brains keep stepping; the dropped segment's props may go, the enemies may
   not). Death ends the run: `alive=false`, `death{wave, by}` (`by` = the enemy id/weapon that dealt the
   lethal hit, as far as `CombatArena` tells you: read `damage()` and the events; omit `by` if you cannot know
   it), the result is written and the scene quits. `--waves=N` stops cleanly after N cleared waves (still a
   valid result, `death` omitted). Per wave record `n`, `seconds` (ticks * `SimClock.TICK_DT` from the wave's
   first spawn to its last kill), `enemies{<id>: count}`, `damage_taken`, `shots` and `hits` if you can count
   them from `CombatArena` / `ArenaTelemetry` (omit what you cannot measure; never write 0 for unmeasured).
2. **The wave composer** (`project/features/gauntlet/gauntlet_composer.gd`, pure RefCounted, no nodes):
   budget = `budget.base + budget.per_wave * n`; an enemy costs its `tier`; a tier may appear from wave
   `tier_unlock_wave[tier-1]`; every `boss_every`-th wave is one `war_machine` plus an escort from the rest of
   the budget. Tier source: if `enemies.json` rows carry `tier` (lane foes adds it; not merged yet), use it;
   otherwise the provisional `tier_map` in `gauntlet.json`. If `war_machine` is not a row in `enemies.json`
   yet, the boss wave uses the highest-tier enemy available, and the result still says what spawned. Draws
   from `ctx.rng.stream(&"gauntlet_waves")` (or the registry's equivalent stream: never the global RNG), so
   composition depends only on the seed and the wave number. Unit test `test_gauntlet_composer.gd`: spent
   cost <= budget and >= budget minus the cheapest unlocked cost; no tier before its unlock wave; boss wave
   has exactly one boss (or the fallback); same seed + wave = same list; budget grows with n.
3. **Spawning real enemies**: spawn through whatever `CombatArena` / the arena uses for its waves today
   (`WaveRun`, `PitWaves`, `ArenaPit`, squad rows); do not fork their logic. Placeholder looks come from the
   existing rigs. The fallback `GauntletWalker` must actually kill wave 1-3 enemies (walks forward, faces the
   nearest, fires/strikes with what it holds: hands at the start, see how `arena_rivet_bot.gd` drives Rivet).
   If it dies early that is fine, but it must not stall: a wave that is not cleared in 90 s of sim time ends
   the run with `death{wave, by: "timeout"}`.
4. **Headless check** (the judge's command):
   `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<abs>/s7a.json` then the same
   to `s7b.json`, then `--seed=8`. Required: verdict line `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result
   fresh`; s7a and s7b byte-identical; seed 8 differs in street order and wave composition; the result
   validates against `project/data/schemas/gauntlet_run.schema.json` (write a tiny check, e.g. a GUT test that
   loads a result produced in-test, or a node script under `project/dev/gauntlet/` is not allowed: use a unit
   test). If `RUN_TICKS` is too short for 10 waves, raise it to a sane cap and say how many sim seconds a
   10-wave run took and the wall time. Put the three results and the run logs under
   `evidence/street/` in the worktree (git-tracked, small JSON only).
5. **Replay untouched**: run the scenarios once at the end
   (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) and quote the count and the 60 s
   replay digest line; your files must not move it (nothing outside the gauntlet changes).

## What the director already knows
- The street is `GauntletSession.open_street` + `GauntletStreet` (an `ArenaHook`, window of 3 segments,
  `StreetSquad` re-maps routes on advance) + `GauntletSegment.spawns` (world metres). Build the run on these.
- `Fighter.damage_k` is the share of a hit the victim TAKES (Tonnage writes 0.3 on Rivet). Not for this brief.
- `CombatArena._repair()` heals Rivet from `tuning.rivet["repair_per_s"]` after `repair_delay_s`; walk speed
  is `tuning.rivet["walk_mps"]`. Brief 03 will scale those per session; do not touch them now.
- Run `node tools/lint/lint.mjs`, `node tools/tests/run_unit.mjs --changed` and `node tools/gate/quick.mjs`
  before each commit. A Godot `--import` before committing new `.gd` (commit the `.uid`).

## Final message
Commits (sha + subject), files, the three verdict lines, the sim seconds per wave for seed 7 (a small table),
the byte-compare result, the schema check, scenario count + replay digest, mutate score on
`gauntlet_composer.gd`, every NEED, anything undone.
