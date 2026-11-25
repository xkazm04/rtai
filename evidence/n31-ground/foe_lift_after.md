# Foe lift after (n31-06, 32 px/m, tilt 70): card foes share one contact shadow

Change: commit `33192b087` (`project/features/characters/card_contact_shadow.gd`, wired into
`foe_gunner_card_view.gd`, `foe_thug_card_view.gd`, `foe_turret_card_view.gd`, `foe_shield_card_view.gd`).
The shadow is a child of the card drawn behind it, placed on the fighter's ground point (sim position,
card parent px) through the inverse card transform, so the card's bounce and placement steps do not move it.
Radius = 0.16 x drawn cell width (cell px x |scale.x|), floored at the patrol contact under a 0.8 m hip
(12.8 px at 32 px/m). War machine untouched (its own shadow, gap 3 px, kept).

Method: same as `foe_lift_before.md` (probe `project/dev/ground_n31/foe_lift_probe.tscn`, `node
tools/ground/lift/foes_capture.mjs --ppm=32 --subjects=robot_gunner,robot_thug,sentry_turret,shield_robot`,
one Godot process, then `python -I tools/ground/lift/foes.py --run 32=<dir>`), tree = HEAD `33192b087`
plus n31-05's uncommitted Rivet files (enemies do not use them). Frames in `build/n31/n31-06/after32/` (not
committed). JSON: `foe_lift_after.json` (`gtai.ground-foe-lift/1`, 32 rows: the four changed kinds). Before
columns are the rows of `foe_lift_before.json`. Cops, SWAT, riot, contractor, lancer are `CutRig`s served by
`RigCastShadows` and were not changed or re-captured.

## Read

- **Gunner: fixed where the drawn sole is at the ground point.** Facing S the shadow no longer rides the card:
  shadow y range 22 -> 1.0 px, corr shadow/head 0.999 -> 0.28, gap planted max 1.5 -> 1.0 px (SE/SW 2.0 -> 1.0,
  y range 13 -> 1.0, corr 0.98 -> 0.10). Gap ALL max S 2.5 -> 25 px, SE/SW 2.0 -> 10.5 px comes from ONE frame
  per facing: the gunner's body top per captured tick (after32, S: 111 then 136-137 for the other 39 ticks;
  SE/SW 123 then 137-138; N 160 then 133-134) shows the whole card 14-26 px off in the first captured tick of
  each facing and steady within 1 px after it. So the gunner's "head travel 26 px" in both tables is that one
  frame, not a stride bounce: the probe moves the foe to the next facing's start line and the card placement
  takes one tick to catch up (a teleport; probe-only as far as I can tell, not checked in play). Before, the
  shadow rode that jump (corr 0.999); now it stays on the ground and the jump shows as a gap for one tick.
- **Gunner NW/NE: registration offset 19 px.** The walk-away cells draw the soles 19 px BELOW the ground point
  (sole lift planted -19.2 px), so the shadow at the ground point sits 21 px above the feet (gap planted
  1.0 -> 21 px). N is 2.5 px (partial: the body covers it). Anchors not moved (brief).
- **Thug: unchanged gaps, registration offset.** Placement was already the ground point; gaps are as before
  (SE/SW 14.5 px, S 12 px, E/W 6 px) because the drawn sole is 7-14.5 px BELOW the ground point in those
  facings (sole lift planted -7 / -11.3 / -14.5 px). NW/N/NE 1.0-2.5 px. Shadow y range <= 2.5 px, |corr| <= 0.77
  (E/W -0.77 with a 2 px range and 4 px head travel: noise-level). Radius 16 -> ~17 px (rx 12-16.5 measured).
- **Turret and door carrier: shadow drawn, measured none.** Both now draw the contact shadow at the ground
  point, but the drawn body covers it there: the turret's plate bottom is 25 px below its ground point (sole
  lift planted -25 px) and the door carrier's sole 8 px below (-8.0 to -8.3 px). The measure finds no shadow
  pixels outside the body (door NW/NE: partial). Registration offsets, anchors not moved; the shadow becomes
  visible only once their drawn sole is registered to the ground point (next call).
- **War machine**: not changed (before: gap planted max 3 px, y range <= 2 px).

