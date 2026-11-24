# Bare hands in the arena, before

Game revision `869642e12`. Each take uses the arena's installed movement, aim and held sprint actions at 60 ticks/s. Both 6.75 and 9.30 m/s select the bare run8 sheet. After acceleration, the analysis checks selection, row, speed and ground displacement on every sampled tick. The actor starts each straight segment on the same stretch of boulevard.

The native screen position of each sole comes from the packed sheet's opaque bottom band and the rendered card transform, rounded to a viewport pixel. Subtracting the arena floor at the rig and undoing the zoom and ground foreshortening gives centimetres on the floor. Contact-to-push spans columns 0–2 and 4–6. Net drift compares the mean position of the first and last drawing in each complete stance. Along-track drift is comparable to the n24 profile ruler. The planar result also includes sideways motion. Excursion measures movement within a single support drawing. Partial drawings at the ends of a segment are discarded.

Raw frames, per-tick transforms and per-facing measurements are under `build/hands/before/`. The paired run uses identical input and fixed render ticks.

| Pitch | px/m | m/s | Facing | Hold (ticks) | Along (cm) | Planar (cm) | Mean excursion (cm) | Max excursion (cm) |
|---|---:|---:|---|---:|---:|---:|---:|---:|
| p55 | 32 | 6.75 | front | 6–7 | 146.2 | 147.9 | 60.3 | 67.5 |
| p55 | 32 | 6.75 | front right | 6–7 | 54.8 | 103.4 | 60.0 | 67.5 |
| p55 | 32 | 6.75 | right | 6–7 | 13.3 | 13.3 | 58.3 | 67.5 |
| p55 | 32 | 6.75 | back right | 6–7 | 142.8 | 143.6 | 60.8 | 67.5 |
| p55 | 32 | 6.75 | back | 6–7 | 136.9 | 136.9 | 57.3 | 67.5 |
| p55 | 32 | 6.75 | front left | 6–7 | 51.9 | 104.6 | 59.6 | 67.5 |
| p55 | 32 | 6.75 | left | 6–7 | 10.4 | 10.4 | 60.3 | 67.5 |
| p55 | 32 | 6.75 | back left | 6–7 | 119.9 | 133.9 | 56.3 | 56.3 |
| p55 | 32 | 9.30 | front | 4–5 | 141.4 | 144.0 | 54.3 | 62.0 |
| p55 | 32 | 9.30 | front right | 4–5 | 54.2 | 102.7 | 55.4 | 62.0 |
| p55 | 32 | 9.30 | right | 4–5 | 8.2 | 8.2 | 55.4 | 62.0 |
| p55 | 32 | 9.30 | back right | 4–5 | 149.2 | 150.2 | 54.3 | 62.0 |
| p55 | 32 | 9.30 | back | 4–5 | 139.5 | 139.5 | 54.3 | 62.0 |
| p55 | 32 | 9.30 | front left | 4–5 | 49.7 | 104.4 | 54.3 | 62.0 |
| p55 | 32 | 9.30 | left | 4–5 | 14.4 | 14.4 | 55.4 | 62.0 |
| p55 | 32 | 9.30 | back left | 4–5 | 107.0 | 126.3 | 55.4 | 62.0 |
| p55 | 64 | 6.75 | front | 6–7 | 146.2 | 148.0 | 60.3 | 67.5 |
| p55 | 64 | 6.75 | front right | 6–7 | 56.0 | 103.1 | 60.0 | 67.5 |
| p55 | 64 | 6.75 | right | 6–7 | 12.3 | 12.3 | 58.3 | 67.5 |
| p55 | 64 | 6.75 | back right | 6–7 | 143.2 | 144.0 | 60.8 | 67.5 |
| p55 | 64 | 6.75 | back | 6–7 | 136.9 | 136.9 | 57.3 | 67.5 |
| p55 | 64 | 6.75 | front left | 6–7 | 50.4 | 105.1 | 59.6 | 67.5 |
| p55 | 64 | 6.75 | left | 6–7 | 8.9 | 8.9 | 60.3 | 67.5 |
| p55 | 64 | 6.75 | back left | 6–7 | 120.4 | 133.6 | 56.3 | 56.3 |
| p55 | 64 | 9.30 | front | 4–5 | 141.4 | 144.0 | 54.3 | 62.0 |
| p55 | 64 | 9.30 | front right | 4–5 | 55.3 | 102.4 | 55.4 | 62.0 |
| p55 | 64 | 9.30 | right | 4–5 | 7.4 | 7.4 | 55.4 | 62.0 |
| p55 | 64 | 9.30 | back right | 4–5 | 149.7 | 150.8 | 54.3 | 62.0 |
| p55 | 64 | 9.30 | back | 4–5 | 139.5 | 139.5 | 54.2 | 62.0 |
| p55 | 64 | 9.30 | front left | 4–5 | 48.6 | 104.8 | 54.3 | 62.0 |
| p55 | 64 | 9.30 | left | 4–5 | 12.9 | 12.9 | 55.4 | 62.0 |
| p55 | 64 | 9.30 | back left | 4–5 | 108.2 | 126.5 | 55.4 | 62.0 |
| p70 | 32 | 6.75 | front | 6–7 | 144.4 | 144.6 | 60.7 | 67.5 |
| p70 | 32 | 6.75 | front right | 6–7 | 70.0 | 102.2 | 60.0 | 67.5 |
| p70 | 32 | 6.75 | right | 6–7 | 8.1 | 8.1 | 60.8 | 67.5 |
| p70 | 32 | 6.75 | back right | 6–7 | 147.3 | 147.4 | 59.6 | 67.5 |
| p70 | 32 | 6.75 | back | 6–7 | 144.4 | 144.6 | 61.3 | 67.5 |
| p70 | 32 | 6.75 | front left | 6–7 | 77.0 | 103.6 | 63.0 | 67.5 |
| p70 | 32 | 6.75 | left | 6–7 | 4.0 | 4.0 | 60.8 | 67.5 |
| p70 | 32 | 6.75 | back left | 6–7 | 72.2 | 103.4 | 61.9 | 67.5 |
| p70 | 32 | 9.30 | front | 4–5 | 143.4 | 143.6 | 56.5 | 62.0 |
| p70 | 32 | 9.30 | front right | 4–5 | 72.1 | 104.3 | 57.2 | 62.0 |
| p70 | 32 | 9.30 | right | 4–5 | 6.6 | 6.6 | 56.5 | 62.0 |
| p70 | 32 | 9.30 | back right | 4–5 | 146.4 | 146.5 | 57.2 | 62.0 |
| p70 | 32 | 9.30 | back | 4–5 | 143.4 | 143.6 | 56.0 | 62.0 |
| p70 | 32 | 9.30 | front left | 4–5 | 75.9 | 103.2 | 57.9 | 62.0 |
| p70 | 32 | 9.30 | left | 4–5 | 3.9 | 3.9 | 56.5 | 62.0 |
| p70 | 32 | 9.30 | back left | 4–5 | 71.3 | 102.8 | 56.5 | 62.0 |
| p70 | 64 | 6.75 | front | 6–7 | 144.4 | 144.5 | 60.7 | 67.5 |
| p70 | 64 | 6.75 | front right | 6–7 | 70.4 | 102.1 | 60.0 | 67.5 |
| p70 | 64 | 6.75 | right | 6–7 | 8.9 | 8.9 | 60.8 | 67.5 |
| p70 | 64 | 6.75 | back right | 6–7 | 147.3 | 147.4 | 59.6 | 67.5 |
| p70 | 64 | 6.75 | back | 6–7 | 144.4 | 144.6 | 61.3 | 67.5 |
| p70 | 64 | 6.75 | front left | 6–7 | 75.5 | 103.5 | 63.0 | 67.5 |
| p70 | 64 | 6.75 | left | 6–7 | 3.4 | 3.4 | 60.8 | 67.5 |
| p70 | 64 | 6.75 | back left | 6–7 | 72.2 | 103.4 | 61.9 | 67.5 |
| p70 | 64 | 9.30 | front | 4–5 | 143.4 | 143.6 | 56.5 | 62.0 |
| p70 | 64 | 9.30 | front right | 4–5 | 72.7 | 104.2 | 57.2 | 62.0 |
| p70 | 64 | 9.30 | right | 4–5 | 7.4 | 7.4 | 56.5 | 62.0 |
| p70 | 64 | 9.30 | back right | 4–5 | 146.4 | 146.5 | 57.2 | 62.0 |
| p70 | 64 | 9.30 | back | 4–5 | 143.4 | 143.6 | 56.0 | 62.0 |
| p70 | 64 | 9.30 | front left | 4–5 | 75.0 | 103.1 | 57.9 | 62.0 |
| p70 | 64 | 9.30 | left | 4–5 | 3.9 | 3.9 | 56.5 | 62.0 |
| p70 | 64 | 9.30 | back left | 4–5 | 71.3 | 102.8 | 56.5 | 62.0 |

## Eight-facing means

| Pitch | px/m | m/s | Along (cm) | Planar (cm) | Mean excursion (cm) |
|---|---:|---:|---:|---:|---:|
| p55 | 32 | 6.75 | 84.55 | 99.26 | 59.11 |
| p55 | 32 | 9.30 | 82.95 | 98.72 | 54.80 |
| p55 | 64 | 6.75 | 84.28 | 98.97 | 59.11 |
| p55 | 64 | 9.30 | 82.88 | 98.54 | 54.80 |
| p70 | 32 | 6.75 | 83.42 | 94.74 | 61.00 |
| p70 | 32 | 9.30 | 82.87 | 94.31 | 56.78 |
| p70 | 64 | 6.75 | 83.32 | 94.75 | 61.00 |
| p70 | 64 | 9.30 | 82.93 | 94.39 | 56.78 |
