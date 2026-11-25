# n29 hall: readability at the front (n29-05 item 6, measured in n29-07 hall-polish)

## Measured (n29-07, 04:23 to 04:25)

Method of `floor_i55_bars.md` (`dusk_contrast.py`, `rivet_delta.py`, pools from the measured row), but every measured exposure on the FRONT camera (26, 3) at 32 px/m instead of the mid fight camera: `yard_stills --dusk=front` (`150130b8a`, `YardDuskCapture.place`), seed 7, ticks 3000..5600 + the round frames, one Godot per capture. Now = `arched_line` at `150130b8a` (= `62982244a`'s row: tall hall, roof glow, wall mouth lights, flipped feed / shutter E bays, and belt-finish's belt-snake spans). n28 = `c649a15d6`'s `arched_line` as a temp row `arched_n28` (+ day twins `arched_n28_day` / `arched_day` with the day grade and no pools, as `imp_row.py`), all three removed afterwards (`git diff` of the table empty). Scripts `build/n29-07/bars.sh`, `temprows.py`; raw `build/n29-07/bars/{now,n28}/`.

| measure | n28 c649a15d6 | now | bar | n28 | now |
|---|---|---|---|---|---|
| patrol blue outside (beyond every pool), % of day | no cop on screen | no cop on screen | >= 65 | n/a | n/a |
| patrol blue inside (fire pool core), % of day | 87.2 (4 cops) | 79.1 (4 cops) | >= 65 | pass | pass |
| patrol blue between (inside a pool radius, not core), % of day | 84.4 (8 cops) | 81.0 (8 cops) | info (>= 65) | pass | pass |
| rifle retained % | not measurable | not measurable | >= 95 | n/a | n/a |
| pellet (shotgun) retained % | not measurable | not measurable | >= 90 | n/a | n/a |
| Rivet luminance delta (mean of 7 exposures on screen) | 0.173 | 0.151 | >= 0.19 | FAIL | FAIL |

- Rifle / pellet: the first qualifying rifle round after tick 6000 flies outside the front camera's frame in both arms (`no measurable rifle`), so the front camera cannot measure the round bars; the floor call's mid-camera numbers (rifle 104.5 %, pellet 100.9 % at i55) remain the last measured ones. Not measured here = not proven at the front.
- Patrol blue holds the 65 % bar in both arms at the front; it is 8.1 points (inside) and 3.4 points (between) lower than n28. The two arms differ in the hall (front, roof glow, mouth lights) AND in the belt spans, which sit over the yard; this run does not separate the two.
- Rivet luminance delta fails the 0.19 bar in both arms (n28 0.173, now 0.151, -0.022); the floor call measured 0.147 at i55 on the mid camera, so the front is not worse than the yard middle. Same caveat: hall and belt spans both changed.

## Earlier proxy (n29-05)

What was measured instead (proxy, not the bars), at the front camera (26, 3), 32 px/m, tick 2290, seed 7 (`hall_finish/band.py`, `hall_finish/rows.py`):

| | d8dd15d98 (collapsed bay only) | now (roof glow + mouth wall pools) |
|---|---|---|
| yard floor y 430..1080 px, mean RGB | 145.0 / 115.2 / 88.9 | 145.4 / 115.6 / 89.0 |
| void strip y 0..165 px, mean RGB | 24.6 / 20.3 / 21.6 | 38.8 / 28.7 / 23.8 |
| void strip red share (hue < 18 deg, S > 0.5, V > 0.5) | 0 % | 0 % |
| void strip teal/blue share | 0 % | 0 % |
| lower window row luma: shutter W / burst / feed / shutter E / collapsed (half in frame) | 39.9 / 84.6 / 86.0 / 67.2 / 59.8 | 39.9 / 110.6 / 86.0 / 67.2 / 85.5 |

The roof glow rect ends at y -7, 5.9 m north of the wall base (-1.1; unit test), so it cannot reach the yard floor; the floor mean moves +0.4 (the mouth wall pools' print light, radius 5.5 m at y -2.9, reaches about 2.6 m into the yard at the two mouths). Expected: bars unchanged within noise; unproven until the readability run.

NOTE (03:18): the frame cost, the stills and the measures above were taken with two extra `yard_hall_mouth_wall` pools (a new kind, no floor glow, at y -2.9). Lint refused the new kind id (the schema enumerates kind ids), so the commit d838f9e66 instead MOVES the existing burst_door / collapsed_wall `yard_hall_mouth` pools from y -0.8 to -2.9 (two fewer lights than measured, so the cost is at most the measured one). The stills show the measured variant, not d838f9e66's; re-shoot owed.

Re-shot at d838f9e66 (same camera/tick, `hall_front_head_d838f9e66_32ppm.png`): lower window row luma shutter W / burst / feed / shutter E / collapsed (half in frame) = 39.9 / 90.3 / 86.0 / 67.2 / 65.2; yard floor mean 143.4 / 114.3 / 88.7 (moved pools: their floor glow is clipped further at the wall, -1.6 on R); void strip unchanged (38.8 / 28.7 / 23.8, red 0 %). So with the moved pools the burst row is only a little brighter than the feed bay and the collapsed row is NOT brighter than shutter E: item 3 is weaker than the measured wall-pool variant. Owed: a pool kind for the wall (schema kind enum + one kind, no floor glow), which lint refused this call.

## n29-07 hall polish: wall mouth light and plume flip (front camera (26, 3), 32 px/m, tick 2290, seed 7, `hall_finish/rows.py`)

| | ca2cb6938 (HEAD before) | 73a4d9968 wall light | 62982244a + flip |
|---|---|---|---|
| lower window row luma shutter W / burst / feed / shutter E / collapsed (half in frame) | 39.9 / 90.3 / 86.9 / 67.2 / 65.2 | 39.9 / 116.0 / 86.9 / 67.2 / 90.8 | 39.9 / 116.0 / 87.4 / 67.2 / 90.8 |
| yard floor just under the front, y 420..620 px, mean diff vs HEAD before | 0 | +0.95 / +0.59 / +0.12 | (render only) |
| yard floor y 430..1080 px, mean diff vs HEAD before | 0 | +0.19 / +0.12 / +0.02 | |

Wall light: kind `yard_hall_mouth_wall` (copy of `yard_hall_mouth`, floor_glow strength 0, intensity 0.6, radius 4.5 m), pools `burst_mouth_wall` (11.8, -3.2) and `collapsed_mouth_wall` (56.2, -3.2). Tried first: the n29-05 variant (intensity 0.45, radius 5.5, y -2.9): burst 115.9 / collapsed 90.7 but the strip under the front +2.05 R (over the 1.0 limit); then intensity 0.5 radius 4.5 y -3.2: collapsed 86.7 under feed 86.9 (fails); 0.65: strip +1.04 R (fails); 0.6 kept. Stills `build/n29-07/{head,wall,wall2,wall3,wall4,flip}_32.png` (not committed).

Plume repeat: the feed (26.6) and second shutter (41.4) bays carry `flip: true` (existing piece key, data only). LOOK at 32 px/m: the plumes over the middle three bays no longer sit on one half-bay beat (their x positions now alternate), so the eight-in-a-row stamp is broken across the centre; each plume is still the same drawing (mirrored), and the shutter W / burst bays at the left keep their pair, so a careful eye still finds the twin plumes. Next step would be new plume art per bay (not in this call).