Bars: shadow present on every walking kind and the turret: MET for gunner and thug (yes in 15 of 16 rows,
gunner N partial); NOT MET as measured for turret and door carrier (drawn, covered). Gap planted max <= 3 px
where the drawn sole is at the ground point: MET (gunner E/SE/S/SW/W/N 1.0-2.5 px, thug NW/N/NE 1.0-2.5 px).
Shadow y range < 3 px with corr ~0: MET for gunner (1.0-2.5 px, |corr| <= 0.53 where it moves at all) and thug.

## Before | after (32 px/m; px are screen px)

| kind | dir | sole lift planted px | head travel px | shadow | gap planted max | gap planted mean | gap all max | shadow y range | corr shadow/head | shadow rx |
|---|---|---|---|---|---|---|---|---|---|---|
| gunner | E | 0.0 | 0 | yes / yes | 2.5 / 2.5 | 2.5 / 2.44 | 2.5 / 2.5 | 0.0 / 2.5 | - / - | 10.1 / 10.2 |
| gunner | SE | -0.4 | 15 | yes / yes | 2.0 / 1.0 | 1.46 / 0.44 | 2.0 / 10.5 | 13.0 / 1.0 | 0.978 / 0.100 | 8.9 / 12.1 |
| gunner | S | -0.3 | 26 | yes / yes | 1.5 / 1.0 | 0.71 / 0.28 | 2.5 / 25.0 | 22.0 / 1.0 | 0.999 / 0.276 | 12.2 / 12.0 |
| gunner | SW | -0.4 | 15 | yes / yes | 2.0 / 1.0 | 1.46 / 0.44 | 2.0 / 10.5 | 13.0 / 1.0 | 0.978 / 0.100 | 8.9 / 12.1 |
| gunner | W | 0.0 | 0 | yes / yes | 2.5 / 2.5 | 2.5 / 2.44 | 2.5 / 2.5 | 0.0 / 2.5 | - / - | 10.1 / 10.2 |
| gunner | NW | -19.2 | 20 | yes / yes | 1.0 / 21.0 | 1.0 / 21.0 | 1.0 / 21.0 | 21.0 / 2.5 | 0.995 / -0.525 | 11.6 / 10.4 |
| gunner | N | -26.1 | 27 | yes / partial | 2.5 / 2.5 | 2.5 / 2.5 | 2.5 / 2.5 | 26.0 / 1.0 | 0.995 / 0.527 | 10.0 / 9.6 |
| gunner | NE | -19.2 | 20 | yes / yes | 1.0 / 21.0 | 1.0 / 21.0 | 1.0 / 21.0 | 21.0 / 2.5 | 0.995 / -0.525 | 11.6 / 10.4 |
| thug | E | -7.0 | 4 | yes / yes | 6.0 / 6.0 | 6.0 / 6.0 | 6.0 / 6.0 | 2.0 / 2.0 | -0.733 / -0.771 | 13.8 / 15.0 |
| thug | SE | -14.5 | 2 | yes / yes | 14.0 / 14.5 | 13.11 / 13.14 | 14.0 / 14.5 | 2.5 / 2.5 | 0.326 / 0.238 | 13.3 / 13.9 |
| thug | S | -11.3 | 6 | yes / yes | 11.0 / 12.0 | 10.71 / 11.26 | 11.0 / 12.0 | 1.0 / 1.5 | -0.101 / -0.234 | 11.6 / 12.4 |
| thug | SW | -14.5 | 2 | yes / yes | 14.0 / 14.5 | 13.11 / 13.14 | 14.0 / 14.5 | 2.5 / 2.5 | 0.326 / 0.238 | 13.3 / 13.9 |
| thug | W | -7.0 | 4 | yes / yes | 6.0 / 6.0 | 6.0 / 6.0 | 6.0 / 6.0 | 2.0 / 2.0 | -0.733 / -0.771 | 13.8 / 15.0 |
| thug | NW | -0.4 | 5 | yes / yes | 1.0 / 1.0 | 0.36 / 0.40 | 1.0 / 1.0 | 1.0 / 1.0 | 0.404 / 0.129 | 15.4 / 16.5 |
| thug | N | -0.4 | 4 | yes / yes | 2.5 / 2.5 | 2.42 / 2.38 | 2.5 / 2.5 | 1.0 / 1.0 | 0.643 / 0.620 | 13.5 / 14.9 |
| thug | NE | -0.4 | 5 | yes / yes | 1.0 / 1.0 | 0.36 / 0.40 | 1.0 / 1.0 | 1.0 / 1.0 | 0.404 / 0.129 | 15.4 / 16.5 |
| turret | all 8 | -25.0 | 0 | none / none (drawn, covered by the plate) | - | - | - | - | - | - |
| door carrier | E, W | -8.0 | 0 | partial / partial (false positive, see before) | 14.5 / 14.5 | 11.76 / 11.73 | 14.5 / 14.5 | 4.0 / 4.0 | - / - | 23.5 / 23.5 |
| door carrier | SE, S, SW, N | -8.1 to -8.3 | 1 | none / none (drawn, covered) | - | - | - | - | - | - |
| door carrier | NW, NE | -8.3 | 1 | none / partial | - | - | - | - | - | - |

