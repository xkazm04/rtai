# n29 red: the tazer, burst arcs and TUCK-IN bolt (audit rows 17-19)

Stills are at the view's own zoom, 48 px/m (the collect_call view draws at `Ink.PX_PER_M`; no 64 px/m camera exists),
1920x1080, d3d12, quest 1 seed as the frame grabber plays it. Files `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_elec_<tazer|burst|tuckin>_<before|after|pair>_64.png`
(crops: tazer 1330,380-1530,540; burst 300,500-540,700; tuckin 1100,70-1250,170; pairs 3x nearest, before left).

How: `electric_grab.gd.txt` is `project/dev/frames/frame_grabber.gd` with three custom shots (tazer CHARGING and charge_frac >= 0.6;
first new `arena.burst_arcs` entry; `burn_ticks == 90` at the crates), `electric_entry.gd.txt` / `electric_run.mjs.txt` run it through
`runGodot` (copies live in `build/n29elec/`, run with `node build/n29elec/run.mjs <abs out dir>`). Same ticks before and after: tazer 15874, burst 16132, tuckin 16393.

## Reddish px (count_red.py --crop: R>170, G<110, B<90)

| crop | before | after |
|---|---|---|
| tazer | 2370 | 1745 |
| burst | 327 | 203 |
| tuckin | 0 | 0 |

## What the pairs show
- Prong sparks and burst arc: the live current draws, but on screen it reads CREAM, not amber. The amber halo strokes (a0.5 / a0.18)
  do not survive the item print on this path; the core `#fffaf0` does. So the vermilion zigzags are gone, but the current is cream-white,
  not amber.
- The barrel stripe is still vermilion on screen (the remaining ~1745 reddish px in the tazer crop are the stripe plus Mertz's red gloves):
  `Ink.AMBER` is snapped to the nearest print ink, vermilion, as c2a found (`fire.md`). Not changed here (not my files).
- TUCK-IN: `StageView._bolt_robot` is dead code (no caller); the crate stencil on screen is the `tuckin_crate` PNG. Its bolt is repainted
  in code but nothing on screen changes (0 reddish px before and after in the crop; the PNG bolt is dark). Forbidden to touch the PNG.

## Not done
Film D (`red_elec_mertz_after.mp4`) and the mutate run: out of wall clock.
