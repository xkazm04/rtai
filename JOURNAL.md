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
- REVERTED (two experiments, not committed):
  1. `look_noir_crowd.gdshader`: the baked crowd atlas printed as ink silhouettes with a lit-side white
     rim (the brief's "black masses with white rim"). The material was applied to the RL_PEDS MultiMesh
     (confirmed by a log line), but the frames were pixel-identical (crowd-ink-v2/): the people on screen
     at the junction are not drawn through that node's material the way I assumed. I ran out of time to
     trace it, so I reverted it.
  2. Quest 1's HUD lifted above the noir pass (quest-v3/): the rain left the bark box, but the HUD then
     prints D4 vermilion (heat pips, speaker name), which breaks the noir doctrine. That is worse, so I
     reverted it. The real fix is a noir HUD palette (Ink tokens), not a layer move.
- Evidence summary for the morning: `evidence/NOIR.md` (+ ladder.png, showcase-d4-vs-noir.png and
  the gate JSONs, all untracked in the worktree). Gates at 81dca0e: lint, 173 unit, 8 scenarios, parity
  and selftest all PASS.
- Image generation: Leonardo balance is 0. No Codex image_gen was run this session (0 images, 0 rejected),
  so there are no provenance lines to add.

- MILESTONE (retry of reverted experiment 1, 23:40): `assets/shaders/look_noir_crowd.gdshader` WORKS when it
  is applied right before each capture (the first try probably raced the first render; a modulate=red
  diagnostic proved RL_PEDS is the atlas crowd, while the near people are full rigs). Opt-in dev flag only:
  `noir_frames.tscn -- --crowd=ink`. The atlas crowd prints as solid ink silhouettes carved by a white
  lit-side rim (7 atlas texels; 1 texel was sub-pixel on screen, crowd-ink-v3). Evidence:
  `crowd-ink-v4/compare.png` (v4 vs ink crowd, junction 48 / street 32).
  Honest read: on the paper pavements it is the noir silhouette the brief asks for, and the frame is much
  less busy. But the silhouettes are blobby (the atlas alpha includes the sticker halo, so limbs merge),
  and the 16 near full rigs stay white, so the foreground and the crowd do not match. It is not the default.

- REVERTED (23:42): a `noir` uniform in `features/characters/print_part.gdshader` + `PartMaterials.set_noir()`
  (the body prints as one ink mass, and the cream halo stays the white rim). The materials were confirmed set
  (8 shared mats, noir 1.0 logged), but the near full rigs still printed cream in crowd-ink-v6. A
  modulate diagnostic was inconclusive (a blue modulate darkens cream by itself). Suspects: the rigs
  redraw only on sim ticks while the A/B shots are paused, or a branch of print_part I did not reach. The
  change touched the characters feature (outside my file scope), so I reverted it rather than leave it half-proven.

NEXT:
1. Item 2, the noir characters (the weakest item): wire look_noir_crowd into --look=noir properly
   (CityCharacters sets the atlas material after bake; noir needs a hook there), bake the atlas without
   the halo in noir (so limbs stay legible), and give the full rigs the same ink + lit rim through
   `part_materials.gd` (a noir part print), so the near and far people match. Start by testing the
   print_part `noir` uniform with the world RUNNING (no pause) and a plain frame grab, before any A/B. Rivet's collar and claw need a rim, not a flat black. If
   that is not enough, run a Codex round (the layout-template technique) for noir Rivet / cop / ped parts on
   the same rig.
2. The showcase with real bodies: put 2 cop rigs at the clip's COPS points (or run the junction fight
   from a CombatArena), and record 48 and 64 px/m clips of 10-20 s.
3. Wall splats (needs wall/prop edges in the view), and the pool shape (discs read as blots; a
   spreading pool could be an SDF ring).
4. Noir HUD palette (Ink tokens without vermilion) for quest 1's view; then lift the HUD above the pass.
5. Measure the noir pass cost (bench with --look=noir) before anyone calls it free.
6. Knockback poses held as panels: the hit-stop holds the world, but the victims are not posed yet
   (the city crowd has no knockback clip). The long coat / rain secondary motion is not started.
