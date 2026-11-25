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

## c07b: `--stripe-edge` (nuke stripe-edge px dark amber) - NOT landed, count rose
`recolour_band.py --stripe-edge` (191 px of nuke_shell, 0 outside the mask) then `godot --headless --path project --import` (a windowed take does NOT reimport a changed PNG:
my first take after the edit still drew the old ctex and counted 39), t1212 at 64 px/m, same take flags as above, round box 395,328,440,401, is_red gate (= r-max(g,b) >= 0.31 count):
| edge value cap | in-game vermilion px |
|---|---|
| HEAD (no step) | 39 |
| 0.30 | 71 |
| 0.14 | 60 |
| 0.09 | 55 |
Darker edges help monotonically but never get below the HEAD count: the vermilion px sit one px off the stripe where the downscale blends the (unchanged) amber with ink, so
recolouring the sprite's edge px moves the blend, not removes it. The PNG was restored (`git checkout`), the HEAD sprite stays. Next option needs the stripe's own px or the print (forbidden here).
Still `gtai-masters/n30/combat/stills/round_band_nuke_pair2_64.png` = HEAD (left, 39) | cap 0.09 (right, 55), 6x, tick 1212.

## c23 soot seam
Why: c18 (`evidence/n30/floor/specks.md`): the item print snaps each sampled colour to its nearest ink, amber->ink blends of ~25-70 % ink are nearest VERM,
a soot grey (128,118,118) between them splits the blend (amber->soot snaps AMBER/STEEL, soot->ink snaps INK).
`python -I evidence/n30/rounds/seam.py HEAD <out.png> [width] [--alpha=N] [--rim | --rim-ink] [--four]`: source = HEAD nuke_shell.png, band = recolour_band.py's mask
on fde0b1f4c; stripe ink = dark (v < 0.2) texels with band texels left and right in the row; seam = band texels (not dark) touching that ink; `--rim` also the band's
top/bottom ink rim; `--four` = orthogonal contact only. Landed: `seam.py HEAD project/.../nuke_shell.png 1 --rim --four` = 262 texels soot, alpha kept, 0 outside the mask
+ its 1-texel ring (all 262 inside the mask in fact); `.import` unchanged.

Scale k: the band is 23 x 62 texels in the PNG (x 112-134, y 17-78); at t1212 64 px/m it spans ~31 x 60 screen px with the same slant (diff bbox 33 x 61 = box
395,328,440,401 less 6 px), so k = 0.97 (about 1:1, sprite barely rotated). Model at k 0.9 / 0.97 / 1.0 / 1.03 plus the old 0.5 / 1.5 / 3.8.

### Model (`evidence/n30/floor/snap.py`, `sim.py` with the k above; candidates in `build/n30seam/model/`)
| candidate | seam texels | VERM texels | amber texels | VERM blends | sim VERM k 0.9 / 0.97 / 1.0 / 1.03 / 1.5 |
|---|---|---|---|---|---|
| HEAD | 0 | 64 | 938 | 389 | 25 / 23 / 64 / 28 / 97 |
| width 1 (stripes, 8-nbr) | 259 | 7 | 826 | 30 | 5 / 1 / 7 / 1 / 9 |
| width 2 | 534 | 5 | 554 | 28 | 4 / 1 / 5 / 1 / 6 |
| width 1 alpha 128 | 259 | 7 | 826 | 30 | 6 / 1 / 7 / 1 / 9 |
| width 1 --rim | 289 | 0 | 821 | 0 | 0 / 0 / 0 / 0 / 0 |
| width 1 --rim-ink | 298 | 7 | 826 | 28 | 0 / 1 / 7 / 1 / 1 |
| width 1 --rim, pure-amber texels kept (hack) | 172 | 0 | 938 | 110 | 4 / 1 / 0 / 5 / 6 |
| **width 1 --rim --four (landed)** | 262 | 0 | 847 | 1 | 0 / 0 / 0 / 0 / 0 (also 0 at 0.5 and 3.8) |
| width 1 --rim --four alpha 128 | 262 | 0 | 847 | 1 | 0 / 0 / 0 / 0 / 0 |
Width 2 does not help (k ~1 averages little) and eats the amber; the 7 left after width 1 are the band's own dark-brown texels on the top/bottom rim (`--rim` clears them).

