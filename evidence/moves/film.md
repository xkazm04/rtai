# RTAI move films

The five 16-second films and their paired PNGs are in `C:\Users\kazda\kiro\gtai-masters\n23\moves`. Open `frames.json` for the best-first index. Every still row names the matching disabled frame in `before`. Film frames are one-based. The scene shows slow motion in the readout when it holds a simulation tick for multiple movie frames.

| Move | Events in the 32 px/m film | Paired frames at 32 px/m | Paired frames at 64 px/m |
|---|---|---|---|
| Ohm short circuit | The shield drops at 1.80 s with two SWAT behind it. Six frontal pistol hits apply ×1.00 during the 120-tick stun. After recovery they apply ×0.20. The sentry fires twice, then the bolt interrupts the sweep at 9.58 s. The stun ends at 11.58 s. | 171, pistol follow-up | 113, shield and escort. 580, dropped turret barrel |
| Tonnage armour crack | The walker stomps at 1.63 s. Tonnage opens the split at 2.67 s. The frontal pistol hit deals 1.00 HP at 3.53 s. The split closes at 6.67 s and the shot at 7.75 s deals 0.50 HP. | 213, frontal hit | 155, raised plates. 164, glowing split |
| Kerf blink behind | The head-on cut lands at 1.80 s. At the crate corner Kerf sidesteps the planted shield and cuts at 10.92 s. The settled pose faces back towards the carrier at 12.25 s. | 656, first landing | 736, settled facing |
| Overkill carry | One hand-cannon round at rank 1 kills two cops at 2.33 s. The same shot at rank 2 kills all three at 12.67 s. The two carry deliveries occur in one simulation tick. | 765, two links | 793, both links and the falling bodies |

Each comparison uses seed 1, shipped hit points, the same pilot, geometry, movie clock, zoom and fixed 70° camera. Both takes use the fixed camera with `--kerf-glide=off` and reduced camera shake so the landing can be measured against the crate. The carry grant is the same on both sides. Only the selected move row's `enabled` field changes. The original crate-corner takes matched at frame 655. One tick later the disabled landing is inside the shield arc at (1.17, 1.27) m. The enabled landing is 1.35 m behind the carrier at (3.04, 0.00) m, facing left. The recorded impact bearings against the shield are +0.338 and −1.000 respectively.

Kerf's simulation applies damage and sets the landing in one step. The [cut pose](../../project/features/souls/kerf_spectral.gd) uses the travel bearing for its first frames, and the [ordnance view](../../project/features/combat/squad/foe_ordnance_view.gd) removes the shield on the lethal tick. The trail and crate show the landing immediately. The later close-up shows the turn.

`kerf_blink_behind-alive.mp4` repeats the crate-corner approach at quarter speed with probe-only slice scale 0.1. Both arms land on tick 53. With the move off (1.47 s), Kerf stops inside the shield arc and the carrier retains 8.02 HP. With it on (9.47 s), Kerf lands 1.35 m behind the carrier, which retains 0.10 HP. The paired 32 and 64 px/m stills at frame 633 (tick 69) show Kerf facing left into its back. The shield stays raised and points away for the next 0.73 s. The shipped slice still kills the carrier on impact.

During prewarm the [ghost sheet loader](../../project/features/souls/ghost_sheet.gd) warned about the five-row layout of `ohm_spec_hover.png` at pitch 70. The captured Ohm takes show the bolt, the amber discharges and both machines' changed silhouettes. The full ten-seed TTK rerun reproduced the m4b raw report byte for byte.

All five MP4s fully decoded as 960 frames of H.264 `yuv420p` at 1920×1080 and 60 fps with audible AAC tracks. The PNG pairs are 1920×1080. At each original gameplay-scale cue, the decoded movie frame matched its enabled control more closely than its disabled control on the pixels where the subjects differed. Godot checked the five original scripts and scene, and the quick gate passed. The initial debt baseline recorded the 506 lines added under `project/dev/moves` for the film scene.

## Reproduce

With the lane's `APPDATA` and `GODOT_BIN` set, run from the worktree root. Substitute any of the four move IDs from the index.

```powershell
$dest = 'C:\Users\kazda\kiro\gtai-masters\n23\moves'
node evidence/moves/capture.mjs $dest ohm_short_circuit --ppm=32
node evidence/moves/capture.mjs $dest ohm_short_circuit --ppm=64 --stills=113,580
node evidence/moves/capture.mjs $dest ohm_short_circuit --ppm=64 --stills=113,580 --off
node evidence/moves/capture.mjs $dest kerf_blink_behind --slice-k=0.1 --ppm=32
foreach ($ppm in 32,64) {
    node evidence/moves/capture.mjs $dest kerf_blink_behind --slice-k=0.1 --ppm=$ppm --stills=633
    node evidence/moves/capture.mjs $dest kerf_blink_behind --slice-k=0.1 --ppm=$ppm --stills=633 --off
}
```

The capture script calls the dev runner with D3D12 and window position (0, 1440). Godot opens its movie writer before the scene sets the window size. A temporary 1920×1080 project configuration points to this worktree's game directories and import cache. The gameplay movies include the stage audio. FFmpeg converts the writer's full-range MJPEG to H.264 at CRF 18 in 4:2:0 and retains exactly 960 frames. The PNGs come directly from the post-draw viewport.
