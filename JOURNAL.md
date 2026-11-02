# JOURNAL - lane visual-engine (n-visual)

## 2026-11-02 iteration 2 BUILD (21:08 -> 22:38)
- Worktree was fresh (no JOURNAL from iteration 1 here). Copied the native DLLs from the f04-core
  worktree (native/ unchanged since b2c5b8b), imported, baked the 256 chunks.
- Baseline frames: `gtai-masters/night/visual-engine/00-baseline/selftest-{32,48}ppm.png` (city_selftest,
  seed 91, junction riot, RTX 4090 d3d12).
- MILESTONE item 1: render layer stack as data. `data/tables/render_layers.json` (gtai.render-layers/1)
  + schema, `core/render/render_layers.gd` (canvas()/z()/audit()), `core/render/README.md`. ChunkView now
  splits each chunk into 5 bands x 4 quadrants (ground, decals, building shadows, props, roofs), CrowdLayers
  uses bands (shadows 0, people 100, vehicles 200, bullets fx 400), rigs at the people band.
  Test `tests/unit/test_render_layers.gd` 5/5 (builds the real city scene and audits it).
  After frames `01-layers/`: cars above people now; rigs no longer under the crowd/cars.
- Item 7 (cheap rig fix) landed early: CityCharacters skips the whole rig pass (feed + select + pose)
  on frames with no sim tick. Not yet measured (bench pending).
- Bench (exported release, 1 run x 30 s, after the rig skip): p99 2.61 ms, 1% low 268 fps; rigs p50 0 /
  p99 0.559 ms per frame (riot, 16 rigs). FRICTION: the skip removes the no-tick frames (p50 -> 0) but
  the p99 is a tick frame and is unchanged vs lane A's 0.57-0.59: the 0.3 ms target is NOT met.
  Next lever: spread the half-rate rigs / move selection to every other tick. evidence/bench-*.json.
- MILESTONE item 2: look profiles as data. `data/tables/look_profiles.json` (gtai.look-profiles/1) with
  d1/d4/d5 rows of every print uniform (+ item uniforms + parts_flat_below), default `auto` = d4 to
  48 px/m, smoothstep to d5 at 64. `-- --look=<id|auto|off>` (shared file touched: boot/launch_args.gd
  KNOWN_FLAGS + boot/world.gd, 3 lines). look_d4 got a `hatch_period` uniform (4.0 = unchanged).
  Golden frames: dev/selftest/look_golden.gd under --fixed-fps 60, 10 cases, goldens in
  tests/golden/look (320x200, LFS). Two runs bit-identical (mean 0.00). Hooked into tools/selftest/run.mjs
  -> selftest evidence: "look goldens 10/10 within mean 4 (worst 0.00)". Unit 154/154, lint 13/13.
  Frames: gtai-masters/night/visual-engine/02-looks/ (D5@64 visibly darker/grimier than D4@64;
  0 rejected, all straight down). D4 at 32/48 is unchanged by construction (auto = d4 below 48).
- MILESTONE item 3: colour doctrine. `data/tables/palette.json` (gtai.palette/1): base tokens, the two
  accents with allowed uses + allowed render layers, classifier gates = look_d4 plates(). `core/render/
  palette_tokens.gd` (classify, allowed, count_accents). `dev/selftest/accent_audit.gd`: per-layer accent
  pixel counts by hiding layers with the tree paused; in the selftest evidence (non-gating).
  Result: vermilion 0.95 % of frame at 32/48 px/m, 0.26 % at 64, all on actors (cops). Teal 0-4 px.
  OFFENDER (asset, for d4-production): `features/city/art/props/traffic_light.png` - its 3 red lamps print
  on the vermilion plate in the world (216 px at 32 px/m). Suggest ink/paper lamps (or an unlit grey).
  Crop: gtai-masters/night/visual-engine/03-accents/world-offender-crop.png.
  Also noted: CityTextures.PLACEHOLDER["prop"] is a warm orange (0.75,0.45,0.3) - below the gate today
  (r-max(g,b) = 0.30 < 0.31) but one tweak from printing vermilion; no placeholder prop on screen now.
- MILESTONE item 4: 2D lighting. `data/tables/lights.json` (gtai.lights/1: 5 kinds, day/night grades,
  max_lights 32), `core/render/light_layer.gd` + `light_pool.gd`, `assets/shaders/light_ink.gdshader`.
  CityView owns a LightLayer stepped on the sim clock (CityCharacters sets view.clock). render_layers:
  `light` canvas -> screen space with bands grade 0 / lights 100. Test test_light_layer 4/4.
  Frames: 04-lights (stipple edges: read as halftone glow - REPLACED), 04b-lights-hatch (hatched band
  edges: read as drawn rings - kept). 0 frames rejected (all straight down).
  Cost: CPU step 70-168 us. GPU NOT reliably measured: deltas +1.32/+0.05/+0.09/-0.87 ms across 4 runs
  (FRICTION: the d5 lane renders on the same GPU at the same time).
  BLOCKED-ish: no positional shot/explosion events exist in Events; lights are API + dev driver only.
