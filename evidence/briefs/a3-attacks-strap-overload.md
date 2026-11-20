# Brief a3-attacks (lane dent, n20): jab above the car, the seatbelt strap, the overload as one attack

Context: RTAI (`gtai`), ghost form **Dent**. Tonight Dent becomes "Ejected" (plate:
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`; **look at its bottom-right vignette**:
a broad glowing seatbelt strap of teal light from his raised hand to a steel buckle clamped on the
car roof, and a black-and-yellow quartered crash disc glowing on that roof). This is a VISUAL night:
abilities, numbers, timing, hit boxes and every sim/replay/parity digest stay exactly as they are.
Render-only code. If something you want needs a sim change, stop and write it in your report.

## Machine rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent` before any Godot or gate run;
  `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`; one Godot
  process at a time; free your own processes by PID, never by name.
- Repo law: AGENTS.md (typed GDScript, files about 200 lines / hard 300, functions <= 40 lines,
  <= 5 params, `Log` not print, data JSON + schema, `.uid` committed). Stage per path, one commit per
  change, no `git add -A/./-u`, no stash, no `reset --hard`, never push.
- Files you may edit: `project/features/souls/dent_*.gd`, `gearbox_link.gd` (render-only parts),
  new files prefixed `dent_` (code, tests `test_dent_*`, data `dent_look.json` + schema),
  `project/dev/ghost-powers/dent_beat.gd`. One appended line each in `project/boot/launch_args.gd`
  `KNOWN_FLAGS` and `docs/decisions.md`. Anything else (vehicle views, render layers, ghost_* files):
  do NOT edit; if a one-line call site in another file is truly needed, make only that one line and
  name file:line in your report.


## Step -1: close out the previous package (a2), 5 minutes
The previous builder session (a2-wiring) was cut off at 01:45 while running
`node tools/tests/run_unit.mjs` / `node tools/mutate/mutate.mjs --file=features/souls/dent_spectral_drawn.gd --max=20`.
Its commits are in (HEAD 9e8bc0619, tree clean). First run
`node tools/tests/run_unit.mjs --select=test_dent_spectral_drawn,test_dent_spectral_top,test_dent_glass`
and fix anything red in one commit. Run the mutate for `dent_spectral_drawn.gd` (--max=20) in the
background-free gap at the END of your session (it is slow), and quote killed/(killed+survived).
Also delete stray scratch scripts under `build/` that a2 left (e.g. `build/dent_points_compare.gd`)
only if they are yours to delete (build/ is git-ignored; leave them otherwise).

## Before anything: take flight's latest
`git merge n20-flight` (allowed tonight, only that branch). It brings `GhostFlight.tail.points()` /
`half_widths()` (1b, d2a44407e) and later the broad tail root (flight package 2). If `dent_glass.gd`
follows its own trail instead of the tail points, switch it to `points()`/`half_widths()` in one small
commit.

## 0. The look data (first commit)
New table `project/data/tables/dent_look.json` (`"schema": "gtai.dent_look/1"`, sorted keys, a
`doc`, one row `id: "dent"`) + `project/data/schemas/dent_look.schema.json`, read by a small
`DentLook` class (`dent_look.gd`, static cached read like other table readers in `features/souls`):
- `tether_look`: `"strap"` | `"strings"` (default `"strap"`; `strings` is built in a later brief:
  for now `strings` falls back to strap and logs once).
- launch flag `--dent-tether=strap|strings` overrides the row (append to `KNOWN_FLAGS` with a
  `# n20-dent:` comment; read through `LaunchArgs.value`).
- strap and ring view constants you introduce below (widths in metres, alphas), so tuning is data.

## 1. Jab and its victim above the seized car
Last night's film: in the tilt views the seized car (a vehicle card, which draws in the vehicles
band over the actors band, see `GhostAttackViews.dent_dz` and `RenderLayers`) draws across Dent's
jab and its victim. Find how the seized car's card is drawn and ordered, and make the jab (Dent's
body while `GhostActs.jabbing`/the jab cells show) and the jabbed body draw above the seized car,
**only for those frames or only for that car**, without changing any other car's or actor's order.
Prefer a change inside Dent's own files (e.g. Dent's body/DentView raising itself; a re-draw of the
jab arm over the car is acceptable if the real victim cannot be moved). Show it: a same-tick
before/after still at 64 px/m in the tilt view (`--view` of the review driver, see below) where the
car overlapped the jab in n19 (`C:\Users\kazda\kiro\gtai-masters\n19\ghosts\dent_close_64.mp4`, first
seconds of the attack chapter).

