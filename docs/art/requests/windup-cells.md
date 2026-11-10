# REQUEST: wind-up cells for Rivet's blades (plasma sword, katana, electro baton)

Lane n13-weapon-art, 2026-11-10. For an artist or an image generator. No composed interim cell
shipped: the trial (below) failed the bar for all three.

## Status (15:40): delivered and shipped at p70

The asset lane answered the same day (`docs/night/2026-11-10/weapon-art/ASSETS-REPLIES.md`; notes
`gtai-art/library/deliveries/blade_windup_it309.md`): side and camera wind-ups for all three blades
at p70 and p55, the baton's left wind-up, plus offers not asked for (chainsaw p70 / p55, the plasma
sword's spin coil). All graded A by that lane.

| Weapon | p70 side + cam | Anticipation (melee.md, 32 px/m) | State | p55 | left |
|---|---|---|---|---|---|
| plasma sword | shipped ON | 2 -> 4 | `rivet_eq_plasma_sword_windup.png` | delivered, not wired | - |
| katana | shipped ON | 4 -> 5 | `rivet_eq_katana_windup.png` | delivered, not wired | - |
| electro baton | shipped ON | 2 -> 4 | `rivet_eq_electro_baton_windup.png` | delivered, not wired | delivered, slot not wired |
| chainsaw (offer) | delivered | - | not built | delivered | - |
| sword spin coil (offer) | delivered | - | not built | - | - |

Laid by `tools/art/rivet_windup_cells.py` (manifest `tools/art/rivet_windup_cells.json`) from
`gtai-art/library/keyed/rivet/rivet_windup_70_cells/`: feet on the strip's pad, body on the cell
centre, scaled by eye to the facings (sword cam 0.86, katana 0.9 / 0.78, baton 0.82 / 0.82; the
sword's side shifted 13 px, the katana's 12, so the helmet holds its line), the sword's B ink rim.
Films: `gtai-masters/n13/weapon-art/i4_<weapon>_windup_drawn-ab-32ppm.mp4`. Before:
`--rivet-windup=off`, or the weapon's row removed from the manifest (no file = off). p55 is not
wired: its deliveries are sheets at the 55 action band's scale, so each cell needs its own scale and
anchor by eye and a boss-view film (more than one manifest row each).

## Why (the original request)

Rivet's drawn equipped strips (`project/features/characters/art/view/<art>/rivet_eq_<weapon>.png`,
cut by `tools/art/rivet_frames.py` from the library sheets) have 8 cells: five facings, the side
strike, the camera strike, rest. There is no wind-up cell, so through a swing's wind-up ticks (3-5
ticks, `melee_weapons.json`) the strike cell (the swing already through, its arc drawn) is shown, and
the hit arrives from the idle pose. Anticipation on the melee.md 1-5 scale (n12 D2 audit, 32 px/m):
plasma sword 2, electro baton 2, katana 4 (its strike cells already lean into the cut).