- DEVIATION logged: chunks now 20 canvas items (5 bands x 4 quadrants) vs the §20 "8 per chunk" row.
- MILESTONE item 5: FX system. `data/tables/fx.json` (gtai.fx/1, 8 kinds), `core/render/fx_system.gd` +
  `fx_pool.gd`, `assets/shaders/fx_ink.gdshader` (analytic placeholder shapes). CityView owns `fx` on the
  fx band, steps it on the sim tick, links fx lights into the LightLayer. test_fx_system 4/4 (budgets,
  tick expiry, determinism). Frames 05-fx at 32/48/64 (0 rejected). Step 48 us for 43 particles.
  Decision: crackle = paper bolts, not teal (teal = the dead only). BLOCKED for gameplay wiring: no
  positional shot/hit/explosion events in Events (needs an events.json change = shared file + owner).
- Gates at 21:50: lint 13/13, scenarios 8/8, unit 166/166 on rerun. FRICTION: the first unit run had
  1 failure (165/166): test_render_layers built CityView twice; the 2nd CityTextures threaded load can
  race the headless dummy renderer (null texture). Fixed: build the scene once in before_all (3/3 clean).
- MILESTONE item 6: camera feel. `data/tables/camera.json` (gtai.camera/1: modes 32/48/64, zoom ease 36
  ticks, car look-ahead, 4 shakes, 3 hit-stops, reduced_motion scales), `core/render/camera_rig.gd`.
  CityView.rig (World sets it, snapped to car = the current 48 px/m boot view; shared file boot/world.gd
  +2 lines). test_camera_rig 5/5. Frames 06-camera (ease 32->35->40.7->46->48 px/m). Gates 21:56: lint
  13/13, unit 171/171, scenarios 8/8, selftest goldens 10/10 (worst 0.00).
  Not wired: nothing calls set_mode on car enter/exit or kick() on hits yet (vehicle_entered/exited
  events exist in Events but the city has no player vehicle flow; hits have no positional events).

### Offender list for d4-production (colour doctrine)
- `project/features/city/art/props/traffic_light.png`: 3 red lamps print on the vermilion plate in the
  world (216 px at 32 px/m; crop `gtai-masters/night/visual-engine/03-accents/world-offender-crop.png`).
  Wanted: lamps in ink / paper (or one lit lamp as paper), no vermilion.
- FX sheet wanted (placeholders are analytic now): muzzle star, tracer streak, impact chips, explosion
  puffs (4-6 frames), smoke puffs, debris shards, ink splats (3 variants), melee crackle bolt (paper).
  Fit: one atlas per kind, frames of equal size, palette inks only, ink rim; straight-down view.
- Item 7 bench after items 1-6 (22:00): FAILED - p99 6.09 ms, 1% low 124, worst swap 72 ms, a 3.6 s frame,
  rig p99 0.98. INVALID run: CPU at 99 %, the n-d4 lane's RTAI-bench (drive48vsync) ran at the same time,
  plus 2 headless scenario runs, codex exec, playwright, a rust gate. All hitches `present` with ~0.3 ms
  game+render CPU; drive (which hardly touches my code) went 1.10 -> 5.48 ms p99. Not claimed green, not
  claimed as a regression: unmeasured. evidence/bench-*-contended.json (and the earlier -rigfix.json).
