# Brief n19-gfx-01-zones: the city spawner reads each zone's car mix

Lane `gfx`, night run n19. You build; the director reviews every diff and frame. Engine polish only: no new story, characters or content.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time. `--rendering-driver d3d12` for anything that renders; any windowed run takes `--position 0,1440` (secondary monitor, never the main display). Kill only your own PIDs, never by name.
- Do not touch `main`, never push, never read other `n19-*` worktrees.

## Goal
Docks and downtown already carry their own traffic car mix as data: `project/data/tables/city_district.json` rows have `car_art` (12 entries; empty = `CitySpawner.CAR_ART`), loaded into `CityZone.car_art` (`project/features/city/gen/city_zone.gd` ~line 117-120), reachable by `CityZones.of_chunk(cx, cy)` / `of_tile(t)` (`project/features/city/gen/city_zones.gd`). The spawner ignores it: `project/features/city/city_spawner.gd` line 76 `var art: int = CAR_ART[_rng.randi_range(0, 11)]`. Make `try_car` pick from the zone of the spawn point's chunk.

Read the decision line `DECISION city/zones-car-art` in `docs/decisions.md` (line ~1349) first: it states this exact plan.

## Constraints
1. **Same RNG draw count.** Keep exactly one `_rng.randi_range(0, 11)` per traffic car, index into the zone's list when non-empty, else `CAR_ART`. The mixed zone must spawn byte-identical art to today. Police cars and bikes unchanged (bike still overrides art via its own stream).
2. The spawner must get the zones without a global: inject a `CityZones` (or a `Callable`/lookup) where `CitySpawner` is constructed (find the callers: `grep -rn "CitySpawner.new" project`). A spawner with no zones (tests, arena, harness) keeps `CAR_ART`. Both sim backends (native + GDScript reference) share this GDScript spawner, so parity must stay exact.
3. Validate that every zone `car_art` list has 12 entries in valid art ids 0-7 (schema or `from_row` or a unit test; pick the strongest that exists already, `project/tests/unit/test_city_zones.gd` already checks some of this).
4. Typed GDScript, files ~200 LOC (300 hard), functions <= 40 lines, <= 5 params, `Log` not `print`. Commit `.uid` with new `.gd` files.

## The digest move (only gfx re-blesses tonight; this is that one move)
This changes which car art spawns in docks/downtown, so city replay/scenario digests that cover those chunks move. Find every golden/digest that moves (`project/tests/scenarios/scenario_replay_60s.gd`, `project/tests/integration/test_replay.gd`, parity, any sim hash constants: run the suites and read what fails). Re-bless only those that move **because of this change**; if one moves that cannot be explained by docks/downtown car art, stop and report it instead of blessing. Bake hashes must NOT move (car_art is not a generator input): confirm with `"$GODOT_BIN" --headless --path project -s res://dev/bake_city.gd -- --check`.
Append ONE line to `docs/decisions.md`:
`- [2026-11-18] DECISION city/spawner-zone-cars (n19 gfx item 1; re-bless): ...` naming every digest/golden re-blessed (file + old -> new short hash) and why.

## Evidence (write under `evidence/n19-gfx/zones/`)
1. A dev script (`project/dev/city/zone_car_census.gd` or similar, runnable via `node tools/dev/run.mjs`) that, on a fixed seed, spawns traffic across the city (or drives the spawner over a fixed set of camera points in docks, downtown and mixed chunks) and writes `car_census.json`: per zone, count of each art id (0 sedan, 1 sedan_b, 2 sedan_c, 3 taxi, 4 van, 5 pickup, 6 ambulance, 7 sedan_grey), for **before** (flag or `--before` that forces `CAR_ART`) and **after**. Quote the table in your report. Expect docks ~6/12 vans+pickups and no ambulance; downtown ~3/12 taxis, no pickups; mixed identical before/after.
2. Films at 32 px/m, 10 to 40 s, one in the docks and one downtown, top view and tilt 70, same seed and tick before and after, using the kit in `tools/film/` (read `tools/README.md` and `tools/film/` for how; `tools/film/compare.mjs` for side-by-sides). Put frames/clips in `C:/Users/kazda/kiro/gtai-masters/n19/gfx/zones/` (not git) and a 1-row side-by-side PNG of docks vs downtown traffic, after, at the same tick, plus a before/after pair per district. If you cannot place the camera in a district with the existing kit, say so and give what you could.

## Acceptance (run all, quote results)
- `node tools/lint/lint.mjs` green.
- `node tools/tests/run_unit.mjs --changed` then the full `node tools/tests/run_unit.mjs` green.
- `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` green after the re-bless.
- `node tools/tests/run_parity.mjs` green (native vs GDScript, exact).
- Bake `--check` unchanged.
- A unit test that fails on today's code: a spawner with zones in a docks chunk never spawns art 6 (ambulance) over N spawns, and a mixed chunk's art sequence is identical to the no-zones spawner for the same seed.
- `node tools/gate/quick.mjs` before each commit.
- Commits: (a) the spawner + test, (b) the re-bless + decision line, (c) the census script. Stage per path.
- After committing, run `node tools/mutate/mutate.mjs --file=project/features/city/city_spawner.gd --max=25` and quote killed/(killed+survived).

## Report back
Files changed, commits (hashes), the census table, every digest re-blessed with old -> new, lint/unit/scenario/parity/bake/mutate results, paths of frames and clips, anything not done and why.