## 2. The seatbelt strap (tether_look strap, the default)
Replace the thin teal tether line in `DentView._tether` (move the drawing into a new
`dent_strap.gd` so `dent_view.gd` stays under 200 lines) with a strap that reads at 32 px/m:
- A **broad flat belt** about 0.32 m wide from Dent's right hand (the form row's `anchors.hand_r`,
  rotated by Rivet's facing, at hand height in tilt views) to a **steel buckle on the car roof**
  (in tilt views the roof is above the car's ground spot: find how the vehicle card lifts its roof
  and match it; top view: the car centre). Ink edge (about 2 px dark ink each side), soul-teal fill
  `HaulerLook.TEAL`, a brighter pale-aqua centre stripe, and short cross ticks along it like belt
  webbing that **travel along the strap** toward the car while the car is driven (speed from the
  link's speed, stepped on sim ticks, never frame delta).
- **His body faces the car he holds.** In
  `C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a2\tilt70-64ppm-attack-steer-tick160-spectral.png`
  the STEER cell reaches away from the car because the drawn octant follows Rivet's aim. While a
  car is seized, pick the drawn octant (tilt) and the top rig's steering arm from the direction
  Dent -> car (render only; the sim facing is untouched), so the strap leaves the reaching hand and
  runs straight to the roof. The strap starts at that hand in the drawn cell (measure the hand spot
  per facing in the STEER cells, a small per-octant offset table is fine).
- Taut while he steers: nearly straight, a small tremble (none under reduced motion). Slack when he
  lets go (link ends without a blast): for 0.35 s the strap droops into a sag, then it frays and
  fades from the car end back to the hand. This needs remembering the last car spot in the view
  (render state only, not in `DentStage.write_state`).
- On the roof: the buckle (a small square steel plate with ink edge) and under it a black-and-yellow
  quartered crash disc about 1.1 m across, glowing faintly teal at its rim, rotating with the car.
- Teal only for soul light; the disc's yellow and black are Dent's marks; no red anywhere.

## 3. The overload reads as one attack, from the car
Today the car gets a heat halo, then a fireball at the car, and the hit star of a victim appears
where the victim was shoved to, so the victim and the wreck look like two attacks. Make:
- **The strap runs amber as it heats**: its fill lerps teal -> amber `#E9A23B`/`#C9822E` family
  with `DentStage.heat` (amber is allowed for heat), pulsing faster once armed (`arm_k`).
- **A ring on the road** around the car showing the blast reach `blast_radius_m` (4.5 m) while it
  heats: a dashed ink-and-amber ring on the ground (squashed like a ground ring in tilt views: copy
  how `TonnageView` draws its reach ring on the street in tilt views), with a fill that grows with
  heat like a clock face from the car's nose. Reduced motion: ring only, no pulse.
- **The blast fills that same ring**: the fireball/shock expands to exactly that ring, and at the
  blast tick draw a short bright shock spoke from the car centre to each body the blast struck
  (find them render-side: live or dying hostiles within the radius of `blast_at` at the blast tick,
  using their pre-shove spots if you can recover them without sim state, else their spots), lasting
  0.25 s, so each victim is visibly connected to the wreck. Keep the existing debris.
- Whatever you add must also read in the TOP view.

## 4. The comet tail (from my review of the a2 stills)
In `C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a2\tilt70-64ppm-move-dive-tick110-spectral.png`
the tail is a thin, faint wisp that starts below the plume. The plate's tail is a broad, bright tongue:
**as wide as the torso at the belt where it leaves the body, brightest there, tapering over about two
body lengths**, glass along it. Note: a2 narrowed the row's `tail.width_m` from 0.48 to 0.26 (commit 1a2d61a97); the plate wants the opposite at the root (about 0.5 m, the torso's width), thin only at the tip. Tune Dent's row in `project/data/tables/ghost_hover.json` (only the
`dent` row: `tail.anchor_m` so the root sits under the belt/plume, `width_m`, `length_m`, `stretch_k`,
`fray`) . Flight (the shared-tail lane) is adding a broad, bright, anchored root to `GhostTail` in its
package 2 (as wide as the torso at the belt, tapering over about two body lengths): `git log
n20-flight` and merge it when it is there, then tune only Dent's row to use it. Do NOT draw a
Dent-side root tongue and do not edit `ghost_tail.gd`; if flight's root has not landed when you reach
this item, tune the row (width at the root back to about 0.5 m) and say in your report that the root
brightness waits on flight. Same-tick before/after at 64 px/m (dive, tick 110, tilt 70 and top).

## Film / check
The review driver: `project/dev/ghost-powers/ghost_review.tscn` (read `ghost_review.gd`: flags
`--ghost=dent --take=attack --ppm=32|64 --view=...`), run through
`node tools/dev/run.mjs ghost_review.tscn --ghost=dent --take=attack ...` with `--fixed-fps 60` and
`--write-movie` if you need frames (see how the n19 films were made in
`C:\Users\kazda\kiro\gtai-masters\n19\ghosts\INDEX.md` and `tools/film/`). Save stills to
`C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a3\`:
1. before/after at the same tick, 64 px/m, tilt view: jab over the car;
2. strap taut while steering, 32 px/m, tilt and top view (and the n19 thin line at the same tick);
3. overload: heating (ring + amber strap) and the blast frame with spokes, tilt and top, 32 px/m.
Name the tick of each still. Do not claim a frame you did not look at.

## Tests and gates
- `test_dent_look.gd` (table loads, default strap, flag override), `test_dent_strap.gd` (geometry:
  endpoints at hand and roof, width in px at 32 px/m, slack timeline on ticks, amber lerp at heat
  0 / 0.5 / 1).
- `node tools/godot/check.mjs` on changed files; `node tools/lint/lint.mjs`;
  `node tools/tests/run_unit.mjs --changed`; the replay/scenario digests unmoved:
  `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` (or its `--only=` for the
  replay and Dent scenarios; name them); `node tools/gate/quick.mjs` before each commit.
- After the strap commit: `node tools/mutate/mutate.mjs --file=features/souls/dent_strap.gd --max=20`
  and quote killed/(killed+survived).

## Order and time
0 -> 2 -> 3 -> 4 -> 1 (the jab order last: it may need investigation). Commit after each. At 65 minutes
commit what is finished and stop with a report: files, commands and results, still paths with
ticks, and what is not done.