The slot is built: `RivetWindup` (features/characters/rivet_windup.gd) draws
`rivet_eq_<weapon>_windup.png` while the view's strike clip is inside its wind-up, on the equipped
strip only; `--rivet-windup=off` is the before. The file not existing = off (today's state).

## What failed (n13 item 4a)

`tools/art/blade_windup.py` composed a wind-up from the strip's own parts: the body from the nearest
facing cell, the blade plate lifted out and turned about its base. Filmed at 32 px/m in the plasma
sword combo (`i4_plasma_sword_windup_trial-dropped-ab-32ppm.png` / `.mp4`):
- the arms cannot move: raised up and back from hip-height hands the blade hides behind the torso;
  raised in front it stands upright off a still-horizontal hilt (a bent sword at 3x);
- the view learns of a strike 2 ticks into the 4-tick wind-up, so the cell shows 2 frames;
- on the chained swings the body pops lunge -> standing -> lunge in 3 frames (a flicker).
Anticipation did not rise by 1 without a pop. The katana's rust-steel blade shares the body's palette
and the baton hangs one-handed at his side, so the same lift cannot even isolate them cleanly.

## Delivery (all three)

- Two figures per weapon and art key, keyed on transparency like the library's equipped sheets
  (`C:/Users/kazda/kiro/gtai-art/library/keyed/rivet/rivet_eq_<weapon>_<70|55>*.png`), drawn at the
  same scale as that sheet's action band, same ink weight, same light:
  1. **side wind-up**: the body turned like the side strike cell (3/4 toward camera-right), the
     weapon cocked back and up behind the leading shoulder, weight on the back foot, ready to swing
     forward-right into the side strike cell.
  2. **camera wind-up**: the body facing the camera like the camera strike cell, the weapon raised
     overhead (blade or baton tip above and behind the helmet), ready to come down toward camera.
- Both feet on the ground line the facings use (the figures stand on the same feet as the strip).
- Headroom: the raised weapon will exceed the equipped cell's height; that is fine (the cut adds it).
- Palette: only the plates already in the weapon's own strip (lists below, p70 strip, by share).
  No new colour; red is for blood only, teal for souls only.
- Two-handed weapons (sword, katana) are mirrored for the left octants. The baton is one-handed:
  it is never mirrored (the owner's hand rule), so it also needs a **left side wind-up** (3/4
  toward camera-left, baton in the right claw), see below.

## Per weapon

### Plasma sword (anticipation 2 -> target 3+)
- Strip slot: `art/view/p70/rivet_eq_plasma_sword_windup.png` and `art/view/p55/...`, cell 0 side,
  cell 1 camera. Equipped cells today: p70 243 x 161 px, p55 211 x 128 px (fig_h 110, act_k 0.82 /
  0.85); the wind-up cells keep the cell width and add about 48 px of headroom.
- Pose: two hands on the long hilt; the hot blade swung back over the right shoulder, glowing tip
  pointing up and behind; for the camera cell the blade straight overhead, its glow above the helmet.
  The ink rim round the blade as shipped in n13 (treatment B: `tools/art/blade_ink_rim.py` runs on
  any row with `ink_rim`).
- Plates (p70, share of opaque px): #030202 14 %, #c0895f 14 %, #775540 12 %, #39251e 11 %,
  #ac683f 11 %, #160f0e 10 %, #53362a 10 %, #ebb64a 7 % (blade glow), #fdea7d 6 % (glow core),
  #733a22 5 %.
- Combo: plasma_1 (wind-up 4 ticks, a flat slash), plasma_2 (3, the backhand return), plasma_3 (a
  full spin). The backhand return could use the side cell mirrored in time; a third cell for the
  spin's coil is optional.

### Katana (anticipation 4 -> keep it, add the cock)
- Strip slot: `art/view/<p70|p55>/rivet_eq_katana_windup.png`. Equipped cells: p70 317 x 172, p55
  237 x 141 (act_k 1.0 / 0.95).
- Pose: a two-hand high guard; the curved blade raised back over the shoulder, edge out, for the
  wide rising slash (katana_1, wind-up 5); camera cell: blade raised overhead for the falling cut.
- Plates (p70): #ae7f5d 14 %, #6d513f 13 %, #57392a 13 %, #342620 11 %, #020203 11 %, #a2623c 10 %,
  #181312 7 %, #09090a 7 %, #f8eab7 7 % (the edge's highlight), #d1a175 5 %.
- Keep the blade's highlight edge legible: at 32 px/m the blade is 1-2 px wide; the edge cream is
  what reads.

### Electro baton (anticipation 2 -> target 3+)
- Strip slot: `art/view/<p70|p55>/rivet_eq_electro_baton_windup.png` (right-facing side, camera),
  plus `rivet_eq_electro_baton_left_windup.png` (one cell, left side) for the drawn left strip; the
  left slot is not wired yet (RivetWindup swaps on the equipped strip only: a one-line follow-up).
  Equipped cells: p70 215 x 163, p55 162 x 117. The p55 strip draws no arc (the game smear,
  `RivetStrips.NO_ARC`); the wind-up cell must show the baton itself (the held part is hidden while
  the drawn figure owns the weapon).
- Pose: one-handed; the baton drawn back past the hip and up, spark tip behind him, the free claw
  forward for balance (jab, baton_1, wind-up 4); camera cell: baton raised overhead for the crack
  (baton_3).
- Plates (p70): #846049 13 %, #020101 13 %, #6b3e27 12 %, #c8936b 12 %, #3e261b 11 %, #b67241 10 %,
  #deab7f 9 %, #1d120e 8 %, #0a0605 6 %, #f7dfba 5 % (the spark).

## Reference stills

In `C:\Users\kazda\kiro\gtai-masters\`:
- `n12\visual\d2_audit_plasma_sword-32ppm-strip.png`, `d2_audit_katana-32ppm-strip.png`,
  `d2_audit_electro_baton-32ppm-strip.png` (the combos at 32 px/m today);
  `n12\visual\d2_plasma_sword_windup_trial-dropped-32ppm.png` (n12's trial: the camera strike cell
  in the wind-up read as a second swing).
- `n13\weapon-art\i4_plasma_sword_windup_trial-dropped-ab-32ppm.png` / `.mp4` (this lane's trial),
  `i4_plasma_sword_windup_compositions-p70-2x.png` (the compositions tried),
  `i4_katana_baton_strips-p70-facings-strikes.png` (the facings and strike cells the wind-ups sit
  between).

## Fitting it in (after delivery)

Cut each sheet with `tools/art/rivet_frames.py` (a row with `counts` "2"; the cutter scales a band
so its median figure is `fig_h` tall and the raised weapon counts in that height, so set the row's
`fig_h` by eye until the wind-up body matches the facings, as the reload rows do), write it to the
slot path, `--import`, and film the combo with and without `--rivet-windup=off`.
The warm (`RivetStripWarm`) already lists `rivet_eq_<weapon>_windup.png`.
