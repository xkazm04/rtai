# Bare hands in the arena, after

Commit `fba046f21` has the exact staged game tree `8481d0eff214031d5fd1c31f387372280983edb6`. Each take uses the arena's installed movement, aim and held sprint actions at 60 ticks/s. Both 6.75 and 9.30 m/s select the bare run8 sheet. After acceleration, the analysis checks selection, row, speed and ground displacement on every sampled tick. The actor starts each straight segment on the same stretch of boulevard.

The native screen position of each sole comes from the packed sheet's opaque bottom band and the rendered card transform, rounded to a viewport pixel. Subtracting the arena floor at the rig and undoing the zoom and ground foreshortening gives centimetres on the floor. Contact-to-push spans columns 0–2 and 4–6. Net drift compares the mean position of the first and last drawing in each complete stance. Along-track drift is comparable to the n24 profile ruler. The planar result also includes sideways motion. Excursion measures movement within a single support drawing. Partial drawings at the ends of a segment are discarded.

Raw frames, per-tick transforms and per-facing measurements are under `build/hands/after/`. The paired run uses identical input and fixed render ticks.

Each cell gives before → after.

| Pitch | px/m | m/s | Facing | Hold (ticks) | Along (cm) | Planar (cm) | Mean excursion (cm) | Max excursion (cm) |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| p55 | 32 | 6.75 | front | 6–7 → 1–1 | 146.2 → 22.5 | 147.9 → 33.5 | 60.3 → 0.0 | 67.5 → 0.0 |
| p55 | 32 | 6.75 | front right | 6–7 → 3–4 | 54.8 → 4.0 | 103.4 → 87.2 | 60.0 → 31.6 | 67.5 → 33.8 |
| p55 | 32 | 6.75 | right | 6–7 → 6–7 | 13.3 → 5.3 | 13.3 → 5.3 | 58.3 → 63.0 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | back right | 6–7 → 1–1 | 142.8 → 30.2 | 143.6 → 34.5 | 60.8 → 0.0 | 67.5 → 0.0 |
| p55 | 32 | 6.75 | back | 6–7 → 1–1 | 136.9 → 22.5 | 136.9 → 22.6 | 57.3 → 0.0 | 67.5 → 0.0 |
| p55 | 32 | 6.75 | front left | 6–7 → 4–5 | 51.9 → 2.5 | 104.6 → 91.8 | 59.6 → 35.2 | 67.5 → 45.0 |
| p55 | 32 | 6.75 | left | 6–7 → 5–7 | 10.4 → 1.7 | 10.4 → 1.7 | 60.3 → 56.3 | 67.5 → 67.5 |
| p55 | 32 | 6.75 | back left | 6–7 → 1–4 | 119.9 → 25.1 | 133.9 → 59.0 | 56.3 → 14.1 | 56.3 → 33.8 |
| p55 | 32 | 9.30 | front | 4–5 → 1–1 | 141.4 → 31.0 | 144.0 → 40.1 | 54.3 → 0.0 | 62.0 → 0.0 |
| p55 | 32 | 9.30 | front right | 4–5 → 2–3 | 54.2 → 5.4 | 102.7 → 87.4 | 55.4 → 28.3 | 62.0 → 31.0 |
| p55 | 32 | 9.30 | right | 4–5 → 4–5 | 8.2 → 2.3 | 8.2 → 2.3 | 55.4 → 59.6 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | back right | 4–5 → 1–1 | 149.2 → 38.7 | 150.2 → 42.1 | 54.3 → 0.0 | 62.0 → 0.0 |
| p55 | 32 | 9.30 | back | 4–5 → 1–1 | 139.5 → 31.0 | 139.5 → 31.1 | 54.3 → 0.0 | 62.0 → 0.0 |
| p55 | 32 | 9.30 | front left | 4–5 → 2–4 | 49.7 → 3.4 | 104.4 → 91.8 | 54.3 → 30.3 | 62.0 → 46.5 |
| p55 | 32 | 9.30 | left | 4–5 → 4–5 | 14.4 → 4.0 | 14.4 → 4.0 | 55.4 → 53.7 | 62.0 → 62.0 |
| p55 | 32 | 9.30 | back left | 4–5 → 1–3 | 107.0 → 29.2 | 126.3 → 63.6 | 55.4 → 12.9 | 62.0 → 31.0 |
| p55 | 64 | 6.75 | front | 6–7 → 1–1 | 146.2 → 22.5 | 148.0 → 33.8 | 60.3 → 0.0 | 67.5 → 0.0 |
| p55 | 64 | 6.75 | front right | 6–7 → 3–4 | 56.0 → 3.8 | 103.1 → 86.1 | 60.0 → 31.6 | 67.5 → 33.8 |
| p55 | 64 | 6.75 | right | 6–7 → 6–7 | 12.3 → 4.5 | 12.3 → 4.5 | 58.3 → 63.0 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | back right | 6–7 → 1–1 | 143.2 → 30.8 | 144.0 → 35.3 | 60.8 → 0.0 | 67.5 → 0.0 |
| p55 | 64 | 6.75 | back | 6–7 → 1–1 | 136.9 → 22.5 | 136.9 → 22.5 | 57.3 → 0.0 | 67.5 → 0.0 |
| p55 | 64 | 6.75 | front left | 6–7 → 4–5 | 50.4 → 2.0 | 105.1 → 92.9 | 59.6 → 35.2 | 67.5 → 45.0 |
| p55 | 64 | 6.75 | left | 6–7 → 5–7 | 8.9 → 2.4 | 8.9 → 2.4 | 60.3 → 56.3 | 67.5 → 67.5 |
| p55 | 64 | 6.75 | back left | 6–7 → 1–4 | 120.4 → 24.2 | 133.6 → 57.8 | 56.3 → 14.1 | 56.3 → 33.8 |
| p55 | 64 | 9.30 | front | 4–5 → 1–1 | 141.4 → 31.0 | 144.0 → 40.3 | 54.3 → 0.0 | 62.0 → 0.0 |
| p55 | 64 | 9.30 | front right | 4–5 → 2–3 | 55.3 → 5.3 | 102.4 → 86.3 | 55.4 → 28.3 | 62.0 → 31.0 |
| p55 | 64 | 9.30 | right | 4–5 → 4–5 | 7.4 → 3.1 | 7.4 → 3.1 | 55.4 → 59.6 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | back right | 4–5 → 1–1 | 149.7 → 39.3 | 150.8 → 42.9 | 54.3 → 0.0 | 62.0 → 0.0 |
| p55 | 64 | 9.30 | back | 4–5 → 1–1 | 139.5 → 31.0 | 139.5 → 31.0 | 54.2 → 0.0 | 62.0 → 0.0 |
| p55 | 64 | 9.30 | front left | 4–5 → 2–4 | 48.6 → 3.8 | 104.8 → 92.9 | 54.3 → 30.3 | 62.0 → 46.5 |
| p55 | 64 | 9.30 | left | 4–5 → 4–5 | 12.9 → 3.7 | 12.9 → 3.7 | 55.4 → 53.7 | 62.0 → 62.0 |
| p55 | 64 | 9.30 | back left | 4–5 → 1–3 | 108.2 → 28.9 | 126.5 → 62.4 | 55.4 → 12.9 | 62.0 → 31.0 |
| p70 | 32 | 6.75 | front | 6–7 → 1–1 | 144.4 → 22.5 | 144.6 → 23.9 | 60.7 → 0.0 | 67.5 → 0.0 |
| p70 | 32 | 6.75 | front right | 6–7 → 3–4 | 70.0 → 1.7 | 102.2 → 75.2 | 60.0 → 25.9 | 67.5 → 33.8 |
| p70 | 32 | 6.75 | right | 6–7 → 6–7 | 8.1 → 0.9 | 8.1 → 0.9 | 60.8 → 64.1 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | back right | 6–7 → 1–1 | 147.3 → 23.6 | 147.4 → 24.2 | 59.6 → 0.0 | 67.5 → 0.0 |
| p70 | 32 | 6.75 | back | 6–7 → 1–1 | 144.4 → 22.5 | 144.6 → 23.9 | 61.3 → 0.0 | 67.5 → 0.0 |
| p70 | 32 | 6.75 | front left | 6–7 → 3–4 | 77.0 → 3.2 | 103.6 → 69.6 | 63.0 → 24.1 | 67.5 → 33.8 |
| p70 | 32 | 6.75 | left | 6–7 → 6–7 | 4.0 → 3.7 | 4.0 → 3.7 | 60.8 → 58.5 | 67.5 → 67.5 |
| p70 | 32 | 6.75 | back left | 6–7 → 3–4 | 72.2 → 3.2 | 103.4 → 74.1 | 61.9 → 25.5 | 67.5 → 33.8 |
| p70 | 32 | 9.30 | front | 4–5 → 1–1 | 143.4 → 31.0 | 143.6 → 32.0 | 56.5 → 0.0 | 62.0 → 0.0 |
| p70 | 32 | 9.30 | front right | 4–5 → 2–3 | 72.1 → 3.0 | 104.3 → 75.0 | 57.2 → 22.1 | 62.0 → 31.0 |
| p70 | 32 | 9.30 | right | 4–5 → 4–5 | 6.6 → 4.3 | 6.6 → 4.3 | 56.5 → 59.8 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | back right | 4–5 → 1–1 | 146.4 → 32.1 | 146.5 → 32.6 | 57.2 → 0.0 | 62.0 → 0.0 |
| p70 | 32 | 9.30 | back | 4–5 → 1–1 | 143.4 → 31.0 | 143.6 → 32.0 | 56.0 → 0.0 | 62.0 → 0.0 |
| p70 | 32 | 9.30 | front left | 4–5 → 2–3 | 75.9 → 4.8 | 103.2 → 70.0 | 57.9 → 20.8 | 62.0 → 31.0 |
| p70 | 32 | 9.30 | left | 4–5 → 4–5 | 3.9 → 3.9 | 3.9 → 3.9 | 56.5 → 56.5 | 62.0 → 62.0 |
| p70 | 32 | 9.30 | back left | 4–5 → 2–3 | 71.3 → 3.3 | 102.8 → 74.1 | 56.5 → 21.6 | 62.0 → 31.0 |
| p70 | 64 | 6.75 | front | 6–7 → 1–1 | 144.4 → 22.5 | 144.5 → 23.7 | 60.7 → 0.0 | 67.5 → 0.0 |
| p70 | 64 | 6.75 | front right | 6–7 → 3–4 | 70.4 → 2.2 | 102.1 → 74.6 | 60.0 → 25.9 | 67.5 → 33.8 |
| p70 | 64 | 6.75 | right | 6–7 → 6–7 | 8.9 → 0.5 | 8.9 → 0.5 | 60.8 → 64.1 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | back right | 6–7 → 1–1 | 147.3 → 23.6 | 147.4 → 24.2 | 59.6 → 0.0 | 67.5 → 0.0 |
| p70 | 64 | 6.75 | back | 6–7 → 1–1 | 144.4 → 22.5 | 144.6 → 23.9 | 61.3 → 0.0 | 67.5 → 0.0 |
| p70 | 64 | 6.75 | front left | 6–7 → 3–4 | 75.5 → 4.5 | 103.5 → 70.9 | 63.0 → 24.1 | 67.5 → 33.8 |
| p70 | 64 | 6.75 | left | 6–7 → 6–7 | 3.4 → 4.3 | 3.4 → 4.3 | 60.8 → 58.5 | 67.5 → 67.5 |
| p70 | 64 | 6.75 | back left | 6–7 → 3–4 | 72.2 → 3.2 | 103.4 → 74.1 | 61.9 → 25.5 | 67.5 → 33.8 |
| p70 | 64 | 9.30 | front | 4–5 → 1–1 | 143.4 → 31.0 | 143.6 → 31.9 | 56.5 → 0.0 | 62.0 → 0.0 |
| p70 | 64 | 9.30 | front right | 4–5 → 2–3 | 72.7 → 3.2 | 104.2 → 74.5 | 57.2 → 22.1 | 62.0 → 31.0 |
| p70 | 64 | 9.30 | right | 4–5 → 4–5 | 7.4 → 5.1 | 7.4 → 5.1 | 56.5 → 59.8 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | back right | 4–5 → 1–1 | 146.4 → 32.1 | 146.5 → 32.6 | 57.2 → 0.0 | 62.0 → 0.0 |
| p70 | 64 | 9.30 | back | 4–5 → 1–1 | 143.4 → 31.0 | 143.6 → 32.0 | 56.0 → 0.0 | 62.0 → 0.0 |
| p70 | 64 | 9.30 | front left | 4–5 → 2–3 | 75.0 → 4.2 | 103.1 → 70.9 | 57.9 → 20.8 | 62.0 → 31.0 |
| p70 | 64 | 9.30 | left | 4–5 → 4–5 | 3.9 → 3.9 | 3.9 → 3.9 | 56.5 → 56.5 | 62.0 → 62.0 |
| p70 | 64 | 9.30 | back left | 4–5 → 2–3 | 71.3 → 3.3 | 102.8 → 74.1 | 56.5 → 21.6 | 62.0 → 31.0 |