### In game (`node evidence/n29/red/take.mjs build/n30seam/<before|after|...> 1206,1212,1218 --rigs --bot=reel --reel=director --loadout=pistol --chapter=pistol,machine_pistol,rocket_launcher,mini_nuke --ppm=64 --clean --silent`; import first via `run_unit.mjs --select=test_weapon_fx_art`)
`python -I evidence/n30/rounds/seam_stills.py build/n30seam/before build/n30seam/<after>`: vermilion = r-max(g,b) >= 0.31, amber, red (R>170 G<110 B<90), teal; box t1212 fixed, else diff bbox + 6.
| candidate | tick | box | vermilion | amber | red | teal | px changed outside box |
|---|---|---|---|---|---|---|---|
| HEAD | 1206 / 1212 / 1218 | 365,365,409,436 / 395,328,440,401 / 421,302,468,378 | 42 / 39 / 43 | 870 / 957 / 1017 | 42 / 39 / 43 | 0 | - |
| width 1 --rim | 1206 / 1212 / 1218 | same | 0 / 0 / 0 | 766 / **846** / 896 | 0 | 0 | 0 / 0 / 0 |
| **--rim --four (landed)** | 1206 / 1212 / 1218 | same | **0 / 0 / 0** | 790 / **869** / 924 | 0 | 0 | 0 / 0 / 0 |
| --rim --four alpha 128 | 1206 / 1212 / 1218 | same (1206: 365,365,409,437) | 0 / 0 / 0 | 790 / 869 / 924 | 0 | 0 | 0 / 0 / 0 |
Bars: t1212 vermilion 39 -> 0 (<= 10), 1206 42 -> 0, 1218 43 -> 0; amber 869 >= 850 (`--rim` alone missed it at 846, hence `--four`); red 0, teal 0, 0 px outside.

### What I saw
Still `gtai-masters/n30/combat/stills/nuke_round_seam_pair_64.png` (t1212, before | after, 6x nearest, counts on it); alpha 128 variant `nuke_round_seam_a128_pair_64.png`.
Opaque seam: the band is flat amber, the two stripes still read as two dark stripes, now with a 1 px light-grey (steel) edge each side, the ink core a touch thinner;
no orange-red px anywhere on the round, 1206 and 1218 the same. Alpha 128: identical counts, the seam prints as the ground shadow, so the stripes look wider and
solid dark (closer to HEAD's weight on this grey floor) - but it is a see-through slit in a solid shell whose look follows the floor under the round (lighter on a
light floor) and would show in any non-print draw. Landed the opaque one: deterministic, same counts.
Unit (mapped by `test_map.mjs`, 54 files): `unit-tests: 334 passed, 0 failed, 0 skipped (GUT, headless)`.
Lint: `lint: all 19 checks pass over 2294 GDScript files`.

## c26 32 px/m film

Command: `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/n30seamfilm/after.mp4` on HEAD with `b0fcfedf5`; copied to `gtai-masters/n30/combat/films/nuke_seam_32.mp4`. Before = `films/blast_floor_after_32.mp4` (pre-seam round).

ffprobe: `h264,1920,1080,60/1` / `25.000000` (bar 1920x1080, 60/1, 15-40 s: met).

Seconds: the nuke is fired at ~7.0 s and is in flight 7.1-7.9 s (blast at ~8.0 s). The camera pans, so the crop (140x70 px) follows the round by hand-placed centres. Vermilion = `r - max(g,b) >= 79`, counts in that crop, after / before:
7.2 s 89 / 77; 7.4 s 0 / 0; 7.6 s 8 / 0; 7.8 s 28 / 48; 7.9 s 72 / 64.

Still: `gtai-masters/n30/combat/stills/nuke_seam_32_pair.png` (7.6 s, 6x nearest, before | after).

What I saw: the round is about 100x40 px on screen, big enough to judge. In both films the band is yellow/black stripes on a lavender body, soot stripe sits on the yellow, and no visible seam or red line in either. The counts are NOT a clean signal: 7.2, 7.8, 7.9 s crops include blood/decals and the exhaust, and the 7.6 s after count of 8 px is video-compression chroma noise, not a seam. At 32 px/m the numbers do not separate before from after; visually the two rounds are equal (after has a slightly cleaner stripe edge, not measurable here). The t1212 39 -> 0 result from c23 stands on the render-level number, not on this film.
