# Brief 04 (lane polish): Dent: hit reaction checked in every view; the seized car teal in the top view too

Hard stop: 50 minutes after you start (write the stop time down at the start). Last commit 8 minutes before it. Film Dent only once, at the end, if time remains.
Order of value: hit reaction filmed + fixed > seized-car tint. If you run short, commit what is green and report
exactly where you stopped.

## Environment (every Godot / gate / film run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.

## Look first
- Plate: `C:/Users/kazda/kiro/gtai-masters/n20/concepts/dent_a.png` (if the n20 dent REPORT names another plate, use that).
- n20: `docs/day/2026-11-20/dent/REPORT.md` + `JOURNAL.md`; films in `C:/Users/kazda/kiro/gtai-masters/n20/dent/`.
- The accepted look: the strap tether is default; the strings stay behind `tether_look`. Do not redesign.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `project/features/souls/dent_*.gd`, `dent_*.gdshader`, `project/features/souls/art/**/dent*`,
  `project/features/characters/art/dent/**`, `project/features/souls/ghost_recoil*.gd` and `ghost_tail*.gd` (only if
  the hit reaction fault is there; keep the other ghosts' outputs identical, prove it with their tests)
- Dent's row in `project/data/tables/ghost_hover.json` / `ghost_forms.json`
- tests `project/tests/unit/test_dent_*.gd` (+ `.uid`); one line in `docs/decisions.md` per real choice
- A vehicle file (`project/features/vehicles/**` or similar) is NOT yours. If the top-view tint needs one, the allowed
  form is: Dent's code sets a public property / `modulate` on the car node it already holds (from Dent's file), or ONE
  added line at a vehicle call site that you name in your report. Anything more: write the patch to
  `evidence/patches/n21-polish-dent-car-top-tint.patch`, do not apply it, and report it as a NEED.

## 1. The hit reaction in both tilts and the top view
- Dent's spectral HIT cell + the tail flicker (the shared recoil: `GhostRecoil`, lean 12 degrees for Dent) was never
  checked on n20. Make a short capture where Dent is hit while flying and while holding a car, in tilt 70, tilt 55 and
  the top view, at 32 and 64 px/m: use `project/dev/ghost-powers/ghost_review.tscn` (read its flags: there may be a
  hit take; if there is none, add one in `project/dev/ghost-powers/` (yours) that applies a hit at a fixed tick) and
  `tools/film/` (`film.mjs` / `ghost_films.mjs`).
- Look at every frame of the hit (+0 to +20 ticks). Wrong is: the body snaps to the legacy cell or the walking
  figure, the cell flips facing, the tail detaches or flickers in another colour than teal/white, legs appear, the
  lean goes the wrong way or not at all in one view, the top view shows no reaction, red appears on him.
- Fix what is wrong in your owned files. Before/after strip (frames +0, +4, +8, +12, +16 side by side, per view):
  `C:/Users/kazda/kiro/gtai-masters/n21/polish/dent/dent_hit_{p70,p55,top}_{32,64}_{before,after}.png`.
  If nothing is wrong, keep the "before" strips only and say "checked, no fault" per view with the strip path.
- A unit test pins what the hit draws (the HIT cell index per facing, lean sign and magnitude, tail flicker on/off
  window) so it cannot silently regress.
- Commit: "Fix Dent's spectral hit reaction in <views>" (or a "Check ..." commit with the dev take and test).

## 2. The seized car agrees across views
- Today the car Dent holds is tinted teal in the tilt views and drawn plain cream (untinted) in the top view
  (`C:/Users/kazda/kiro/gtai-masters/n20/dent/` attack films show both). Make the top view match the tilt views:
  the same teal tint and alpha while seized, released exactly when the tilt view releases it.
- Find where the tilt tint is applied and apply the same to the top-view sprite through the allowed form above.
- Before/after at the same tick in the top view at 32 and 64 px/m:
  `dent/dent_car_top_{32,64}_{before,after}.png`, and a test that the top-view car node's modulate equals the tilt
  view's while seized and returns to white after release.
- Commit: "Tint Dent's seized car in the top view".

## After each commit
- `node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` green.
- `node tools/mutate/mutate.mjs --file=<the main file you changed> --max=20 --lines=<changed lines>`; quote the score.
- Re-film Dent: `node tools/film/ghost_films.mjs --ghost=dent --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n21/polish/dent`.

## Repo law (binding)
- AGENTS.md / STANDARDS.md. Typed GDScript, functions <= 40 lines, files about 200 lines (hard 300), <= 5 params,
  `Log` not `print`, no frame delta in sim code, RNG only through the registry.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on.
- No sim, replay, parity or bake digest may move; timing the sim decides does not move. Colour law: teal only for
  souls; red is blood only; amber for heat/overload. Hit lean stays 12 degrees for Dent (`GhostRecoil.LEAN_BY_FORM`).

## Report back
Per item: what you saw (per view), what changed (files), commit hash, the strip/still paths; test results; the mutate
line; film paths; anything not done and why; any NEED with its patch path.
