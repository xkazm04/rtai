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

- MILESTONE (23:45, the reverted rig attempt fixed): the rig noir print works. The bug was mine:
  `noir_keep` 0.86 kept every source pixel above that luminance as paper, and the art's cream body is about
  0.91, so the bodies stayed cream. At 0.97 every body part prints as ink inside the cream halo (the white
  rim). The world is also no longer paused for the shots in this mode (the rigs redraw on ticks).
  SHARED FILES (characters feature, minimal, default OFF): `print_part.gdshader` +`noir`/`noir_keep`
  uniforms (one line in the fragment); `part_materials.gd` +`static var noir`, `set_noir()`. Only
  `noir_frames.tscn -- --crowd=ink` switches it on. Evidence `rig-ink-v2/` + `compare.png` (D4 /
  noir v4 / ink crowd / ink everyone).
  Honest read: the most noir frame of the night - every person is one black mass carved by a white rim,
  near and far consistent, and the junction reads clean. BUT Rivet now reads only by his claw
  silhouette: the visor and hero read are gone, and he is the same value as the cops. The brief wants the
  visor kept: a noir Rivet needs paper "light" on the visor/claw (noir parts or a per-part keep mask).

- MILESTONE (23:46): Rivet's hero read in the ink-people mode. `PartMaterials` sets `noir_keep` per kind:
  CORE (Rivet-only: the visor / chest plate) 0.80, all else 0.97. Rivet is now the one lit figure (his
  visor plate prints as paper) among the ink masses, with the claw as a silhouette (`rig-ink-v3/`). The claw
  tips are not lit yet.

NEXT:
0. (partly done: the core is lit) Rivet's hero read in the ink-people mode: keep the visor and the claw tips as paper (a per-part keep
   flag in PartMaterials, e.g. the COLLAR/CORE kinds, or noir parts from a Codex round), then make
   ink people the --look=noir default if the owner likes rig-ink-v2/compare.png.
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
- 23:43 Final gates at c5829e2 (`run.mjs --no-bench --allow-dirty`; the only dirty path is the untracked
  evidence/ folder): lint, 173 unit, 8 scenarios, parity and selftest all PASS. evidence/ = NOIR.md
  + ladder.png (6 rows) + showcase-d4-vs-noir.png + crowd-ink-compare.png + the gate JSONs. It is not
  committed (the PNGs are 2-4 MB; the Director decides). Masters are about 220 MB in night/noir (mp4 + png).
  Images: 0 generated, 0 rejected (Leonardo 0 tokens; no Codex round tonight).
- 23:47 Session close. Gates at b0e7fba (`run.mjs --no-bench --allow-dirty`, the only dirty path being the untracked
  evidence/ folder): lint, 173 unit, 8 scenarios, parity and selftest all PASS. Ladder: 7 rows
  (masters/night/noir/ladder.png, copied to evidence/). Masters were trimmed to 155 MB (superseded fight-v1..v3 and
  the quest-v1/v3 clips deleted). No processes left running.
  NEXT (in order): see the NEXT list above. Top: make the ink-people print (crowd + rigs + Rivet's lit core)
  the --look=noir default if the owner picks it from evidence/people-ink-compare.png; light the claw tips;
  a real-bodies showcase (2 cop rigs at a junction in rain, 48 and 64 px/m clips); measure the noir pass cost.

## 2026-11-02/03 iteration 4 (BUILD), 23:48-01:18

- 23:48 Leonardo probe (key not printed): apiSubscriptionTokens 0, apiPaidTokens null -> no Leonardo.
  No Codex round planned this session (code + evidence first). Disk 219 GB free.
- MILESTONE (00:05) work order 5, the showcase with REAL bodies: `dev/noir/showcase_fight.tscn` +
  `dev/noir/fight_script.gd` (NoirFightScript, deterministic beats on a live-tick clock that does
  not advance while the world is held). Rivet + two cop cutout RIGS (own CharacterRigs on the city's
  actor layer, stepped by the world clock, so the hit-stop freezes the bodies = the held panel) at the
  junction in rain; the city around them is the real city with a thin street crowd (12 peds, 0 cars:
  show-v1 had a car drive through the fight). Cops close in and fire (MuzzleFlash starbursts at
  CutRig.muzzle_local(), the noir threshold +0.25 for the lit tick); Rivet dashes, punches (combo 3),
  rolls clear of cop B's fire, dashes, punches. The kills go through the REAL Events.actor_killed /
  player_hit -> NoirCombatFx (blood spurt along the hit, spreading pools, impact frame, hit-stop 5);
  the victim gets the HIT clip (shove + twist) + DEAD (sprawl) + a 6 m/s knockback slide.
  `--d4` shoots the same fight in D4. Unit test `test_noir_showcase.gd` (2 kills, A then B; same cues
  every run). Evidence `show-v3/`: showcase-noir-48.mp4, showcase-noir-64.mp4, showcase-d4-48.mp4
  (11.2 s each, movie maker 60 fps) + 15 hero frames per run + `showcase-compare.png`
  (D4 48 | noir 48 | noir 64 at the opening, a shot, the kill flash, the inverted panel, the aftermath).
- MILESTONE (00:05) the comic impact frame fixed: show-v1 showed mode 3 (paper + speed lines) blanking
  the fighters to nothing. New mode 4, the silhouette flash: ImpactFrame hides `hide_on_flash` (the
  world canvas + the noir pass) for that tick and sets the clear colour to a green key; the shader
  prints every non-key pixel as ink. Result (show-v2/v3): the two fighters as solid ink silhouettes
  on white paper inside the speed-line burst, the blood still red - the brief's "silhouette inverted"
  beat. Default sequence is now [4, 4, 1]. Blood moved under the actor layer (z -1) so it survives the
  flash. Unit test: the flash hides then restores.
  HONEST: in `--d4` the flash prints all black (the D4 print layer is not in the hide list; the beat is
  a noir-only feature). quest_fight.gd has no hide list, so there mode 4 is a black flash (red blood
  only) - not re-shot.
  Honest read of the showcase (show-v3/showcase-compare.png): the kill beats read as comic panels and
  blood is the only colour on screen. BUT the cops lost their threat read: in D4 they pop vermilion,
  in noir they are white figures the same value as Rivet (shape only: cap + gun). At the punch Rivet's
  claw overlaps the cop (REACH 1.6 m), so the hit itself is one white knot at 48 px/m. Rain at 48 px/m
  is busy around small figures. Rivet bleeds red on player_hit (a robot: oil/sparks would be truer;
  kept, as the doctrine is "violence in red").
- 00:07 FIX the doctrine: Rivet's prod tip printed teal (the only teal on screen; the souls are not drawn
  yet). Params `teal` 0.0; the dead must draw above the pass (layer > 10) to keep theirs. Before/after
  `teal-before-after-64.png`, ladder row 10. CORRECTION to my 00:05 read: at 64 px/m the cops DO read as
  ink masses with a white rim (paper badge bar + gun hand) and Rivet as the lit paper figure (crop
  `cop-crop-noir64.png`); the loss vs D4 is speed of read (value + shape, not hue), not the read itself.
- MILESTONE (00:06) noir pass cost, measured: `dev/noir/noir_cost.tscn` (the riot junction, alternating
  120-frame blocks D4 / noir, RenderingServer viewport GPU/CPU time). 1920x1080, RTX 4090: noir 0.85 ms
  (48 px/m) / 0.75 ms (64 px/m) GPU vs D4 1.44 ms; CPU render ~0.2 ms both. Noir REPLACES the D4 print pass
  (keep_d4 false). One GPU only; a low-end number is still unmeasured. JSONs in masters + evidence/.
  FRICTION: two hangs of 5 min each - a GDScript warning-as-error in a dev scene leaves the window open
  forever and the piped stdout is lost on kill. Fix: `--headless --quit-after 60` first, it prints the parse error.
- (00:10) showcase `--d4` binds no impact frame (it printed the silhouette flash as all black); punch
  REACH 1.9 m (the claw still touches the cop at 48 px/m).
