# JOURNAL: lane n13-weapon-art, 2026-11-10

Branch `n13-weapon-art` in `C:\Users\kazda\kiro\gtai-wt\n13-weapon-art`, cut from main `0e5e1e19d`.
Brief: `BRIEF.md` beside this file (committed alone, `2f03b0024`). Scratch: `build/n13/` (git-ignored:
film.sh, strip.py, zoom.py, abf.py, ab_sheet.py, d1sheet.py, abmp4.sh, the films). Masters (films,
stills, `frames.json`): `C:\Users\kazda\kiro\gtai-masters\n13\weapon-art\`. Godot: the launcher's
known path `gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; every windowed run with
`--position 0,1440`. Native DLLs as copied from n12 (release md5 7995c493), untouched.

## Setup
- Brief committed by path (`2f03b0024`; the hook ran lint 15/15).
- First `--import` exit 0, 0 ERROR (2 m 13 s); `dev/bake_city.gd` 256 chunks, 0 SCRIPT ERROR.
- Films: `build/n13/film.sh <label> <ticks> <flags>` = n12's sync/film.sh (editor binary, d3d12,
  1280x720, Movie Maker MJPEG, `--fixed-fps 60`, the arena at `--ppm=32 --rigs --clean`, FightFrames
  log for frame -> tick) plus `--position 0,1440`. A director chapter needs `--loadout=pistol` (without
  it the chapter is skipped: my first sword film showed a bare claw; the log says so).

## Item 1: plasma sword, treatment B (heavier ink rim)

### Audit
- `sword-before` (`--bot=reel --reel=director --chapter=plasma_sword --loadout=pistol`, 330 ticks):
  rest cell ticks 52-58, the side strike from tick 59 (hit 61, held to 63), back to the facing at 86.
- The strip is cut by `tools/art/rivet_frames.py --manifest` from the library sheet
  (`rivet_eq_plasma_sword_70_v2.png`, p55 `_55_v4`); re-running the cutter reproduces both shipped
  strips byte for byte (p70 1944x161, p55 1688x128), so a manifest key is a clean before.
- The n12 B candidate was made by an uncommitted PIL pass. Read back at strip scale (the 3x candidate
  is NEAREST, so every third pixel is the strip): it is solid ink (27,21,23) laid on the cutter's soft
  halo (alpha < 160) 1-2 px outside the silhouette, plus a few edge pixels; no colour inside the blade
  changed. It also inked part of the body's halo and left stray ink dots on the side strike's drawn
  arc (cell 5).

### Change
- `tools/art/blade_ink_rim.py` (new): per cell, the blade's core = the largest run of its glow; its
  plate = opaque pixels within `reach` px of it; ink = the darkest decile of the plate's outline (the
  plate's own line, no new colour); the soft halo outside the plate out to `px` turns solid ink,
  falling off over one more pixel; bright soft pixels (the arc) are never painted. Blade only (the
  owner's B label is "heavier ink rim round the blade").
- Fit to the n12 candidate on its cells 0 and 5 (pixels within reach of the blade): px 0.5 reach 4
  matched 37/53 and 57/79 of B's changed pixels with about as many of its own; reach 6 also catches the
  spine's top edge (B inked it), so shipped px 0.5 reach 6. px 1.0+ was visibly heavier than B.
- `rivet_frames.py --manifest`: a row's `ink_rim` ({px, reach}) runs the pass after the cut;
  `--no-ink-rim` skips it. `rivet_frames.json`: `ink_rim` on p70 and p55 `rivet_eq_plasma_sword`.

### Before
- `python -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json --only=rivet_eq_plasma_sword --no-ink-rim`
  (or the two `ink_rim` keys removed) cuts the shipped strips: verified byte-identical to the shipped
  PNGs (both art keys). The same command without the flag reproduces the B strips byte for byte.

### Measured
- Every cell (5 facings, side and camera strike, rest), p70 and p55: the blade wears the ink rim, the
  arcs untouched. Game scale (x 0.33, x3): `i1_plasma_sword_B-game-scale-x3.png` (shipped / n13 B /
  n12 B cells 0 and 5).
- Film A/B, same build, 32 px/m: `i1_plasma_sword_B-ab-32ppm.mp4` (left before, 2x slow, x3),
  `i1_plasma_sword_B-ab-32ppm-frames52-60-64-70-90.png`. Same strip size and path: nothing new to
  load (RivetStripWarm already prefetches it).
- Commit `7c2626947`.

## Item 2: the dropped pistol, a drawn gun cell

### Audit
- `baton-before` (`--chapter=electro_baton --loadout=pistol`, 330 ticks) frames 70/85/130 match n12's
  D1 shot: ShockArcsView's n7 placeholder (an ink polygon in a 1.5 px cream rim) reads as a cream
  bracket beside Rivet. The pistol art in weapon_art.json: `held` / `parts.small` (top-down, along
  the bore) and `pickup` (the side view lying on the floor: the view a dropped gun shows the camera).
  The cop's own gun is part of his drawn forearm cell (navy, not a separate part).

### Change (four passes on film, `build/n13/film/d1-ab-v*.png`)
1. The pickup cell as drawn, 0.38 m, the pickups' 2 px ink outline: an ink blob (a 12 px cell inside
   4 px of ink, and the 301 px cell sampled 25:1 without mips: the project's default filter is
   linear, no mipmaps).
2. Floor node `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`, 1 px ink: a grey smudge; the drawn rust and steel
   sit at the pavement's own grey (luminance about 110).
3. `tools/art/dropped_gun.py` (new, committed, re-runnable): the pickup cell through held_small.py's
   re-tone (mid tones lifted into Rivet's tone budget, darkest ink kept, no new colour), cut to 64 px
   wide with a premultiplied Lanczos -> `pistol/dropped.png` (mipmapped import), `parts.dropped` in
   weapon_art.json. Pale and readable, but turned 35-60 deg at 12 px it read as a bone.
4. Offline sim (12/15/18 px, 0/35 deg, three tones: `scratchpad gunsim.png`): the L of barrel and
   grip reads near flat from about 15 px. Shipped: span 0.48 m (15 px at 32 px/m), the drop angle
   folded so the muzzle points sideways (mirrored, never upside down) with half its tilt
   (`ShockArcsView.lie_of`), 1.5 px ink outline (1.0 was soft at the edge).
- Keeps `GUN_ON_FLOOR` (the floor child, cast-shadow band + 1); the toss, spin, sink and ink-out with
  the corpse unchanged (the whole cell inks out now, not the rim).

### Before
- `--dropped-gun=polygon` (read through ArenaArgs: no new LaunchArgs flag, launch_args.gd sits at its
  200-line soft cap). Film `baton-flagoff` vs `baton-before` (pre-change build): 0 of 330 frames
  differ (framemd5). After vs before: frames 59-329 differ (from the drop).

### Measured
- `i2_dropped_gun_cell-ab-32ppm-frames70-85-130.png` (top before, bottom after; 8x crops on the gun at
  right), `i2_dropped_gun_cell-ab-32ppm-frame130-2x.png`, `i2_dropped_gun_cell-ab-32ppm.mp4`. At 1x
  the gun is a pale pistol about 15 x 11 px with an ink edge: barrel and grip read, the tape and
  slots do not; softer than the drawn rigs (mip-sampled). Read: a pistol, not a bracket.
- Load: one 64x52 texture, loaded in ShockArcsView._ready (the arena's build, behind the load).
- Tests: `test_dropped_gun_cell.gd` (5: loads at ready, mip filter, lie_of side, mirror, tilt cap);
  test_shock_arcs_floor 1/1.
