# 01-print: the D5 print toward the riso middle ground (n5-look, 2026-11-04)

- `before/`, `after/`: `dev/showcase/city_frame.tscn -- --zooms=1,2 --foci=0,4`, `--fixed-fps 60`, d3d12, seed 91. before = main a1275c82 (now `--look=today`), after = `--look=auto` with `world_riso`.
- `crop-0-{32,64}.png`: before | after, 480x300 crop at 2x nearest. `pair-4-32.png`: full street block, before | after.
- Mean tone check (PIL, crop 700,250-1200,350 of city-4-32): asphalt RGB 80.5/71.2/71.7 -> 81.0/71.6/72.1; paper 211.7/196.0/175.4 -> 211.9/196.1/175.5.
- Not yet: the full director reel (all kill chapters), a 64 px/m three-way with the target, frame cost (shader budget), paper warmth toward the target. See JOURNAL NEXT.
- Pan (shimmer): `city_frame --foci=4 --zooms=1 --pan=600` per look; residual after the camera shift (rows 250-550, 60 frame pairs): today and riso both 1.29 % of pixels > 24 (moving actors), median 0. Clip: `gtai-masters/n5/look/print-pan-today-vs-riso-32ppm.mp4`.
- Arena: `res://dev/arena/arena.tscn --write-movie --fixed-fps 60 --quit-after 1500 -- --bot=reel --reel=director --look=today|auto`, clip `gtai-masters/n5/look/arena-reel-today-vs-riso-32ppm.mp4` (first 25 s of the reel only).
- Look goldens: block site over the gate with this change only (main's tables restored: pass); re-blessed, decisions line.

## Iteration 2 (2026-11-04 17:36-18:15)
- `after-it2/`: the same city_frame shots with `tan_k` 1.0 + `stain_k` 0.35 (`world_riso`). Paper (crop 100,40-500,170 of city-0): 32 px/m 231.0/214.2/191.1 -> 207.7/188.5/157.9, 64 px/m 225.1/202.3/174.7 -> 199.4/180.4/150.9; target r2_a5 149/131/109.
- CORRECTION: iteration 1's arena A/B was invalid. The dev arena ignored `--look=` (only boot/world.gd read it), so both halves were the riso print. Fixed in 4c42f589 (arena_game sets the print stage's look id); the A/B was re-filmed: `gtai-masters/n5/look/arena-reel-today-vs-riso-it2-32ppm.mp4` (40 s, 76 % of pixels differ, the fight identical). The city pan check (city_frame honours --look) stands.
- `cost/`: the riso layer's frame cost (CONTENDED, unresolved under the noise; static fetch count). See cost/README.md.

## Iteration 10 (2026-11-05 02:00-02:10)
- `after-it10/`: the same city_frame shots (`--zooms=1,2 --foci=0,4`) on 9a448a83 (speck + patchy, the iteration 2 tan). `after-it10-tone/`: with `world_riso.tan_tone` [1.02, 0.99, 0.94].
- Paper measured (PIL, crop 100,20-1200,150 of city-0-32, mean / median): today 222/205/183 / 238/220/197; it10 197/178/150 / 212/193/162; it10-tone 219/201/173 / 238/218/187. Target r2_a5 tiled sidewalk (crop 900,250-1600,650 of the 1672x942 image): 216/192/159 / 250/218/177. The iteration 2 sample (149/131/109) was not the sheet: the tan had darkened the paper below both ends. The new tone sits between today and the target. Asphalt unchanged (86/76/75 -> 88/78/77 mean).
- Composite: `gtai-masters/n5/look/print-3way-city-32ppm-it10.png` (today | it10 old tan | it10 tone | r2_a5 at 32 px/m; below, 64 px/m crops today | old tan | tone).

## Iteration 11 (2026-11-05 02:25-02:40)
- `after-it11-splat/`: the same city_frame shots (`--zooms=1,2 --foci=0,4`) with `world_riso.splat_k` 0.8 (splat_scale 0.07, splat_cut 0.79, splat_tone 0.5/0.48/0.47). Before = `after-it10-tone/`. Composite: `gtai-masters/n5/look/print-splat-it11-city0-vs-r2a5.png` (top: before | splat | r2_a5 at 32 px/m, 2x crops of city-0; below: before | splat at 64 px/m).
