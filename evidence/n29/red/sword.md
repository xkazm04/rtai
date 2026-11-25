# n29 red audit row 15: the plasma sword's hilt rings (stills)

Take: `node build/dev/n28-deflect.mjs blade6 1 62` (pressure_film, seed 1, tick 62, 64 px/m, 1920x1080, d3d12; the helper is git-ignored
under build/dev). The sword hilt is mid-swing at about (820, 478). Same tick, same seed, before and after.

- **After** = HEAD (the four steel PNGs of 85c6b0c53), rendered as committed.
- **Before** = the four PNGs of `3e2fde824` (`git show 3e2fde824:<png> | git lfs smudge`, copied OVER the working files for one import and one
  render, then `git checkout HEAD -- <the four>` and a second import; `git status` clean after; no temp worktree). Files: `plasma_sword/{held_long,held,pickup}.png`,
  `held_55/plasma_sword.png`. At 64 px/m the rig draws `held_long.png` (held_small only under 56 px/m).
- Stills: `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_sword_{before,after}_64.png`, crops (box 795,420,895,500, 6x nearest)
  `..._crop.png`, pair `red_sword_pair_64.png` (before left).

| region | reddish px (R>170, G<110, B<90) before | after |
|---|---|---|
| crop box 795,420,895,500 (includes a strip of Rivet's orange hazard stripes) | 78 | 41 |
| sword only, box 805,440,895,500 | 40 | 3 |

Whole frame: 43 pixels differ between the two stills (x 817-836, y 468-484): only the rings moved. The 3 left (829,475), (820,478),
(805,494) are the leftover dots the committed mask also leaves (held_long 15 px).

## What I saw
The red ring on the grip is gone. In the look print the steel grey does not land on vermilion: changed ring pixels print as ink-dark
(about 100,93,89) or the cream of the blade's own paper (about 244,220,189), so the rings now read as an ink ring with cream flecks, not
grey and not red. They are less defined than the red ring was (the grip reads as dark ink there), which fits "to steel" at this size.
Two or three tiny red dots stay on the hilt (the emitter prongs' lights), left as the mask spares them.

## Film
`CHAPTERS=plasma_sword,plasma_sword_left,plasma_sword_cam,plasma_sword_deflect QUIT=1440 node evidence/n29/red/film.mjs C:/Users/kazda/kiro/gtai-masters/n29/combat/films/red_sword_after_32.mp4`
(film.mjs gained `CHAPTERS`, `QUIT`, `LOADOUT` env overrides; defaults unchanged). ffprobe: 1920x1080, 60/1, 24.000 s, 24.2 MB; 32 px/m (the arena's tilt).
Four sword chapters: combo on a cop ahead, left, below, then the deflect against a shooter. I looked at frames at 2, 4, 9, 15 s: the sword fights read.
In the wind-up swing (2 s, `stills/red_sword_film_crop_4x.png`) the sword is Rivet's own `rivet_eq_plasma_sword*` sheet art, whose copper-red rings
are still there (NEED keys); the repainted `held_long` is what draws at the rest and in the deflect (the 64 px/m pair above).
At 32 px/m the held part is `held_55`/small variants under 56 px/m, whose rings the repaint also covers (held_55/plasma_sword.png 224 -> 13).

## After2 (02f): the last specks
`python -I evidence/n29/red/recolour.py --sword-specks --hot` (new mode; `--dry` lists only): per file the pixels the audit counter still counts
(R>170, G<110, B<90) plus their 1 px reddish-orange fringe, and with `--hot` the small hot-copper lights the gate misses
(hue <= 24 or >= 345, s > 0.52) take the fire remap's amber hue (alpha, max and min channel kept). Pixels changed == pixels listed in every file
(outside the list: 0). Reddish px before -> after: held_long 15 -> 0, held 3 -> 0, pickup 16 -> 0, held_55/plasma_sword 13 -> 0.  Pass 1 (reddish + fringe) moved 51 / 14 / 57 / 34 px; `--hot` then moved 41 / 14 / 28 / 14, and after a widened threshold 36 / 44 / 14 / 45 more.
The first pass (reddish + fringe only) changed 1 px of the 64 px/m still: the three dots in game (222,77,40) were not the gate's reddish px but
orange-copper lights (hue 11-16, s 0.6-0.7) that the lit render pushes over the gate, hence `--hot`.
Still `stills/red_sword_after2_64.png` (+ `_crop.png`, pair `red_sword_pair2_64.png`, before left): sword box 805,440,895,500 reddish 3 -> 0,
crop box 795,420,895,500 41 -> 38 (the rest is Rivet's own hazard stripes); 4 px differ from the after still (y 475-494, x 804-829).
Seen: no red dot on the hilt. The amber lights are 1 px at 64 px/m and print dark/steel, not as a readable amber speck.
