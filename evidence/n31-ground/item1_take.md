# n31 item 1: the play take (Rivet on the floor in the owner's gauntlet)

Builder n31-05. Mode: gauntlet `--pick-view --bot=average --controls=wheel`, seed 7, ticks 0-2400, 1920x1080 60 fps, release-style
d3d12 take through `tools/ground/play_take.mjs`. Arms: `main ba8e470b0` (before) | `HEAD` (after: `72703154f` bob rule, `2f143d1e1`
shadow fade; game code of `8e5ec8d9d`/`d563b5c1a`). The sim is deterministic: both arms run the same route, so the same tick is the same moment.

## Running ticks (`tools/ground/running_ticks.py`, background phase correlation on the mp4, camera follows Rivet)
At 32 px/m, seed 7: E 342-478, NE 485-685 and 936-1075, S 702-773, NW 781-820, SE 828-924, N 1107-1126 (the only N run, 20 ticks),
E 1244-1610, SW 1623-1945, W 1962-2214, SE 2247-2291. Before and after list the same runs (the route does not change).
Windows crops were cut at: **E ticks 1280-1519** (E run), **N ticks 1060-1299** (N run is 1107-1126, in the middle), **W ticks 2030-2269** (W run).
The 600/1200/1800 stills of the earlier take stay identical because Rivet is standing there.

## Crops before | after (`tools/ground/take_crops.py`: 240 px box around Rivet x4 nearest at 32 px/m; 480 box x2 at 64 px/m)
Masters: `n31/ground/item1/pair_E_1330_32.png`, `pair_N_1114_32.png`, `pair_W_2080_32.png`, `pair_E_1330_64.png`, `pair_W_2080_64.png`;
4 s strips (240 frames, 60 fps) `strip_crops_E1280.mp4`, `strip_crops_N1060.mp4`, `strip_crops_W2030.mp4`, `strip_crops64_E1280.mp4`, `strip_crops64_W2030.mp4`.

Measure, in the delivered frames (both arms, same ticks, 1080p pixels; mask = Rivet's brown body, shadow = dark grey blob under it;
positive = HEAD lower on screen than main, which is less lift because the camera holds his ground position):

| window | frames | helmet top, HEAD minus main (mean / mean abs) | body bottom abs diff | frames with same helmet row |
|---|---|---|---|---|
| E 1280-1519, 32 px/m | 240 | +1.55 / 1.72 px | 2.08 px | 30 % |
| N 1060-1299, 32 px/m | 210 | +1.15 / 1.47 px | 1.86 px | 76 % |
| W 2030-2269, 32 px/m | 240 | +1.05 / 1.90 px | 1.41 px | 51 % |
| E 1280-1519, 64 px/m | 240 | +2.37 / 3.77 px | 3.48 px | 19 % |
| W 2030-2269, 64 px/m | 240 | +1.62 / 1.79 px | 2.22 px | 52 % |

Helmet-top travel over the 240-frame window is about the same in both arms (E 32: 20 px main, 19 px HEAD; W 64: 35 and 35): most of that
travel is the run-frame art itself (head lean per cell) and the camera, not the bob. What changed is the lift: HEAD sits about 1-2.4 px (1080p) lower
on average, up to ~5-7 px at the lift peaks, and the shadow stays under the sole. Shadow-centre minus helmet-top differs by under 0.5 px mean at 32 px/m
(the shadow follows the lifted sprite), so the gap shrinks by the body moving down, not the shadow moving up.
The segmentation is coarse (colour mask, camera smoothing, an enemy or a corpse in the box can pull the N window), so read the table as
"small, consistent, HEAD lower", not as a precise lift figure. The lab numbers (`lift_after.md`: sole lift 8 -> 1.0 px, gap 9.5 -> 2.5 px at 32 px/m) remain the precise ones.

Seen (crops E 1330 at 64 px/m and W 2080 at 64 px/m): in the HEAD frame Rivet is visibly lower on the street and the contact shadow sits right under
the planted foot (W 2080: shadow touching the boot); in the main frame he hangs higher with a gap to the shadow. In the E 1330 frame both arms
still show a mid-stride pose with the rear leg off the ground and a shadow centre ~10 px below the sole at 1080p: the stride art itself has a
leg in the air, the fix does not remove that, it only removes the whole-body hop.

## Films (masters `C:\Users\kazda\kiro\gtai-masters\n31\ground\item1\`)
- `gauntlet_side_32.mp4`, `gauntlet_side_64.mp4`: main | HEAD, centre 960x1080 of each take, labelled, ticks ~1230-2230 (E, SW, W runs), 1920x1080 60/1,
  16.68 s, 1001 frames, crf 28 (50 MB, 29 MB).
- `sprint_tour_p70_32.mp4`: the arsenal recorder `--weapon=hands --pitch=p70 --sprint-tour=on` (E, SE, S, SW, W, NW, N, NE, 90 ticks each), main | HEAD, centre 960x1080 of each 1920x1080 run, real speed (a frame every 2 ticks at 30 fps, then -r 60), played twice: 24.0 s, 1440 frames, 1920x1080 60/1.

## Sprint tour (item 4)
Harness: scratch `build/n31/n31-05/tour.mjs` (snapshots of ba8e470b0 and HEAD under `%TEMP%/gtai-film-*`, `--import` each, `res://dev/rivet_arsenal/arsenal_turn.gd -- --weapon=hands --pitch=p70 --ppm=32|64 --sprint-tour=on`).
PITFALL (cost two reruns): the ba8e470b0 snapshot is shared with `play_take.mjs`, which leaves an `override.cfg` (viewport 1920x1080) in it; a plain HEAD snapshot has none
(default viewport 1280x800). The first tour pair therefore drew Rivet and the ground ~1.3x larger on the HEAD side (orange body mask 1242 vs 2138 px, same at 64 px/m: 4916 vs 8884) and
was discarded; the delivered pair has the same `override.cfg` in both trees (mask 1242 vs 1165 px at clip frame 10). Any film of one arm from a play_take snapshot needs this check.
Result at 32 px/m, same ticks: stills `sprint_oct0..7` differ in 2581-3550 px of 119k each (Rivet's body and shadow), clip frames differing per octant (of 45): E 44, SE..NE 45 each: every octant changes, since
the bob rule acts on every run cell, not only some rows. Looked at: HEAD frames sit about a pixel or two lower with the shadow a little nearer the sole; the difference is subtle at 32 px/m.
64 px/m tour stills: see the report (not in the repo).

## Mutation (item 7)
Not run: the Godot lane mutex was busy with the tour renders until the deadline; no killed/(killed+survived) figure exists for `rig_cast_shadows.gd` or `rivet_bob.gd` from this call.

## What a player feels
At 32 px/m the change is small (about 1-2 px at 1080p on average): the hop that read as flying is gone and the shadow now sits under the foot, but the run
cells still show a foot in the air mid-stride, so it reads as "less floaty", not "planted"; at 64 px/m (zoomed) it is easy to see.
