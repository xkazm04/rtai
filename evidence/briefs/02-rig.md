# Brief 02 (lane tonnage): wire the Press Golem body, its flight character and the attack poses

Tonnage becomes the Press Golem of the owner's plate `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`.
**Look at the plate first**, then at the art the previous session committed (`git log --oneline -10`):
`project/features/souls/art/tonnage/spectral/*.png` (top-view parts: back, upper_arm, forearm, fist, hoses) and
`project/features/souls/art/view/{p70,p55}/tonnage_spectral_{pose,act}.png` (4 columns x 5 facing rows: front,
front three-quarter, side facing right, back three-quarter, back; left facings mirrored). Pose sheet columns:
0 CARRY, 1 CRUISE, 2 ARMED, 3 RECOIL. Act sheet columns: 0 RAISE, 1 POUND, 2 LIFT, 3 CARRY. The cell size,
`fig_px` and baseline of each sheet are in the previous report: `C:\Users\kazda\kiro\gtai-n20\logs\tonnage\`
(the last `astra-*-body-art.last.txt`) and in `docs/art/prompts/n20/tonnage/`.

This is a VISUAL change only. Nothing in `powers.json`, `ghost_attacks.json`, the sim, hit boxes, timing, replay,
parity or bake may move. Tonnage keeps his size (the drawn height on screen stays the legacy `GhostDrawn` height:
`height_m` 3.3 at the same `size_k`). `GhostRecoil.LEAN_BY_FORM` values do not change.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`,
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time; windowed runs `--position 0,1440`; free your own processes by PID, never by name.

