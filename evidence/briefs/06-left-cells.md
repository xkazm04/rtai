# Package 6 (guns lane, n19): left-facing cells - plasma_rifle, gatling, flamethrower, gloria

Same pipeline and law as packages 3-5 (your thread knows them); the turn kit from package 4 for evidence. Re-run the audit first; it is the authority. Each of these four has `left` X at p55 and p70 (no `rivet_eq_<gun>_left.png`): 8 holes. Order: plasma_rifle, gatling, flamethrower, gloria; each finished (both pitches, evidenced) before the next. If time runs out, stop at a finished weapon and say which are left.

## Per weapon
1. `rivet_eq_<gun>_left.png` at p55 and p70 in the layout of the neighbours' left strips (`RivetFrames.LEFT_CELLS`; the closest siblings: `rivet_eq_electro_gun_left.png` / `rivet_eq_assault_rifle_left.png` for two-hand guns), plus whatever rows the left path reads (`rivet_muzzle.json` left rows, `RivetFireCam` / `RivetStrips` tables: find them from how `assault_rifle` left cells are wired, which you did).
2. The gun from its own cells (`rivet_eq_<gun>.png`, `_diag.png`, `held.png`); Rivet's pose and density from the neighbours' left strips at that pitch. The gatling's belt box and the flamethrower's fuel tank sit where its side cells put them (on his back/hip), seen from the other side. Energy colours stay the weapon's own: plasma_rifle keeps its existing plasma colour (the amber comet is plasma's projectile; do not repaint it), the flamer its existing flame.
3. Mirroring: these guns are not symmetric (ejection port, belt, tank, which hand holds the grip, collar stripes): draw them. If you mirror any cell, list it and say why it is honest.

## Evidence per weapon (`C:/Users/kazda/kiro/gtai-masters/n19/guns/<gun>/`)
64 px/m contact sheets per pitch, old (`28302bd3c`) above new; 32 px/m turning clip p55; `frames.json` (8-15 entries, best first). Compare each new left cell with the hand-made neighbours at 64 px/m and redraw any that can be told apart; say which came closest.

## Acceptance
- Measured, not eyeballed (package 5 drew left cells 30 % too tall and pale): `cell_metrics` (package 5b's tool) shows each new left cell within 5 % height and inside the tone threshold of that weapon's own E rest cell, at both pitches. Quote the rows.
- Audit: each finished weapon 0 holes; `arsenal_known_holes.json` updated; `evidence/arsenal/matrix_after_6.txt` (+ .json).
- `run_unit.mjs --changed` and `--select=test_arsenal_audit,test_rivet_gun_diag,test_rivet_fire_cam` green; lint; `release_compile.mjs`; `node tools/gate/quick.mjs` before each commit (`--no-godot` only for the known standalone-autoload error, said per commit). Mutate the main changed `.gd` if any (quote the score).
- One commit per weapon (art + rows), staged per path (stage only yours; commit with `-- <paths>`), `.import`/`.uid` with their sources.

## Law
Art: image_gen only, own-art references only, masters to `C:/Users/kazda/kiro/gtai-masters/n19/guns/masters/` + `art_src/n19-guns.manifest.json`, prompts under `docs/art/prompts/n19/guns/`, one provenance line per shipped PNG in `steam/ai-provenance/2026-11.jsonl`, cut by script under `tools/art/`, at the neighbours' density (`rivet_res.gd` line per gun is an allowed call site; list it). Rigid striped hazard collar. Vermilion is danger only.
`export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns` and `GODOT_BIN` before every Godot run; `--rendering-driver d3d12`; windowed `--position 0,1440`; one Godot at a time; kill only your PIDs. No balance change, no digest moves. Typed GDScript, size limits, `Log`. No stash / add -A / commit -a / reset --hard / push. Shared files: this weapon's rows only, list the lines.
Report: commits, holes before/after, evidence files, mirrored cells, closest-to-tellable cells, anything left.
