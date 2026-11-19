# Brief n19-gfx-08-apron-bench: make the docks loading apron read, and the quiet benches

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -15`, `AGENTS.md`, the last 6 lines of `docs/decisions.md` first. You build and measure; the director reviews every diff and frame. Engine polish only: no new content, no new art, no colour change to the print.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time. `--rendering-driver d3d12` for anything that renders; windowed runs take `--position 0,1440`. Kill only your own PIDs, never by name.
- Never push, never read other `n19-*` worktrees. gfx owns `project/features/city/**`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`. `node tools/gate/quick.mjs` before each commit.
- Owner's law: a wall or solid never stands on a zebra crossing unless the road is closed there (`project/tests/unit/test_city_zebra_clear.gd` guards it; keep it green).

## Part A. The loading apron reads as a loading apron (about 35 min)
Item 4 (`6ead32adc`, `features/city/gen/dock_painter.gd` `yard()`): a docks yard tile whose south neighbour is a warehouse block stamps the last `LOADING_APRON_M` = 3 m as `C_PROP`, so walkers turn 3 m short of the roof's north edge (the black ink wedge is gone: `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/yard_compare_tilt70_64ppm_t150.png`). But nothing is drawn there: walkers stop at an invisible line on open paving.
1. Draw the edge with what the docks already own, no new art: a row of `T_BOLLARD` (37) along the apron's north edge (y = 8 - LOADING_APRON_M in the tile), spaced like the quay's (`BOLLARD_V_M`, about 2.5 m), placed through `kerb.prop(...)` as the quay does, and/or an existing docks ground/decal texture over the 3 m strip (a paving or bay texture the zone already uses; look at `CityZone` docks fields and the textures table). Pick what reads best at tilt 70, 32 and 64 px/m; say what you rejected and why with a frame.
2. Every bollard sits on the C_PROP apron, never on a walk aisle, a container slot or a zebra; walk connectivity per docks chunk unchanged (count components before/after).
3. Generator law: bump `CityGen.GENERATOR_VERSION` by one, re-bake (`"$GODOT_BIN" --headless --path project -s res://dev/bake_city.gd`, then `-- --check` green), prove with an equal-version bake that only docks chunks moved (count per zone; downtown and mixed must be 0), one decision line `- [2026-11-19] DECISION city/zones-v<N>-apron-bollards (n19 gfx item 4 polish; re-bless): ...` naming the chunk list re-blessed and every digest checked (city replay final, 60 s replay, quest 1 input, parity: unchanged or old -> new).
4. Extend `project/tests/unit/test_dock_yard.gd`: every apron tile carries its edge markers on its north edge. Mutate: `node tools/mutate/mutate.mjs --file=project/features/city/gen/dock_painter.gd --oracle=tests,bake-check --lines=<your changed lines>`; quote killed/(killed+survived), kill non-equivalent survivors.
5. Evidence to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/`: same spot and tick as `yard_compare_*_t150`, before (current HEAD) / after, tilt 70 at 32 and 64 px/m and top 64, side by side; prepend the best to that folder's `frames.json`. Look at each frame.

## Part B. The benches on a quiet machine (about 30 min, after Part A is committed)
The bench lock is `C:/Users/kazda/kiro/gtai-n19/bench.lock`, shared by five lanes. Protocol: create it exclusively (`fs.writeFileSync(p, '<lane gfx> <iso time>', {flag:'wx'})` or PowerShell `New-Item` without `-Force`); if it exists and is younger than 20 min, wait (check every 2 min, at most 20 min) then go on without it; if older than 20 min it is stale: delete it and take it. Delete it the moment your runs end, also on failure.
Inside the lock, in this order:
1. Heat-3 bench: `node tools/bench/run.mjs --heat=3` (it waits on other Godot runs itself; let it). Last night's police lane got p99 2.39 ms CONTENDED. Quote the section 20 verdict lines and whether the run says CONTENDED.
2. The rig bench for item 3A's cost: `"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=build/evidence/rig-bench.json` at HEAD, then at `268960380^` (a temp worktree under `%TEMP%`: `git worktree add --detach <tmp> 268960380^`; it needs this worktree's native DLLs copied into its `project/` bin path if it loads the extension; never commit them; `git worktree remove --force <tmp>` + `git worktree prune` after). Report 50 and 200 people p50/p99 before -> after, and the CONTENDED flag of each.
Before each run, count the other Godot processes on the machine (`Get-CimInstance Win32_Process -Filter "Name like 'Godot%'"`) and quote the count: a run with others alive is CONTENDED whatever the tool says.
Copy the bench JSONs to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/bench/`.

## Part C. Item 2 (far cops) evidence gaps (about 15 min, between A and B if the lock is busy)
`b9cddfe91` made the far crowd draw cops blue (rows 5/6) instead of civilian row 7. `C:/Users/kazda/kiro/gtai-masters/n19/gfx/farcop/` has stills (`top-32-cop-details.png`, `*-before-after.png`) but no `frames.json` and no clip.
1. A 32 px/m clip, 10 to 40 s, tilt 70, heat 3 (seed 18 as the stills), with far (baked, rank > 16) cops in shot: before (`b9cddfe91^`, temp worktree as in Part B, with DLLs built from that commit's native if `render.cpp` differs: build them in the temp worktree with `scons`, never copy this branch's DLL into a before run) and after (HEAD), same ticks, side by side, into that folder.
2. `frames.json` there, 8 to 15 entries best first (`[{file,title,ppm,before,note}]`), the clip second. Delete scratch renders it does not reference (the `before-*`/`after-*` frame dirs if nothing references them).

## Acceptance
- lint, full unit, scenarios, parity, bake `--check`: green at your last commit; quote each line.
- Commits: (a) apron edge + test, (b) version bump + re-bake + decision line. The benches change no file in git.

## Report back
A: what draws the apron edge, rejected options, chunks moved per zone, digests, mutate score, frame paths. B: the lock (taken when, freed when), other Godot count per run, heat-3 verdict lines, rig bench numbers before -> after. Anything not done and why.