## Step 0: take the shared flight interface (committed at 0e7d91e46 on n20-flight)
Run `git merge --no-edit n20-flight` (allowed tonight: only that branch; merge again later if it moved). Read
`project/features/souls/README.md` section "Spectral look". The contract: `GhostLook.spectral(&"tonnage")` (flag
`--ghost-look=legacy|spectral`, else the row's `look` in `ghost_forms.json`). `GhostFormBodies.step_tonnage`
(`ghost_form_bodies.gd`) places the rig at the flight spot, feeds `speed_mps = 0` while `tonnage.drawn.hover`, and
mounts the body above `tonnage.drawn.flight` (a `GhostFlight`: `flight.hover.bank`, `.lean`, `.speed_mps`,
`.yaw_rate_dps`, `.lift_m`; the shared tail and the ground shadow are flight's, do not draw your own).

## Files you may touch
`project/features/souls/tonnage_*.gd`, `hauler_*.gd`, `ram_*.gd`, `slam_debris.gd`, `plate_sparks.gd`, new files
named `tonnage_*` (code, tests `project/tests/unit/test_tonnage_*.gd`), the Tonnage row of
`project/data/tables/ghost_hover.json` (only if flight committed it), and ONE line in
`project/features/souls/ghost_form_bodies.gd` `step_tonnage`: right after the `tonnage.speed_mps = (...)` statement add
`tonnage.hauler = p.hauler  # n20-tonnage: the spectral body reads the slam and ram state`. Nothing else in
any `ghost_*` file (flight owns them). If you need more from flight, write it in your report as `NEED flight: ...`.

## What to build

1. **`TonnagePose`** (`tonnage_pose.gd`, RefCounted, pure logic, stepped per sim tick on `SimClock.TICK_DT`, never a
   frame delta, no RNG). Inputs per tick: velocity (m/s vector, from `hauler.form.vel`), facing (rad),
   `hauler.form.windup_k()`, ticks since `hauler.stomp_tick` (-1 none), `hauler.ram_hits` (a rise = a ram contact),
   `hauler.form.ramming()`, hurt (ticks since Rivet's hurt tick, -1 none: read what `drawn.act_col()` and the
   existing feed give you). Outputs (metres in the body frame, x forward, y right, h = height above the road):
   torso offset + pitch, each fist's (x, y, h), the tilted-sheet cell (sheet pose|act, column), `armed_k` 0..1, and
   `lean_k` 0..1 (how much of `GhostRecoil`'s hit lean to apply). Character, from the owner's brief:
   - **Fists never read as legs.** CARRY: both fists level at chest height (h about 1.4 m), forward (x about 1.0 m),
     elbows out (y about +-0.8 m). They never alternate and never touch the road except in the slam's POUND.
   - **Weight without feet:** slow to start and slow to stop (the torso leads, critically damped follow of about
     10 ticks); the fists arrive late (their own follow, about 6 ticks behind the torso); a deep slow bob (the hover
     row's bob; the fists bob a few ticks behind the torso); CRUISE (speed above 1.5 m/s) tips the torso forward and
     lets the fists trail.
   - **Ram, armed:** while `ramming()` (speed above the data's `ram_mps`, 3 m/s) blend into ARMED over 4 ticks: the
     right fist tucks in front of the chest as a bumper (x about 1.2, y about +0.25, h about 1.1), the left pulls
     back beside the body. On a ram contact (`ram_hits` rises) that fist punches through: out 0.6 m over 4 ticks,
     back over 10. `lean_k` is 0 while `armed_k` > 0.5 (the hit lean must not fight the charge).
   - **Slam:** RAISE through the wind-up (`windup_k` 0..1): both fists rise to h about 2.6 and spread to y +-1.5.
     POUND on the stomp tick (the existing `CUT_TICKS` 5): both fists land TOGETHER on the road in front, side by side
     with a gap: their centres at the slam point (it is `press_ahead_m` ahead of Rivet; use the same value the sim
     uses, read from data) plus 0.3 m forward, y +-0.7, h 0; the torso hunches forward but stays behind the slam point.
     LIFT for `FOLLOW_TICKS` 10: the fists rise halfway, then ease back to CARRY over about 20 ticks.
   - **Hit:** RECOIL cell for the existing `HIT_TICKS`; `lean_k` 1 (keep the legacy 4 deg lean) unless armed.

2. **`TonnageSpectral`** (`tonnage_spectral.gd`, Node2D, render only): the body. `TonnageRig` makes it when
   `GhostLook.spectral(&"tonnage")` and then hides every legacy part, the legacy `drawn` sprite and the card; legacy
   look = not a single legacy frame changes. It owns one `TonnagePose`, steps it in `TonnageRig.advance` (ticks from
   dt, as today), and draws:
   - **Top view** (`ViewMode.shared().is_flat()`): the cut-out parts. Back centred on the torso offset, hoses on the
     back, each arm as two bones from the shoulder (y +-0.95 at the back's front corners) to the fist with the elbow
     bent OUTWARD (simple two-bone IK, elbow on the outside), fists drawn last. Height reads as scale (a part at h
     grows by about 6% per metre, as the old foot lift did) and as the ground shadow's distance. Widths in metres
     from the plate (back about 2.3 m wide, fist about 0.95 m, arms about 0.42 m thick).
   - **Tilted views (p70/p55):** one sprite showing the pose/act sheet cell for the octant (reuse `GhostSheet` and
     `GhostDrawn.octant`-style octant hold; mirrored left facings), scaled exactly like `GhostDrawn.step` scales the
     legacy cell (same on-screen height), plus the pose's torso offset as a small screen shift (height via
     `ViewMode.shared().lift_k()`), a small bank from `drawn.flight.hover.bank`, and the hit lean
     `GhostRecoil.tilt(...) * lean_k`.
   - **Fist shadows:** two dark soft ellipses ON THE ROAD under each fist (squashed by `ground_k()` in tilts), darker
     and tighter as the fist comes down; through RAISE they mark exactly where the fists will land.
   - Translucency: the body sprites at about 0.88 alpha with an additive teal rim/glow (reuse `GhostRim.soft_glow`
     as the old rig does); during POUND and LIFT the torso and arms drop to about 0.55 alpha so the victims and the
     wrecked car under them stay visible from above.

3. **Slam and ram effects under spectral** (`tonnage_view.gd`, `hauler_marks.gd`, `ram_wake.gd`; legacy unchanged):
   - Wind-up: no filled disk and no ink wash. A THIN soul-teal ring (2 px) at `stomp_radius_m` (4 m) that draws on
     over the wind-up, plus the two fist landing marks (the shadows above). No die-plate square.
   - Landing: the shock ring thin (start 3 px, not 9), teal edge kept; the crack and debris as today; the cream
     landing flash may stay but must not cover the 2 m crush zone for more than 4 ticks.
   - Ram: the bow wave may stay thinner; the armed fist is the read.

4. **The film hooks:** make sure `project/dev/ghost-powers/ghost_review.tscn` with `--ghost=tonnage
   --ghost-look=spectral` shows the new body (flight owns the driver; if it does not pass the flag through, write
   `NEED flight:` and test with whatever override you have).

## Tests (GUT, `project/tests/unit/test_tonnage_pose.gd`)
- CARRY fists at h >= 1.0 and never alternate (left and right h equal at rest and in cruise at every tick).
- No fist reaches h < 0.2 except during POUND.
- `armed_k` reaches 1 within 6 ticks of `ramming()` turning true, and `lean_k` is 0 while armed.
- POUND fists are ahead of the slam point's x and the torso is behind it.
- Stepping 3 ticks at once equals 3 single ticks.
Run `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, and
`node tools/godot/check.mjs` on every new `.gd`. Lint: files about 200 lines (hard 300), functions <= 40 lines,
<= 5 parameters, typed, `Log` not `print`, commit `.uid` files.

## Proof you produce (look at every frame yourself)
Render stills with the review driver (`--ghost=tonnage --ghost-look=spectral`, `--ppm=32` and `--ppm=64`, both the
70 deg tilt and the top view) into `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\scratch\`: rest, cruise, armed just
before a contact, RAISE, the POUND frame, LIFT, and the same tick with `--ghost-look=legacy`. Report their paths.

## Commits
One per step (pose logic + tests; body; effects), staged per path, imperative one-line messages. No stash, no
`add -A`, no reset --hard, never push. Report: files, commits, test results, still paths, anything not done.

## Numbers from the art session (commits c988ab26c..16c5ce2d2)
Tilted sheets: cells 384x320, 4 columns x 5 rows, every figure bottom-anchored at cell y = 315 (zero-based last
visible row). fig_px (median figure height, cell px): p70 pose 215.5, p70 act 221.5, p55 pose 216, p55 act 225.5.
Use ONE fig_px per tilt for both sheets (the pose sheet's) so a pose switch does not pop the scale. The act sheet's
last column (CARRY) is byte-identical to the pose sheet's column 0. Top-view parts are individual trims in
`art/tonnage/spectral/` (back 473x321, upper_arm 462x226, forearm 466x162, fist 286x373, hoses 337x321; body parts face
DOWN the page, limbs lie left-to-right with the shoulder/elbow joint at the left end). The anchor of a tilted cell is
the figure's bottom-centre at y 315: under the flight interface that point sits at the body's lifted spot, not on the
road (the shadow and tail are flight's).
