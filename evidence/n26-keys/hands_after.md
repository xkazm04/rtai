# Bare hands in the arena

## Profile stance drift

At 32 px/m, mean contact-to-push drift along the ground on the left and right profiles was **8.96 → 2.11 cm at 6.75 m/s** and **8.28 → 5.48 cm at 9.30 m/s**. Each pitch and each profile counts equally. The respective targets are 2 and 6 cm. Both game speeds select the bare run8 sheet.

| Pitch | px/m | Speed (m/s) | Right drift (cm) | Left drift (cm) | Profile mean (cm) | Target |
|---|---:|---:|---:|---:|---:|---|
| p70 | 32 | 6.75 | 8.12 → 0.94 | 3.96 → 2.92 | 6.04 → 1.93 | met |
| p70 | 32 | 9.30 | 6.62 → 2.56 | 3.87 → 2.31 | 5.25 → 2.44 | met |
| p70 | 64 | 6.75 | 8.90 → 0.46 | 3.44 → 2.92 | 6.17 → 1.69 | 64 px/m detail |
| p70 | 64 | 9.30 | 7.41 → 3.34 | 3.87 → 3.09 | 5.64 → 3.22 | 64 px/m detail |
| p55 | 32 | 6.75 | 13.33 → 3.13 | 10.42 → 1.46 | 11.87 → 2.29 | missed |
| p55 | 32 | 9.30 | 8.19 → 9.31 | 14.44 → 7.75 | 11.31 → 8.53 | missed |
| p55 | 64 | 6.75 | 12.29 → 3.91 | 8.85 → 0.52 | 10.57 → 2.22 | 64 px/m detail |
| p55 | 64 | 9.30 | 7.41 → 8.53 | 12.87 → 7.75 | 10.14 → 8.14 | 64 px/m detail |

The p55 sprint profile mean was 3.17 cm in the earlier `fba046f21` take. With the corrected depth cadence it is 8.53 cm. Both profile takes contain four complete stances per facing. At the first sampled sprint tick, the right and left profiles were in columns 3 and 6 in the earlier take and 5 and 0 in this one. The measured p55 profile cycle lengths are the same in both revisions.

## Drawing holds and front-facing travel

Front and back have no drawn backward stride along the direction of travel. They use the original pitch cycle and speed cap for both boots. At 32 px/m the front/back holds were 6–7 ticks at 6.75 m/s and 4–5 ticks at 9.30 m/s. Front/back mean in-drawing excursion was 59.9 → 60.7 cm and 55.3 → 55.9 cm, respectively. At 6.75 m/s each tick advances 11.25 cm. Holding one drawing for six or seven sampled ticks moves its sole 56.25 or 67.50 cm between the first and last sample. This is the limit of a held sprite.

The p70 front-right diagonal at 6.75 m/s changed from 69.98 → 1.68 cm. Across all sprint rows at both zooms, the shortest complete drawing held 2 ticks. At 32 px/m the maximum excursion within a sprint drawing was 62.0 cm.

## Every facing, before and after

