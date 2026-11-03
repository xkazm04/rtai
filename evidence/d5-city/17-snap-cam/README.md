# 17 Pixel-snapped world camera, d5-city iteration 4, 2026-11-03

`CityView.snap_px` (default on): camera.position * zoom rounds to whole screen px, so a pan moves the
world art by whole px in step with the print's (already rounded) world_px.

Measure: real game (city_frame.tscn `--pan=20`, focus 1, 48 px/m), the camera pans east at 7.3 m/s
(5.84 px a frame) for 20 frames; a world-locked roof crop (x 120-320, y 20-760; no actors walk on
roofs) is compared frame to frame at the camera's whole-px step (masters tools/pan_swim.py). Anything
left over is swim. swim.jsonl:

| camera | look | mean abs diff | pixels off > 24 |
|---|---|---|---|
| snapped | auto (D4 at 48 before the ramp change) | 0.02 | 0 % |
| sub-pixel | auto | 6.90 | 8.2 % |
| sub-pixel, sub-px step compensated | auto | 8.60 | 11.3 % |
| snapped | d5 | 0.02 | 0 % |
| sub-pixel | d5 | 6.64 | 7.8 % |

The sub-pixel camera re-samples the art bilinearly and the print thresholds re-quantize it every frame
(the hatch strokes and pen weights re-draw; swim-crop-3x.png): undoing the sub-px shift does not help.
The snapped camera keeps every world pixel. This removes the d5 lane's objection to D5 at gameplay
zoom ("flips more pixels under a sub-pixel camera"), see 18-d5-earlier. Raw frames:
gtai-masters/day-d5/d5-city/i4/17-snap-cam/.
