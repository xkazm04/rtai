# 18 D5 earlier than 64 px/m (work order item 2), d5-city iteration 4, 2026-11-03

Real game (dev/showcase/city_frame.tscn: real World + CitySystem + CityView, seed 91), foci 1 (roofs),
2 and 4 (streets), 32 and 48 px/m, the pixel-snapped camera (17-snap-cam). Three looks:

- `auto` before this change: D4 print, D5 overlay ramp 0 up to 48 px/m, 1 at 64.
- `ramp50` (adopted): overlay 0.5 at 32 px/m, 0.75 at 48, 1 at 64 (`look_profiles.json` amount_ppm).
- `--look=d5`: the overlay at 1 at every zoom.

Readability gate against D4 (gate-32ppm.txt; edge = mean |gradient|, ink = share L < 60, paper = mean
of L > 170 vs T1's (239,219,194)):

| frame | edge auto / ramp / d5 | paper dE to T1 auto / ramp / d5 |
|---|---|---|
| city-1 32 px/m roofs | 51.0 / 49.4 (97 %) / 48.4 | 12.5 / 8.6 / 15.6 |
| city-1 48 px/m roofs | 48.0 / 46.1 (96 %) / 46.0 | 12.5 / 9.5 / 13.8 |
| city-2 32 px/m | 31.1 / 30.2 (97 %) / 30.5 | 13.1 / 4.2 / 10.9 |
| city-4 32 px/m | 26.1 / 25.3 (97 %) / 26.2 | 14.0 / 2.9 / 9.8 |
| city-2 48 px/m | 22.4 / 21.9 (98 %) / 22.8 | 14.1 / 3.3 / 8.7 |

Verdict: ramp50 holds D4's read (every roof item, kerb line, sign and prop still reads at 32 px/m,
edge energy 96-98 %) and warms the cool D4 paper to T1's beige. Full D5 at 32 px/m is rejected: the
paper overshoots to orange and the asphalt gets patchy diagonal hatch blocks. Shimmer: no swim under a
pan with the snapped camera at either look (17-snap-cam). Camera breaks rejected: 0 (all frames
straight down). Full frames: gtai-masters/day-d5/d5-city/i4/18-d5-earlier/.

Files: strip-*.png (auto | ramp | d5 crops), keep/<auto|ramp50>-<frame>.png (full frames), t1-crop.png.
