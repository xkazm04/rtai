# n20-kerf brief 02: wire Kerf's spectral body + flight + the three charge beams

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. Visual night: no sim,
replay, parity or bake digest may move; abilities, numbers, hit boxes unchanged. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf` (bash) /
`$env:APPDATA='C:/Users/kazda/kiro/gtai-n20/appdata/kerf'` (PowerShell). Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`
for anything that renders, `--position 0,1440` on any windowed run. One Godot process at a time; free your
own processes by PID, never by name.

## Step 0: take flight's shared pieces (only once they are committed)
Flight's interface (`GhostLook`, `GhostFlight`, `ghost_hover.json`, README section "Spectral look") may
not be committed on branch `n20-flight` yet. Check with `git log --oneline n20-flight -5` (its base is
`a3eb0bf78`).
- Do steps 1, 2 and 4 FIRST in any case: they need nothing from flight (KerfSpectral takes its look,
  speed, charges and facing as plain inputs from its host; no `GhostLook` reference in those files).
- Then, if `n20-flight` has a commit adding `project/features/souls/ghost_look.gd` (or a README
  "Spectral look" section), `git merge n20-flight` (the ONLY merge allowed tonight), read the README
  section, and do step 3 and the stills. If it conflicts, abort the merge (`git merge --abort`), and report.
- If flight has still not committed when steps 1, 2, 4 are done and committed, STOP there and report
  (the director will resume you for step 3).

## What exists (brief 01, already committed)
- Top-view parts `project/features/souls/art/kerf/spectral/` (hull, cables, arm, lens_open, lens_half,
  lens_slit; `cut.json`). Look at them: the accepted hull may already include small cable loops/arms
  drawn in; if so do not add the separate cables/arm parts on top of it twice.
- Tilted grids `project/features/souls/art/view/p70/kerf_hover.png` and `p55/kerf_hover.png`:
  5 rows (toward, 3/4 toward right, right profile, 3/4 away right, away) x 3 columns
  (0 POISED, 1 CRUISE, 2 LUNGE), figures centred on the cell (no feet).

## Build (files you own: `kerf_*.gd`, `project/features/souls/art/kerf/**`, Kerf files under `art/view/`,
`project/dev/ghost-powers/kerf_beat.gd`, tests named for them, the `kerf` row of `ghost_forms.json` - DO NOT
switch that row's look tonight in this package)

1. New `project/features/souls/kerf_spectral.gd` (`class_name KerfSpectral`, Node2D; split into a second
   file e.g. `kerf_beams.gd` if it passes ~200 lines). The spectral body in BOTH views, render only:
   - **Tilted views** (`ViewMode.shared().art` is `p70`/`p55`): one Sprite2D from the `kerf_hover` grid via
     `GhostSheet` (3 columns; left facings mirrored as `GhostDrawn`/`GhostSheet` already do; use the same
     octant hold as `GhostDrawn.octant`). Column = mood (below). Scale so the figure is the size the
     legacy figure was (`KerfRig` CARD/drawn sizes, `PlayerScale` as before); figure centre on the
     flight's body point (no feet: nothing is planted).
   - **Top view**: the spectral parts as sprites (hull nose +x, lens at the nose socket, arms if the
     hull does not already carry them), length about `KerfRig.HULL_M` x 1.1.
   - **Mood** (one function, unit-tested, pure: `static func mood(speed_mps, ticks_since_blink, charges) -> int`):
     LUNGE for `LUNGE_TICKS` (8) after a blink (`KerfStage.blinks` increments; you get the stage the way
     `KerfView`/`GhostActs` do); else CRUISE above 3 m/s; else POISED. POISED with charges ready is the
     cocked idle: he waits on the aim line (the brief: "the idle is the wind-up").
   - **Eye**: top-view lens part = open (POISED with a charge), half (CRUISE, or POISED while
     `KerfStage.pick` on the last aim finds a target: he narrows on it), slit (LUNGE, or no charges).
   - **Dart at speed**: top view hull scale (x 1.0->1.08, y 1.0->0.86) by speed/12; turns get no extra
     softening from us (the flight row does the bank).
2. **The three beams = the three charges** (`kerf_beams.gd` or inside KerfSpectral, drawn with
   `draw_line`, ground-space, projected for the tilt with `ViewMode.ground_k()` and lifted with the
   flight's lift): three straight beams of light from the hull's tail (`-0.55 m` on the body axis),
   beam i drawn iff `i < charges`, plus the regrowing one whose LENGTH is the recharge fraction (add a
   view-only getter `recharge_k() -> float` to `kerf_stage.gd`: `_recharge / ticks(recharge_s)`, 0 when full;
   it reads state, writes nothing, so no digest moves - confirm `write_state` is untouched).
   - At rest: length 0.9 m, fanned +-7 degrees, each wavering +-3 degrees on its own phase (tick-driven,
     never frame delta; reduced motion = no waver).
   - At speed (12 m/s): length 3.2 m, parallel, 0.12 m apart, dead straight. Lerp by speed.
   - Colour: a soft teal glow line (`#2EC4B6`, alpha ~0.35, width ~0.14 m) under a thin pale-mint core
     (width ~0.035 m, `Color(0.85, 1, 0.96)`), additive or plain; NO red, NO white star.
   - Use only colours from the colour law (teal is the soul's).
3. **KerfRig** (`kerf_rig.gd`): when `GhostLook.spectral(&"kerf")` the rig builds and shows KerfSpectral
   and none of the legacy parts (legs, old hull, old arms, old card, drawn walk/run); otherwise the legacy
   path stays exactly as today (legacy films must be byte-for-byte what they were: do not change constants
   on the legacy path). Follow the README for `drawn.hover` / flight. Keep the file under ~200 lines
   (hard 300), functions <= 40 lines, <= 5 params, typed, `Log` not print.
4. Tests (`project/tests/unit/test_kerf_spectral.gd`): mood selection, beams shown = charges (+1 regrowing
   with length = recharge_k), legacy look builds legacy parts and spectral builds none of them
   (use `GhostLook.override_for_test` / `reset_for_test`). Run
   `node tools/tests/run_unit.mjs --changed` and paste the summary line.

## Check (look yourself; scripts are fine)
- `node tools/godot/check.mjs` on every new/changed `.gd`.
- Stills with the review driver `project/dev/ghost-powers/ghost_review.tscn` (read its KNOWN_FLAGS; use
  `tools/dev/run.mjs` as the front door) with `--ghost-look=spectral`, Kerf only, into
  `C:\Users\kazda\kiro\gtai-masters\n20\kerf\`:
  `wire_idle_32.png` (at rest, both views: 70 tilt above, top view below if the driver's layout does
  that, else two stills), `wire_cruise_32.png` (at full speed), `wire_close_64.png` (64 px/m),
  and `wire_legacy_32.png` without the flag (proves legacy is unchanged). Look at each: legless, beams
  straight, eye readable, nothing planted on the ground.
- `node tools/gate/quick.mjs` green before the commit (read `tools/README.md` for it).

## Commit
One commit for the wiring (+ tests, + `.uid` files), staged per path; a merge commit for step 0 is fine.
No `git add -A/./-u`, no stash, no reset --hard, no commit -a, never push. Then
`node tools/mutate/mutate.mjs --file=project/features/souls/kerf_spectral.gd --max=12` and quote the score.

## Final message
Files, test/gate lines, mutate score, the still paths, anything that looked wrong, and every place you
needed a file you do not own (write those as `NEED flight: <file> <why>` in your report, not edits).
