# JOURNAL - lane noir (D-Noir: high-contrast noir comic, selective colour)

Branch `n-noir`, worktree `gtai-wt/n-noir`. Evidence: `C:\Users\kazda\kiro\gtai-masters\night\noir\`.

## 2026-11-02 iteration 2 (BUILD), 22:41-00:11

- 22:41 No JOURNAL from iteration 1 in this worktree; starting fresh from main 721fbbb.
- FRICTION: the worktree had no native sim DLL and no baked city (both git-ignored). Copied
  `project/native/bin/*.dll` and `project/data/generated/city/` from the n-visual worktree (build
  output, not committed).
- Leonardo probe (key not printed): apiSubscriptionTokens 0, apiPaidTokens null -> no Leonardo tonight.
- Shared files touched (minimal): `boot/launch_args.gd` (+`--look` in KNOWN_FLAGS),
  `features/city/view/city_view.gd` (+`noir` var, `set_noir()`, 2 lines in `_place_camera`).
- MILESTONE look_noir: `assets/shaders/look_noir.gdshader` + `look_noir.params.json`
  (`gtai.look-noir-params/1`, one `frame` table of uniforms, same shape as look_d5.params.json) +
  `features/fx/noir/noir_look.gd` (CanvasLayer 10, over world AND actors). `--look=noir` switches it on.
  Frames: `dev/noir/noir_frames.tscn` shoots junction / street / roofs at 32/48/64 px/m in D4 and noir
  back to back with the world paused (same frame). Iterations (all in masters/night/noir):
  - look-v1: Sobel ink on lit edges + rim everywhere -> embossed double lines, too busy. Rejected.
  - look-v2: rim only dark-on-dark, no edge ink; cops/collar printed as paper (white blobs). Threats lost.
  - look-v3: vermilion prints as a solid ink mass (verm_value 0): cops = black mass + white sticker rim.
  - look-v3raw / v4: `keep_d4 false` (the noir pass reads the raw art, not the D4 print): the D4
    pavement hatching disappears, big black masses, much more stark. v4 = all scenes. Chosen.
  Honest read of v4: streets AND pavements both print black (kerb lines remain); roof tile grid is lost
  (roofs print as flat paper); people pop white; Rivet reads (claw, visor) but his collar is now black.
  Colour doctrine: no colour except the protected blood red and the teal plate (none on screen yet).
