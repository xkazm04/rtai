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
- MILESTONE blood + impact frames (work order 3) and hit-stop (part of 4):
  `features/fx/noir/blood_fx.gd` + `blood_fx.json` (`gtai.noir-blood/1`): pooled droplets (max 320)
  thrown in a cone along killer -> victim, landing as ink-blot splats; a pool under each kill that
  spreads over 420 ticks with a white wet sheen; decals persist 60 s then fade over 120 s; pools have
  their own ring (16) so droplet splats never evict them (v1 bug, caught in frames, fixed + unit test).
  Scatter is a counter hash (no RNG stream, no sim state). `impact_frame.gd` +
  `look_noir_impact.gdshader`: a 3-tick comic beat on kills - inverted panel (blood stays red), paper
  with a speed-line burst, white flash with ink silhouettes. `noir_combat_fx.gd` listens to the REAL
  `Events.actor_killed` / `player_hit` and emits `hit_stop(ticks)` (impact.hit_stop_ticks 5 in params).
  Evidence `fight-v4/`: `dev/noir/blood_clip.tscn` recorded with the movie maker (fixed 60 fps) ->
  fight-48.mp4 / fight-64.mp4 (~10 s) + hero frames f050 (inverted), f051, f060, f176, f300, f600.
  FRICTION: draw_colored_polygon triangulation failed on hashed star blobs (4276 errors in v3); blots
  are now discs (core + lobes) - 0 errors, and they read rounder.
  HONEST: the "cops" in the clip are fixed points (no bodies) in the riot crowd; the kills go through
  the real events, but the city scene has no CombatArena. Wall splats are not done (no wall data in the
  city view). The world hit-stop holds the sim; the rigs keep their pose (that is the held panel).
- MILESTONE real fight wiring + muzzle flash (work order 4, part): `dev/noir/quest_fight.tscn` plays
  quest 1 (collect-call, its bot, seed default) drawn by CollectCallView (placeholder ink) under the
  noir pass; NoirCombatFx is bound to the play's own EventBus (`CollectCallPlay.bus()`, a 3-line
  accessor added to dev/bots/collect_call_play.gd), so the blood comes from CombatArena.damage's
  real `actor_killed` (15 kills in 900 live frames). `features/fx/noir/muzzle_flash.gd`: a white
  ink-rimmed starburst per new round for 2 ticks, and the noir threshold drops for the fire tick
  (the frame "lights"). Hit-stop holds the play 5 ticks per kill. Evidence `quest-v2/`:
  quest-fight-48.mp4 (15 s) + strip.png + 4 hero frames.
  HONEST: weak evidence for the look - the guards are placeholder rings that print dark on black and
  nearly vanish; the HUD sits under the noir pass (rain over the bark box); Rivet's placeholder eyes
  and hp bar are teal (the noir doctrine keeps teal for the dead only - the placeholder's colour, not
  the pass's; noted for the noir parts). quest-v1 (camera on Rivet) had the fight off-frame; v2
  frames between Rivet and the nearest guard but loses Rivet when they are > 26 m apart.
