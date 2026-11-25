# n30 combat 03: Rivet's rocket and nuke nose band amber

Env: `APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat`, `GODOT_BIN=.../Godot_v4.7.2-stable_win64_console.exe`; takes through `runGodot` (d3d12, windowed `--position 0,1440`).

## Files (the only copies the game draws)
`project/features/combat/weapons/art/fx/rocket.png` and `fx/nuke_shell.png` (weapon_art.json fx rows `rocket`, `nuke_shell`; `WeaponFxArt._rocket` and
`WeaponFxShell` draw them; no colour/ variant, no atlas copy; `enemy_rocket_*` are the foe's rocket, not touched).
`python -I evidence/n30/rounds/recolour_band.py [--dry]`: source = the PNG of fde0b1f4c (git show + lfs smudge, nothing written into the tree), mask = n29 `is_red`
plus the 8-neighbours with hue <= 30 or >= 340 and s > 0.25 (edge px keep their own saturation, dark ones x0.3), amber #EDAB42 hue, value and alpha kept.
Result: rocket 389 px (336 core + 53 edge), nuke_shell 1238 px (1029 + 209) changed; independent diff: 0 px changed that is not within 1 px of a core px, alpha changed 0,
13611 / 17962 px unchanged. (The brief's 968 for nuke_shell is the n28 gate; the n29 `is_red` gate counts 1029.)

## In-game (64 px/m, arena reel director cut, `node evidence/n29/red/take.mjs build/n30round/<before|after> 832,836,840,844,1200,1206,1212,1218,1224,1230 --rigs --bot=reel --reel=director --loadout=pistol --chapter=pistol,machine_pistol,rocket_launcher,mini_nuke --ppm=64 --clean --silent`)
Same ticks before (fde0b1f4c PNGs) and after; `python -I evidence/n30/rounds/band_stills.py` counts in the round box (diff bbox + 6 px):
| round | tick | box | reddish (is_red = R>170 G<110 B<90) before -> after | amber before -> after | diff px outside box |
|---|---|---|---|---|---|
| rocket | 836 | 843,489,862,514 | 91 -> 0 | 0 -> 84 | 0 |
| nuke | 1212 | 395,328,440,401 | 1048 -> 39 | 0 -> 957 | 0 |
The round prints amber (the FX view's amber ink works); nothing else in the frame changed.

## What I saw
Rocket: the band is a flat amber block, no vermilion edge left (the first pass left a 1 px vermilion bottom row: the print snaps each px to the nearest ink and
an orange-brown blend of amber and dark edge lands on vermilion; making the edge px low-saturation fixed it). Nuke: band amber with the two black stripes;
39 single vermilion px remain along the stripe edges (blend of amber and the ink stripe at the downscale, nearest ink = vermilion). Not fixable in the sprite
without recolouring the stripes or touching print code (forbidden).
Film `films/round_band_32.mp4`: `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs <out>` ->
`h264,1920,1080,60/1,25.000000`; frame at 12 s shows the nuke blast ring in amber/cream, Rivet left; the round is too small to judge at 32 px/m.
Commits: 42e7af756 (strict mask), 201763968 (edge fringe).