- REJECTED for the fight: the ink-people mode (`--ink`, show-ink/): on black asphalt the ink figures
  vanish into the ground, leaving only a thin rim. It works on paper ground only, so it is not the default.
- MILESTONE (00:19) the knockback held as a comic panel: after the sequence, ImpactFrame holds
  `panel_ticks` 8 with the frame boxed as a comic panel (paper gutters, ink border; half 0.36 x 0.38 uv,
  clamped so a gutter shows on every side - v6 touched the screen edge on a corner kill). The showcase
  starts its hit-stop AFTER the 3 flash ticks, so the held pose is the HIT shove, not the wind-up
  (hit_stop_ticks 5 -> 8). Evidence show-v7 (clips 48/64 noir + d4, 11.3 s), ladder row 11.
  FRICTION: 297a63f was committed with test_blood_fx failing (it counted panel ticks as flash frames;
  my && chain ended in `tail`). Fixed in 0fd7880; 177 unit tests pass.
- MILESTONE (00:22) rain secondary motion: splash rings in look_noir (`splash` 0.45, `splash_cell` 28 px,
  `splash_period` 36 ticks): one landing per cell per cycle at a new hashed spot, a ring growing over 7
  ticks, white on ink and ink on paper; it lands on the figures too (rain on shoulders). Render only (rain_phase).
  v1 rings were faint grey 1 px circles; v2 is a slightly thicker, slower fade. Honest read: subtle in a
  still (`splash-before-after.png`), it reads as rain hitting puddles; it is mechanical (perfect circles).
  The long coat is NOT done: no coat part exists on the rigs.
  Clips re-recorded with splashes: show-v8/showcase-noir-48.mp4, -64.mp4 (the D4 clip moved from show-v7).
- NOT DONE, by choice: quest_fight's silhouette flash (its placeholder view draws the ground and the actors
  on one node, so it can't be keyed; it stays a black flash). No Codex round this session (0 images, 0
  rejected): a parts round can't be assembled and evidenced on the rig in the time left.
- (00:30) splash LOD: NoirLook.update reads the active Camera2D zoom (no city_view change); params
  `splash_zoom` [1.0, 1.5]: no rings at 32 px/m, full from 48 px/m (`lod-before-after.png`).
- MILESTONE (00:29) image route for noir parts, first images of this lane: Codex image_gen, one at a
  time, no limit hit. noir_cop_1 (52 s): the D4 cop torso / cap head / pistol forearm at 2.5x on green as
  the layout template -> ink masses, white rim line, brush highlights, a white badge on the cap; top-down
  kept (0 rejected). Sliced back with the ORIGINAL part alpha (exact silhouettes and pivots,
  tools/slice_noir.py) into `features/characters/art/noir/cop/`. Hook: `showcase_fight --noir-parts`
  fills PartLibrary.of("cop").textures before the showcase rigs are built (no feature code change).
  Honest: a small gain (the pass already printed cops as ink + rim); the cap badge is the new cop cue at
  64 px/m; the torso highlights vanish at game scale. `parts-before-after.png`, ladder row 14.
- MILESTONE (00:33) the long coat: noir_coat_1 (52 s, 0 rejected): the noir torso + a grey guide polygon
  -> two coat flaps with a vent, ink + white folds. tools/slice_coat.py cuts by the polygon.
  `dev/noir/noir_coats.gd` hangs it from each cop's torso back (z under the torso and its halo, own halo
  rim), damped spring on TICK_DT: sideways velocity, turning and hit shove swing it, speed stretches it.
  `showcase_fight --coat`. Evidence coat-v1/ (frames + showcase-noir-64-coat.mp4), `coat-motion-strip.png`
  (4 clip frames 0.3 s apart: the tail trails cop A as he walks and turns), ladder row 15.
  Honest: subtle at 64 px/m, a dark flap behind a dark figure; no unit test for the spring (dev code); the
  dead cop's coat is not visible under the sprawl in f322.
  Images this session: 2 generated, 0 rejected; provenance: 4 lines (3 cop parts + coat) in
  steam/ai-provenance/2026-11.jsonl. Leonardo 0 tokens.
- (00:40) noir_cop_2 (50 s, 0 rejected): an edit of noir_cop_1, only the cap changed, adding a white checkered
  hat band. At 48 px/m it prints as a light ring on the cap, where the badge alone was a dot (`band-compare.png`).
  Mild gain. Cop B wears the riot helmet (look 6), so his head is unchanged. Opt-in (--noir-parts).
- (00:42) Final showcase clips re-recorded with `--coat --noir-parts`: masters night/noir/show-final/
  showcase-noir-48.mp4, showcase-noir-64.mp4, showcase-d4-48.mp4 (11.3 s, 60 fps) +
  evidence/showcase-hero.png (D4 48 | noir 48 | noir 64: a shot, the silhouette flash, the held panel,
  the aftermath) + evidence/showcase-final-64-crop.png. Ladder: 16 rows.
  Images this session: 3 generated (noir_cop_1, noir_coat_1, noir_cop_2), 0 rejected, no limit hit;
  provenance: 5 lines. Masters: ~400 MB in night/noir (trimmed superseded show-v1/v2/v3/v6 and the
  old clips; NOTE ladder row 10 now uses the teal-before-after composite, as show-v3 was deleted).

NEXT (iteration 4 close, in order):
1. Owner pick from evidence/showcase-hero.png + the show-final clips: is the noir kill beat (silhouette flash
   -> held comic panel) the comic language they want? If yes, port the hide-list flash to the real
   game host (CityView needs a "world canvas" handle; quest 1's placeholder view can't be keyed).
2. The rain at 32 px/m: the splash rings now have a zoom LOD (off at 32), but the streaks are still
   screen-sized and busy around small figures (ladder row 13). Try a streak-density LOD with the same zoom uniform.
3. Noir characters (item 2): extend the noir cop redraw to every cop part (pelvis, arms, legs, the riot helmet) and Rivet,
   then move noir parts + the coat from the dev hook into the rig (a noir art_dir per plan, the coat as a CutRig part).
4. Speed of the cop read at 32/48 px/m: cops and peds are both ink-with-rim or paper; try a thicker white
   sticker rim on COP kind only (needs a per-plan halo material, PartMaterials key). The checkered cap
   band (done, opt-in) helps capped cops at 48; the riot helmet needs its own noir cue.
5. Wall splats (needs wall/prop edges in the view); the blood pool as an SDF ring, not discs.
6. Noir HUD palette (Ink tokens without vermilion) for quest 1's view, then lift the HUD above the pass.
7. (done 00:53) the low-end number: on the AMD Radeon iGPU (--gpu-index 1) at 1080p, noir 6.61 ms vs D4 8.17 ms GPU.
- (00:44) rain streak LOD: `rain_far` 0.5 keeps half the streak columns at 32 px/m (same zoom ramp as the
  splashes), full from 48 px/m. 48 is identical. `rainlod-compare.png`.
- REVERTED (00:47) the noir riot helmet: noir_helmet_1 (45 s; the D4 helmet beside the finished noir cap
  as a style reference) gave an ink shell with a white visor crescent + ridge line, top-down, so it was
  usable as an image. But in-engine at 64 px/m it read WORSE: the D4 helmet's bold white visor bar became a
  thin line and the crescent was lost under the rim (`evidence/helmet-rejected-zoom.png`, left = kept D4
  print). Removed, never committed. Images this session: 4 generated, 0 rejected as images, 1 reverted in-engine.
  Lesson for the next parts round: at 32-64 px/m only bold, wide white shapes survive the part print and
  the noir threshold; thin lines (ridges, torso highlights) vanish.
- (00:47) the kill snaps the victim 0.5 m away on the kill tick: in the silhouette flash Rivet and the cop
  are two shapes with a gap, where before they were one knot (`evidence/snap-compare.png`, a modest gain).
  The final clips were re-recorded at af6d3e2 (show-final/, --coat --noir-parts), along with the hero
  sheet, the final crop and the ladder.
