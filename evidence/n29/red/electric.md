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

## After2 (commit 3bf74f0c7: cast view amber ink + opaque amber body stroke)

Files `red_elec_<tazer|burst|tuckin>_after2_64.png` and `_pair2_64.png` (before | after2, 3x nearest) next to the others, from
`elec_stills.py` (frames `build/n29elec/after2/`, same ticks 15874 / 16132 / 16393; a fourth `cops` frame at 16393 has Rivet's collar in shot).

| crop | before | after (c2c) | after2 |
|---|---|---|---|
| tazer | 2370 | 1745 | 1366 |
| burst | 327 | 203 | 196 |
| tuckin | 0 | 0 | 0 |

LOOK: the tazer stripe prints amber, the prongs are a cream core inside an amber body (no vermilion left in the current); the remaining reddish px
in the tazer crop are Mertz's gloves, untouched. Burst arc the same (the 196 left are other red in the crop, not the arc).

Ink scope: only `PrintStage.cast_material()` (cast view = Rivet, cops, allies, Mertz, pickups) gets `amber_ink`, switched by `look_profiles.json`
`fx_amber_ink` (same key as the FX view). Pixel diff of after2 vs a control render with the cast amber ink forced off (same frames, threshold 24/255):
outside the electric boxes 5 (tazer), 58 (burst), 5 (tuckin), 5 (cops frame, Rivet's collar and a patrol cop in shot) px; inside tazer 933 / burst 5 / tuckin 0.
The outside px are all amber-ward re-prints of the ember / flame speckle in the cast view (vermilion or grey -> amber, a handful of px at the fire edge);
Rivet's collar, the cops and Mertz's gloves did not move (checked by eye in the 6x crops). I did not re-render to test for render noise.

D: `StageView._bolt_robot` still has no caller (TUCK-IN on screen is the `tuckin_crate` PNG); left alone. `CurrentLook._serial` stays a copy.
