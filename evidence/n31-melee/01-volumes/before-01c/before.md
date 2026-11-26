# n31 melee 01c - blade volume from PIXELS, before (game code of ba8e470b0)

Command (the before): a temp worktree at `ba8e470b0` (`git worktree add --detach %TEMP%\gtai-melee-01c-base ba8e470b0`)
with the probe files copied in (`project/dev/melee_n31/blade_pixels.{gd,tscn}`, `blade_tap.gd`), then
`node tools/melee/blade_volume.mjs --label=before --tree=<that worktree>` from this checkout. The worktree was removed after.
After on HEAD (next call, with or without `--melee-sweep`): `node tools/melee/blade_volume.mjs --label=after`
(renders from this checkout; the hit side still comes from `--hits`, default `before-model/`, so an after that changes
hit rules must re-run 01a's hit side first: `node tools/melee/blade_volume.mjs --model --label=after-model`, then
`--hits=evidence/n31-melee/01-volumes/after-model`).

Files: `before/table.md`, `before/volumes.json` (`gtai.blade-volumes/2`, source pixels), `before/<weapon>.json`
(every ring cell and mover re-judged, per-tick drawn polar), `before/drawn_ticks.json` (for item 02),
`before/<weapon>.png` + `before/sheet.png` (left to right: hands, chainsaw, electro_baton, katana, plasma_sword),
`overlay_pixels_<weapon>.png`. 01a's model version (failed overlay) is in `before-model/`.

## How it is measured

- Render: one windowed d3d12 Godot per weapon (`--position 0,1440`, 1920x1080, `--fixed-fps 60`, `--ppm=64`, view
  `combo` = tilt 70, `--clean`, `--cam-lock=5,-38` on Rivet's start so the floor is the same pixels every frame).
  Every other body's rig is hidden every frame (an empty arena). Per facing (0, 90, 315 deg) it keeps a 560x570 crop
  around Rivet: `bg` (Rivet's rig + held view hidden, k -3), `idle` (k -1) and every tick k 0..56 of one swing.
- Mask (isolation choice): tick k vs the IDLE frame, |dR|+|dG|+|dB| > 60, minus Rivet's idle body (idle vs bg,
  dilated 6 px: his body, idle-held weapon and shadow), minus pure darkening (a cast shadow), minus ticks with < 12 px.
  Kept: blade, swipe crescent, smear AND any part of Rivet's body that moves outside his idle silhouette (the
  strike arm, the katana/plasma lunge). Ticks are kept only inside the swing's on-screen window (01a's views:
  blade/crescent shown or strip swing, k 0..12 claw, 0..19 baton, 0..25 katana, 0..31 plasma, 0..48 saw).
- Screen to ground: the held view's own world-to-screen transform (camera zoom x 2, y 2 sin70), inverted, then
  minus `ShotLift.up_m()` (0, -0.364 m): ASSUMPTION every mask pixel is at gun height (GUN_H_M 1 m), as the game
  draws Rivet's gun and tracer. Pixels of the body lower than that land slightly farther down-screen (+y) than true.
- Drawn cell = any mask point (every 2nd px) within the dummy's body radius 0.45 m of the cell centre, union over
  ticks (facing 0). Hit side = 01a's (headless ring + movers, same seed, game code identical to ba8e470b0: only
  dev/test paths changed between them).

| weapon | drawn-no-hit /60 | of them drawn after the test | hit-not-drawn /60 | both | hit test k | cut k (clip) | drawn mask k | overlaps drawn k | mover hit / drawn / drawn-no-hit (of 14) |
|---|---|---|---|---|---|---|---|---|---|
| hands (claw) | 13 | 11 | 0 | 8 | 4 | 1..6 | 0..12 | 0..12 | 12 / 13 / 1 |
| chainsaw (chainsaw) | 27 | 23 | 0 | 6 | 11, 22, 30 | 8..15 | 0..48 | 0..48 | 11 / 14 / 3 |
| electro_baton (electro_baton) | 21 | 19 | 0 | 7 | 3 | 0..5 | 0..19 | 0..19 | 13 / 13 / 1 |
| katana (katana) | 19 | 13 | 3 | 13 | 6 | 3..9 | 0..25 | 0..25 | 14 / 14 / 0 |
| plasma_sword (plasma_sword) | 19 | 15 | 10 | 15 | 7 | 4..13 | 0..31 | 0..31 | 14 / 13 / 0 |

Drawn reach at the hit-test tick, facing 0 (bulk of the mask, `deg_p5_p95` off the aim / `reach_p95`):
claw -60..31 deg / 1.66 m; saw -58..27 / 2.41 m; baton -134..38 / 2.15 m; katana -58..32 / 3.16 m;
plasma -58..43 / 2.53 m. Per tick and for facings 90 and 315: `before/drawn_ticks.json`.

## What the overlay frames show (looked at, k = hit test + 1, facing 0)

Magenta = mask outline, dim = idle body mask edge, cyan = each mask point dropped from gun height to the floor,
yellow cross = Rivet's ground point.
- `overlay_pixels_electro_baton.png`: the magenta outline sits ON the drawn baton (out to the right, its sparking
  tip) and on the white swipe crescent under it; it also rings his head/claw arm, which moved out of the idle pose.
  01a's model line (down-right from the chest) is gone: the pixels say the baton is across his front to the right.
- `overlay_pixels_katana.png`: the outline follows the long pink/white smear arc in front of him and the blade, plus
  his lunged head and arm. Cyan footprint lies on the floor under the arc, 2-3.5 m out.
- `overlay_pixels_hands.png`: the outline sits on the claw and the short swipe slash in front of his right hip;
  01a's "small arc at his feet" is not what is drawn: the drawn claw swipe is to his front-right at hip height.

## Read before using the numbers

1. The drawn side now includes Rivet's own moving body outside his idle silhouette (the strike arm, the lunge):
   it is what is drawn, but the 0.8 m ring cells around him are partly "drawn" by his torso, not the blade.
2. Stray arena motion leaks in: a blob far behind Rivet (~3.3 m at 180 deg, hands/baton/plasma plots) and a comb of
   bars up-left (katana, plasma) change during the swing and are not the swing. They inflate drawn-no-hit BEHIND
   Rivet; the red cells behind him in the plots are mostly these + the windup body. Use `deg_p5_p95`/`reach_p95`.
3. Several consecutive ticks give identical masks (e.g. baton k 2..6): either the strike pose holds or the
   viewport readback repeats a frame; not resolved in this call. The per-tick window is therefore coarse.
4. Hit-not-drawn is small (katana 3, plasma 10 - the plasma's wide cone ice-blue cells top/bottom right where its
   drawn smear does not reach), so the defect is the drawn side reaching where no hit lands, and late: of the
   drawn-no-hit cells, most are only touched after the single hit-test tick.
