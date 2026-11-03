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
   unit-tested). Still to do: the kill's silhouette flash (2 white ticks per kill) has no cap in a mass
   fight; have an accessibility toggle (flash off) reviewed before anything ships.
3. Rivet's noir limbs read as paper (the redraw is mostly lit white, and at 32 px/m the sticker LOD ignores
   the art for limbs and core). If the owner wants a darker Rivet: a limbs round with more ink mass, or a
   noir limb_wash in print_part.
4. Move noir parts + the coat from the dev hook (NoirParts.wear) into the rigs: a noir art_dir per plan,
   the coat as a CutRig part.
5. Wall splats (still needs wall/prop edges in the view); blood marks on the bodies themselves.
6. Noir HUD palette (Ink tokens without vermilion) for quest 1's view, then lift the HUD above the pass.
7. Make noir_frames tick-exact between runs (step the world by ticks, not frames) so ped/crowd A/Bs are
   the same pixels; re-shoot quest_fight with the muzzle light.
- (01:53) Gates at 180c78a (`run.mjs --no-bench --allow-dirty`, only the untracked evidence/ dirty): lint
  (13), 181 unit, 8 scenarios, parity (1200 steps, mutation caught at 629), selftest all PASS (the run
  before it flagged unit-tests only because I edited JOURNAL.md during it). Gate JSONs copied to evidence/.
  Then the photosensitivity guard (LIT_GAP 20 ticks) + its test: 182 unit pass, showcase pixel-identical.