| Pitch | px/m | Speed (m/s) | Facing | Hold (ticks) | Along-track drift (cm) | Planar drift (cm) | Mean excursion (cm) | Max excursion (cm) |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| p55 | 32 | 6.75 | front | 6–7 → 6–7 | 146.2 → 138.7 | 147.9 → 140.5 | 60.3 → 58.5 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | front right | 6–7 → 3–4 | 54.8 → 3.7 | 103.4 → 87.4 | 60.0 → 32.5 | 67.5 → 33.8 |
| p55 | 32 | 6.75 | right | 6–7 → 6–7 | 13.3 → 3.1 | 13.3 → 3.1 | 58.3 → 66.3 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | back right | 6–7 → 6–7 | 142.8 → 142.8 | 143.6 → 143.6 | 60.8 → 59.3 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | back | 6–7 → 6–7 | 136.9 → 142.5 | 136.9 → 142.5 | 57.3 → 59.6 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | front left | 6–7 → 3–5 | 51.9 → 1.9 | 104.6 → 92.4 | 59.6 → 35.3 | 67.5 → 45.0 |
| p55 | 32 | 6.75 | left | 6–7 → 5–7 | 10.4 → 1.5 | 10.4 → 1.5 | 60.3 → 55.2 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | back left | 6–7 → 3–7 | 119.9 → 81.9 | 133.9 → 116.7 | 56.3 → 41.8 | 56.3 → 67.5 |
| p55 | 32 | 9.30 | front | 4–5 → 4–5 | 141.4 → 141.1 | 144.0 → 143.1 | 54.3 → 54.8 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | front right | 4–5 → 2–3 | 54.2 → 4.9 | 102.7 → 87.5 | 55.4 → 27.1 | 62.0 → 31.0 |
| p55 | 32 | 9.30 | right | 4–5 → 4–5 | 8.2 → 9.3 | 8.2 → 9.3 | 55.4 → 59.6 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | back right | 4–5 → 4–5 | 149.2 → 147.2 | 150.2 → 148.3 | 54.3 → 54.3 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | back | 4–5 → 4–5 | 139.5 → 141.4 | 139.5 → 141.5 | 54.3 → 54.3 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | front left | 4–5 → 2–4 | 49.7 → 3.7 | 104.4 → 92.3 | 54.3 → 31.7 | 62.0 → 46.5 |
| p55 | 32 | 9.30 | left | 4–5 → 3–5 | 14.4 → 7.7 | 14.4 → 7.7 | 55.4 → 53.1 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | back left | 4–5 → 2–5 | 107.0 → 63.9 | 126.3 → 108.7 | 55.4 → 40.1 | 62.0 → 62.0 |
| p55 | 64 | 6.75 | front | 6–7 → 6–7 | 146.2 → 138.7 | 148.0 → 140.5 | 60.3 → 58.5 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | front right | 6–7 → 3–4 | 56.0 → 4.1 | 103.1 → 86.3 | 60.0 → 32.5 | 67.5 → 33.8 |
| p55 | 64 | 6.75 | right | 6–7 → 6–7 | 12.3 → 3.9 | 12.3 → 3.9 | 58.3 → 66.3 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | back right | 6–7 → 6–7 | 143.2 → 143.2 | 144.0 → 144.0 | 60.8 → 59.3 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | back | 6–7 → 6–7 | 136.9 → 142.5 | 136.9 → 142.5 | 57.3 → 59.6 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | front left | 6–7 → 3–5 | 50.4 → 1.5 | 105.1 → 93.3 | 59.6 → 35.3 | 67.5 → 45.0 |
| p55 | 64 | 6.75 | left | 6–7 → 5–7 | 8.9 → 0.5 | 8.9 → 0.5 | 60.3 → 55.2 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | back left | 6–7 → 3–7 | 120.4 → 79.6 | 133.6 → 115.5 | 56.3 → 41.8 | 56.3 → 67.5 |
| p55 | 64 | 9.30 | front | 4–5 → 4–5 | 141.4 → 141.1 | 144.0 → 143.2 | 54.3 → 54.8 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | front right | 4–5 → 2–3 | 55.3 → 4.4 | 102.4 → 86.4 | 55.4 → 27.1 | 62.0 → 31.0 |
| p55 | 64 | 9.30 | right | 4–5 → 4–5 | 7.4 → 8.5 | 7.4 → 8.5 | 55.4 → 59.6 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | back right | 4–5 → 4–5 | 149.7 → 147.8 | 150.8 → 148.9 | 54.3 → 54.3 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | back | 4–5 → 4–5 | 139.5 → 141.4 | 139.5 → 141.4 | 54.2 → 54.3 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | front left | 4–5 → 2–4 | 48.6 → 2.7 | 104.8 → 93.2 | 54.3 → 31.7 | 62.0 → 46.5 |
| p55 | 64 | 9.30 | left | 4–5 → 3–5 | 12.9 → 7.7 | 12.9 → 7.7 | 55.4 → 53.1 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | back left | 4–5 → 2–5 | 108.2 → 65.6 | 126.5 → 107.8 | 55.4 → 40.1 | 62.0 → 62.0 |
| p70 | 32 | 6.75 | front | 6–7 → 6–7 | 144.4 → 146.2 | 144.6 → 146.4 | 60.7 → 63.0 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | front right | 6–7 → 3–4 | 70.0 → 1.7 | 102.2 → 75.2 | 60.0 → 25.9 | 67.5 → 33.8 |
| p70 | 32 | 6.75 | right | 6–7 → 6–7 | 8.1 → 0.9 | 8.1 → 0.9 | 60.8 → 65.0 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | back right | 6–7 → 6–7 | 147.3 → 145.5 | 147.4 → 145.6 | 59.6 → 63.0 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | back | 6–7 → 6–7 | 144.4 → 146.3 | 144.6 → 146.4 | 61.3 → 61.9 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | front left | 6–7 → 3–4 | 77.0 → 4.3 | 103.6 → 69.8 | 63.0 → 23.5 | 67.5 → 33.8 |
| p70 | 32 | 6.75 | left | 6–7 → 6–7 | 4.0 → 2.9 | 4.0 → 2.9 | 60.8 → 60.8 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | back left | 6–7 → 3–4 | 72.2 → 2.2 | 103.4 → 74.1 | 61.9 → 25.3 | 67.5 → 33.8 |
| p70 | 32 | 9.30 | front | 4–5 → 4–5 | 143.4 → 145.3 | 143.6 → 145.5 | 56.5 → 57.2 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | front right | 4–5 → 2–3 | 72.1 → 3.1 | 104.3 → 75.0 | 57.2 → 21.6 | 62.0 → 31.0 |
| p70 | 32 | 9.30 | right | 4–5 → 4–5 | 6.6 → 2.6 | 6.6 → 2.6 | 56.5 → 59.6 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | back right | 4–5 → 4–5 | 146.4 → 146.4 | 146.5 → 146.5 | 57.2 → 56.0 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | back | 4–5 → 4–5 | 143.4 → 145.3 | 143.6 → 145.5 | 56.0 → 57.2 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | front left | 4–5 → 2–3 | 75.9 → 3.2 | 103.2 → 69.9 | 57.9 → 20.8 | 62.0 → 31.0 |
| p70 | 32 | 9.30 | left | 4–5 → 4–5 | 3.9 → 2.3 | 3.9 → 2.3 | 56.5 → 56.5 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | back left | 4–5 → 2–3 | 71.3 → 2.9 | 102.8 → 74.1 | 56.5 → 21.0 | 62.0 → 31.0 |
| p70 | 64 | 6.75 | front | 6–7 → 6–7 | 144.4 → 146.2 | 144.5 → 146.4 | 60.7 → 63.0 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | front right | 6–7 → 3–4 | 70.4 → 2.2 | 102.1 → 74.6 | 60.0 → 25.9 | 67.5 → 33.8 |
| p70 | 64 | 6.75 | right | 6–7 → 6–7 | 8.9 → 0.5 | 8.9 → 0.5 | 60.8 → 65.0 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | back right | 6–7 → 6–7 | 147.3 → 145.5 | 147.4 → 145.6 | 59.6 → 63.0 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | back | 6–7 → 6–7 | 144.4 → 146.3 | 144.6 → 146.4 | 61.3 → 61.9 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | front left | 6–7 → 3–4 | 75.5 → 3.9 | 103.5 → 70.8 | 63.0 → 23.5 | 67.5 → 33.8 |
| p70 | 64 | 6.75 | left | 6–7 → 6–7 | 3.4 → 2.9 | 3.4 → 2.9 | 60.8 → 60.8 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | back left | 6–7 → 3–4 | 72.2 → 2.2 | 103.4 → 74.1 | 61.9 → 25.3 | 67.5 → 33.8 |
| p70 | 64 | 9.30 | front | 4–5 → 4–5 | 143.4 → 145.3 | 143.6 → 145.5 | 56.5 → 57.2 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | front right | 4–5 → 2–3 | 72.7 → 3.4 | 104.2 → 74.5 | 57.2 → 21.6 | 62.0 → 31.0 |
| p70 | 64 | 9.30 | right | 4–5 → 4–5 | 7.4 → 3.3 | 7.4 → 3.3 | 56.5 → 59.6 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | back right | 4–5 → 4–5 | 146.4 → 146.4 | 146.5 → 146.5 | 57.2 → 56.0 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | back | 4–5 → 4–5 | 143.4 → 145.3 | 143.6 → 145.5 | 56.0 → 57.2 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | front left | 4–5 → 2–3 | 75.0 → 2.9 | 103.1 → 70.8 | 57.9 → 20.8 | 62.0 → 31.0 |
| p70 | 64 | 9.30 | left | 4–5 → 4–5 | 3.9 → 3.1 | 3.9 → 3.1 | 56.5 → 56.5 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | back left | 4–5 → 2–3 | 71.3 → 2.9 | 102.8 → 74.1 | 56.5 → 21.0 | 62.0 → 31.0 |