- Bench re-run 22:05 (n-d4's bench finished): PASSES the section 20 hard limits - p99 4.22 ms (< 7),
  1% low 111 fps (> 45), worst swap 4.5 ms (< 50), 4 frames > 50 ms all `present`; rig p99 1.24 ms.
  CPU load sampled right after: 83-96 % (docker, launchers, other lanes), so it is NOT comparable with
  the 2.61 ms run after item 1; the rig number rose with unchanged rig code = load. evidence/bench-*-rerun.json.
- Accent audit now splits the full rigs by kind (22:10): peds 0 vermilion at 32/48/64 px/m; Rivet
  168-304 px vermilion (collar) + 4 px teal (torch tip) - both allowed; cops 0 / 0 / 2028 px (no cop in
  the 16 nearest at 32/48 in this scene). The rest of the 0.95 % is the atlas crowd (not split: one
  MultiMesh). Real boot path smoke-tested windowed: `--look=d5` and `--look=auto` exit 0, no script errors.

NEXT (iteration 3 / morning):
1. FIRST: bench on an idle machine (no other lane benching), A/B `ad2078b` vs `n-visual` HEAD, 3 runs.
   If the 20-item chunk split costs, merge ground+decals and props+roofs (12 items) per the DEVIATION.
2. Rig p99 (0.56 ms tick frames vs 0.3 target): profile CutRig.drive vs _assign/RigInput; candidate:
   quarter-rate for ranks >= 10 (characters scope: coordinate with its owner).
3. Wire gameplay: positional events (shot_fired, bullet_hit, exploded at a world pos) -> FxSystem +
   LightLayer + CameraRig.kick; vehicle_entered/exited -> rig.set_mode(car/on_foot). Needs events.json
   (shared file, owner OK).
4. D5 integration after the merge (n-d5 61bc0f7 ships `look_d5.gdshader` = an OVERLAY pass over the
   look_d4 print + `assets/shaders/look_d5.params.json` gtai.look-d5-params/1 with zoom_amount stops
   32:0 / 48:0.35 / 64:1, plus a part tier at zoom 1.75-2.0 and look_d5_shadow). That differs from my
   placeholder `d5` row (a re-tuned look_d4 blended 48->64, weight 0 at 48). Plan: add an `overlay`
   block to look_profiles (shader id + uniforms from their params file + amount stops) and a `d5_overlay`
   render band on the `print` canvas; keep `d4` as the base, retire my placeholder d5 world row, decide
   with the owner whether 48 px/m gets 0.35 of D5 (their stop) or none (gameplay zoom = pure D4, the
   brief). Re-bless goldens with before/after frames. D1 as a live profile only if the owner wants it.
5. Accent audit: full rigs are split by kind now; split the atlas crowd too (per-variant instance colour
   or a second capture with cop variants masked); make it gating once the traffic light is redrawn.
6. Lights GPU cost on an idle GPU + the Deck; the night grade needs the owner's eye (frames 04b).
7. FX sheet landed on n-d4 (`features/fx/art/fx_atlas.png`, 8x4 cells of 256 px, README has the cell
   map: muzzle_1-3, tracer, impact_1-2, debris_1-2 / expl_1-8 / smoke_1-4, shock_1-4 / splat_1-4,
   spark_1-2, casing, flash_ring). After the merge: give fx.json rows `atlas_cells` [first, count] and a
   frame rate, switch fx_ink.gdshader to sample the atlas by INSTANCE_CUSTOM (cell, frame), keep the
   analytic shapes as the fallback. Their muzzle cores are vermilion: re-run the accent audit (fx layer
   allows vermilion) and check it stays rare.
- 22:13 evidence run (`node tools/evidence/run.mjs --no-bench`, commit 82d4036): lint PASS, unit 171 PASS,
  scenarios 8 PASS, parity PASS (bit-exact, mutation caught), selftest PASS (goldens 10/10 worst 0.00;
  accent 0.95 % / 0.95 % / 0.26 %, 1 off-doctrine world source = traffic_light.png). Copied to evidence/pof/.
  Ladder: gtai-masters/night/visual-engine/ladder.png (00 baseline .. 06 camera). Frames rejected tonight: 0
  (every capture is the straight-down engine camera); 1 approach reverted: the stipple light edges (04).
  AI assets generated: none (no codex image_gen this session), so no provenance lines.

## 2026-11-02 iteration 4 BUILD (22:12 -> 23:42)
- 22:13 machine at 19 % CPU: started the idle bench of HEAD (3 runs x 30 s) first (NEXT 1).
- Plug-in work while it runs (no Godot runs during the bench):
  - FX sheet as data: `fx.json` `atlas` (path, 8 x 4) + per-kind `atlas` blocks (cells, pick/anim,
    frame_ticks, overrides); `FxSystem.atlas_live` only when the texture exists; `fx_ink` samples
    the sheet by instance custom `.z` = cell + 1, alpha cut 0.5 + the fade dither. New kinds `casing`,
    `spark`. Tests: cell pick/anim/hold, a present sheet overrides the row, a missing one does not.
  - D5 overlay as data: `look_profiles.json` `overlays` (d5_world -> look_d5.gdshader + params
    `world`, base d4, auto ramps 48:0 -> 64:1, d5 pins 1), `core/render/look_overlay.gd`
    (BackBufferCopy + ColorRect on the new `print_overlay` band, hidden at amount 0), CityView feeds
    amount + world_px each frame. Live only when d5-close's files are in the tree. Goldens for an
    overlaid look are `-ov` files.
- MILESTONE bench idle HEAD (c761d7c, 22:13-22:21, CPU 19 % before): PASSES - p99 3.14 ms, 1% low 199 fps,
  worst swap 32 ms, 0 frames > 50 ms; riot rig p50 0 / p99 0.558 ms, 0.474 ms per tick. evidence/bench-*-idle.json.
  Caveat: fx.json was edited within a minute of the export (fx is not spawned in the bench; no effect expected).
  No A/B vs ad2078b done (the machine got contended again from 22:40, see below).
- MILESTONE FX sheet plug-in (267722f). Frames with n-d4's fx_atlas.png copied in for the capture only
  (`gtai-masters/.../plug.sh fx in|out`, never committed): 07-fx-atlas/ab2-{32,48,64}ppm.png (left placeholder,
  right sheet). Clearly better: real blast with a vermilion core, cloud smoke, shards, crackle, splat with a
  cream rim. First pass (`after/`) REJECTED in part: the linear dither fade turned splats/smoke into grey
  stipple and the casing drew 1.6 m long -> added `fade_from` + casing 0.5 m (`after2/`). 0 frames rejected for
  camera (engine camera, straight down). (Corrected 23:07: the smoke row of the sheet IS grey + hatched; it reads
  cream in the frame because smoke is lit and sits next to the blast light - correct behaviour, no art ask.)
- MILESTONE D5 overlay plug-in (94f6e44). With n-d5 157dec8's look_d5.gdshader + params copied in for the
  capture: same-tick mean diff vs the placeholder: auto 48 px/m 0.00 (pure D4 at gameplay zoom holds), 56: 6.56,
  64: 12.33. 08-d5-overlay/ab-auto-64ppm.png: the overlay gives the sparse street hatch, paper tooth and
  off-register ghosts of the mock; the placeholder d5 row was just darker grime. Kept. -ov goldens blessed with
  that copy (5 files); d1/d4 goldens byte-identical; without the files goldens 10/10 worst 0.00.
- Rig (151a079): selection every 4th call + native re-find. Interleaved headless A/B (riot 20 s, rig ms per
  tick): every=1 0.566 / 0.603 vs every=4 0.527 / 0.504 (-12 %). Target 0.3 ms still NOT met. Drive profile
  (headless debug, per CutRig.drive ~34 us): RigPose.step 18.6 us (55 %), RigGait.step 12.5 us (37 %), clips 0.9,
  facing 0.5, hose+view 1.6. That is where the next win is (characters owner): per-part transform writes in
  GDScript; candidates: a cheaper pose for rank >= FULL_RATE (no secondary motion), or the pose in native.
- FRICTION: the exported bench after the rig change (22:30-22:39) ran while other lanes started Godot (22:40
  processes seen, CPU 31 %): p99 5.04 ms, 1% low 73, one unexplained > 50 ms frame -> exit 1. Recorded as
  CONTENDED/INVALID (evidence/bench-*-select4-contended.json), neither a pass nor a regression.
- Camera (b9ebf33): CameraRig.listen(Events, clock): vehicle_entered -> car 48, vehicle_exited -> on_foot 32.
  Shared file boot/world.gd +1 line. Nothing emits these in the city yet.
- Accent audit (52d966c): the atlas crowd split per look at the source; HIT clip frame 0 is a full vermilion flash
  (danger cue) counted apart. 6/6 pedestrian looks 0 vermilion outside it; cops 24.7-29.3k texels.
  crop: 03-accents/iter4/ped-hit-cells.png. FRICTION: a parse error in a windowed selftest scene never quits
  (I killed my own PID 46452); run.mjs has a 180 s timeout so the evidence run would not hang forever.
- Evidence 22:51 at 9765862 (f4c53b1): lint 13/13, unit 182, scenarios 8, parity bit-exact + mutation caught,
  selftest: goldens 10/10 (worst 0.74), accent 0.95 / 0.95 / 0.25 %, crowd atlas 6/6 ped looks on doctrine,
  1 off-doctrine world source (traffic_light.png, 216 px at 32 px/m, unchanged).
- MILESTONE emissive FX (0b60126): the additive paper light lifted the sheet's vermilion blast core to peach
  (73-84 % of warm px in the vermilion gate) -> emissive kinds (muzzle, tracer, explosion, spark, crackle) draw on
  a new `emissive` canvas (layer 4) above the lights via an FxSystem glow twin; world_ui -> 5. 91-96 % in the gate.
  Frames 07-fx-atlas/ab3-{48,64}ppm.png. Ladder rows 07, 08, 09 added (ladder.png now 1280 x 4370).
- MILESTONE GPU costs, finally with numbers (interleaved blocks, median, 3 runs each, shared GPU 10-33 %):
  lights full budget (32 fires) +0.29 / +1.13 / +1.35 ms; D5 overlay at 64 px/m +0.90 / +1.15 / +1.51 ms
  (0 at 32/48). Both are fill-rate bound. evidence/light-cost/, evidence/overlay-cost/.
- Frames rejected tonight (iteration 4): 0 for camera (all engine captures straight down); 1 approach
  partly rejected and redone: the linear fx fade (grey stipple) -> fade_from. No AI images generated (no codex
  image_gen this session), so no provenance lines.

NEXT (iteration 5 / morning, in order):
1. After the Director merges n-d4 and n-d5: the FX sheet and look_d5 go live with no code change. Then
   (a) run look_golden: the -ov goldens were blessed with n-d5 157dec8 - if look_d5 changed after that, re-bless
   the 5 -ov files only and look at them; (b) run fx_showcase + accent_audit; (c) delete my placeholder `d5`
   profile row only if the owner agrees the overlay replaces it (it is unused once the overlay is live).
2. Owner call: amount at 48 px/m = 0 (shipped, the brief) or 0.35 (d5-close's stop). One number in
   look_profiles.json `overlays[0].amount_ppm`.
3. D5 overlay GPU (+0.9-1.5 ms at 64 px/m on a 4090): ask d5-close for a cheaper look_d5 (fewer vnoise taps)
   or render it at half resolution in a SubViewport; measure on the Deck.
4. Rig p99 still above 0.3 ms: RigPose.step 55 % + RigGait.step 37 % of CutRig.drive (~34 us each). Candidates
   for the characters owner: a cheaper pose for ranks >= FULL_RATE (no secondary motion), quarter rate for
   ranks >= 10, or the pose in native. Selection decimation (151a079) gave -12 %.
5. Gameplay wiring still BLOCKED on positional events (shot_fired / bullet_hit / exploded with a world pos)
   in events.json (shared file, owner OK). With them: FxSystem.spawn + CameraRig.kick + LightLayer.add.
   The camera already follows vehicle_entered / vehicle_exited.
6. d4-production ask: traffic_light.png lamps (vermilion in the world). (The smoke row is fine: see the 23:07
   correction.)
7. Lights on the Deck: cap fires at 8-16 or a smaller radius if the Deck shows the same fill cost.
- MILESTONE final bench 23:00-23:04 (fd1703f, CPU 7 % / GPU 10 % before): PASSES - p99 3.78 ms, 1% low 155 fps,
  worst swap 32 ms, 0 frames > 50 ms (49 > 25 ms, all vsync/present). Riot rig 0.457 ms per tick, p99 0.501
  (idle HEAD run: 0.474 / 0.511): in the release build the selection decimation is only -2..-4 %; the 0.3 ms
  target is NOT met. evidence/bench-*-final.json, evidence/bench-final-iter4.txt.
- Evidence 23:06 at 05531f3: lint 13/13, unit 183, scenarios 8, parity PASS, selftest PASS (goldens 10/10 worst 0.74; crowd 6/6 on doctrine). Copied to evidence/pof/.
- 23:08 real boot path smoke (windowed, --quit-after 600): --look=auto / d5 / off all exit 0, 0 script errors (World + CityView with the emissive canvas, overlay hook and camera events). Scratch cleaned (Temp probe dirs, masters bless/check dirs); no plugged n-d4 / n-d5 files left in the tree. Session end.

## 2026-11-02 iteration 6 BUILD (23:08 -> 00:38)
- Read JOURNAL, git log, events.json. main gained 11 commits (quest 1); n-d4 / n-d5 still unmerged here.
  F-04 still has no positional shot/hit events, BUT CitySim already has projectiles (the riot shoots):
  the snapshot the rigs take every tick frame carries [1000 + slot, x, y] projectile records.
- MILESTONE FX wired to the riot (65762d3), no events.json change: `data/tables/fx_triggers.json`
  (gtai.fx-triggers/1: cue -> fx kinds + shake + shake_near_m), `core/render/fx_triggers.gd`
  (fire(), listen(Events) for player_hit -> sparks + `hit` shake), `features/city/view/city_fx_feed.gd`
  (snapshot diff: new projectile = shot -> muzzle + casing + muzzle light + gunfire shake within 6 m;
  vanished = projectile_end -> impact chips; person turned M_DEAD = death -> ink splat). Selftest
  junction: 11 shots / 9 ends / 9 deaths / 0 dropped. Tests test_fx_triggers 5/5.
- Frames 10-fx-feed/: before (feed off) vs after. REJECTED my first placement: the splat on the `fx`
  band drew OVER the dead bodies' torsos (crops-48ppm.png). Fix: fx.json `ground` flag -> a ground twin
  FxSystem on the world canvas's ground_decals band (printed by look_d4 like a decal, under bodies,
  shadows, roofs): crops2-48ppm.png - the ink spreads from under the body. Subtle on charcoal (black
  ink blood on a dark street, as the doctrine wants); it will read strongly on cream pavement. 0 frames
  rejected for camera (engine captures, straight down).
- BUG found and fixed (characters glue, my earlier file): CityCharacters._fill_feed stepped the
  snapshot by 14 floats into the projectile records (3 floats each) and could read misaligned junk as
  a person (a phantom rig) whenever qx < 1000 and int(qy) in {0, 2}. It now breaks at the first one.
- Gates 23:17: lint 13/13, unit 190/190, scenarios 8/8.
- FRICTION: `export GODOT_BIN` does not persist across Bash calls; run_unit.mjs without it printed the
  stale "189 passed" from the last junit file with exit -1 - read the exit codes, not just the count.
- Exported bench with the feed (65762d3 build, 23:18-23:30, CPU 5 % before, but the n-noir / n-d5
  lanes rendered on the same GPU from 23:13 / 23:41): PASSES section 20 - p99 4.63 ms, 1% low 140 fps,
  worst swap 25.7 ms, 2 frames > 50 ms (1 `present`, 0 unexplained); riot rig 0.455 ms per tick
  (unchanged vs 0.457). Note the bench ran 3 x 4 x 60 s (tool default) where iteration 4 used 30 s.
  evidence/bench-*-fxfeed.json, bench-fxfeed.txt.
- MILESTONE FX cost found and cut (9f8c83e): riot avg frame 0.67 -> 1.07 ms with the feed. Interleaved A/B
  (debug binary windowed, 3 pairs x 20 s, new `city_bench -- --fx-feed=off`): +0.35 ms per frame, 3/3.
  Cause: FxPool rewrote every live particle (3 RS calls + dict lookups each) on EVERY frame, tick or not
  (splats live 240 ticks x 5). Fix: no tick and no spawn = keep the MultiMesh. Re-A/B: +0.07 ms (median
  0.696 / 0.764), p99 CPU +0.15 ms. evidence/fxfeed-ab, fxfeed-ab2. All 3 `on` runs of the 2nd A/B had a
  ~32 ms worst frame (0/3 off): `present` stalls with pipelines 0, with 2 other lanes on the GPU; the
  1st A/B had them in `off` runs too. Not attributed, not claimed clean.
- MILESTONE world-UI markers (0eb053f + rim fix): `world_markers.json` (gtai.world-markers/1),
  `core/render/world_markers.gd` + `marker_shapes.gd`, CityView.markers on a world_ui canvas (band now live).
  Objective = vermilion diamond, pickup = vermilion ring, soul = teal ring, constant screen size,
  ink + paper sticker rim, tick bob; the objective pointer pins inside the screen edge. A kind whose
  accent is not allowed for its `use` does not load (doctrine at load). test_world_markers 3/3.
  Frames 11-markers-night/: day + night grade at the first muzzle moment (`--fx-moment --markers
  --grade=night`). REJECTED in part: the 22 px pointer lost against the riot's vermilion cops and its
  scaled-polygon rim sat lopsided -> 34 px + outlined rim (pointer-abc.png: left/middle rejected, right
  kept). OWNER CALL: with ~30 vermilion cops on screen a vermilion objective competes; the doctrine gives
  objectives and cops the same ink - consider a shape language (the diamond + pointer only for
  objectives) or a paper objective with a vermilion core.
- MILESTONE prewarm (29cb86f): the loading-screen prewarm now draws one particle of every FX kind on
  all three FX canvases + one light, then FxSystem.clear() - fx_ink / light_ink were first bound on the
  riot's first shot. Prewarm 30.5 ms (31.0 before), same cues, no leftover (12-prewarm/centre-32.png).
- FRICTION x2: (1) a new class_name is not in the global class cache until an `--import`; a windowed
  bench that fails to parse never quits - my first A/B loop timed out 3 x 150 s (killed my own PIDs
  37276 / 46192 only). (2) A Variant `.duplicate()` and a discarded `append()` are parse errors (warnings
  as errors) that gdlint does not see: run run_unit.mjs (load_all) after every GDScript change.
  (3) I copied stale build/selftest/*.json over evidence/pof and restored them from git at once; the
  fresh ones are in build/evidence/.
- Evidence at 29cb86f (8282183): lint 13/13, unit 195, scenarios 8, parity bit-exact + mutation caught,
  selftest PASS (goldens 10/10 worst 0.85; accent 0.95 / 0.95 / 0.25 %; crowd 6/6 on doctrine; 1 off-
  doctrine world source = traffic_light.png 216 px, unchanged, still not redrawn on n-d4).
- Boot path smoke (windowed, --quit-after 600): --look=auto / d5 / off exit 0, 0 script errors.
- Ladder: rows 10 (fx feed, off | on) and 11 (markers, day | night) added (ladder.png 1280 x 5226).
  Frames rejected for camera: 0 (all engine captures, straight down). Approaches rejected: 2 (splat on
  the fx band over the bodies; the 22 px / lopsided pointer). No AI images generated (no codex), so no
  provenance lines.

NEXT (iteration 7 / morning, in order):
1. After the Director merges n-d4 / n-d5: FX sheet and look_d5 go live with no code change. Re-bless only
   the 5 `-ov` look goldens (blessed with n-d5 157dec8; n-d5 has since changed look_d5: f871411 aged
   paper, 5645ece shadow) and look at them; run fx_showcase + accent_audit (the sheet's muzzle cores are
   vermilion, the fx band allows it).
2. Owner calls: overlay amount at 48 px/m (0 shipped vs 0.35); objective vs cop vermilion (above); the
   night grade (#6E6878) and its look with real muzzle lights (11-markers-night/night/).
3. Rig p99 still above 0.3 ms (0.455 ms per tick release): RigPose.step 55 % + RigGait.step 37 % of
   CutRig.drive. Arithmetic: 6 full + 10 half = 11 drives per tick; the target needs about 7 (e.g. 4 full +
   12 quarter rate) or a native pose. Characters owner + a motion strip to judge 15 Hz rigs at 14 m.
4. FX per-tick cost: FxPool still does 3 RS calls per particle per tick; one multimesh_set_buffer per
   twin (like CitySimRender) would cut the remaining +0.15 ms p99. LightLayer.step rewrites every frame
   too (<= 32 lights, cheap) - same skip if it ever shows.
5. Explosions / crackle / smoke still have no source (no grenades, no melee in CitySim): fire them via
   FxTriggers.fire from whatever system lands them, or a `sim` cue if CitySim grows them.
6. traffic_light.png lamps (d4-production) - the one off-doctrine world source; then make the accent
   audit gating.
7. Quest 1 on main has objectives: after the merge, point its objective at CityView.markers (objective =
   the handle) - the markers API is ready.
- 00:00 Tried NEXT 4 (FX as one multimesh_set_buffer per pool): REVERTED. fx_showcase (bit-identical run to
  run: before vs before2 diff None) changed with it (probably my 2D transform row layout, or the unhidden
  ground twin) and the step got slower in its one sample (136 -> 192 us for 147 particles): 16 GDScript
  indexed writes per particle cost about what 3 native RS calls do. Frames 13-fx-buffer/. The p99 lever for
  FX is native (or fewer live particles: splats 5 x 240 ticks), not a GDScript buffer. README per-pass table
  updated with the feed A/B and this.
- 00:05 LightLayer gets the FX no-tick skip (rewrite only when the tick moved or a light was added / moved /
  removed). light_showcase before/after pixel-identical 12/12 (14-light-skip/). Gain unmeasured (the
  showcase is all tick frames). Unit 196, lint 13/13. Evidence at 29cb86f is two commits behind this
  (render-only skip + docs); the next evidence run should be at HEAD.
- 00:12 evidence at ad0223e (HEAD code): lint 13/13, unit 196, scenarios 8, parity PASS, selftest PASS. Copied to evidence/pof.
- Session end: tree clean, no processes of mine running, /tmp scratch deleted; masters frames kept as evidence.

## 2026-11-03 iteration 8 BUILD (00:03 -> )
- Read JOURNAL, git log. n-d4 / n-d5 still unmerged here; main unchanged since iteration 7. All 7 brief
  items evidenced; weakest number = rig p99 (0.455 ms per tick release vs 0.3 target). Working that.
- FINDING: a plain quarter-rate pose (drive(4 * TICK_DT) every 4th tick) is UNSTABLE: the facing spring
  (k 260, semi-implicit Euler) has an eigenvalue of magnitude > 1 at h = 1/15 s (det = 1 - 2 sqrt(k) h =
  -1.15). Measured: face_w 2765, facing off by 2.2 rad after 30 steps. Half rate (h = 1/30) is stable.
- MILESTONE quarter-rate rig LOD (8d79b38): ranks 0-3 full, 4-7 half, 8-15 quarter (drives per tick
  11 -> 8). The 3 springs (facing, shove, twist) moved to `features/characters/rig_springs.gd` and
  sub-step any step longer than 2 ticks; full and half rate are bit-identical to before (same Euler
  step). test_rig_rates 3/3: tiers; quarter-rate turn settles (and FAILS with sub-stepping off - the
  test catches the blow-up); quarter vs a full-rate twin over 240 ticks with a 1.2 rad turn: facing
  lag <= 0.111 rad, planted feet <= 6.1 px (0.19 m).
  Rig bench headless DEBUG, 3 interleaved pairs (consts flipped 6/16 <-> 4/8): avg 0.386/0.386/0.395
  -> 0.312/0.303/0.298 ms (50 people), p99 0.64/0.57/0.65 -> 0.57/0.44/0.40; 200 people avg 0.39-0.40
  -> 0.32, p99 0.55-0.71 -> 0.45-0.53. -21 % avg (expected -27 % from drives; selection is fixed cost).
  evidence/rig-quarter/rig-bench-{old,new}-{1,2,3}.json.
- Frames 15-rig-quarter/ (masters): `rig_showcase -- --motion` (new rig_motion_run.gd): Rivet + 15
  walking peds ranked by distance, 24 consecutive ticks at 32 and 48 px/m, old (6 full / 10 half) and
  new. outer-*ppm-old-left-new-right.png = the quarter-rate band, 8 consecutive ticks: no broken or
  popping poses, feet and arms read the same as the half-rate ones. Stills cannot judge 15 Hz judder:
  motion-*ppm-old-top-new-bottom.gif (20 fps playback, 3x slow) is for the owner's eye. 0 frames
  rejected for camera (engine captures). The 1 m ped spacing overlaps bodies - good enough to judge
  poses, not pretty.
- MILESTONE exported release bench at 8d79b38 (00:2x, CPU 12 % before, 2 other Godot processes on the
  machine - other lanes): PASSES section 20 - p99 2.55 ms, 1% low 214 fps, worst swap 6.7 ms, 2 frames
  > 50 ms (both `present`, 0 unexplained). Riot rig 0.338 ms per tick (iteration 4: 0.457, iteration 6:
  0.455) = -26 %; rig p99 per frame 0.387 ms (was 0.501). The 0.3 ms TARGET IS STILL NOT MET (about one
  drive per tick short: ~34 us per drive). evidence/bench-*-quarter.json, bench-quarter.txt.
- MILESTONE objective option as data (owner call from iteration 6): world_markers.json kinds take an
  optional `fill_token` (the body's ink) and `core` (a core of the token's ink at core x size); both
  inks pass the doctrine check at load (`WorldMarkers.on_doctrine`, unit test). Shipped default
  UNCHANGED (solid vermilion diamond). Frames 16-objective-core/ (city_selftest --markers --fx-moment,
  which now also puts an objective on screen): crops-before-left-after-right.png, 32 (top) and 48 px/m.
  My read: the paper diamond + vermilion core reads as UI beside the riot's vermilion cop bodies; the
  solid diamond reads as one more vermilion blob. Less vermilion area, so less pop on charcoal; not yet
  seen on cream pavement. OWNER CALL: to ship it, set `"fill_token": "paper", "core": 0.5` on the
  objective row (one line). 0 frames rejected.
- Tried: skip the arm z_index sets when unchanged. Rig bench A/B 3 pairs: within noise both ways
  (avg 0.302/0.303/0.293 old vs 0.297/0.292/0.303 new at 50 people) -> REVERTED, not committed.
- Probe (throwaway, deleted): one cop drive = 28.1 us (debug, headless): RigGait 10.7, RigPose 14.9
  (RigArm.solve x2 = 12.0, i.e. 6 us per arm). A Sprite2D.transform set costs 0.19 us and a
  global_transform read + global_position write 0.31 us: the engine calls are NOT the cost, the GDScript
  arithmetic is (Vector3 IK, lerps, the end-on cell checks). For the characters owner: the remaining
  ~0.04 ms to the 0.3 ms target is a native RigArm/RigGait (or ~1 fewer drive per tick, e.g. 3 full
  ranks), not GDScript micro-tuning.
- Evidence at 3aa7005 (203239d): lint 13/13, unit 200, scenarios 8, parity PASS, selftest PASS (goldens
  10/10 worst 1.10 - was 0.85: the quarter-rate rigs pose differently, within the threshold; accent
  0.95 / 0.95 / 0.25 %; 1 off-doctrine world source = traffic_light.png 216 px, unchanged).
- MILESTONE cop accent option: `BodyPlan.torso_swap` (print_part `swap` on the torso; -1 = none, the
  default for every plan, so nothing changes). Frames 17-cop-accent/ with HumanPlan.cop() torso_swap = 2
  (vermilion -> cream) for the capture only: the cop becomes a cream sticker body with the vermilion
  cap / helmet (head_swap 4), as in the d4h2 mock. Accent audit: frame vermilion 0.95 % -> 0.56 % at 32
  and 48 px/m, 0.25 -> 0.18 % at 64; crowd atlas patrol 29276 -> 20344 px, riot 24744 -> 15484
  (evidence/accent-audit-cop-cream.json). My read: closer to the mock and to "accents rarely", and it
  leaves the objective diamond as the only vermilion SHAPE; but cops lose salience as threats at 32
  px/m (a red dot instead of a red body). OWNER CALL (with the objective call above, they are one
  decision): to ship it, add `p.torso_swap = 2` to HumanPlan.cop(). Not shipped. 0 frames rejected.
- MILESTONE accent audit GATES the selftest (7222102 + fix): `data/tables/accent_debt.json`
  (gtai.accent-debt/1, schema) lists known debt as accent + layer + ppm <= max_px with source and owner
  (one row: traffic_light_lamps <= 240 px at 32 px/m, d4-production). tools/selftest/run.mjs
  `judgeAccents`: an unlisted offender, one above max_px, or an off-doctrine crowd look fails the
  selftest; a row no longer seen is reported for deletion. Checked: real run PASS ("known debt: 216 px");
  planted max_px 100 -> ok=false "NEW off-doctrine: 32 px/m vermilion on world: 216 px"; node cases for
  other ppm / teal / crowd looks all fresh. (First planted run printed the row as "no longer seen" too:
  fixed - only rows with no offender at their key are reported.)
- MILESTONE no quarter tier at arena zoom: `CharacterRigs.ARENA_ZOOM` 1.9 - at 64 px/m ranks past
  HALF_RATE pose at half rate (the rigs are 2x the size and nearly all on screen; arenas hold few
  people). rate_of(r, zoom), unit-tested. Frames 18-rig-arena/ (rig_showcase -- --motion, now 32 / 48 /
  64 px/m): 32 and 48 px/m pixel-identical before/after (0 px changed), 64 px/m changed (754k px over
  24 ticks): outer-64-before-left-after-right.png shows the outer peds holding a pose for 4 ticks
  before vs 2 after; motion-64ppm-before-top-after-bottom.gif for the owner. Bench unaffected (riot and
  drives run at 32 / 48 px/m). 0 frames rejected.
