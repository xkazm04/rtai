# Builder n31-melee-06b (sonnet, 30 min): pinning tests for the item 4 mutate survivors

Read `evidence/briefs/n31-common.md` (binding) and `evidence/n31-melee/04-impacts/mutate.md` (the survivors).
Tag `06b`. Launched ~05:00. Commit by 05:25; report and END by 05:35 whatever state. `git commit -- <paths>`.

LOCK (important): builder 04g shares the lane Godot lock and may run `tools/melee/fatal_takes.sh`, which takes and
frees the lock once per arm; grabbing the lock between its arms starved a film last session. So before EVERY
Godot run: (a) the lock `build/n31/godot.lock` must be free, AND (b) no `fatal_takes.sh` / `play_take.mjs`
process may be running (`powershell -c "Get-CimInstance Win32_Process | ? { $_.CommandLine -match 'fatal_takes|play_take' } | select ProcessId,CommandLine"`).
If either fails, wait (poll 30 s) and write tests meanwhile. Then take the lock (common law), run, free it.
Keep each Godot run short: `node tools/tests/run_unit.mjs --select=test_gun_fx_wound,test_shield_sparks_melee`.

1. `project/tests/unit/test_gun_fx_wound.gd`: assert the returned count on every early-out guard (:30-36 of
   `project/features/combat/weapons/gun_fx_wound.gd`: no bleed, flick off, not admitted -> 0), the robot vs flesh
   count (:39, :42: robot with oil -> its count, flesh -> its count, a robot without oil -> flesh path or 0, as the
   code says), and that a reused instance after its reset (`_last.clear()`, :22) admits again. Read the code first;
   pin what it does, do not change product code.
2. `project/tests/unit/test_shield_sparks_melee.gd`: the blood throw on a blocked hit (:36-37 of
   `project/features/combat/react/shield_sparks.gd`), the zero-length direction fallback (:64, :68), the kind == 1
   branch (:77). Use doubles/spies the existing tests use; if a branch needs a scene the unit test cannot build,
   skip it and say so.
3. Run the two tests (green), `node tools/lint/lint.mjs` on your files (fix gdformat/gdlint findings), commit
   (part A).
4. If before 05:20 and the lock rule allows: `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/gun_fx_wound.gd --max=20 --tests=test_gun_fx_wound`
   (take the lock for it; outer timeout 600 s). Append the new score (killed/(killed+survived)) under a
   `## 06b re-run` heading in `evidence/n31-melee/04-impacts/mutate.md`; commit (part B).
Owned: those two test files, `evidence/n31-melee/04-impacts/mutate.md`. Nothing else (no product code). Before
killing any PID print its CommandLine; kill only your own. Final report: tests added (names), result lines, commits,
the new score, what you could not do.
