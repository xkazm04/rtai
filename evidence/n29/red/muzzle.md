# n29 combat 02b: muzzle-flash cores from vermilion to amber (red audit rows 5-10, 11)

Env: `APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat`, `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`GTAI_GODOT_EST_MB=1000`. Takes through `runGodot` (d3d12, windowed `--position 0,1440`, 1920x1080, `--fixed-fps 60`).

## Takes (`<side>` = before | after)
1. Reel director cut, chapters pistol, machine_pistol, rocket_launcher, mini_nuke at 64 px/m (fire events from `probe.json`:
   pistol 46/61, smg 406-458 every 4, rocket 826, nuke 1193). The 5-tick stills missed the 1-3 tick flash, so the stills are
   tick-exact one tick after each fire:
   `node evidence/n29/red/take.mjs build/n29muz/<side>/fine 46,47,48,49,61,62,63,64,406,407,408,409,410,826,827,828,829,1193,1194,1195,1196,1197 --rigs --bot=reel --reel=director --loadout=pistol --chapter=pistol,machine_pistol,rocket_launcher,mini_nuke --ppm=64 --clean --silent --shot=user://n29muz_end.png --shot-tick=1705`
   Used ticks: pistol t47, smg t407, rocket t828, nuke t1194.
2. FX showcase: `node evidence/n29/red/fxshow.mjs build/n29muz/<side>/fxshow` -> `fx-64ppm-1-fx.png`; the d4 `muzzle`
   kind star and the small burst / ricochet stars are the small stars at the right (crop x1250-1560 y250-620, holds blood).
3. `python -I evidence/n29/red/muzzle_stills.py <side>` (+ `pair`) -> `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_muzzle_<gun>_<side>_64[_crop].png`,
   `red_muzzle_<gun>_pair_64.png`.

## Before: reddish px (n28 gate R>170 G<110 B<90) per crop
| gun | tick | crop | reddish px |
|---|---|---|---:|
| pistol | 47 | 440,405,800,685 | 0 |
| smg | 407 | 340,180,940,580 | 134 (blood/gun art) |
| rocket | 828 | 397,395,757,675 | 24 |
| nuke | 1194 | 65,259,665,659 | 165 |
| d4 muzzle + stars | showcase | 1250,250,1560,620 | 1528 (mostly blood) |

Source cells before (reddish px): flash_pistol 1019/659/0, flash_smg 473/298/0, flash_tube 1633/1058/0, flash_nuke 3761/2181/0;
colour/ variants 675/547/361, 494/423/261, 797/634/426, 1217/847/741; rocket.png 336, nuke_shell.png 968.
Note: at 64 px/m the pistol and smg flash is a tiny square or hidden in the frame (smg t407 shows no flash).

## After (commit B 2a1069f77: `python -I evidence/n29/red/recolour.py --muzzle`)
Remap result (reddish before -> after): flash_nuke 3761/2181/0 -> 0, flash_tube 1633/1058/0 -> 0, flash_pistol 1019/659/0 -> 0,
flash_smg 473/298/0 -> 0 (colour/ variants 675..1217 -> 3..16, a few dark-red edge px left), atlas cell 0 576 -> 0, 1 485 -> 0,
2 1880 -> 0, 8 630 -> 0, 13 257 -> 0, 14 1 -> 0. Cells 9-12 sha256 before = after (e2ba1c89a91c92ca, 59dfef887e241597,
5f22162e7dffa563, 2b9927bb3c40a84c); every other cell identical; `recolour.py` (no flag) on the fire files: 0 px changed (re-run is a no-op).
Row 11: `rocket.png` (336 reddish) and `nuke_shell.png` (968) KEPT as drawn: Rivet's own rounds, their red is paint on the body, not
fire or danger; amber would make the round read as a pickup.

Same takes after (`build/n29muz/after/...`), pairs `red_muzzle_<gun>_pair_64.png` (before left, labelled, 2x).
The first before take (`before/fine_invalid`) was rendered with a stale rig look and is not comparable; the before frames in the table
come from a re-take at the pre-repaint PNGs (`git checkout 62234251c -- <the 29 files>`, take, `git checkout 2a1069f77 -- ...`).

| gun | tick | crop px reddish before -> after | px changed in the whole frame (channel > 24) |
|---|---|---:|---:|
| pistol | 47 | 449 -> 449 | 0 |
| smg | 407 | 622 -> 622 | 0 |
| rocket | 828 | 194 -> 194 | 0 |
| nuke | 1194 | 1035 -> 1035 | 0 |
| d4 muzzle + stars (fx showcase) | - | 1528 -> 1422 (blood in crop) | 140 inside the crop (the muzzle star) |

Finding: in the arena the gun flashes at 64 px/m (22 ticks, 46-49, 61-64, 406-410, 826-829, 1193-1197) are identical before and
after, so the star seen at the muzzle there is not drawn from these cells (it is the rig/ink flash). The repaint is visible in the fx
showcase: the d4 `muzzle` star core goes from vermilion-orange to amber, cream centre and ink rim unchanged (pair `red_muzzle_d4_muzzle_pair_64.png`).
The `flash_*` cells and atlas cells 8, 13, 14 were not seen on screen in any take (only the source and the colour path carry them).
Amber ink: the d4 muzzle is drawn in the FX view, which has the amber ink (c2a commit 12b7c141b), and it reads amber there: no NEED line.