(sole lift planted and head travel are the after rows; they match the before rows within 1 px since the
drawing did not change.)

## Cop bounce in play

From the real gauntlet take `build/n31/n31-02/s7_32/take.mp4` (main `ba8e470b0`, 32 px/m, seed 7), frames
324-372 (= ticks; the take duplicates each drawn frame in pairs at places, e.g. 335/336): one patrol cop of the
lowest file of the first wave, walking W (aim walk, the facing the probe calls E/W), followed by a blue-cap
tracker and checked by eye on an x4 nearest strip (`build/n31/n31-06/p3_cop_x4.png`, yellow line y 616, red y 624).
Two strides: the cap dips at 337-340 and again at 357-362 (period about 22 ticks).
- By eye: head top between y 616 and 624: **8 px** of travel (25 cm) over two strides. Camera has no vertical
  motion in that window (the road dashes stay on one row).
- Tracker: 11 px raw (616-627), the 627 being two frames (357/358) where the eye puts the cap top at ~620-622;
  without them 8 px.
- So the probe's **patrol walk E/W 8 px holds in play**. The probe's **22-24 px run (S/N)** is NOT verified
  here: no cop in this window runs toward or away from the camera (the wave walks in along the road, W). The
  "whole cop translated ~23 px between two ticks" was not seen in this cop. It may be the same first-tick-of-a-
  facing jump the gunner shows in the probe (see above); I did not re-check the cop frames for it. Seen in passing: in the take the
  cops' contact shadows sit right of and below the feet (about 20-30 px at x1 in `p3_sheet.png`, frames
  300-345), which may be what reads as "flying" in play; not measured.

## Stills (64 px/m, x2)

