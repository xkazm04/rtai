# Package 4 (guns lane, n19): homing_shard, then ray_gun - diagonals, magazine, reload; and a general turn kit

You finished the rifle (3b). Same pipeline, same law, now for two existing weapons whose holes are in `evidence/arsenal/matrix_after_3b.txt` (re-run the audit first; it is the authority):
- `homing_shard`: fire8 X at p55 and p70 (no `_diag.png` cells, no `RivetGunDiag` rows), reload X at top/p55/p70 (no `parts.mag`, no reload strips). 5 holes.
- `ray_gun`: the same 5 holes.
Finish homing_shard completely (all its holes, both pitches, evidenced) before starting ray_gun. If time runs short, a finished homing_shard beats two half weapons.

## 0. General turn kit (do this first, small)

Generalise your rifle turn driver (`project/dev/rivet_arsenal/rifle_turn.gd` + `_rec.gd`, and the film wrapper you kept in `build/3b-film.mjs`) into a committed, any-weapon tool: a dev `-s` script `project/dev/rivet_arsenal/arsenal_turn.gd` (`--weapon=<arsenal id> --pitch=p55|p70 --ppm=32|64 --out=<dir>`, own `const KNOWN_FLAGS`) and a node wrapper under `tools/film/` (shared tooling: add files only, keep every existing test green) that renders a revision's tree (`--rev=<sha>` the way `tools/film/compare.mjs` snapshots one) and writes (a) the 32 px/m turning mp4 through all eight directions and (b) the 64 px/m contact sheet, 8 directions x (rest, fire), with `--a=<rev> --b=<rev>` giving old row above new row, each cell labelled direction + rev. Add a small `node --test` test for the layout logic. If the rifle versions are now redundant, delete them in the same commit. Use it for every weapon from now on.

## 1. Diagonal fire cells (per weapon, p55 and p70)

`rivet_eq_<gun>_diag.png` + `_diag_noflash.png` in RivetStrips' DIAG order (3/4 toward right, away right, toward left, away left; gun in his right hand in all four), and if the facing strip lacks it, the `_noflash.png` twin the neighbours have. `RivetGunDiag` rows `p55/<gun>` and `p70/<gun>` (DEG, HELMET_X, FOOT_PX: measured, as you did for the rifle), `rivet_muzzle.json` diag rows. References: the weapon's OWN existing cells (`rivet_eq_<gun>.png`, `_left.png`, its `held.png`) for the gun, and the neighbours' diag strips at the same pitch for Rivet's poses and density (`rivet_eq_electro_gun_diag.png` is the nearest sibling: a one-hand energy pistol). Energy colours stay the weapon's own (look at its existing flash and projectile; do not invent a new hue; never amber, never vermilion).

## 2. Magazine and reload

`weapon_art.json` `parts.mag` for the gun (top-down part, drawn like the rifle's `mag.png` and the pistol's, in the gun's own materials: an energy cell or shard cartridge, whatever its held art shows) and `rivet_reload_<gun>.png` + `_left.png` at p55 and p70 in the layout of `rivet_reload_pistol*.png` (the one-hand sibling). With the mag part present `RivetMagView` must no longer draw its ink-block placeholder for this gun: confirm with a still.

## 3. Evidence per weapon (in `C:/Users/kazda/kiro/gtai-masters/n19/guns/<gun>/`)

- 64 px/m contact sheet per pitch, old (`28302bd3c`) row above new: `<gun>_p55_64.png`, `<gun>_p70_64.png`.
- 32 px/m turning clip, p55, 10-40 s: `<gun>_p55_turn32.mp4` (and p70 if cheap).
- A reload still per pitch.
- `frames.json` (8-15 entries, best first: `{file, title, ppm, before, note}`).
- Before you ship a sheet, compare a new diagonal cell with its hand-made neighbours at 64 px/m (ink line weight, texel size, collar, palette): name any cell that can be told apart and redraw it.

## Acceptance

- Audit: `homing_shard` 0 holes (then `ray_gun` 0); update `arsenal_known_holes.json`; write `evidence/arsenal/matrix_after_4.txt` (+ .json).
- `node tools/tests/run_unit.mjs --changed` and `--select=test_arsenal_audit,test_rivet_gun_diag,test_rivet_fire_cam` green; `node tools/lint/lint.mjs` green; `node tools/tests/release_compile.mjs` green; `node tools/gate/quick.mjs` before each commit (if its Godot step still fails, quote the exact line).
- `node tools/mutate/mutate.mjs --file=features/characters/rivet_gun_diag.gd --max=10` after the code/data commits (quote the score); the same for the turn tool's main `.gd` if it has logic worth mutating.
- One commit per change (turn kit; per weapon: art, data rows, audit), staged per path, `.import`/`.uid` with their sources.

## Art law

image_gen only, own-art references only (LEG-04), masters to `C:/Users/kazda/kiro/gtai-masters/n19/guns/masters/` + `art_src/n19-guns.manifest.json` entries, prompts under `docs/art/prompts/n19/guns/`, one provenance line per shipped PNG in `steam/ai-provenance/2026-11.jsonl`, cut by script under `tools/art/` (reuse yours), never by hand, at the neighbours' density (`rivet_res.gd`; the one-line registration per gun is an allowed call site, list it). Rivet's neck band is a rigid striped hazard collar, never cloth. List every mirrored cell (only where gun and Rivet are symmetric in that view; a one-hand gun in the right hand is NOT symmetric).

## Law

- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns`, `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` before every Godot run; `--rendering-driver d3d12` to render; windowed runs `--position 0,1440`. One Godot at a time; kill only your own PIDs.
- Damage, rates, hitboxes, ranges do not change. No sim/replay/parity/bake digest moves (stop and report if one does). Typed GDScript, size limits, `Log`. No stash / add -A / commit -a / reset --hard / push.
- Shared files (`rivet_strips.gd`, `tools/art/rivet_frames.json`, `rivet_res.gd`): this weapon's rows only; list the lines.
- Report: commits, holes before/after, evidence files, mirrored cells, which new cells you judged closest to telling apart from the hand-made ones and why, anything left.
