# Brief n19-gfx-03-gen: the zebra rule over the generated city, and the docks roof wedges

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -15` and `AGENTS.md` first. You build; the director reviews every diff and frame. Engine polish only: no new content.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time. `--rendering-driver d3d12` for anything that renders; windowed runs take `--position 0,1440`. Kill only your own PIDs.
- Never push, never read other `n19-*` worktrees. gfx owns `project/features/city/**`; the arena (`features/arena/**`, the street-fight arena's authored wall) is the `ai` lane's: do not touch it.

## Part 1. The zebra rule (owner's law, 2026-11-18): a wall/solid never stands on a zebra crossing unless the road is closed there.
Zebras are decals `TilePainter.T_ZEBRA` (73) laid by `project/features/city/gen/tile_painter.gd` (~line 88, `b.add(ChunkBuild.L_DECAL, T_ZEBRA, ...)`). Solids are the chunk's solid cells/props (see `chunk_build.gd`, `kerb_dresser.gd`, `dock_dresser.gd`, `block_painter.gd`, plus anything with a solid footprint: barriers, props with collision, parked cars if solid).
1. Write a unit test (`project/tests/unit/test_city_zebra_clear.gd`) that generates **all 256 chunks** (the same seed/district the bake uses) and asserts that no solid cell and no solid prop footprint overlaps any zebra decal's footprint (decal rect from its centre, rotation and the texture's metres). Report every hit (chunk, position, what). Keep it fast enough for the unit suite (if > ~10 s, tag it slow in `tools/tests/tiers.json`).
2. Run it on today's code. If it finds hits, fix the generator so they cannot happen (move/skip the prop, not the zebra), and the test now passes. If none: the test stays as the guard; also plant one fault by hand to prove it fires (quote the failure).
3. "Unless the road is closed": if the generator has any closed road concept (a road tile with a barricade by design), exempt only that, by name, and say so.

## Part 2. Docks roof wedges
`docs/day/2026-11-17/districts/REPORT.md` line ~30 and next step 3: docks yards put walkers right against a warehouse's north wall, so `CityOcclusion` (`project/features/city/view/city_occlusion.gd`, n8: a body north of a building under tilt is repainted with the printed world and inked as a silhouette) shows black wedges on the roof edge. The note's proposed fix: "a docks-only yard gap" (layout). The alternative is an occlusion fix (e.g. the silhouette/patch for a body whose feet sit within `NORTH_TOL_PX` of the north edge, or the patch clipped to the roof's drawn area makes a wedge).
What the director already read: `docs/day/2026-11-17/districts/JOURNAL.md` ~line 260: the wedges (black "!" marks over a warehouse roof's north edge, still `evidence/n18-districts/zones_v22_combo_48ppm.jpg`, yard panel) are the full rigs' behind-a-roof ink silhouettes, n8 design (rigs keep theirs, the baked crowd is hidden). So the occlusion is probably working as designed and the layout fix (docks-only yard gap) is the expected route; prove it in the probe before choosing.
1. PROBE: reproduce in the docks (a docks yard next to a warehouse, tilt 70 and combo, 32 and 48 px/m, any walker hugging the north wall) and capture the wedge; read the code and state the root cause in one paragraph (which rect/patch draws the wedge, and why at the north wall).
2. FIX: if the cause is an occlusion fault that would also show anywhere else, fix the occlusion (`city_occlusion.gd` / `city_crowd_occlusion.gd` / shader), not the layout. If the occlusion is right and only the layout puts walkers in the bad band, make the docks layout keep walkers off the warehouse's north wall (a docks-only yard gap: walkable cells against the north wall become non-walkable apron/props, or the yard row shifts), **without changing any downtown or mixed block** (prove it: the bake golden list differs only in docks chunks; list the changed chunk ids and their zones).
3. Same-tick before/after frames at the same spot, 32 and 64 px/m, tilt 70 and top.

## Generator law (if either part changes generated output)
- Bump `CityGen.GENERATOR_VERSION` once for this brief (33 -> 34) (`project/features/city/gen/city_gen.gd:10`), re-bake and re-bless the golden hash list: `"$GODOT_BIN" --headless --path project -s res://dev/bake_city.gd` then `-- --check` green (AST-12).
- One decision line: `- [2026-11-18] DECISION city/zones-v34-<slug> (n19 gfx items 4+5; re-bless): GENERATOR_VERSION 33 -> 34, what, why, which chunks moved (count per zone), what rejected.` If the sim/replay digests also move (walkable cells changed), find which, re-bless only those, and name them (old -> new) in the same line.
- Score every generator file you changed: `node tools/mutate/mutate.mjs --file=<file> --oracle=tests,bake-check --max=15` and quote killed/(killed+survived).

## Evidence
Frames to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/` (not git), via `tools/film/` (`compare.mjs` for side-by-sides). Names carry item, view, ppm, tick. A `frames.json` there (best first, `[{file,title,ppm,before,note}]`). For part 1, if hits were fixed, a before/after at one fixed crossing.

## Acceptance
- `node tools/lint/lint.mjs`, full `node tools/tests/run_unit.mjs`, scenarios, `node tools/tests/run_parity.mjs`, bake `--check`, all green; `node tools/gate/quick.mjs` before each commit.
- Commits: (a) the zebra test (+ generator fix if any), (b) the wedge fix, (c) the version bump + re-bake + decision line. Stage per path; commit `.uid` with new `.gd`.

## Report back
Zebra hits found (count, where) and fix; wedge root cause, fix, chunks moved per zone; digests re-blessed; test/lint/scenario/parity/bake/mutate results; frame paths; anything not done and why.
