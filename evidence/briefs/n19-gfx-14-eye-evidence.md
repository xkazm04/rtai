# Brief n19-gfx-14: eye evidence for items 1 and 5, and evidence tidy (no product change)

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -25`, `AGENTS.md`, `JOURNAL.md` (last 30 lines) and `tools/README.md` (the `tools/film/` and `tools/dev/` sections) first. You build and measure; the director looks at every frame. HARD STOP: finish and write your report by 07:20 local; the freeze is 07:30. If time runs short, finish Part A and skip the rest, saying so.

Report as you go to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/eye-14-REPORT.md`.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time (yours). `--rendering-driver d3d12` for renders; windowed runs take `--position 0,1440`, never the main display. Kill only your own PIDs, never by name.
- Never push; only branch `n19-gfx`, this worktree. Do not touch other lanes' worktrees.
- Prefer existing dev scripts. Item 1's district films were made by brief 06 (`evidence/briefs/n19-gfx-06-zones-film.md` and its `.out.txt` name the script and flags); item 5's guard is `project/tests/unit/test_city_zebra_clear.gd`.
- If you must add a dev-only script, it goes under `project/dev/` (release export drops it), typed, under 200 lines, functions at most 40 lines, `Log` not `print`, with its `.uid`, one commit, `node tools/gate/quick.mjs` green before the commit. No change to `features/`, `core/`, `boot/`, data, native or any golden.

## Part A: item 1, a downtown close-up to pair with the docks one (most important)
The docks has a 64 px/m close-up (`C:/Users/kazda/kiro/gtai-masters/n19/gfx/zones/docks3-top-64.png`, cars labelled by art). Make the matching downtown one: same seed, tick, render settings and labelling as `docks3-top-64.png`, centred on a downtown street with at least 4 moving cars in view. Then compose one side-by-side sheet `zones/docks-vs-downtown-top-64.png` (docks left, downtown right, a title line per panel naming the district and the car-art count in view). The owner must see in ten seconds that docks runs vans and pickups and downtown runs taxis. Look at it before you hand it over.

## Part B: item 5, a crossing frame
Render one 64 px/m top frame and one tilt-70 frame of a docks crossing that sits near the new v35 apron bollards or a warehouse, and one downtown crossing beside a tower (find candidates from the zebra footprints the guard walks; pick crossings where a solid stands within 2 m of the decal, so the frame shows the rule held at the closest call). Mark the zebra decal outline and the nearest solid's footprint, label the gap in metres. Write `gen/zebra-closest-64ppm.png` (one sheet, 4 panels). In the report, give the 5 smallest decal-to-solid gaps over all 256 chunks (chunk, zone, gap m, solid texture id).

## Part C: tidy the evidence folders
For `zones/`, `farcop/`, `contact/`, `gen/` under `C:/Users/kazda/kiro/gtai-masters/n19/gfx/`: every file not referenced by that folder's `frames.json`, by the top-level `frames.json`, or by `REPORT.md` in this worktree (grep the folder-relative name) moves to `<folder>/_scratch/`. Never delete. Each `frames.json` keeps 8 to 15 entries, best first. Add the Part A and B sheets to `zones/frames.json` and `gen/frames.json` (drop the weakest entry if a folder is at 15) and to the top-level `frames.json` (best per item first; item 1's new sheet goes first for item 1). List what moved in the report.

## Acceptance
- Part A sheet: same seed and tick both panels, car-art counts printed, docks and downtown read different at a glance.
- Part B sheet: 4 panels, gaps labelled; the 5-smallest-gaps table with its source (the script or test output) named.
- No product file changed, or one dev-only commit with a green quick gate.

## Report back (short, also in the report file)
Sheet paths, the car-art counts per panel, the 5 smallest zebra gaps, what moved to `_scratch/`, any commit with its quick-gate line.
