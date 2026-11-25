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
