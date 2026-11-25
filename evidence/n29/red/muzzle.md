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
