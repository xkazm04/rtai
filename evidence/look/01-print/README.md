# 01-print: the D5 print toward the riso middle ground (n5-look, 2026-11-04)

- `before/`, `after/`: `dev/showcase/city_frame.tscn -- --zooms=1,2 --foci=0,4`, `--fixed-fps 60`, d3d12, seed 91. before = main a1275c82 (now `--look=today`), after = `--look=auto` with `world_riso`.
- `crop-0-{32,64}.png`: before | after, 480x300 crop at 2x nearest. `pair-4-32.png`: full street block, before | after.
- Mean tone check (PIL, crop 700,250-1200,350 of city-4-32): asphalt RGB 80.5/71.2/71.7 -> 81.0/71.6/72.1; paper 211.7/196.0/175.4 -> 211.9/196.1/175.5.
- Not yet: the full director reel (all kill chapters), a 64 px/m three-way with the target, frame cost (shader budget), paper warmth toward the target. See JOURNAL NEXT.
- Pan (shimmer): `city_frame --foci=4 --zooms=1 --pan=600` per look; residual after the camera shift (rows 250-550, 60 frame pairs): today and riso both 1.29 % of pixels > 24 (moving actors), median 0. Clip: `gtai-masters/n5/look/print-pan-today-vs-riso-32ppm.mp4`.
- Arena: `res://dev/arena/arena.tscn --write-movie --fixed-fps 60 --quit-after 1500 -- --bot=reel --reel=director --look=today|auto`, clip `gtai-masters/n5/look/arena-reel-today-vs-riso-32ppm.mp4` (first 25 s of the reel only).
- Look goldens: block site over the gate with this change only (main's tables restored: pass); re-blessed, decisions line.
