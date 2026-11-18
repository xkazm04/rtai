# Tonnage's p70 right-profile walk

| At 32 px/m | Mean ride | Worst ride |
|---|---:|---:|
| Original, n15's 48 ticks | 8.3 px | 16.1 px |
| req221 pixels with original timing, same ticks | 8.3 px | 16.1 px |
| req221 pixels and measured timing, same ticks | 8.4 px | 15.5 px |
| Original, extended to 110 ticks | 9.8 px | 25.5 px |
| Final, extended to 110 ticks | 9.8 px | 25.4 px |

The 48-tick film starts partway through column 6 and ends on column 0. Column 12 holds for eight ticks in both films (ticks 30–37 before and 29–36 after). The longer capture includes both redraws and the transitions either side. Its longest completed hold moves from column 6 to column 5. The 9 px worst-hold target is still missed.

With the original and final sheets, run `evidence/it13/tools/foot_travel.py <sheet> 2 4 16 5`. Coordinates below are contact centres in cell pixels, alpha >128 in the lowest four rows. Column numbers are zero-based.

| Transition | Original contacts | Final contacts | Shipped step before → after |
|---|---|---|---|
| 1 → 2 | 124.5 → 90.5 | 124.5 → 99.5 | 35.0 → 25.0 |
| 2 → 3 | 90.5 → 79.5 | 99.5 → 79.5 | 10.5 → 20.0 |
| 5 → 6 | 62.0 → 18.5 | 62.0 → 17.5, rear pad | 43.5 → 44.5 |
| 6 → 7 | pad switch | 144.0 → 140.0, front pad | 23.9 → 4.0 |

The new column 6 establishes double support. Its rear pad is still far behind column 5's, which leaves a long incoming step. Retiming moves some of the hold into column 5. The left profile has separately generated keys and in-betweens from asset round 20261110-2315. None of its 16 flipped, tightly cropped poses matches the corresponding right pose.

## Reproduce the films

Use the lane's APPDATA and GODOT_BIN. The entry is `res://dev/rivet_motion/stride_film.tscn`. Use D3D12, window position `0,1440`, fixed 60 fps and flags `--rigs --start=pad --film-form=tonnage --film-every=1 --film-leg=2`. Set `--film-out` to an absolute prefix. Compare leg 2 only.

- Use `--ppm=32 --film-frames=48` for the n15 comparison. Run `hold_ride.py <prefix> 2 48 0,45 70,150,190,222`. The upper band covers textured ground above his head and the change detector covers the lower body and feet. The historical tool reports holds closed by a detected pose change.
- Use `feet_track.py <prefix> 2 48 0,45 198,214 70` and `feet_trace.py <prefix> 2 48 0,45 198,214 <out.png> 1`. The ground mark holds x 282.5–283.1 on ticks 26–31. On the final film the stance pad returns to x 192.0, 192.0, 191.1 and 191.8 at ticks 13, 17, 22 and 29. The trace shows forward ride within each hold and a return at the next pose, without sustained creep over that stance.
- Use `--ppm=64 --film-crop=460 --film-frames=110` for the still. The sheet and film agree on columns 1, 2, 3, 5, 6 and 7 at the six labelled ticks. Column 2 brings the near pad forward. Column 6 spreads the two pads across the floor. The riveted press body, yellow stripe and teal outline read consistently across both rows, with no visible cell seam.
- Use `--ppm=32 --film-frames=180` for the final clip and the first 110 frames of that clip for the longer measurement. Compare with a 110-frame original film. `frames.py` writes the still and 12-second clip. It plays the 180 consecutive ticks at real time, then repeats them at one-third speed.