## Eight-facing means

| Pitch | px/m | m/s | Along (cm) | Planar (cm) | Mean excursion (cm) |
|---|---:|---:|---:|---:|---:|
| p55 | 32 | 6.75 | 84.55 → 14.22 | 99.26 → 41.95 | 59.11 → 25.01 |
| p55 | 32 | 9.30 | 82.95 → 18.13 | 98.72 → 45.30 | 54.80 → 23.11 |
| p55 | 64 | 6.75 | 84.28 → 14.08 | 98.97 → 41.90 | 59.11 → 25.01 |
| p55 | 64 | 9.30 | 82.88 → 18.26 | 98.54 → 45.32 | 54.80 → 23.11 |
| p70 | 32 | 6.75 | 83.42 → 10.17 | 94.74 → 36.94 | 61.00 → 24.76 |
| p70 | 32 | 9.30 | 82.87 → 14.17 | 94.31 → 40.48 | 56.78 → 22.60 |
| p70 | 64 | 6.75 | 83.32 → 10.40 | 94.75 → 37.02 | 61.00 → 24.76 |
| p70 | 64 | 9.30 | 82.93 → 14.23 | 94.39 → 40.61 | 56.78 → 22.60 |

Both revisions matched world position, ground reference, row, strip, speed and tick in 5,888 paired samples. The default and sprint speeds both use run8. Walk8 was calibrated separately from its contact-to-passing drawings (0–3 and 4–7), including stretch and lift from the shipped bob table. The table stores a separate full-cycle length per support boot and facing in 110-pixel figure space. Negative or zero projected travel takes the fastest available cadence, one drawing per tick. The greatest measured excursion within a held sprint drawing at 32 px/m was 62.0 cm. At 6.75 m/s, 12.2 cm mean along-track drift across the two pitches exceeded the 2 cm target. At 9.30 m/s, 16.2 cm mean along-track drift across the two pitches exceeded the 6 cm target. The depth poses have little backwards ground travel between contact and push. Two pose advances still cost at least two ticks, or 22.5 cm at 6.75 m/s and 31.0 cm at 9.30 m/s.

The side-by-side film pairs 960 native-size arena crops at identical ticks. FFprobe reports 1920 x 1080, 60/1 fps and 16.000 seconds. The 64 px/m still pairs the two right-profile speeds. Both are in `C:/Users/kazda/kiro/gtai-masters/n26/keys/`.