`C:\Users\kazda\kiro\gtai-masters\n31\ground\item2\n31-06_gunner_thug_64ppm_before_after_t000.png` and
`..._t006.png`: gunner and thug facing S, before (snapshot worktree of `ba8e470b0` plus the probe files) |
after (this tree), crop x2, labelled. t006 (mid-walk): the gunner's and the thug's feet sit on the shadow in
both; after, the gunner's shadow is the same size, the thug's a little larger. t000 (the first tick after the
probe's facing switch, see the gunner note): before, the shadow rides the jumped card under its feet; after,
the card is drawn ~25 px (64 px/m) above a shadow that stays on the ground, so the gunner floats for that tick.

## Head pump (n31-10): the side-view toe-off registration

Probe (placement only, no render): `foe_place_probe.gd --strip=<p70 sheet> --mps=<m/s> --stances=8` now logs
`head` = the cell's alpha bbox top (topmost opaque row, bbox centre column) through the placed transform.
Head travel = max - min of head y minus ground point y per full stride, strides 2-4, 32 px/m, texel 0.3173.

The term: on every walk sheet the drawn head top is steady in the cell (patrol side column -167 cell px in all
8 drawings, riot -168..-170, SWAT -162..-163) and some boot always touches the foot line (cell alpha bottom
-2..+2), but on the toe-off drawings (3 and 7, some 2/4) the anchor's sole is the LIFTING planted heel, 15-46
cell px above the foot line (patrol side -45.5 and -32.5, riot side -15.5). `_ground` registered that heel to
the ground, so the whole drawing (head and the other, standing boot) dropped by the lift (14 / 10 px): the cap
dip of the W walkers in play. Not pose roll/stretch/settle (the sole column is constant to 0.4 px).

Fix: `StreetPatrolPose.HOLD_TOE_OFF` (true; false = the old registration): on the side column (`SIDE_COLUMN` 2)
of a walk (not a run: lifted run marks are the flight, and match the alpha bottom), a mark higher than
`TOE_OFF_PX` 13 cell px registers on the foot line. Applied on every column it made S worse (patrol walk S 9.4
-> 15.9, SE 9.8 -> 11.5, riot SE 9.2 -> 14.7): there the screen vertical is also the travel and the drop
stands in for the step forward the drawing lacks, so those columns keep it.

Probe, head travel per stride px (strides 2 / 3 / 4), before | after:

| kind | W, E | S | N | SE | NE |
|---|---|---|---|---|---|
| patrol walk 3.2 | 8.1 / 7.6 / 7.9 -> 0.6 / 0.5 / 0.6 | 9.0-12.2 (same) | 15.5-18.5 (same) | 9.3-10.1 (same) | 10.7-12.4 (same) |
| patrol run 6.0 | 5.0-5.3 (same) | 22-26 | 24-28 | 15-19 | 16-18 |
| riot walk 2.8 | 5.2 / 5.4 / 4.9 -> 1.8 / 1.7 / 1.9 | 21-30 (same) | 20-28 (same) | 9-12 (same) | 15 (same) |
| SWAT walk 3.4 | 1.1-1.2 (same) | 22-36 (same) | 23-35 (same) | 11-12 (same) | 16-18 (same) |
| SWAT run 6.0 | 2.9-3.0 (same) | 28-36 | 28-36 | 16-22 | 21-25 |

Bars (32 px/m, walk <= 4 px, run <= 7 px): MET side-on (the facing the gauntlet waves walk in): patrol walk
0.6, riot 1.8, SWAT 1.2, patrol run 5.0, SWAT run 3.0 (probe). NOT MET toward/away and three-quarter (9-36 px):
that is the drawing, not a placement term I can damp with the feet on the floor. Those columns draw no forward
progression in the cell (head top and both soles at one cell height through the stance), so with the planted
boot locked to the ground the whole figure holds for a stance while the ground point runs a stance (22.6 px patrol
walk, 31 px SWAT walk) and then steps: the head line can only run steady if the boots slide a stance (the old
four-drawing look) or the legs stretch ~60 % (MAX_STRETCH is 0.12). Sole slide: unchanged (sole column of the
held drawing constant to 0.4 px; the side-view sole-y range 0.4 -> 9.1 px is the toe-off heel now drawn lifted).
Unit: `test_side_walk_torso_holds_its_line_within_four_screen_pixels` (patrol, riot, SWAT side walk, torso mark
travel <= 4 px over strides 2-3; 8.28 px with the old constant), and
`test_registered_soles_hold_through_drawings_and_wrap_in_both_pitches` now expects the toe-off heel at its lift.

### Rendered before | after (foes_capture --ppm=32 + foes.py)

`node tools/ground/lift/foes_capture.mjs --ppm=32 --subjects=patrol_cop,riot_cop,swat --out=build/n31/n31-10/after32`
then `python -I tools/ground/lift/foes.py --run 32=build/n31/n31-10/after32 --json ... --md ...` (40 rows, 1600
frames; 40 captured ticks per facing, the before had 48). JSON: `foe_lift_after_n31-10.json`. Before = the rows of
`foe_lift_before.md` (main `ba8e470b0`); after = this tree (n31-09 `fe5712271` mid-stance landing + n31-10
`e3393e180` N stance shift + HOLD_TOE_OFF), so the sole/gap columns also carry n31-09's half-stance landing.

| kind | gait | dir | head travel px | sole lift planted px | sole lift max px | gap planted max | gap all max |
|---|---|---|---|---|---|---|---|
| patrol_cop | run | E | 5.0 / 5.0 | -2.56 / -2.43 | 3.0 / 3.0 | 2.5 / 2.5 | 4.0 / 4.0 |
| patrol_cop | run | N | 24.0 / 22.0 | -37.92 / -12.67 | -4.12 / 20.07 | 25.0 / 12.0 | 25.0 / 21.0 |
| patrol_cop | run | NE | 16.0 / 16.0 | -25.25 / -8.75 | -1.15 / 14.26 | 25.0 / 8.0 | 25.0 / 15.0 |
| patrol_cop | run | NW | 16.0 / 16.0 | -25.25 / -8.75 | -1.15 / 14.26 | 25.0 / 8.5 | 25.0 / 15.0 |
| patrol_cop | run | S | 22.0 / 22.0 | 1.34 / -23.07 | 34.98 / 10.01 | 3.0 / 12.5 | 36.0 / 12.5 |
| patrol_cop | run | SE | 15.0 / 14.0 | -1.46 / -17.75 | 22.62 / 5.13 | 2.5 / 16.5 | 23.5 / 16.5 |
| patrol_cop | run | SW | 15.0 / 14.0 | -1.46 / -17.75 | 22.62 / 5.13 | 1.0 / 16.5 | 23.5 / 16.5 |
| patrol_cop | run | W | 5.0 / 5.0 | -2.56 / -6.0 | 3.0 / 3.0 | 2.5 / 4.0 | 4.0 / 4.0 |
| patrol_cop | walk | E | 8.0 / 1.0 | -7.6 / 0.0 | 0.0 / 0.0 | 9.5 / 2.5 | 9.5 / 2.5 |
| patrol_cop | walk | N | 21.0 / 15.0 | -33.88 / -9.93 | -9.13 / 9.76 | 22.0 / 9.0 | 22.0 / 11.0 |
| patrol_cop | walk | NE | 11.0 / 10.0 | -8.87 / -1.76 | 4.01 / 12.47 | 8.0 / 1.5 | 8.0 / 13.5 |
| patrol_cop | walk | NW | 11.0 / 10.0 | -8.87 / -1.76 | 4.01 / 12.47 | 8.0 / 1.5 | 8.0 / 13.0 |
| patrol_cop | walk | S | 10.0 / 9.0 | 0.06 / -10.24 | 14.72 / 4.13 | 2.0 / 6.5 | 15.5 / 6.5 |
| patrol_cop | walk | SE | 10.0 / 9.0 | -3.33 / -10.54 | 11.05 / 3.59 | 1.5 / 10.0 | 12.0 / 10.0 |
| patrol_cop | walk | SW | 10.0 / 9.0 | -3.33 / -10.54 | 11.05 / 3.59 | 1.5 / 9.5 | 12.0 / 9.5 |
| patrol_cop | walk | W | 8.0 / 1.0 | -7.6 / 0.0 | 0.0 / 0.0 | 8.0 / 2.5 | 8.5 / 2.5 |
| riot_cop | walk | E | 5.0 / 1.0 | -5.0 / 0.0 | 0.0 / 0.0 | 2.0 / 2.5 | 2.5 / 2.5 |
| riot_cop | walk | N | 20.0 / 19.0 | -31.96 / -12.93 | -6.72 / 12.66 | 13.0 / 9.5 | 13.0 / 13.5 |
| riot_cop | walk | NE | 17.0 / 15.0 | -22.4 / -9.91 | -0.18 / 8.85 | 20.5 / 8.5 | 20.5 / 10.0 |
| riot_cop | walk | NW | 15.0 / 14.0 | -23.4 / -8.94 | -3.18 / 8.85 | 18.5 / 7.5 | 18.5 / 10.0 |
| riot_cop | walk | S | 23.0 / 20.0 | -4.28 / -12.75 | 26.65 / 13.26 | 3.5 / 5.5 | 27.5 / 14.0 |
| riot_cop | walk | SE | 8.0 / 9.0 | -8.97 / -8.84 | 3.93 / 3.9 | 7.5 / 8.5 | 7.5 / 8.5 |
| riot_cop | walk | SW | 8.0 / 9.0 | -8.97 / -8.84 | 3.93 / 3.9 | 8.0 / 8.5 | 8.0 / 8.5 |
| riot_cop | walk | W | 5.0 / 1.0 | -5.0 / 0.0 | 0.0 / 0.0 | 2.0 / 2.5 | 2.5 / 2.5 |
| swat | run | E | 3.0 / 3.0 | 0.0 / 0.0 | 4.0 / 4.0 | 2.5 / 2.5 | 5.0 / 5.0 |
| swat | run | N | 27.0 / 27.0 | -38.6 / -14.94 | 1.06 / 28.03 | 38.5 / 14.0 | 38.5 / 29.0 |
| swat | run | NE | 19.0 / 20.0 | -22.83 / -9.5 | 5.01 / 20.11 | 22.0 / 8.5 | 22.0 / 21.0 |
| swat | run | NW | 19.0 / 19.0 | -28.01 / -9.5 | 0.61 / 20.11 | 27.5 / 10.0 | 27.5 / 21.0 |
| swat | run | S | 27.0 / 28.0 | -15.06 / -27.96 | 25.17 / 13.94 | 13.5 / 11.0 | 26.0 / 15.0 |
| swat | run | SE | 16.0 / 17.0 | -8.31 / -19.81 | 21.36 / 8.86 | 6.5 / 12.5 | 22.5 / 12.5 |
| swat | run | SW | 15.0 / 16.0 | -16.01 / -19.81 | 12.03 / 8.86 | 13.0 / 19.5 | 13.0 / 19.5 |
| swat | run | W | 13.0 / 12.0 | -12.0 / -12.0 | -1.0 / 4.0 | 10.5 / 7.0 | 10.5 / 7.0 |
| swat | walk | E | 1.0 / 1.0 | -0.08 / -0.1 | 0.0 / 0.0 | 2.5 / 2.5 | 2.5 / 2.5 |
| swat | walk | N | 21.0 / 21.0 | -34.71 / -14.06 | -6.9 / 14.26 | 7.5 / 10.0 | 7.5 / 15.0 |
| swat | walk | NE | 20.0 / 15.0 | -24.11 / -10.99 | -1.95 / 8.23 | 24.5 / 9.0 | 24.5 / 9.0 |
| swat | walk | NW | 20.0 / 15.0 | -24.11 / -10.99 | -1.95 / 8.23 | 23.5 / 9.0 | 23.5 / 9.5 |
| swat | walk | S | 21.0 / 21.0 | -0.74 / -14.24 | 27.22 / 14.07 | 1.0 / 4.5 | 28.0 / 15.0 |
| swat | walk | SE | 11.0 / 11.0 | -10.01 / -9.67 | 4.93 / 4.75 | 8.5 / 8.5 | 8.5 / 8.5 |
| swat | walk | SW | 11.0 / 11.0 | -10.01 / -9.67 | 4.93 / 4.75 | 9.0 / 8.5 | 9.0 / 8.5 |
| swat | walk | W | 1.0 / 1.0 | -0.08 / -0.1 | 0.0 / 0.0 | 2.5 / 2.5 | 2.5 / 2.5 |

Read: side-on walks now hold the head line in the frames too (patrol W/E 8 -> 1 px, riot 5 -> 1 px, SWAT 1 px);
patrol run W/E 5 px (bar 7: met), SWAT run E 3 px, W 12 px (13 before; the probe gives 3.0 for both, so the W
render row is another term: not found in this call). Toward/away and diagonal rows 9-28 px, essentially as before
(the drawing; see above).

### Gauntlet crop (n31-10, part 3)

`node tools/ground/play_take.mjs --rev=HEAD --seed=7 --ticks=420 --from=0 --ppm=32 --out=build/n31/n31-10/after_s7`
(HEAD `258f6f6ef`, 1920x1080 60 fps 420 frames by ffprobe), then `python tools/ground/take_crops.py
--a=build/n31/n31-02/s7_32/take.mp4 --b=build/n31/n31-10/after_s7/take.mp4 --from=300 --count=46 --box=1270,510,240
--scale=4` -> `build/n31/n31-10/cop_crop/pair_*.png`, stills `build/n31/n31-10/cop_crop_{300,312,324,336}.png`,
strips `cop_crop_{head,main}_330_345.png` (not committed). Look: on HEAD the wave-1 cops' disc sits under the boots in
most frames, where main has it right of and below them. At tick 336 it still trails the lowest cop by about 20 px.
By eye the cap shows no stride dip on HEAD (main: 8 px). Not measured: a quick
blue-cap tracker jumps between cops (ranges 104 / 68 px are tracking noise), so no number is claimed. (take_crops'
`measure.json` is Rivet's orange mask and does not apply to cops.)
