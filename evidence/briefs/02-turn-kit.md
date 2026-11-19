# Package 2 (guns lane, night n19): the turning-fire film and the per-weapon contact sheet

The lane's goal: by morning no weapon in `rivet_arsenal.json` is a stand-in and none lacks the cells its neighbours have. Package 1 (committed) built the audit (`project/dev/rivet_arsenal/arsenal_audit*.gd`, `evidence/arsenal/matrix_before.txt`). Every weapon we complete tonight must be evidenced by two things, and this package builds the tools for both and shoots the BEFORE set. No art and no gameplay change in this package.

## 1. A turning-fire film shot: `turn:<weapon id>`

Add a shot to `tools/film/` (read `tools/README.md` "tools/film/film.mjs" and `tools/film/shots.mjs` first; add, do not rewrite): Rivet stands alone (no hostiles needed, or a few far targets if the shot needs something to fire at), holds the given weapon, and fires while his aim steps through all eight directions (E, SE, S, SW, W, NW, N, NE, i.e. through side, diagonal, toward-camera, left and away cells), dwelling ~1.5 s per direction with the trigger held or tapped per the weapon's fire mode, then once more round, ~25 s total. Fixed seed, fixed 60 Hz, deterministic, camera locked on him.
- Must work for every weapon id in `rivet_arsenal.json` `weapons`, including `assault-rifle` (no `weapons.json` row: it is quest 1's pick-up rifle from `combat.json`; find how the game equips it) and melee ids (swing instead of fire), and for both art pitches (p55, p70; find how a film picks the pitch / look profile, and expose `--pitch=p55|p70` if it is not already a flag) and any px/m (`--ppm=32|64` or the existing zoom flag).
- Any dev-only hook goes in `project/dev/**` or behind the existing dev hook pattern (`gunplay_hook.gd`), declared in `KNOWN_FLAGS` if it adds a launch flag (`project/boot/launch_args.gd` is shared append-only: one line per flag). The release export must not depend on it (`node tools/tests/release_compile.mjs` stays green).
- The shot writes `probe.json` as every film does; the turn schedule (tick ranges per direction) goes into `film.json` so a sheet tool can pick the stills.
- Movie: `--movie` gives an mp4 of the whole turn at 32 px/m.

## 2. A per-weapon contact sheet: `node tools/film/arsenal_sheet.mjs <weapon> --pitch=p55|p70 [--a=<rev>] [--b=<rev>] --out=<png>`

One labelled sheet at 64 px/m: for each of the 8 directions, Rivet at rest and on a firing tick (the shot's flash frame), cropped tight round him at the same crop per cell. With `--a`/`--b` it renders both revisions (use `--rev` snapshots like `compare.mjs`) and lays them out old row above new row, each cell labelled with direction + rev, plus which drawn cell the game picked if the probe or a log line exposes it (strip file + cell index; add that to the probe if it is cheap and render-only). Reuse `tools/film/sheet.mjs` / `png.mjs` / `font.mjs` rather than adding a dependency. Add a small `node --test` test for the layout logic (e.g. `tools/film/arsenal_sheet.test.mjs`).

## 3. The BEFORE set

On the base commit's tree (`--rev=28302bd3c` or HEAD before your changes, they are the same art), shoot for every gun in `rivet_arsenal.json` (and the melee weapons if cheap) the p55 64 px/m sheet and the p70 64 px/m sheet. Write them to `C:/Users/kazda/kiro/gtai-masters/n19/guns/before/<weapon>_<pitch>_64.png` (outside git). Shoot one 32 px/m turn movie for `assault-rifle` p55 only (the next package redraws it): `C:/Users/kazda/kiro/gtai-masters/n19/guns/before/assault-rifle_p55_turn32.mp4`. If the whole set would take more than 30 minutes of Godot time, shoot the weapons with holes in `evidence/arsenal/matrix_before.txt` first and say which you skipped.

## Acceptance

1. `node tools/film/film.mjs turn:pistol --pitch=p55 --stills=<a few ticks> --out=build/film/turn_pistol` passes and its stills show Rivet turning; paste the `fire at ...` line.
2. `node --test "tools/film/*.test.mjs"` green; `node tools/lint/lint.mjs` green; `node tools/tests/release_compile.mjs` green.
3. The before sheets exist; list them with sizes. Open two of them yourself and say in one line each what you see (e.g. "p55 assault-rifle: draws the machine pistol in all 8; diagonals use the side fire cell").
4. One commit per change (shot, sheet tool, any dev hook), staged per path.

## Law

- Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12` for anything that renders; any windowed run takes `--position 0,1440` (secondary monitor, never the main display). One Godot process at a time; kill only your own PIDs, never by name.
- Typed GDScript, files ~200 LOC (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. No `git stash`, no `add -A/./-u`, no `commit -a`, no `reset --hard`, never push. Commit `.uid` files.
- Performance numbers are not needed here. Do not touch sim, replay, parity or bake digests.
- Ownership: guns lane owns `project/features/combat/weapons/**`, Rivet's gun/muzzle/magazine/gun-diag view files, `rivet_arsenal.json`, `rivet_muzzle.json`, `weapon_art.json`, `weapons.json`, `melee_weapons.json`, `project/dev/rivet_arsenal/**`. `tools/film/**` is shared tooling: add files and add a shot, keep every existing test green, do not change other shots' behaviour. Do not edit `project/features/characters/**` scripts other than `rivet_gun_diag.gd` in this package (if you think you must, stop and say so in your report).
- End with: files changed, commands and results, the before-set list, and anything you could not do.