- 00:51 Session close. Gates at af6d3e2 (`run.mjs --no-bench --allow-dirty`, the only dirty path is the
  untracked evidence/ folder): lint (13 checks), 178 unit, 8 scenarios, parity (1200 steps, mutation
  caught) and selftest all PASS. No processes left running (no Godot, no codex). Masters: ~415 MB in
  night/noir. Images: 4 Codex (cop parts, coat, cap band, helmet), 0 rejected as images, the helmet
  reverted in-engine. Leonardo 0 tokens. Provenance: 5 lines.
  Morning entry points: evidence/NOIR.md, evidence/showcase-hero.png, evidence/showcase-final-64-crop.png,
  masters night/noir/show-final/*.mp4, evidence/ladder.png (16 rows). NEXT: see the list above
  (iteration 4 close).
- (00:53) noir pass cost on the integrated GPU: `noir_cost.tscn --gpu-index 1` (AMD Radeon(TM) Graphics) at
  1920x1080, 48 px/m riot junction: GPU noir 6.61 ms vs D4 8.17 ms; CPU render 0.24 ms both. A 4090 re-run:
  0.90 vs 1.09 ms. Noir is cheaper on both GPUs because it replaces the D4 print pass. evidence/noir-cost-1080p-igpu.json.

## 2026-11-03 iteration 6 (BUILD), 00:52-02:22

- 00:53 Leonardo probe (key not printed): apiSubscriptionTokens 0, apiPaidTokens null -> Codex only. Disk 217 GB free.
- MILESTONE (01:07) noir Rivet (work order 2, the weakest item: Rivet had no noir redraw). Two Codex
  layout-template edits, one at a time, no limit hit (the gen.sh "limit=429" flag on the 2nd was a false
  positive: a file size of 1429015 bytes in the log): noir_rivet_1 (84 s; helmet, collar, torso, pelvis,
  claw_closed, prod forearm at 1.85x) and noir_rivet_limbs_1 (61 s; upperarm, forearm, claw_open,
  claw_pistol, thigh, shin, foot, foot_toeoff at 1.5x). Prompt: hard chiaroscuro (top-left half lit paper,
  lower-right a solid ink mass), and per the helmet lesson only BOLD WIDE white shapes: the visor U thick,
  the collar as wide black/white hazard stripes. Both top-down, 0 rejected. New tool
  masters:night/noir/tools/make_template.py (D4 parts pasted at a scale, rows, box json); sliced with
  slice_noir.py (original part alpha, so pivots and silhouettes are exact). l_/r_ D4 limbs are the SAME
  image (diffed), so one redraw serves both sides. 19 pngs in features/characters/art/noir/rivet/,
  19 provenance lines. `--noir-parts` now wears every png under art/noir/<kind>/ (ResourceLoader.list_directory).
  FRICTION: a typed `const Dictionary[String, PackedStringArray]` iterated in _ready crashed Godot 4.7.2
  (signal 11, no script error); plain consts fixed it, then the scan replaced them.
  Evidence: masters night/noir/rivet-before-after.png (Rivet crops f040, rows 32 / 48 / 64 px/m, left
  before = show-final / rivet-v0-32, right after = rivet-v2), clips rivet-v2/showcase-noir-32/48/64.mp4.
  The rerun after the refactor is pixel-identical (3 frames diffed).
  Honest read: a MODEST gain. At all three zooms the helmet prints as an ink plate with the white visor U
  (before: a paper square); from 48 px/m the collar shows black/white hazard stripes (before: one ink ring) -
  the brief's B/W collar. The limbs barely change: the redraw is mostly lit white, and the part print
  (print_part, D4 limb wash; the sticker LOD at 32 px/m) keeps them paper with ink outlines, so only the
  joint hubs go black. At 48 the torso is a little busier (black blots between the white plates). Kept, opt-in.
- MILESTONE (01:21) blood marks (work order 3, "blood as the star"): new `features/fx/noir/blood_marks.gd`
  (static, stateless). Landed droplets are teardrops stretched along their travel (elongation from the
  landing speed) with 3 satellite drops flung ahead and 4 small lobes, so a spray on the ground shows
  which way the hit went. A kill's pool is a star-shaped wobbly polygon (3 hashed low-frequency waves,
  min 0.66 r so it never self-crosses: no triangulation errors, 0 in the logs) run out along the hit
  (`pool.run` 0.6 in blood_fx.json), a dark body inside a bright red meniscus rim with a white sheen arc.
  `decal.lobes` removed from the JSON (unused). Unit test: the edge wobbles, stays star-shaped, runs
  along the hit. 179 unit pass, lint clean. Evidence: masters night/noir/blood-before-after.png (kill
  crops at 64 and 48, before = rivet-v2, after = blood-v2), blood-v2/blood-32-compare.png, clips
  blood-v2/showcase-noir-32/48/64.mp4. Ladder rows 17 (Rivet) and 18 (blood), 18 rows now.
  Honest read: a clear gain at 48/64 - it reads as spatter and a wet pool, not as round ink blots; at
  32 px/m it is a bit more fragmented but still directional.
  FRICTION: a parse error (new class_name not yet in the global cache) hung the movie recording for
  10 min again; fixed by `--import` + a `--headless --quit-after 60` check BEFORE every record. The 2
  Godot processes running pass_cost.tscn at 01:15 are the visual-engine lane's (not touched).
- MILESTONE (01:26) drips: `player_hit` starts a bleed (`drip` table in blood_fx.json: bleed_ticks 360,
  one drop per every_px 9 px moved, stretched along the move; one per still_ticks 45 standing).
  NoirCombatFx.step_ticks(n) on the fixed tick (all three noir hosts call it). Unit test (a 6 m walk
  leaves 15-25 drips, the wound stops). Evidence masters blood-v3/drip-crops.png (left before, right
  after): a dotted red trail follows Rivet's dash and roll after the hit. The drips advance the scatter
  hash counter, so later splashes differ in detail run to run of DIFFERENT code (same code = identical).
- (01:30) FIX: blood_clip logged 2 "triangulation failed" - small pool rings far from the origin (city px
  ~4000) lose float precision in the triangulator (a probe: 2 of 6400 rings failed, both r=1). The ring is
  now built at the origin and placed with draw_set_transform; < 3 px is a disc. 0 errors in all three
  hosts; the showcase frames are pixel-identical before/after the fix.
- (01:28) Final showcase re-shot with everything (`--coat --noir-parts`, blood marks, drips):
  masters night/noir/show-final2/ (showcase-noir-48.mp4, -64.mp4, showcase-d4-48.mp4, 11.3 s, 60 fps) +
  evidence/showcase-hero.png (D4 48 | noir 48 | noir 64: shot, silhouette flash, held panel, aftermath;
  the previous sheet is evidence/showcase-hero-v1.png). evidence/NOIR.md updated. Masters trimmed to ~580 MB.
- (01:36) Gates at b3c3d1f (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty):
  lint (13), 180 unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS.
- MILESTONE/NOT ADOPTED (01:36) noir peds: noir_ped_1 (62 s, 0 rejected): 10 ped parts (hat head, hair
  head, jacket torso, shirt torso, pelvis, upperarm, forearm, thigh, shin, foot) as trench-coat ink masses
  with a thick white rim, the hat as a fedora seen from above with a white band. Sliced into
  art/noir/ped/ (10 provenance lines). `dev/noir/noir_parts.gd` (NoirParts.wear) is now the shared hook;
  `noir_frames -- --noir-parts` wears cop + rivet + ped, the showcase only cop + rivet (its frames are
  pixel-identical to show-final2 after the refactor). Evidence: masters ped-before-after.png (street
  noir crops at 64 / 48 / 32 px/m, ped-v0 vs ped-v1; also evidence/).
  CAVEAT: noir_frames is NOT tick-exact between runs (the crowd positions differ), so this pair is the
  same seed and moment, not the same pixels.
  Honest read: at 48 px/m the crowd becomes the brief's ink masses carved by a white rim, and Rivet stays
  the one lit figure. BUT the cops lose their main noir cue (they were the dark masses among white peds;
  now everyone except Rivet is dark), and at 32 px/m a dense crowd turns into a busy mesh of rims. So it
  is opt-in only, not in the showcase.
- EXPERIMENT (01:38) the cop read with ink peds: `noir_frames -- --noir-parts --verm=1` (the vermilion
  plate prints as paper; the crowd cops carry it through the rig palette swap). Evidence
  evidence/ped-cop-read.png (street + junction 48 px/m: D4 peds | ink peds | ink peds + paper cops) and
  ped-cop-read-zoom.png. Read: the crowd cop pops again as the one bright torso among dark passers-by,
  but the white cap band is lost and cops and Rivet are now both the bright figures (Rivet keeps his ink
  core + visor U). An owner choice of value roles, not adopted: params keep verm_value 0, showcase unchanged.
- MILESTONE (01:44) the muzzle lights the scene (work order 4): look_noir `flash`, `flash_uv`, `flash_r`
  115 px (at 32 px/m, x zoom), `flash_lift` 0.3: on the fire tick a pool around the muzzle is lifted to
  paper (the darkest ink, under 0.4 crush, stays ink); MuzzleFlash.lit_at(); the showcase sets it on the
  lit tick and saves that tick as a "lit" hero frame (the old "shot" heroes were the tick AFTER, so the
  old light never showed in any still). Before (flash-v0, a temporary uncommitted patch restoring the old
  thresh +0.25) shows almost nothing; v1 a hard round pool (reads as a spotlight disc); v2 a ragged brush
  edge (angle waves + fibre noise). Kept v2. Evidence masters flash-before-after-48.png (v0 | v1, two
  shots), flash-v2/f230-3way.png (v0 | v1 | v2); ladder row 20.
  Honest read: the strongest new comic beat of the session - the shooter is a solid black silhouette with
  the white starburst inside a burst of light, one frame per round. Risk: a big white strobe (6 rounds in
  11 s here) needs a photosensitivity check before it ships. quest_fight still uses the old lift.
- (01:47) Final showcase re-shot: masters night/noir/show-final3/ (noir 48 / 64, D4 48; 11.3 s, 60 fps)
  + evidence/showcase-hero.png (rows: the fire tick, the silhouette flash, the held panel, the aftermath).
  show-final2 clips deleted (frames kept for the before/afters). Ladder 20 rows. NOIR.md updated.
  Images this session: 3 Codex (noir_rivet_1, noir_rivet_limbs_1, noir_ped_1), 0 rejected, no limit
  hit; Leonardo 0 tokens. Provenance this session: 29 lines (19 Rivet + 10 ped).
- (01:50) The muzzle light at 32 / 48 / 64 px/m (show-final3 f230, evidence/flash-32-48-64.png): the pool
  scales with the zoom and reads the same at all three. +1 unit test (one tick of light, at the muzzle):
  181 unit pass. quest_fight ported to the light pool (headless clean, NOT re-shot).

NEXT (iteration 6 close, in order):
1. Owner picks from evidence/showcase-hero.png + masters night/noir/show-final3/*.mp4:
   (a) the comic language: silhouette flash -> held panel on kills, the muzzle's one-frame pool of light;
   (b) value roles: cops = ink among paper peds (default) vs ink peds + paper cops (`noir_frames --noir-parts
       --verm=1`, evidence/ped-cop-read.png); (c) noir Rivet parts (evidence/rivet-before-after.png).
2. Photosensitivity: (done 01:53) the muzzle light is capped at one lit frame per 0.33 s (LIT_GAP 20 ticks,
   unit-tested) and (done 01:54) the kill beat at one per second (ImpactFrame.BEAT_GAP 60; kills inside
   the gap keep their blood, no flash, no hit-stop). Still to do: an accessibility toggle (flashes off),
   reviewed against a real guideline, before anything ships. blood_clip's kills may now skip a beat.
3. Rivet's noir limbs read as paper (the redraw is mostly lit white, and at 32 px/m the sticker LOD ignores
   the art for limbs and core). If the owner wants a darker Rivet: a limbs round with more ink mass, or a
   noir limb_wash in print_part.
4. Move noir parts + the coat from the dev hook (NoirParts.wear) into the rigs: a noir art_dir per plan,
   the coat as a CutRig part.
5. Wall splats (still needs wall/prop edges in the view); blood marks on the bodies themselves.
6. Noir HUD palette (Ink tokens without vermilion) for quest 1's view, then lift the HUD above the pass.
7. Make noir_frames tick-exact between runs (step the world by ticks, not frames) so ped/crowd A/Bs are
   the same pixels. (quest_fight re-shot with the muzzle light at 01:57: done.)
- (01:53) Gates at 180c78a (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty): lint
  (13), 181 unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS (the run
  before it flagged unit-tests only because I edited JOURNAL.md during it). Gate JSONs copied to evidence/.
  Then the photosensitivity guard (LIT_GAP 20 ticks) + its test: 182 unit pass, showcase pixel-identical.
- (01:54) Photosensitivity guard on the kill beat too (BEAT_GAP 60 ticks) + test: 183 unit pass; the
  showcase kill frames are pixel-identical (its kills are 124 ticks apart).
- (01:55) Gates at 9062ecf (`run.mjs --no-bench --allow-dirty`): lint (13), 183 unit, 8 scenarios, parity
  (1200 steps, mutation caught), selftest all PASS; JSONs in evidence/.
- (01:57) quest_fight re-shot with the muzzle light: masters night/noir/quest-v4/quest-fight-48.mp4 (15 s,
  16 kills through the real CombatArena events) + evidence/quest-lit-strip.png (frames 193 / 194 / 550 of the
  clip, found as one-frame brightness bumps: Rivet's nail-gun rounds light a ragged pool around him). The
  kill beats show as 8-9 frame bright runs; the spacing in this clip is >= 1 s, so the cap did not bite.
- 01:57 Session close (iteration 6). Head after this entry; last code commit 9062ecf, all gates PASS there.
  This session: noir Rivet parts (modest gain: visor U, B/W collar), blood marks (directional spatter,
  wet-edged pools; clear gain), drips, the muzzle's one-frame pool of light (the strongest new beat),
  photosensitivity caps on the light and the kill beat, noir peds (not adopted: they cost the cop read),
  the cop-read value-role experiment, final showcase re-shot (show-final3). Images: 3 Codex, 0 rejected,
  no limit hit; Leonardo 0 tokens; provenance +29 lines. Ladder 22 rows (masters + evidence/). Masters
  ~720 MB in night/noir. No process of mine left running (the Godot processes at 01:57 are the n-d5 and
  visual-engine lanes'; codex-windows-sandbox-service is Codex's own service).
  Morning entry points: evidence/NOIR.md, evidence/showcase-hero.png, masters night/noir/show-final3/*.mp4,
  evidence/ladder.png. NEXT: the list above (iteration 6 close).

## 2026-11-03 iteration 8 (BUILD), 01:58-03:28

- 01:58 Read JOURNAL + git log (head df54a58). No iteration 7 entry in this journal. Leonardo probe (key not
  printed): apiSubscriptionTokens 0, apiPaidTokens null -> Codex only, if any images.
- MILESTONE (02:07) photosensitivity, measured (NEXT item 2). New tool (outside git, masters
  night/noir/tools/flash_check.py, `python -I flash_check.py <clip>`): an approximation of the WCAG 2.x
  2.3.1 general-flash test - linear relative luminance averaged over sliding quarter-screen windows,
  transitions of >= 0.1 with the darker side < 0.8, a flash = a pair of opposite transitions, worst
  count in any 1 s. LENIENT on small local flashes (its windows are bigger than WCAG's ~10-degree area)
  and it has no red-flash test, so it is a smoke test, not a certification.
  BEFORE: show-final3 noir 48 = 3 flashes in one second (frames 177-222: light, beat, light) - AT the
  limit with zero margin; quest-v4 = 3 too; D4 = 0. The two separate caps (light 3/s, beat 1/s) could
  add up past 3 together. (A first version of the tool double-counted; fixed before these numbers.)
  FIX: `features/fx/noir/flash_budget.gd` (FlashBudget): ONE budget shared by the kill beat (cost 2)
  and the muzzle light (cost 1), 3 per 60 ticks, and the light only spends when a beat would still fit
  (safe-v1 showed a round just before a kill otherwise turned that kill's beat calm - fixed in befeb57).
  Net: at most 1 light + 1 beat a second. The light now lights 1 round a second (was up to 3): in the
  showcase 3 of 6 rounds light (f064, f150, f230), f104/f194/f270 do not - a visible cost.
  Flashes-off mode: params `safety.flashes` (ships true) / `--flashes=off` in showcase_fight and
  quest_fight: no muzzle light, and the kill beat is the CALM one (no white flash, no gutters, the
  hit-stop kept, the held pose framed by a thin PAPER border - v1's ink border vanished on black).
  AFTER: safe-v2 (default) = 2 flashes max in any second, 2 full-frame flashes (the two kills); safe-v3
  (flashes off) = 0. 188 unit pass (+5: test_flash_budget.gd), lint clean.
  Evidence: masters night/noir/safety-before-after-48.png (rows before / budget / flashes off, cols the
  fire ticks and kill 101), safety-calm-beat-48.png (calm beat v1 ink border vs v3 paper border), clips
  safe-v2/showcase-noir-48-budget.mp4, safe-v3/showcase-noir-48-flashes-off.mp4 (both also in evidence/
  as PNG sheets). Not yet: a settings-menu toggle (core/settings is a README only; the param is the hook).
- (02:12) quest_fight re-measured with the budget: quest-v5/quest-fight-48-budget.mp4 = 2 flashes max in any
  second (quest-v4 before: 3), 16 kills. Note: quest_fight logs "36 resources still in use at exit" at
  quit (seen at befeb57 already, before the stains; dev host only, not investigated).
- MILESTONE (02:15) blood on the bodies (NEXT item 5, half): `features/fx/noir/blood_stains.gd`
  (BloodStains, above the rigs, z 20): a kill soaks the victim's torso with 5 hashed teardrop stains
  toward the exit side of the hit, a player hit leaves 2 small spots; each stain follows its body via
  NoirCombatFx.set_stains (the px locate), grows over 24 ticks; data `stain` in blood_fx.json, pooled
  (max_stains 48). Wired in showcase_fight and quest_fight. +2 unit tests (190 pass), lint clean.
  Evidence: masters night/noir/stain-before-after-64.png (crops of both dead cops and Rivet, left
  show-final3, right stain-v1), stain-before-after-48.png (top before safe-v2, bottom after), clips
  stain-v1/showcase-noir-48.mp4 / -64.mp4. Ladder rows 23 (flash budget) and 24 (stains), 24 rows.
  Honest read: modest but right - the dead cops' torsos now carry a red soak, so the body itself shows
  the wound (before, the blood was all on the ground beside it); Rivet's two spots are small (2 px at
  48 px/m) and read as dots. Wall splats still need wall edges in the view (not done).
  FRICTION: an earlier Python edit wrote CRLF into 5 noir files, and a later multi-line replace then
  silently missed (caught by the line count); files normalised to LF, edits now assert their match.
- MILESTONE (02:30) wall splats (the brief's last missing blood item; NEXT item 5 now done in a first
  form): BloodFx.solid = Callable(px) -> bool (the host's wall test). A droplet that would fly into a
  solid cell stops at the last free point and leaves two splats there, sized by the impact speed and
  stretched both ways along the wall (axis-aligned normal: the city's 1 m cells), so a spray ends in a
  hard red line at the edge. The hosts use the sim's cells (`cell_at >= C_BUILD`: buildings AND props /
  parked cars count as walls; void does not). `blood_clip --wall` stages the first kill 1.2 m short of
  the nearest solid cell along the kill line (`--wall=nosplat` = the same staging, walls ignored = the
  before). 39 droplets hit the wall. +1 unit test (191 pass), lint clean.
  v1 (r = size * (1.4 + v/5)) read as a few dots along the edge - too small; v2 (r = size * (2.2 + v/2.5),
  full stretch, nudged off the wall) reads as a smear line. Kept v2.
  Evidence: masters night/noir/wall-crops-64.png (64 px/m crops: before | v1 | v2),
  wall-before-after-48/64.png (v1 full frames), wall-v2/48 + wall-v2/ frames, clip wall-v1/wall-fight-48.mp4
  / -64.mp4 (v1); evidence/wall-crops-64.png, evidence/wall-48-f300.png. Ladder row 25.
  Honest read: correct and readable at 48/64 as "the blood hit something and stopped", but top-down
  hides the wall face, so it is a line, not a splash running down a wall; the before (spatter over the
  roof of the block) was more spectacular and physically wrong. The block it hits here is a hatched
  solid on the pavement (a building or a prop - the test does not tell them apart). The showcase kills
  are > 4 m from any wall, so the showcase does not show it (it is wired there; frames re-shot to check
  nothing else moved). FRICTION: the first showcase re-record with the wall test hung for 10 min (no
  frames); killed by PID (my own processes only); a headless check found no script error; re-recording.
- (02:37) Gates at 572a4a2 (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty): lint (13),
  191 unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS; JSONs in evidence/.
  Showcase re-shot at 572a4a2 (show-v10, 48 px/m): all 23 hero frames pixel-identical to stain-v1 (the wall
  test changes nothing there). evidence/NOIR.md updated for iteration 8.
- (02:37) NEXT item 7 (noir_frames tick-exact) needs no code: `--fixed-fps 60` makes every frame one tick;
  two runs of `noir_frames --scenes=street` were pixel-identical in all 6 frames (masters tick-exact/a, b).
  Usage line added to the script header. Older ped A/Bs (ped-v0/v1) were shot without it (not re-shot).
- (02:41) Final showcase re-shot at b6797ea+: masters night/noir/show-final4/ (noir 48 / 64, D4 48; 11.3 s, 60 fps,
  `--coat --noir-parts`) + evidence/showcase-hero.png rebuilt with masters tools/hero.py (the previous sheet is
  evidence/showcase-hero-v3.png). Flash meter on show-final4 noir 48 and 64: 2 flashes max in any second
  (show-final3: 3). Rows: f230 (lit under the budget), f169 silhouette flash, f175 held panel, f322 aftermath
  (now with the stains). The hero rows use f169 for the silhouette flash: the kill fires on f168 and the heroes
  are saved at kill +1 / +2 / +4 / +7, so f168 + f169 are the two silhouette ticks and f170 the inverted panel,
  exactly the params' [4, 4, 1] (checked; an earlier note of mine here called it a one-frame bug - wrong).
  Masters trimmed (my own superseded scratch) to ~950 MB. Images this session: 0 (no generation needed);
  Leonardo 0 tokens; provenance +0.
- MILESTONE (02:46) NEXT item 5 (noir HUD), in the dev host: quest_fight lifts the HUD's CanvasLayer to
  ImpactFrame.LAYER + 1 (above the noir pass and the comic beat) - v6 showed that this exposes the HUD's D4
  vermilion (heat pips, speaker name, weapon), against this direction's no-orange rule - so v7 adds
  `assets/shaders/look_noir_hud.gdshader` on HudView: colours near the vermilion key print as ink (blood
  and teal untouched). Evidence: masters night/noir/hud-noir-3way.png (also evidence/: v5 under the pass |
  v6 lifted | v7 lifted + noir print), hud-before-after-f300/f600.png, clip quest-v7/quest-fight-48.mp4
  (flash meter 2/s). Ladder row 26 (26 rows). Honest read: a clear gain - the text is clean, the heat pips
  read as solid ink vs cream; the speaker name loses its accent (still upper case). The boxes stay D4 cream,
  not pure paper. Only in the dev host; the shared HudView / CollectCallView are not touched.
- (02:48) Gates at afdb64f (after the HUD commit; `run.mjs --no-bench --allow-dirty`): lint (13), 191 unit, 8
  scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS; JSONs in evidence/.
- (02:49) TUNE the hit spots on Rivet: stain.player_hit r_px 1.0-2.0 -> 1.8-3.0 (3450469). Evidence
  masters night/noir/stain-rivet-64.png (64 px/m crop, f322, left before / right after; also evidence/):
  reads as a wound on his chest instead of two specks. show-final4 re-shot with it (noir 48 / 64 / 32, D4
  48) and evidence/showcase-hero.png rebuilt from it. Flash meter: noir 32 / 48 / 64 all 2 per second max.
  The 32 px/m cut (evidence/show-32-final3-vs-final4.png, aftermath f322): at the on-foot zoom the body
  stains are barely visible (a few px); the ground pools and spatter carry the blood there.
- (02:53) Flash meter + WCAG red-flash test (masters tools/flash_check.py: saturated red = R/(R+G+B) >= 0.8,
  value (R-G-B)*320, a transition > 20, counted per quarter-screen window like the luminance flashes).
  Results: show-final4 noir 48 / 64, D4 48, quest-v7, wall-v1 64, safe-v3 (flashes off): 0 red flashes.
  HONEST: the 0 is about area, not colour: blood pixels peak at 142 (the threshold is 20), but blood covers
  about 1.6% of any quarter-screen window (the peak window value is 2.3). Blood spurts never cover the area
  WCAG counts; a full-screen red beat would be caught, a local one would not. Self-review of tonight's diff:
  one stale comment fixed (ImpactFrame: the calm border is paper); nothing else found.
- MILESTONE (02:59) a calmer on-foot frame (the weakest zoom per the ladder): look_noir rim_lo 0.02 -> 0.06,
  rim_hi 0.06 -> 0.14 (9aa5986). The dark-on-dark rim caught faint ground detail (cracks, puddle outlines) and
  printed it as white double lines - the busiest part of the 32 px/m street. A/B with noir_frames
  `--fixed-fps 60` (tick-exact): masters night/noir/rim-v1/ (base vs hi, junction + street at 32 / 48 / 64;
  ab-street-32.png also as evidence/rim-street-32.png, ab-junction-64.png, crop-junction-32.png). Read: a clear
  gain on the 32 street (the cracks drop to dim grey); the actors' rims are strong edges and do not change
  (junction crops at 32 and 64 look the same on the figures); some puddle/planter outlines go dimmer too.
  Kept. 191 unit pass. The final showcase re-shot again with it: masters night/noir/show-final5/ (noir 32 /
  48 / 64; the D4 48 clip and frames copied from show-final4, as the D4 run never reads look_noir) and
  evidence/showcase-hero.png rebuilt (show-final4's sheet kept as evidence/showcase-hero-v4.png). Flash meter
  on show-final5 noir 32 / 48 / 64: 2 per second max, 0 red. Ladder row 27 (27 rows).
- (02:59) Gates at b0bac00 (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty): lint (13),
  191 unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS; JSONs in evidence/.
- 03:00 Session close (iteration 8). Last code commit 9aa5986 (rim tune); gates PASS at b0bac00.
  This session: photosensitivity measured and fixed (a flash meter with the WCAG luminance + red tests; the
  showcase was AT 3 flashes/s, now 2 with one shared FlashBudget; a flashes-off mode with a calm beat = 0),
  blood on the bodies (stains following each body; Rivet's hit spots tuned up), wall splats (sprays stop at
  the sim's solid cells and smear along the edge), quest 1's HUD lifted above the pass and printed B/W,
  noir_frames tick-exact via --fixed-fps 60, a calmer 32 px/m street (rim tune), final showcase re-shot twice
  (show-final5 is current) + hero sheet rebuilt. Images: 0 generated, 0 rejected; Leonardo 0 tokens;
  provenance +0. Ladder 27 rows (masters + evidence/). Masters ~1.1 GB in night/noir. No process of mine left
  running (the two Godot run_scenarios processes at 02:59 are another lane's; untouched).
  Morning entry points: evidence/NOIR.md, evidence/showcase-hero.png, masters night/noir/show-final5/*.mp4,
  evidence/safety-before-after-48.png, evidence/ladder.png.
- (03:00) The rim tune checked on the third scene too (roofs at 32 / 48 / 64, tick-exact; params restored with
  `git checkout` after the temporary base run - tree clean): masters rim-v1/ab-roofs-32.png, ab-roofs-48.png
  (also evidence/rim-roofs-32.png). The paper rooftops do not change (the rim only acts dark-on-dark); the
  street strip at the edge gets calmer, as on the street. Neutral to positive: kept.
NEXT (iteration 8 close, in order):
1. Owner picks from evidence/showcase-hero.png (re-shot, show-final5) + masters night/noir/show-final5/*.mp4:
   (a) the comic language: silhouette flash -> held panel on kills, the muzzle's one-frame pool of light (now
       1 light a second under the shared flash budget); (b) value roles: cops = ink among paper peds (default)
       vs ink peds + paper cops (evidence/ped-cop-read.png); (c) noir Rivet parts (evidence/rivet-before-after.png);
       (d) whether Rivet stays the lit paper figure (his limbs) or gets more ink mass (a limbs round).
2. Photosensitivity: a real check before shipping (the flash meter in masters tools/flash_check.py is a
   smoke test: lenient on small flashes, no red-flash test); a settings-menu toggle for `safety.flashes`
   once core/settings exists (today it is a README only).
3. Move noir parts + the coat from the dev hook (NoirParts.wear) into the rigs: a noir art_dir per plan,
   the coat as a CutRig part. Wire BloodStains / BloodFx.solid into the real game hosts with the look.
4. Wall splats are a line on the edge (top-down hides the wall face); a vertical run-down smear on the
   building's lit face would need the facade in view (the D4 roofs have no facades).
5. The noir HUD (done in quest_fight, 02:46) belongs in the look profile: when --look=noir is the game's
   look, the composition root should lift the HUD and set look_noir_hud (today: the dev host only).
6. blood_fx.gd is 250 lines (over the ~200 guide, under the 300 stop): split the droplet pool out if it grows.

## 2026-11-03 iteration 10 (BUILD), 03:01-

- 03:02 Read JOURNAL + git log. Leonardo probe (key not printed): apiSubscriptionTokens 0, apiPaidTokens null
  -> no Leonardo. No image generation planned this session. Disk C: 226 GB free.
- Weakest point picked from the hero sheet: the noir world is a uniform black street with thin white lines;
  the brief's "big black shadow masses carved by white light" only happens on the one muzzle frame.
- MILESTONE (03:14) street light (2d0c56a): `features/fx/noir/noir_lamps.gd` (NoirLamps) reads the city's
  `lamp_post` props from the resident chunks' draw lists (each chunk scanned once; the offset shadow copy
  - xf[3] = 1 - skipped, an early bug: every lamp came in twice), centres the pool under the arm's head
  (HEAD_M 1.0 along the prop's rotation; the art's head is its +x end) and NoirLook.light_street hands up
  to 8 (screen px, nearest the focus) to look_noir: `lamps[8]`, `lamp_count`, data `lamp_r` 190 (px at 32
  px/m, ~5.9 m), `lamp_lift` 0.45, `lamp_core` 0.45, `lamp_gate` 0.05 (values under it stay ink in the
  light: the cops' ink masses). The lift falls off from core to rim through the threshold band, so a pool's
  edge prints as pen strokes. Shared file: city_view.gd +1 line (`noir.light_street(...)` in
  _place_camera). +5 unit tests (196 pass), lint clean.
  A/B tick-exact (noir_frames --fixed-fps 60): masters night/noir/lamp-v1/ (base = lamp_r 0, lamp = v1 pool
  on the post, v3 = under the head, lift 0.45 = kept; ab-<scene>-<ppm>.png = before | v1 | v3, all 3 scenes
  at 32/48/64), evidence/lamp-street-48.png, lamp-street-32.png, lamp-roofs-32.png. Ladder row 28.
  Iterations: v1 (pool on the post, lift 0.35, gate 0.144) lit the pavement and spilled onto the roof
  behind the post; v2 (gate 0.05) = no visible change (asphalt is darker than the gate matters for); v3
  (under the head, lift 0.45) moves the pools to the kerb. Kept v3.
  Honest read: the biggest step towards the brief's "black masses carved by white light" since look-v4 -
  the street now has a rhythm of white pools along both pavements (16 m apart, the city's spacing), the
  falloff hatches, a cop in a pool is a solid black silhouette, white peds keep their ink outline. Costs:
  the asphalt barely lights (pools stop at the kerb: reads as "light on the sidewalk"); where a pool falls
  on an already-paper area (roofs scene) it washes out the D4 grid dots; the junction (the showcase spot)
  has NO lamp within reach (nearest heads ~19-24 m away), so the hero frames do not change.
  FRICTION: city_view.gd was CRLF in the working tree (index LF); a scripted edit missed - normalised.
  FRICTION: one `ladder.py` row pointed at rim-v1/hi/, which the iteration 8 trim emptied; row 27's after
  now uses lamp-v1/base (the same code as 9aa5986: lamp_r 0 = no lift).
- MILESTONE (03:30) headlights + a placement fix (ba739a2). `features/fx/noir/noir_headlights.gd`
  (NoirHeadlights, static, render only): every live traffic / police car in the sim snapshot (kind [1],
  mode [2] not M_DEAD, x y [4..5], unit heading hx hy [6..7]) throws a cone of white ahead of its nose (centre
  + heading * 2 m); up to 12 nearest the focus. look_noir `cars[12]`, `car_count`, data `beam_len` 300,
  `beam_w` 18, `beam_spread` 0.2, `beam_lift` 0.5; the throw ends in a ragged arc (v1 = a hard straight cut).
  v1 cones were ~9 m wide (spread 0.38): too much; narrowed in v2.
  FIX (a bug in my 03:14 lamp commit, found because the v2/v3 cones did not sit on any car): the lights were
  placed in canvas px, but the project's base viewport is 1280x800 with canvas_items stretch, so at a
  1280x720 window the canvas view is 1422x800 and canvas px != screen px. A printed car record vs the D4 frame
  showed the cone ~1.5 m off its car; the lamp pools were off by up to ~2 m, so the 03:14 "pool under the
  head" read was confounded. Lamps and cars now go in as screen uv (the muzzle light's mapping, which was
  right), sizes scale by zoom * window / view (`view_h`). Checked: at 32 px/m (beam-v4/cmp32.png, D4 above,
  noir below, same tick) every cone starts at a car's nose and the pools sit on the D4 lamp posts.
  `light_street(city, focus, zoom)` (CityView's one call changed). +2 unit tests (197 pass), lint clean.
  Evidence: masters night/noir/beam-v4/ (all 3 scenes at 32/48/64; ab-<scene>-<ppm>.png = before | after),
  evidence/light-street-48.png, light-street-32.png, light-junction-48.png (replacing the mis-placed
  lamp-*.png of 03:14). Ladder row 28 now = before vs beam-v4.
  Honest read: the street at 48 px/m reads as a noir street - pools on both pavements, a hard white wedge
  ahead of every car, silhouettes inside. The junction (no lamps in reach) now gets light from the riot's
  cars. Costs: the cone edges are perfectly straight (a vector look next to the ragged pools); a car prints
  as a flat paper box, so box + cone read as one shape; more white area makes the 32 px/m frame lighter
  overall (less "black mass" at the on-foot zoom).
- MILESTONE (03:32) the showcase under the street light: showcase `--at=<x>,<y>` (b1ca607) stages the same
  fight at (501, 523), the street west of the junction with a lamp above the fight. Re-shot after the fix:
  masters night/noir/lamp-show2/ (noir 32 / 48 / 64 clips + frames; D4 48 in lamp-show/d4, the D4 run is
  unaffected) and evidence/showcase-hero-street.png (D4 48 | noir 48 | noir 64: fire tick, silhouette flash,
  held panel, aftermath). Ladder row 29 (junction vs lit street aftermath). Flash meter: 32 = 2/s, 48 = 3/s
  (the WCAG limit, still a pass; the junction showcase is 2/s - the lit pools make one quarter window count
  one more transition around the kill beat), 64 = 2/s; 0 red flashes. The lamp-show/ (03:12) set is the
  mis-placed one; superseded.
  Read: this is the stronger hero - the fight on black asphalt between two white pools, red the only colour.
  The junction showcase (show-final5, evidence/showcase-hero.png) stays the brief's spec'd scene.
- (03:33) Gates at 7195d2c (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty): lint (13), 197
  unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS; JSONs in evidence/.
  evidence/NOIR.md updated for iteration 10. Masters: my superseded light scratch deleted (lamp-show 48/64/32,
  beam-v1..v3, lamp-v1 lamp/v3); night/noir ~1.2 GB.
- (03:45) Cost of the lights (`noir_cost`, junction riot, 1920x1080, RTX 4090, zoom 1.5; light_street now skips
  while the pass is hidden and records `light_us`; noir_cost reports `noir_light_cpu_ms`):
  CPU: light_street = **0.064 ms / frame** (the lamp lookup + one extra sim snapshot copy), measured.
  GPU: NOT resolved. Four alternating runs (lights off / on / off / on): D4 2.65 / 1.47 / 1.97 / 1.50 ms, noir
  1.57 / 1.30 / 2.33 / 1.66 ms - the run-to-run noise (other lanes share this GPU tonight) is bigger than the
  lights' cost, so the honest statement is "below ~0.5 ms at 1080p on this GPU, not measured more precisely".
  The per-pixel loops are 8 lamps + 12 cars with a value-noise call each; a quiet-machine re-measure (or the
  iGPU, `--gpu-index 1`) is the next step. Files: evidence/noir-cost-1080p-z1.5-lights.json, -z1.0-lights.json,
  masters night/noir/cost-*.json.
- (03:38) TUNE the cones' brush edge (c04dae9): width wobbles 16% along the cone (world-locked value noise), so
  the edge is a hand-inked line, not a ruler. Small gain. masters beam-v5/edge-*.png (v4 above, v5 below;
  also evidence/light-cone-edge-48.png).
- TRIED / NOT ADOPTED (03:41) traffic in the showcase: `--cars=<n>` (efd6435). 6 cars never reached the
  street in 11 s (spawns are >= 105 m out; the clip was byte-identical); 40 cars do pass. The cone sweeping
  under Rivet is the best noir image of the night (evidence/cars-through-fight-NOT-adopted.png, 9.0 s), but
  the sim's cars do not see the scripted fighters: at --at=501,523 a car's roof ran over a dead cop's legs,
  at --at=501,520.5 a car drove straight through Rivet and the body (the same evidence image, 9.5 / 10.0 s).
  A camera-break-class defect, so not in the hero. Needs the fighters as sim obstacles (or a scripted car).
  Masters cars-show2/ (clip + strip). Flag kept, with the caveat in its doc line.
- (03:45) The junction showcase re-shot with the lights: masters night/noir/show-final6/ (noir 32 / 48 / 64 at
  efd6435; D4 48 copied from show-final5, the D4 run never reads look_noir). Checked frame by frame against
  show-final5: all 48 and 64 px/m hero frames are pixel-identical (no lamp or car within reach of the
  junction view; the showcase has 0 cars), only the 32 px/m frames change (lamp pools from off-screen posts
  on the four corner pavements): evidence/show-32-final5-vs-final6.png. So evidence/showcase-hero.png (48/64)
  stands as it is. The four posts in the junction's corners are traffic signals, not `lamp_post`, so they
  throw no pool. Flash meter show-final6 noir 32 / 48 / 64: 2 per second max, 0 red.
- (03:46) REFACTOR (NEXT item 6, aa0621a): blood_fx.gd 250 -> 215 lines; its static helpers (counter hash,
  colour from data, zero-filled packed pools) move to `features/fx/noir/noir_pack.gd` (NoirPack). 197 unit
  pass; the junction showcase re-recorded at 48 px/m: all 23 hero frames pixel-identical to show-final6.
- MILESTONE (03:47) cars as ink masses (9fa045b): `car_ink` 1 prints each moving car's body (`car_len` 140 x
  2 * `car_half_w` 30 px at 32 px/m, behind the headlight nose, from the same NoirHeadlights data) as solid ink
  with a 1.5 px white edge. A/B same tick: masters night/noir/carink-v1/ab-junction-48.png, ab-street-48.png,
  ab-street-32.png (left beam-v5, right car_ink); evidence/car-ink-junction-48.png, car-ink-street-32.png.
  Ladder row 30 (30 rows). Read: a modest gain - the car becomes a dark hulk behind its own light, so the cone
  and the pools (and Rivet) are the brightest things, not the car box; matches "cops = ink masses". Costs: the
  body is an exact rectangle sized to tonight's placeholder car art (real car art will need its size from the
  art table), and it paints over whatever stands on its footprint (at 32 px/m a ped brushing the car loses a
  sliver). 197 unit pass.
- (03:48) Gates at f3689ac (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty): lint (13), 197
  unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS; JSONs in evidence/. Note: the
  selftest's D4 48 px/m colour count read 71 (80 at 7195d2c); the noir code is not in that path (no NoirLook
  in the selftest's CityView: light_street never runs) and the crowd is live - not investigated further.
  evidence/NOIR.md updated (iteration 10 section, gates line, 30 ladder rows).
  Images this session: 0 generated, 0 rejected; Leonardo 0 tokens; provenance +0.
NEXT (iteration 10, in order):
1. Owner picks: the street-light showcase (evidence/showcase-hero-street.png, masters lamp-show2/*.mp4) vs the
   junction one (showcase-hero.png, show-final6/); plus the iteration-8 open choices (value roles, noir Rivet
   parts, Rivet's ink mass).
2. Traffic in a fight (evidence/cars-through-fight-NOT-adopted.png): the best image of the night, blocked by
   the sim's cars not seeing the scripted fighters. Either a scripted car in fight_script (dev) or the fighters
   as sim obstacles (sim scope, not this lane).
3. Flash margin (see 03:50): the street showcase is at 3 flashes/s at 48 px/m (the limit, as FlashBudget allows) - the inverted
   panel flips the lit pools to ink. Options: keep lit pools paper in the inverted panel, or count the lit
   area in FlashBudget. The junction showcase stays at 2.
4. The muzzle pool's radius still scales by zoom in canvas px (~11% larger on screen than flash_r says at a
   1280x720 window); move it to `ls` with flash_r * 1/0.9 to keep the look (cosmetic, re-shoot the heroes).
5. Lights: the asphalt barely lights (pools stop at the kerb), car bodies are placeholder-sized rectangles
   (car_len / car_half_w should come from the car art table once real cars exist), the lights' GPU cost is
   unmeasured on a quiet GPU (CPU 0.064 ms/frame measured). Traffic signals could cast small pools too.
6. Carried over: noir parts + coat into the rigs (art_dir per plan), BloodStains / BloodFx.solid into the real
   game hosts, the noir HUD in the composition root under --look=noir, a settings toggle for safety.flashes.
- (03:50) NEXT item 3 looked at (no code change): which flashes make the street showcase's 3/s at 48 px/m.
  The worst window is the bottom-left quarter (window 12), video frames 177-206 (masters night/noir/
  flash-street-48-frames176-206.png: 176, 177, 178, 194-199, 206): 177 the muzzle light's pool (up) / 178
  (down) = 1; then the kill beat: 195 silhouette flash (up), 197 the inverted panel turns the lit pool to ink
  (down), 198 the panel's paper gutter (up), 206 back to the scene (down) = 2. That is exactly FlashBudget's
  own accounting (a kill beat costs 2, the light 1, at most 3 a second = the WCAG 2.3.1 limit): the junction
  measured 2 only because there the inverted frame stays mostly paper. So: a pass by design, with no margin
  where the ground is lit. NEXT item 3 corrected: if a margin is wanted, the inverted mode could keep lit
  pools paper (or the beat skip mode 1 over lit ground); not changed tonight.
- REVERTED (03:51) lamp_gate 0.05 -> 0.01 (to let the asphalt catch the pools): no visible change (masters
  night/noir/gate-v1/ab-street-48.png, ab-street-32.png, ab-junction-48.png). The gate is not why the pools stop
  at the kerb: the cones light the asphalt fine at full lift, but the kerb lies in a pool's falloff (the pools
  are centred on the pavement), where the lift is too small to cross the threshold. A geometry question (pool
  radius / centre / core), left in NEXT item 5. Params restored with `git checkout`.
- TRIED (03:52) lamp_core 0.6 with the pools 2.2 m out (geo-v1): bigger, flatter pools, ink share 62% at 48 px/m.
  Too much white for little gain; not kept.
- MILESTONE (03:53) pool geometry (32e1bc0): the pool centres 2.2 m out along the lamp arm (was 1.0), core
  kept 0.45 (geo-v2). The light now reaches the kerb line and bites into the road edge with hatching, which
  answers most of "the pools stop at the kerb". Ink share (pixels < 100 of 255) street 48: 70% -> 65%,
  street 32: 58% -> 55%. A/B 3-way: masters night/noir/geo-v2/ab3-street-48.png, ab3-street-32.png,
  ab3-roofs-32.png (current | v1 | v2). 197 unit pass.
  Street showcase re-shot: masters lamp-show3/ (noir 32 / 48 / 64) + evidence/showcase-hero-street.png rebuilt;
  ladder row 29 now uses lamp-show3 (lamp-show2 deleted: superseded). Flash meter: 32 = 2/s, 48 = 3/s, 64 = 3/s
  (64 rose from 2: the same mechanism as 03:50, the inverted panel over a lit pool; the budget's own maximum,
  a pass); 0 red. The junction showcase at 48 px/m re-recorded and diffed: 23/23 frames pixel-identical to
  show-final6, so evidence/showcase-hero.png stands (its 32 px/m frames will differ slightly; not re-shot).
- (03:57) Gates at acb72b3 (`run.mjs --no-bench --allow-dirty`): lint (13), 197 unit, 8 scenarios, parity (1200
  steps, mutation caught at 629), selftest all PASS; JSONs in evidence/ (selftest D4 colours 76 / 73: the
  count moves run to run). evidence/NOIR.md: gates line, the honest comparison gains the street-light note.
- 03:57 Session close (iteration 10). Last code commit 32e1bc0; gates PASS at acb72b3. This session: street
  light (lamp posts -> pools of paper, from the city's own props), headlights (sim cars -> white cones), cars as
  ink masses, a placement bug found and fixed (canvas px vs screen px under canvas_items stretch), the pools moved
  out over the kerb, the showcase staged under a street lamp (`--at`), traffic in the fight tried and not
  adopted, the street showcase's 3 flashes/s explained (the budget's own maximum), blood_fx.gd split (NoirPack),
  lights' CPU cost measured (0.064 ms), GPU cost not resolvable tonight (noise). Images: 0 generated, 0 rejected;
  Leonardo 0 tokens; provenance +0. Ladder 30 rows. Masters night/noir ~1.2 GB. No process of mine running.
  Morning entry points: evidence/NOIR.md, evidence/showcase-hero-street.png + masters lamp-show3/*.mp4,
  evidence/showcase-hero.png + show-final6/*.mp4, evidence/light-street-48.png, evidence/ladder.png.
NEXT addendum (iteration 10 close): item 5's "pools stop at the kerb" is mostly answered by 32e1bc0; the
  junction showcase (show-final6) re-shot at 32 px/m after it (03:58; flash meter in the next line); 48 / 64 verified unchanged.
  show-final6 noir 32 re-shot at a62cc7c: flash meter 2 per second max; evidence/show-32-final5-vs-final6.png rebuilt from it.
