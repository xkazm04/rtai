# Package 5 (guns lane, n19): the shoulder launchers - mini_nuke, then rocket_launcher

Same pipeline and law as packages 3-4 (your thread knows them). Use the turn kit from package 4 for every weapon's evidence. Re-run the audit first; it is the authority. Holes now:
- `mini_nuke`: fire8 X (no diagonal cells/rows) and left X, at p55 and p70. 4 holes.
- `rocket_launcher`: fire8 X at p55 and p70 because its diagonal fire cells draw no rear exhaust (the audit's `_exhaust` check in `project/dev/rivet_arsenal/arsenal_audit_files.gd`: a hot pixel that differs from the noflash twin, on the side behind the helmet centre, in EACH of the four diagonals), and left X at p55 and p70. 4 holes.
Finish mini_nuke completely (both pitches, evidenced) before starting the rocket launcher.

## mini_nuke
1. Diagonal fire cells `rivet_eq_mini_nuke_diag.png` + `_diag_noflash.png` (and the facing `_noflash.png` twin if the audit wants it) at p55 and p70, `RivetGunDiag` rows (DEG, HELMET_X, FOOT_PX measured), `rivet_muzzle.json` diag rows. Poses from the rocket launcher's diag cells (the shoulder-launcher sibling); the launcher itself from mini_nuke's own `rivet_eq_mini_nuke.png` cells and `held.png`. A launcher vents behind: draw the rear blast in the diagonal fire cells exactly as you will for the rocket (so both pass the same exhaust rule; extend the audit's rocket-only exhaust check to mini_nuke if it is honest to, in its own commit with a test).
2. Left cells `rivet_eq_mini_nuke_left.png` at p55 and p70, in the layout of the neighbours' `_left.png` (`RivetFrames.LEFT_CELLS`). Mirroring: a shoulder launcher may look symmetric, but Rivet's collar stripes, his pack hose and which hand holds the grip are not; draw them, and list any cell you did mirror and why it is honest.

## rocket_launcher
3. Redraw (or repaint from the existing masters, by script) the p55 and p70 diagonal fire cells so each of the four shows the rear back-blast: a short cone of hot gas and grey-white smoke behind the tube, on the side away from the muzzle, in the same flash palette as its existing muzzle flash (warm white/yellow core; not vermilion, not amber comet, which is plasma's alone). The noflash twins stay without it. The game's back-blast must read at 32 px/m. Keep DEG/HELMET_X unless the redraw moves them (re-measure).
4. Left cells at p55 and p70 as for mini_nuke.
5. Film the rocket's p55 diagonal fire in a boss arena (the owner noted the p55 strike cells were never filmed in one): find how a dev shot or film puts Rivet in a boss/arena room (`tools/film/shots.mjs`, `project/dev/**`), shoot a 32 px/m clip of Rivet firing the rocket through the eight directions there, and a still per diagonal at 64 px/m.

## Evidence per weapon (in `C:/Users/kazda/kiro/gtai-masters/n19/guns/<gun>/`)
64 px/m contact sheets per pitch, old (`28302bd3c`) above new; 32 px/m turning clip p55 (and p70 if cheap); `frames.json` (8-15 entries, best first). Before you ship, compare each new cell with its hand-made neighbours at 64 px/m (ink weight, texel size, collar, palette) and redraw any that can be told apart; say which came closest.

## Acceptance
- Audit: `mini_nuke` 0, `rocket_launcher` 0; `arsenal_known_holes.json` updated; `evidence/arsenal/matrix_after_5.txt` (+ .json).
- `run_unit.mjs --changed` and `--select=test_arsenal_audit,test_rivet_gun_diag,test_rivet_fire_cam` green; lint green; `release_compile.mjs` green; `node tools/gate/quick.mjs` before each commit (`--no-godot` allowed only when its Godot step fails with the known standalone-autoload error; say so per commit).
- Mutate after code/data commits: `rivet_gun_diag.gd --max=10`, and `arsenal_audit_files.gd` if you touched it; quote scores.
- One commit per change, staged per path (`git commit -- <paths>` or stage only yours), `.import`/`.uid` with their sources.

## Law
Art: image_gen only, own-art references only, masters to `C:/Users/kazda/kiro/gtai-masters/n19/guns/masters/` + `art_src/n19-guns.manifest.json`, prompts under `docs/art/prompts/n19/guns/`, one provenance line per shipped PNG in `steam/ai-provenance/2026-11.jsonl`, cut by script under `tools/art/`, at the neighbours' density (`rivet_res.gd` line per gun is an allowed call site; list it). Rivet's neck band is a rigid striped hazard collar. Vermilion is danger only.
`export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns` and `GODOT_BIN` before every Godot run; `--rendering-driver d3d12`; windowed `--position 0,1440`; one Godot at a time; kill only your PIDs. Damage, rates, hitboxes, blast radii do not change. No digest moves. Typed GDScript, size limits, `Log`. No stash / add -A / commit -a / reset --hard / push. Shared files: this weapon's rows only, list the lines.
Report: commits, holes before/after, evidence files, mirrored cells, closest-to-tellable cells, anything left.
