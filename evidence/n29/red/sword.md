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