## Capture and measurement

The before take used `869642e12`. The new take used `a78c5f4c9`. Both drove the live arena with its installed move, aim and sprint actions at 60 ticks/s on the same boulevard. All 5,888 sampled ticks matched in simulation position, screen ground point, pitch projection, speed, facing, strip and hand selection. The 32 px/m film pairs 960 native-size frames at matching ticks (1920 × 1080, 60 fps, 16.000 s), including straight approaches toward the camera at 2–3 and 10–11 seconds. The 64 px/m still shows the right profile and a straight approach toward the camera at each speed.

Each pitch uses its original cycle when a support boot's projected travel falls below 40% of that cycle. A measured boot uses its own cycle with a 3.75 cycles/s ceiling. Phase carries across a turn, so the pose number on entry depends on the preceding facing. This lets one boot keep the original cadence when its partner has measurable travel.

The opaque bottom band of each packed sole is transformed into viewport pixels and rounded on that zoom's native pixel grid. Subtracting the rig's screen ground point and undoing the zoom and foreshortening gives floor centimetres. Contact-to-push compares the mean floor positions in columns 0 and 2 or 4 and 6. Along-track drift projects that displacement onto the movement axis. Planar drift also includes lateral displacement. In-drawing excursion measures the first-to-last displacement of a complete support drawing. Partial drawings at the ends of a segment are excluded.

Raw frames, per-tick transforms and measurements are under `build/hands/before/` and `build/hands/finish/`. The film and close-up are in `C:/Users/kazda/kiro/gtai-masters/n26/keys/`.
