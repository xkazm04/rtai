# Spectral ghost verdicts, 20 November 2026

The owner review started from f96c8f938. The three view changes landed in order as a263c044d (proportions), ff3ad215c (Kerf size) and 86361843e (voice wash). `M/` below means `C:/Users/kazda/kiro/gtai-masters/n21/verdicts/`.

## Body proportions

Each entry gives the on-screen width/height divided by the source width/height. A value of 1.000 means the proportions match. Measurements use the resting HOVER pose, tick 88, at 64 px/m and alpha ≥128. The tilt reference is the matching PNG cell. The top reference uses the source cutouts assembled at their posed joints and rotations, with uniform scaling along each bone. The matte includes the drawn body and its painted ribbon. Detached effects are excluded.

| Form | Tilt 70° | Tilt 55° | Top |
| --- | ---: | ---: | ---: |
| Dent | 1.342 → 0.999 | 1.358 → 1.000 | 0.859 → 1.000 |
| Kerf | 1.338 → 1.001 | 1.359 → 1.001 | 1.000 |
| Ohm | 1.007 | 1.028 | 1.000 |
| Tonnage | 0.998 | 1.000 | 0.983 |

Dent and Kerf now use the authored height to set both screen axes. The inverse ground projection cancels the camera's vertical compression. Dent's dive still tips the cell. The other correction was Dent's overhead arms, whose width now follows their posed length. Ohm and Tonnage met the 3% tolerance in all three views.

The 70° before boards are `M/dent_aspect_before.png` and `M/kerf_aspect_before.png`. The three-way comparisons are `M/dent_aspect_after.png` and `M/kerf_aspect_after.png`. Those boards show the aspect commit. The table includes Kerf's subsequent size cut. The individual pixel bounds and source ratios are in `M/aspect_measurements.json`.

## Kerf at guard scale

The tilt and top rigs share a 0.75 size multiplier. The flight attachments use it for the lift, ground pool and tail socket. The charge slots and echo inherit the drawing's transform. At 32 px/m the reference guard is 43 px tall in both tilts.

| View | Armour with blades, before → after | Full silhouette with ribbon, before → after |
| --- | --- | --- |
| Tilt 70° | About 85 → 64 px (1.49 guards after) | 129 → 97 px |
| Tilt 55° | About 80 → 60 px (1.40 guards after) | 124 → 94 px |
| Top | Guard silhouette is 52 × 38 px | 121 × 160 → 89 × 120 px |

The armour measurement runs from the blade tip to the lower waist plate. The full silhouette includes the trailing swarf. The matched before and after guard shots are in `M/kerf_size_32.png`.

## Speaking wash

Spectral voice band strength rose from 0.20 to 0.45. Kerf's speaking apparition washes the tilted card and the assembled overhead parts. At native 32 px/m the bands cross the armour and leave the helmet detail legible. The 4× comparison is in `M/voice_wash_strength.png`. All twelve spectral comparisons changed inside the body crop. All twelve matched legacy frames were pixel-identical before and after the voice change.

## Films

All three films were rendered from 86361843e. Each pairs the 70° view with the overhead view at 32 px/m. ffprobe verified H.264 at 1920 × 1080 and 60 fps. All eight chapters of the combined reel were visually checked.

| Film | Duration | Frames | SHA-256 |
| --- | ---: | ---: | --- |
| `M/kerf_attack_32.mp4` | 5 s | 300 | 5966337c76b31a99329bffa41784be8870915cadaa18984ce22f53a0012a26ef |
| `M/kerf_move_32.mp4` | 5 s | 300 | 26c380a31438107b2b3f7403b5ddd5e53e3c905e690e58f94fd88aba2d4173b2 |
| `M/all_ghosts_32.mp4` | 40 s | 2,400 | 308fba1d23bb46071510b00a8dd1e27f62177aa4d266a0454b94f3558aec345b |

## Verification

The changed unit suite passed before each code commit with 3,378 passed, zero failed and two skipped. Lint passed all 19 checks. Godot imported the shader changes successfully. The only tracked edit outside the souls views, unit tests and this report was `tools/debt/baseline.json`. Its dev line count tightened from 26,602 to 26,600 after the lane merge.

The following checks ran independently on the starting merge and the final code. The full gate belongs to the Director. The before and after output is in `M/digest_comparison.log`. Per-frame voice difference counts are in `M/voice_wash_pixels.json`.

| Check | Result on both revisions |
| --- | --- |
| 60-second replay | 3,600 ticks, 60 checkpoints, final digest cbeb734ff9b97c41 |
| Kerf in quest 1 | Byte-identical result file, state hash starting 26fa9dc0 |
| Four ghost attacks | Byte-identical result file, SHA-256 starting 26c0d14f |
| Native and GDScript parity | Identical over 1,200 steps, final digest 94b2865f7f17d778. Both caught the planted mismatch at step 629. |
| City bake | All 256 chunks matched the committed golden hashes on two bakes per revision. |
