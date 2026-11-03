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
- BUG FOUND + FIXED (the brief's "make sure world_px is fed every frame", now tested): look_d4's paper
  tooth was `hash(floor(FRAGCOORD.xy))` - screen-locked, so a 5 % per-pixel speckle sat still on the
  screen while the world slid under it (a screen-door on cream ground, roofs, crosswalks when the camera
  pans). Now `hash(floor(w) + offset)` with w = FRAGCOORD + world_px (offset so it does not correlate
  with the grit hash). NEW `dev/selftest/world_lock.gd` (+ tscn): the paused junction, actors canvas
  hidden, panned by 1.25 x 0.75 m (whole px at every zoom); B must equal A shifted. World-only share of
  differing pixels (RGB sum > 24): before 0.60 / 0.23 / 0.52 % (32 / 48 / 64 px/m), after 0.00 / 0.00 /
  0.11 %; planted (`--plant-unlocked`: world_px held, view disabled) 25 / 18 / 33 % -> the check bites.
  (My first plant did nothing: CityView rewrites world_px every frame - fixed by disabling the view.)
  Gating in the selftest evidence (tools/selftest/run.mjs runWorldLock, max 0.5 %). Look goldens still
  10/10, worst 1.64 (was 1.10): the tooth moved; NOT re-blessed. Frames + masks 19-world-lock/.
  OPEN: look_d4_item and print_part (actors, cars) hash FRAGCOORD for their tooth too (0.6 % of the
  frame differs after a pan with the actors shown, all on actors / cars); needs an object- or
  world-locked coordinate in those shaders.
- MILESTONE the item + part prints world-locked too: look_d4_item (traffic, atlas crowd, ghosts) and
  print_part (full rigs: tooth, shadow dots) take `world_px` (CityView sets the item material;
  `PartMaterials.set_world_px` from CityCharacters._before_render every frame, before the no-tick skip:
  the camera moves between ticks; CityView.world_px is now a member). world_lock with the actors shown
  (paused, so they hold still): before 0.20 / 0.41 / 0.57 % (32 / 48 / 64), item only 0.16 / 0.35 / 0.59,
  item + part 0.00 / 0.00 / 0.04 %. The check now judges the whole frame by default (`--world-only`
  keeps the world-pass view); planted 43 / 37 / 45 %. city_view.gd is 202 lines (soft 200).
- Evidence at aa4fa2a: lint 13/13, unit 200, scenarios 8, parity PASS, selftest PASS incl. the new gates
  (accent: no new offenders, known debt 216 px; world lock 0.00 / 0.00 / 0.03 %); goldens 10/10 but worst
  1.88 of 4 (drift: the tooth moved, the rig LOD, the FX feed's muzzle lights since 58e6416).
- RE-BLESSED the 10 non-overlay look goldens (the 5 `-ov` ones untouched: they need n-d5's look_d5).
  Old -> new mean diffs 0.86 .. 1.88. Looked at them (20-golden-rebless/d4-old-left-new-right.png,
  crop-64-light.png): same junction, rig poses differ, and the one new shape at 64 px/m is a muzzle
  light cone (hatched paper) + muzzle star from the FX feed - expected. 0 rejected.
- The last screen-locked noise: fx_ink's fade dither (`hash(FRAGCOORD / 2)`) - a fading ink splat (240
  ticks on the ground twin) or smoke dissolved through a screen-fixed pattern while the camera panned.
  FxSystem.step(tick, world_px) sets it on all three twins (CityView passes its world_px). world_lock
  full frame at 64 px/m: 0.03 % -> 0.00 % (32 / 48 already 0.00). Goldens 10/10, worst 0.05 (the
  dither moved under the junction's muzzle stars), not re-blessed. Every print shader in the game now
  hashes world coordinates: look_d4, look_d4_item, print_part, fx_ink, light_ink.
- MILESTONE final release bench at b8ecb19 (00:47-00:54, CPU 10 % before): PASSES section 20 - p99 3.14 ms,
  1% low 208 fps, worst swap 32 ms, 0 frames > 50 ms (45 > 25 ms, all present / vsync). Riot rig 0.334 ms
  per tick (last run p99 0.377 ms per frame; the summary's 0.483 is the worst of the 3 runs). Target 0.3
  still not met. evidence/bench-*-iter8.json, bench-iter8.txt.
- Ladder rows 15-19 added (ladder.png 1280 x 7366). Frames rejected for camera: 0 (all engine captures,
  straight down). Approaches rejected: 1 (the arm z_index guard: no measurable gain). No AI images (no
  codex), so no provenance lines.

NEXT (iteration 9 / morning, in order):
1. Owner calls, now with frames: (a) objective = solid vermilion (shipped) or paper + vermilion core
   (16-objective-core, one data line); (b) cop = vermilion body (shipped) or cream body + vermilion cap
   (17-cop-accent, `p.torso_swap = 2` in HumanPlan.cop(); accent 0.95 -> 0.56 %). They are one decision:
   with cream cops the vermilion objective needs no core. (c) 15 Hz limbs on ranks 8-15 at 32 / 48 px/m:
   watch 15-rig-quarter/motion-*-old-top-new-bottom.gif (stills cannot judge judder).
2. Rig 0.334 ms per tick vs 0.3: a native RigArm + RigGait (drive = 28 us debug, all GDScript math;
   engine calls ~0.2 us) or 3 full ranks. Characters owner.
3. After the n-d4 / n-d5 merge: look_d5 + FX sheet go live; re-bless the 5 `-ov` goldens and look; the
   accent gate will then judge the new art (traffic_light_lamps debt row: delete it when n-d4 redraws the
   lamps - the gate reports a debt row it no longer sees). Check the world lock still holds with
   look_d5 (its vnoise must hash `FRAGCOORD + world_px`, never FRAGCOORD alone: world_lock.gd catches it).
4. Gameplay FX wiring still waits on positional events (explosions, melee crackle); smoke has no source.
5. D5 overlay GPU at 64 px/m (+0.9-1.5 ms): half-res SubViewport once look_d5 is merged.
- Evidence at 4738565 (HEAD code): lint 13/13, unit 200, scenarios 8, parity PASS, selftest PASS (goldens 10/10 worst 0.05, accent gate: no new offenders, world lock 0.00 % at 32 / 48 / 64). Copied to evidence/pof.
- test_shader_world_lock (unit, 201 now): every .gdshader under assets/shaders and features that reads
  FRAGCOORD reads it only as `FRAGCOORD.xy + world_px` and declares world_px (comments ignored). Planted
  the old fx_ink dither line -> fails "fx_ink.gdshader: FRAGCOORD without + world_px". When n-d5's
  look_d5 merges, this test judges it before any frame is rendered.
- Evidence at dfa61d9 (HEAD): lint 13/13, unit 201, scenarios 8, parity PASS, selftest PASS (goldens 10/10, accent gate clean apart from the listed debt, world lock 0.00 % x3). Copied to evidence/pof. Session end ~01:03: tree clean, no processes of mine running, /tmp + Temp scratch deleted; masters frames 15-20 kept as evidence.

## 2026-11-03 iteration 9 BUILD (00:59 -> )
- Read JOURNAL, git log. All 7 brief items evidenced. n-d4 / n-d5 / n-noir still unmerged here.
  Started this session with a pre-merge check for the Director (the morning merge is the next risk).
- `git merge-tree` n-visual vs n-d4 / n-d5 / n-noir: only JOURNAL.md (add/add, every lane has one)
  plus 2 real conflicts with n-noir (part_materials.gd: my world_px var + set_world_px vs its noir var +
  set_noir at the same spots; city_view.gd: my pass feeds vs its `noir.update` after the
  `_look_mat` world_px line). FIXED on my side (a66ad1b, no behaviour change): moved my lines off
  those insertion points -> n-noir now auto-merges too. Only JOURNAL.md conflicts are left.
- MILESTONE trial merge (scratch worktree `gtai-wt/scratch-visual-trial`, detached at a66ad1b, merged
  n-d4 + n-d5 + n-noir with JOURNAL = ours; the scratch commits are in no branch; deleted after use).
  n-noir carries main's 11 quest-1 commits, so this is effectively main + all 4 lanes:
  lint 13/13 (282 files), unit 244/244, scenarios 8/8, selftest: render OK (0 placeholders, 65 textures,
  fx cues 11 / 9 / 9), accent gate PASS (no new offenders; frame vermilion 0.93 / 0.95 / 0.27 %;
  `traffic_light_lamps` debt row reported "no longer seen" = n-d4's redrawn lamps are on doctrine),
  world lock 0.00 / 0.00 / 0.00 % (look_d5 and look_noir both hash FRAGCOORD + world_px; the unit
  world-lock test passes on them). FAILS only: look goldens 0/10, means 5.1 .. 14.9 = n-d4's new art
  (cream slab pavement + curved kerbs, car sprites, lane arrows, aggregate asphalt) and n-d5's current
  look_d5 (warmer aged paper at 64 px/m). Looked at them side by side: same junction, same actors, the
  differences are the new art (21-trial-merge/goldens-branch-left-trial-right.png; my first composite
  pasted the corner of the 1280 px frame next to the 320 px golden - redone at equal size).
  Re-blessed in the scratch and re-checked: 10/10 at mean 0.000 -> the merged build is deterministic.
- POST-MERGE RECIPE for the Director (after merging n-d4, n-d5, n-noir into main or a merge branch):
  1. JOURNAL.md: keep each lane's journal (they are per-lane files at the same path - e.g. move them to
     docs/journals/<lane>.md or keep one side); no code conflicts.
  2. `godot --fixed-fps 60 --path project res://dev/selftest/look_golden.tscn -- --out=<abs dir> --bless`
     (windowed, d3d12), look at the 10 frames, commit the 10 PNGs (tests/golden/look, LFS).
  3. Delete the `traffic_light_lamps` row from data/tables/accent_debt.json (the gate reports it).
  4. `node tools/evidence/run.mjs` -> expect lint, unit 244, scenarios 8, parity, selftest all PASS.
- MILESTONE low-end GPU numbers, first time for my passes: `dev/selftest/pass_cost.gd` (new): the riot
  junction at 48 px/m, interleaved 30-frame blocks that switch ONE pass off vs `full`, median of 8
  rounds; `--gpu-index 1` = the 7800X3D's AMD Radeon iGPU (2 CU: weaker than a Steam Deck, so a
  pessimistic Deck proxy; idle - the other lanes render on the 4090), `--resolution 1280x800` = Deck.
  iGPU 1280x800 BEFORE: frame 5.99 ms GPU = D4 world print 2.95 + actors 2.08 + lights 0.26 + FX ~0.
  1920x1080: 11.15 ms, print 5.31. The 4090: 0.86 ms (print 0.39) - but my 4090 after-runs read 2.61 ms
  for a bit-identical shader = other lanes on that GPU: 4090 GPU numbers tonight are NOT trustworthy.
- MILESTONE look_d4 early-outs (1871a36): every value-noise term whose mask is exactly 0 sits behind an
  `if` on that mask (deep hatch d > hatch_on, cross-hatch d > 0.93, edge wobble e > edge_lo, vermilion
  jitter vden > 0.20) -> a typical pixel runs 2 vnoise instead of 9. BIT-IDENTICAL: look_golden with the
  old and the new shader, 10 frames x 1280x800, 0 px differ. iGPU 1280x800, 3 interleaved pairs: frame
  6.06 / 6.06 / 6.12 -> 4.94 / 4.66 / 4.92 ms (-1.2 ms, -20 %), print pass 2.86 / 2.92 / 2.76 ->
  1.76 / 1.58 / 1.21 ms (-45 %). 1080p (1 run): print 5.31 -> 3.76 ms. evidence/pass-cost/.
  No visual change, so no ladder row; before/after frames kept (22-pass-cost/frames).
- D5 overlay on the iGPU (trial-merge scratch, n-d5's look_d5 at f6b9018), 64 px/m 1280x800: +2.47 /
  +2.52 / +2.57 ms (frame 5.9 -> 8.4 ms). The same early-out rule applied to look_d5 (scratch only, NOT
  committed - n-d5's file): 0 px differ in all 10 look frames incl. the 5 overlay ones; overlay +2.12 /
  +2.02 ms (-0.45, -18 %). Patch: evidence/pass-cost/look_d5-early-outs.patch (for n-d5 / the Director:
  apply after the merge, then re-run look_golden - it must stay at mean 0). What is left of the overlay
  is the full-viewport BackBufferCopy + the always-on paper tooth (2 vnoise) + street strokes over most
  of a 64 px/m frame.
- Actors split (pass_cost `no_rigs` / `no_peds` / `no_cars`), iGPU 1280x800, 2 runs: actors 2.11 ms =
  atlas crowd + its shadows 1.60 / 1.61, full rigs 0.52 / 0.59, moving cars 0.04.
- REJECTED (reverted, evidence/pass-cost/crowd-trim-rejected): shrinking the crowd quads to the figures
  (the 2.67 m cells are mostly empty: median figure half-extent 43 of 64 px). Per-column trim, then
  per-cell: crowd 1.60 / 1.62 -> 1.58 / 1.65 / 1.64 ms = no gain, and the frames moved by up to 4/255
  on up to 0.9 % of pixels (UV rounding). Not fill-bound; cause of the 1.6 ms still unknown (candidates:
  the ped shadow layer, MultiMesh instance count CAP vs visible, texture cache on the 3200 x 1024
  atlas without mipmaps at 32 px/m). Next: split no_peds into figures vs shadows.
- FRICTION (again): a parse error in a windowed scene never quits - my first pass_cost runs hung to the
  300 s timeout (Array[Vector2] from a Dictionary = Variant -> warning as error); killed my own PIDs
  56680 / 32664 only. Run the scene once with output to a file before looping it.
- NOTE for the Director: `--look=off` (or any look whose `printed` flips) re-applies the item material
  to ALL crowd nodes in CityView.set_look_enabled, which would replace the crowd atlas material on the
  people layer after the bake (wrong cells). Not seen in play (the default look never flips); fix =
  skip the people node once CityCharacters.bake swapped it. Not done tonight.
- CORRECTION (01:54) - my own measurements above were partly wrong. While writing the note on
  set_look_enabled I fixed it (1c7e3aa: a look toggle replaced the baked crowd atlas material on the
  people layer; unit test planted -> 2 failing asserts). pass_cost toggles the print OFF and ON, so
  from its first `no_print` block every crowd person drew the WHOLE 3200 x 1024 atlas. With the fix,
  iGPU 1280x800 48 px/m (2 runs, evidence/pass-cost/split2-*): frame 3.23 / 3.30 ms = print 1.56 /
  1.61, full rigs 0.47 / 0.56, atlas crowd 0.09 / 0.15, crowd shadows ~0.03, lights 0.12 / 0.17, cars
  0.01 / 0.15, FX ~0. So: (1) the "atlas crowd 1.6 ms" was the bug, not the crowd; (2) the crowd-trim
  A/B was INVALID (its shader was not even bound after the first toggle) - still rejected, because the
  real crowd costs ~0.1 ms; (3) the frame totals I quoted for look_d4 (6.06 -> 4.9 ms) include ~1.5 ms
  of that artifact on both sides; the print-pass deltas (2.76-2.92 -> 1.21-1.76 ms) are like for like
  (same broken layer in both configs of a run) and the frames are bit-identical, so the shader change
  stands. Honest low-end headline: at Deck resolution on a 2-CU iGPU the D4 frame is ~3.3 ms of GPU,
  half of it the print pass. In play the bug needed a look whose `printed` flips (`--look=off`); the
  default look never flips, so shipped play was not affected.
- 01:58 re-checked against the lanes' newer heads (n-d4 dbb8c6f, n-d5 1f348e6, n-noir 9062ecf): still only
  JOURNAL.md conflicts; their shaders still hash FRAGCOORD + world_px; look_d5 unchanged since f6b9018, so
  evidence/pass-cost/look_d5-early-outs.patch applies cleanly (patch --dry-run).
- Ladder rows 21 (trial merge, D4 48 px/m: branch | merged) and 21b (64 px/m: branch D4 | merged auto with
  look_d5 at full amount; NOTE 21b's two halves are different ticks of the golden run - a look comparison,
  not the same moment). ladder.png 1280 x 8222. Frames rejected for camera: 0 (engine captures, straight
  down). Composites I made wrong and redid: 1 (golden vs full-res corner paste) + 1 mislabelled ladder row
  (cropped off and re-added). Approaches rejected: 1 (crowd quad trim). No AI images (no codex), so no
  provenance lines.
- Scratch worktree gtai-wt/scratch-visual-trial removed (its trial-merge commits were on no branch); my
  /tmp scratch deleted. Processes of mine killed tonight: 56680 / 32664 (the hung pass_cost parse error).

NEXT (iteration 10 / morning, in order):
1. Director merge: follow the POST-MERGE RECIPE above (JOURNAL.md only conflicts; re-bless the 10 look
   goldens and look at them; delete the traffic_light_lamps debt row; evidence run). Then apply
   evidence/pass-cost/look_d5-early-outs.patch (n-d5's file, bit-identical, -0.45 ms of the overlay's
   +2.5 ms on the iGPU) - look_golden must stay at mean 0.00 after it.
2. Moving traffic is still the steel placeholder quad (the lavender boxes in every frame; ladder 21).
   n-d4 shipped `features/city/art/vehicles/traffic_atlas.png` for exactly this quad: 2 x 4 cells of 512 x 256
   px = 6.4 x 3.2 m (CL x CW in native render.cpp), nose +x, cell = the spawn variant (custom.x, already
   written by fill_render). Design: CrowdLayers plugs it when the file exists (like FxSystem.atlas_live)
   and owns the per-layer materials (move the set_look_enabled loop into CrowdLayers.apply_print, which
   also brings city_view.gd back under 200 lines); look_d4_item gets `uniform ivec2 cells = ivec2(1, 1)` +
   a vertex() cell lookup, used by a SECOND item material for the cars only (car SHADOWS keep the body
   blob: they carry the variant in custom.x too, so they must not get the cell lookup); that material must
   receive the look's item uniforms on every look change and world_px every frame (as _item_mat does).
   Unprinted looks use crowd_atlas.gdshader (cols 2, rows 4). Then frames at 32 / 48 / 64 px/m: does the
   item print's nearest-ink snap keep n-d4's grime and glass, or flatten it? If it flattens, give the car
   material a softer snap (the steel wash only) - judge on frames. Damage / hijack states need a state in
   custom.y from the sim (characters / sim owner).
3. Low-end GPU (iGPU 1280x800, after 1c7e3aa): frame 3.3 ms, print 1.6, rigs 0.5. The print pass is
   still half: next candidates, each A/B'd with pass_cost + bit-identity checked by a full-res look_golden
   diff: drop the always-on 2 vnoise grime to one octave (NOT bit-identical: needs the owner's eye),
   sobel on 2 taps reused from the plate samples. The D5 overlay (+2.0 ms after the patch) is the bigger
   one at 64 px/m: its BackBufferCopy + paper tooth; measure on a real Deck before cutting more.
4. Owner calls still open (frames ready): objective solid vermilion vs paper + core (16-objective-core);
   cop vermilion body vs cream body + cap (17-cop-accent); 15 Hz outer rigs (15-rig-quarter gifs);
   overlay amount at 48 px/m (0 shipped vs n-d5's 0.35).
5. Rig 0.334 ms per tick vs 0.3: native RigArm / RigGait (characters owner).
6. The one unreproduced 9 s `game` stall in the trial-merge drive bench (evidence/trial-merge): re-run the
   full bench on the real merge; if it recurs, it is in streaming (stream+spawn 5.5 ms/tick in that run).
- MILESTONE (02:02, after NEXT was written - NEXT 2 is now DONE at 746c765) moving traffic plugs n-d4's
  traffic_atlas.png: look_d4_item `cells` (default 1 x 1 = unchanged) + a vertex() cell lookup;
  CrowdLayers._plug_traffic (live only when the PNG loads; an LFS pointer - which is what `git show`
  gave me first - keeps the placeholder: found and guarded) and CrowdLayers.apply_print (owns every crowd
  layer's material; replaces CityView's loop). Cars AND car shadows sample the variant's cell (the shadow
  quad was the full 6.4 x 3.2 m cell: a dark rectangular pad around the car in the first pass -
  REJECTED, frames after-*; fixed: shadows sample the atlas tinted ink = car-shaped, frames after2-*).
  Without the PNG (this branch): golden means identical, unit 202. With n-d4's PNG + .import copied in for
  the capture only (never committed; first copy also clobbered its .import to valid=false - restored from
  the n-d4 worktree): lavender boxes -> inked cream cars with hatched glass, accent gate clean (no new
  offenders, vermilion 0.92 / 0.96 / 0.24 %), world lock 0.00 % x3; the goldens move (5.15 worst) =
  re-bless after the merge (already step 2 of the recipe). Frames 23-traffic-atlas/
  (crops-before-after-after2.png: placeholder | pads | car shadows), ladder rows 23 / 23b (1280 x 9078).
  0 frames rejected for camera. Still open from NEXT 2: damage / hijack states need a sim state in
  custom.y; the cop rig drawn over a car at 32 px/m (rigs vs vehicles band) - check after the merge.
- Evidence at a4f61ad (HEAD code, 02:04): lint 13/13, unit 202, scenarios 8, parity PASS, selftest PASS
  (goldens 10/10 worst 0.05, accent gate clean apart from the listed debt, world lock 0.00 % x3). Copied
  to evidence/pof. No bench this session on the branch (the trial-merge bench is in evidence/trial-merge).
- REVERTED (02:07, 2a72129) the traffic atlas plug-in (746c765) - NEXT 2 is OPEN again. Found while
  checking the plugged frames up close (23-traffic-atlas/zoom-cop-car-32-v3/v4.png): (a) a thin steel
  streak (~110 x 4 px at 32 px/m, steel wash 157,147,154 + ink = the traffic layer through the car print)
  across two cops; not there with the placeholder; a variant -> cell map did NOT change it, so it is not
  the police variant; UNDIAGNOSED. (b) civilian traffic rolls art 0-7 (CitySpawner CAR_ART), and cell 4 of
  the atlas is the police cruiser (vermilion light bar) -> civilians would wear the cop's livery =
  a doctrine / readability bug; police cars spawn art 8, which is outside the 8 cells. The plug-in
  would have gone live by itself on the n-d4 merge, so nothing lands tonight. Unverified cell-map work
  discarded (never committed). Project code at HEAD == 1ed6d3e (git diff empty), whose evidence passed
  (01:56: lint, unit 202, scenarios 8, parity, selftest); unit 202 re-run after the revert. Ladder rows
  23 / 23b show the PLUGGED capture of the reverted change (labelled "capture only"): the look target,
  not the shipped state.
- NEXT 2 (replaces the one above): re-apply 746c765 (`git revert 2a72129`) on top of the merged tree,
  then (1) render-only variant -> cell map (civilian 0-7 -> never cell 4; police 8 -> 4): a uniform int
  array set from GDScript must have the declared length (pad to 16) - and SEE a cruiser on screen before
  calling it done (spawn one at the junction in the selftest); (2) find the streak: dump the car layer's
  instance transforms + custom.x for that frame (CitySim write_render buffer) and look for a quad with a
  tiny axis or an out-of-range cell; (3) frames 32 / 48 / 64 + accent gate + world lock, then re-bless.
- 02:09 corrected 1080p iGPU (after 1c7e3aa, 2 runs): frame 5.72 / 5.79 ms = print 3.07 / 3.18, rigs 0.54 /
  0.61, crowd 0.19 / 0.25, lights 0.26 / 0.34, FX 0.09 / 0.21. The print pass is ~55 % of the low-end frame
  at both resolutions: it stays NEXT 3's target. README per-pass table updated. Session end 02:10: tree
  clean, scratch worktree removed, my temp files deleted, no processes of mine running (the two Godot
  processes on the machine are the noir lane's movie capture).

## Iteration 10 (02:10 - , BUILD)

- MILESTONE (02:15, 7bfb6b9) NEXT 2's streak DIAGNOSED and the traffic plug-in RE-APPLIED. Root cause:
  n-d4 re-laid traffic_atlas.png out 3 x 3 (1536 x 768, cell = sim car art id: 0-7 civilian, 8 police)
  at 01:49 (59e1448); my 746c765 (02:02) hard-coded the old 2 x 4 grid, so every car sampled across cell
  borders: the "steel streak" was the next row's car sliver, the sliced taxi above it the same bug, and
  "civilians in the cruiser's livery" was cell 4 of a 2 x 4 read of a 3 x 3 image. Fix: the grid is read
  from the texture size (CrowdLayers.traffic_grid: whole 512 x 256 cells, >= 9 so cell 8 exists; else the
  steel quad + Log.warn) - a future re-layout cannot silently mis-address it again. No variant map needed:
  n-d4's cells ARE the art ids. The look-toggle unit test assumed the unplugged state (assert_null on the
  car material) and would have failed after the n-d4 merge: now branches on crowd.car_print. Unit 203.
  Evidence (capture only, atlas copied in via plug.sh traffic in/out, never committed):
  24-traffic-3x3/crops-2x4-vs-3x3-32ppm.png (same frame, same region: sliced taxi + streak -> whole
  cars); probe-police/ (CAR_ART forced to 8 in scratch, reverted - the black-and-white cruiser with the
  vermilion light bar, doctrine-correct, seen at 48 px/m); after/ = the 10 golden frames plugged. Accent
  gate clean (no new offenders; 0.95 / 0.96 / 0.25 %; known debt 216 px), world lock 0.00 % x3, goldens
  move (worst mean 3.23, 5 over far) = re-bless after the merge. Unplugged: goldens 10/10 (worst 0.05).
  64 px/m: n-d4's grime stipple and dark hatched glass survive the item print's snap (no softer snap
  needed). Ladder rows 24 / 24b / 24c (placeholder | plugged; 1280 x 10362). 0 frames rejected for
  camera (engine captures, straight down). Still open: damage / hijack states need a sim state in
  custom.y (n-d4 ships traffic_atlas_hijack.png + _d1/_d2 bodies).
- MILESTONE (02:30, 52bec98) print pass -17 % on the low-end GPU: the D4 grime (2 octaves = 8 sin hashes on
  EVERY pixel) samples a baked 128 x 128 value lattice (core/render/grime_lattice.gd, the same hash, L8,
  bilinear at i + smoothstep(f) + 0.5 = the same faded value noise, 1 fetch per octave). iGPU 1280x800
  48 px/m, 2 runs each (evidence/pass-cost/hash-ab): print 1.67 / 1.61 -> 1.39 / 1.33 ms, frame 3.21 /
  3.29 -> 3.08 / 3.01. Bounds measured first (scratch): grime + paper tooth 0.43 ms, Sobel 0.18 ms.
  Goldens 10/10 worst mean 0.09 (no re-bless), accent gate clean, world lock 0.00 % x3, unit 206.
  Not bit-identical (8-bit values, a 128-cell tile = 1.1-3.6k px period), so judged on frames:
  25-grime-lattice/{before,after} (all 10 golden frames) and amp8-{sin,lattice} (grime x8 in scratch so
  the pattern is visible: same blotch scale and shape, amp8-compare.png). Ladder 25 / 25b.
- REJECTED (reverted, never committed) an integer hash for every hash() in look_d4: print 1.67 -> 2.37 /
  2.40 ms (+0.75, 2 runs) - 32-bit integer multiplies are slow on the AMD iGPU; sin is cheaper there.
  Shader kept as 22-pass-cost/look_d4-inthash-rejected.gdshader.
- MILESTONE (02:31) the D5 overlay on the same lattice - a PATCH for n-d5 (its file), my side committed:
  LookOverlay hands every overlay material `grime_tex` (unused if the shader does not declare it). With
  n-d5's current look_d5 plugged in (plug.sh d5 in/out, capture only) + my early-outs patch (still
  applies on n-d5 HEAD b98bb9b), look_d5's vnoise() -> one lattice fetch: iGPU 1280x800 64 px/m,
  interleaved pairs, overlay +1.91 / +1.87 -> +1.25 / +1.39 ms (-0.57 ms, -30 %). Frames
  26-d5-lattice/{before-eo,after-lattice}: d5/auto overlay frames move (mean 3.2-3.5, 2.3-2.9 % of px
  > 24) because the stroke wobble / pressure patches are re-laid (negative lattice coords wrap the tile);
  same character up close (crop-d5-64-eo-vs-lattice.png), no tiling seen in the 64 px/m frame; the d4
  and d1 frames are untouched (mean 0.00). Patch: evidence/pass-cost/look_d5-early-outs-lattice.patch
  (early-outs + lattice in one, `git apply --check` OK on n-d5). Needs the owner's eye for the moved
  hatch patches; the -ov goldens are re-blessed after the merge anyway. Ladder 26.
- Evidence at 0d4175d (02:42, e79c19f): lint 13/13, unit 206, scenarios 8, parity PASS, selftest PASS
  (goldens 10/10 worst 0.09, accent gate clean apart from the listed debt, world lock 0.00 % x3). Copied
  to evidence/pof. Bench started 02:44.
- NOTE for the Director: n-d4's README offers `traffic_atlas_wiring*.patch` (lane masters) for the same
  quad. Do NOT apply it on top of 7bfb6b9 - this branch already wires the atlas (through the item print,
  grid from the texture size); applying both would double-wire CrowdLayers.
- Bench at e79c19f (02:44-02:56, release export, 3 runs x 4 scenarios, another lane's Godot running = contended):
  PASSES section 20 - p99 2.83 ms (iter 8: 3.14), 1% low 238 fps (208), worst swap 32.5 ms, worst frame
  49.6 ms, 0 frames > 50 ms; >25 ms 106 summed (iter 8: 45) - every hitch in the last run's lists has cause
  `present` (render GPU <= 2.6 ms, draw ~29 ms = waiting on the swap), none game / render / pipeline, so
  read as the shared display, not the lattice or the traffic plug (the plug is not live on this branch
  anyway). Riot rig 0.372 ms per tick (iter 8: 0.334; also contended). evidence/bench-*-iter10.json,
  bench-iter10.txt.
- REJECTED (02:58, reverted) the rest of look_d4's value noise on the lattice too (hatch wobble / gaps,
  edge jitter, vermilion edge). Why it looked worth it: a branch-mask capture (27-print-masks, scratch
  shader) shows the deep-shadow hatch runs on 27-38 % of the print (the hatched lots), edges 8-12 %,
  vermilion 6-7 %. Measured interleaved on the iGPU: print 1.44 / 1.41 ms vs grime-only 1.57 / 1.37
  (and 1.39 / 1.33 earlier) - inside the run-to-run noise, so no gain to pay a re-laid hatch for.
  Shader kept as 27-print-masks/look_d4-all-lattice-rejected.gdshader; jsons in evidence/pass-cost/hash-ab.
- test: the traffic cell (512 x 256 px) is pinned to the sim's car quad at 80 px/m (CitySimRender CAR_L /
  CAR_W); planted 512 x 240 -> 3 failing tests, restored. Unit 207.
- 03:03 the lattice at 1080p on the iGPU (2 runs): frame 5.29 / 5.40 ms (was 5.72 / 5.79), print 2.60 / 2.70
  (3.07 / 3.18, -15 %), rigs 0.56 / 0.67. README per-pass row updated. evidence/pass-cost/hash-ab/lattice-1080-*.
- Checked (03:05): the plugged D1 frame (unprinted crowd_atlas cell path) shows whole cars; the "cop rig over a
  car" from iteration 9 was the mis-addressed atlas slice - rigs draw at actors z 100 + part z (<= ~11), cars
  at vehicles z 200, so a rig is always under a car. Closed.
- Iteration 10 tally: frames rejected for camera 0 (all engine captures, straight down); approaches rejected
  2 (integer hash +0.75 ms; all-noise lattice no gain); scratch probes reverted 3 (police-forced CAR_ART,
  branch-mask shader, sobel / grime bounds). No AI images, so no provenance lines. My processes: only the
  Godot runs I started, all exited; /tmp scratch deleted.

NEXT (iteration 11 / morning, in order):
1. Director merge (POST-MERGE RECIPE above, still JOURNAL.md-only conflicts with n-d4 / n-d5 / n-noir at
   their 02:10 heads). After merging n-d4 the traffic atlas goes LIVE by itself (7bfb6b9): re-bless the 10
   look goldens and LOOK at them (cars should be whole inked cars, the cruiser black-and-white with the
   vermilion bar). Do NOT also apply n-d4's traffic_atlas_wiring*.patch.
2. Apply evidence/pass-cost/look_d5-early-outs-lattice.patch (supersedes look_d5-early-outs.patch; needs
   0d4175d's LookOverlay grime_tex, which is on this branch): D5 overlay -0.57 ms on the iGPU, but its
   stroke wobble / pressure patches re-lay (frames 26-d5-lattice) -> owner's eye, then re-bless the -ov
   goldens.
3. Traffic states: n-d4 ships traffic_atlas_hijack.png (same 3 x 3 cells) and _d1 / _d2 damage bodies. The
   render side needs a per-car state from the sim (native fill_render writes only custom.x = art id):
   characters / sim owner adds custom.y (0 intact, 1 d1, 2 d2, 3 hijacked); then CrowdLayers picks the
   texture / an atlas row by it.
4. Low-end GPU now (iGPU 1280x800): frame ~3.05 ms, print ~1.35, rigs ~0.5. Print bounds: Sobel 0.18 ms,
   tooth + grit ~0.15 ms; the rest is the screen copy + 3 plate fetches + tone maths. Small wins only left;
   measure on a real Deck before cutting the look.
5. Owner calls (frames ready, unchanged): objective solid vermilion vs paper + core (16); cop vermilion
   body vs cream body + cap (17); 15 Hz outer rigs (15); overlay amount at 48 px/m.
6. Rig 0.37 ms per tick (contended bench) vs 0.3: native RigArm / RigGait (characters owner).
- 03:04 the look_d5 patch REBASED on n-d5 5f0c13b (its f9f07fb grain_floor proposal broke the old context):
  evidence/pass-cost/look_d5-early-outs-lattice.patch now = early-outs + lattice + `amount > 0` guards on the
  strokes and both ghosts. Why the guards: with a floor live (age_floor / grain_floor below the D5 zoom,
  amount 0) the overlay runs everywhere at 32 / 48 px/m, and the strokes + 2 ghost fetches were computed
  only to be multiplied by 0. Checked bit-identical where it matters: n-d5's shader plugged in with
  grain_floor forced to 0.3 (scratch), guarded vs unguarded = 0 px differ in all 10 look frames, and the
  floor path was live (auto 48 px/m differs from D4 on 21 % of px). Frames 28-d5-guards/. Not timed (the
  floors are proposals, default off). NOTE for the owner: if grain_floor ships, the D5 overlay's screen copy
  + tooth cost moves to every zoom (~+1 ms on the iGPU before this patch; measure with overlay_cost).
- Evidence at 6f5e9d7 (HEAD code, 03:15): lint 13/13, unit 207, scenarios 8, parity PASS, selftest PASS
  (goldens 10/10 worst 0.09, accent gate clean apart from the listed debt, world lock 0.00 % x3). Copied to
  evidence/pof. Session end: tree clean, no Godot of mine running, my /tmp scratch deleted; masters frames
  24-28 kept as evidence, ladder.png 1280 x 11646 (rows 24, 24b, 24c, 25, 25b, 26).

## Iteration 11 (03:07 - , BUILD)

Weakest point picked by comparing the in-engine D4 frame with the target frame (d4h2_mock.jpg) instead of
by the item list (all 7 items are evidenced): the world print's inks. Measured, same regions: mock street
(81,71,72) warm, engine (75,70,78) lavender (B > R) - it fought the cream paper; mock street grain stddev
14-22, engine 9 (flat). Both are print-pass parameters = this lane.
- MILESTONE (f5fb578) item 2 gap closed: look_d4 / look_d4_item printed hard-coded CREAM / WASH / INK, the
  one print parameter outside the look profiles. Now uniforms `paper_tone` / `wash_tone` / `ink_tone`,
  filled from palette.json tokens through look_profiles.json `tones` (LookParams.add_tones; a row may
  override). Goldens 10/10 worst mean 0.10 (hex rounding). Unit 209 (+2: every profile prints in the
  tokens; both shaders declare the tone uniforms).
- MILESTONE (aa8a5f7) warm charcoal: ink #17131B -> #1B1517, wash #665F68 -> #6C6161 (solved for the mock's
  street through the dark-step mix) -> engine street (81,71,72) = the mock, same luminance. Accent gate
  unchanged (0.95 / 0.95 / 0.25 %), world lock 0.00 % x3, goldens re-blessed. Frames 29-tones/ (a-refactor
  vs b-warm, all 10 looks; compare-*.png with the mock strip). Ladder 29 / 29b / 29c. Rigs (print_part,
  characters' file) keep their own ink constant (23,19,27) vs the world's (27,21,23): not visible apart;
  README notes to pass the tones there when that file is next touched.
- MILESTONE (2a51fe3) D4 aquatint: the grime only moves wash step EDGES, so a field deep inside one step
  (the street) printed flat whatever `grime` was. `aquatint` (d1 0, d4 0.18, d5 0.26) = 1 px lattice
  grains inside the washes, mean-preserving around 35 % cover, the cover pushed by the grime blotches;
  paper clean. Street stddev 9 -> 12. iGPU 1280x800 48 px/m interleaved x2: print 1.35 / 1.38 -> 1.45 /
  1.45 ms, frame 3.04 / 3.05 -> 3.13 / 3.14 (evidence/pass-cost/aquatint). World lock 0.00 % x3, accent
  unchanged, d1 goldens untouched (aquatint 0 is exactly off), the rest re-blessed. Frames 30-mottle/.
  REJECTED x2 (never committed): (1) smooth tone mottle (col *= 1 + gn * 1.2) - read as airbrushed clouds,
  not ink (grain-m12-x2 / m12/); (2) the same grain from the sin hash() - diagonal streaks at 35 % cover
  (cmp1x-d4-48ppm.png), fixed by reading the lattice at texel centres. Ladder 30 / 30b / 30c (rejected).
  Owner's eye: at 32 px/m the lots' diagonal hatching is a little less crisp on the grain.
- MILESTONE (c31574a) colour doctrine BY CONSTRUCTION in the world print: moved the accent audit off the
  junction (scratch copies of city_selftest / accent_audit with the camera 32 m into the block, never
  committed, deleted) - a plaza with props. barrel_cluster.png prints 2 vermilion barrels per cluster:
  world vermilion 4324 / 5632 / 3916 px at 32 / 48 / 64 px/m = 20x the traffic-light debt, invisible to
  the junction-only audit. palette.json already allows neither accent on `world`, so every profile's
  world `verm` / `teal` -> 0: a red prop prints as its ink density (barrels = cream discs in an ink rim,
  the lamps = paper discs - what the debt row asked d4-production for). After: 0 / 0 / 0 at the block;
  junction: only the 32 px/m frames move (mean 0.02, the lamps), every other look frame bit-identical
  (actors / cars / FX print accents in their own passes; actor vermilion unchanged 0.93-0.95 %).
  accent_debt.json rows: none (n-d4 0fa27c3 redrew the lamps too - consistent). New test ties every
  profile's world plates to palette.json's layer rule; PLANTED d4 verm 0.5 -> 1 failure, restored.
  Frames 31-block/ (before, + audit/), 32-world-no-accent/ (barrels-48ppm.png, traffic-light-32ppm-x2.png).
- For d4-production (asset note, no longer a doctrine break): barrel_cluster.png's red barrels now print
  as cream; if the barrels are meant as an explosive hazard, that is a gameplay object -> a world_markers
  danger cue or an actor, not a red prop texture. The plaza's 1 m ink grid is n-d4's (a1874f7 already).
- MILESTONE (753b94c) LookOverlay hands the overlay ink_tone / paper_tone (palette); look_d5-tones.patch
  for n-d5 (applies AFTER look_d5-early-outs-lattice.patch; built and checked on n-d5's file): plugged
  capture <= 2 levels on ~5 % of px at 64 px/m, 48 bit-identical. 33-d5-tones/. D5 at 64 px/m over the
  warm aquatint print looks right (the Rivet concept's warm grime). Ladder 32, 33.
- Merge check (03:30, merge-tree): n-d4 / n-d5 / n-noir still conflict on JOURNAL.md only.
- MILESTONE (55f60d5) hatched building cast shadows (item 1's `building_shadows` band, finally carrying
  the height cue): found a building block via a scratch chunk probe (dev/selftest/zz_scratch_*, never
  committed; camera at (456, 428)) - cream inked roofs + charcoal street already read like the target
  frame; the gap was the shadow: the bake offsets the roof silhouette only 0.25 m at flat ink 0.45 = a
  thin grey line at the roof edge, where the mock drops a broad hatched band. Now cast_shadows.json
  (gtai.cast-shadows/1): one material for the band = n-d5's look_d5_shadow when in the tree (their
  "proposal for the city lane"; only their showcases used it), else my cast_shadow.gdshader placeholder
  (same uniforms period 5 / tint 0.36 / stroke 0.85 / cov 0.42, wobble + gaps on the grime lattice); the
  view adds the per-class cast distance (buildings 1.1 m total = n-d5's offset_m; baked 0.25) -> no
  re-bake. Every block drops a 1.1 m hatched band on its pavement. Frames 34-buildings/ (before,
  after-d4, cmp-32 / cmp-48). World lock 0.00 % x3 (the strokes use the canvas position), goldens moved
  only at 32 px/m (prop shadows; worst 0.11, re-blessed), accents unchanged, unit 214 (+3).
  iGPU at the building block, interleaved x2: +0.01 / +0.02 ms frame = noise (evidence/pass-cost/
  cast-shadows). Ladder 34 / 34b. Not fed: look_d5_shadow's `zoom` (only matters above 64 px/m).
- MILESTONE (c89365e) the selftest gates now run at TWO sites: `--site=block` (456, 428), a street between
  built blocks, next to the riot junction. look goldens (block: d4 32 / 48 + auto 64, tests/golden/look/
  block-*.png, LOOKED at before blessing) and the accent gate run at both via tools/selftest/run.mjs; debt
  rows stay junction-measured. Why: this session's two finds (the plaza barrels' vermilion, the missing
  roof shadow) were both invisible to a junction-only gate. Selftest PASS: goldens 10/10 + block 3/3 worst
  0.00, accents clean at both (block 1.05 / 0.70 / 0.31 % actor vermilion), world lock 0.00 % x3. The
  scratch zz_scratch_* scenes it replaces are deleted (never committed).
- Checked, not mine: a hatched 4 m square mid-street at the block (block-auto-64ppm) is there with the
  flat shadow too - a darker asphalt patch in the road tile that look_d4 hatches as deep shadow. FOR
  d4-production: now that hatching = a cast shadow, a hatched patch with no caster reads as a shadow of
  nothing; keep road patches out of the hatch range (lighter than density 0.86) or give them a caster.
  Frame: 34-buildings/square-64-flat-vs-hatched.png.
- 03:45 evidence run started at c89365e (lint, unit, scenarios, parity, selftest, bench).
- FRICTION (03:45): I edited chunk_view / city_view / cast_shadow (the `zoom` feed) while the evidence run
  read the working tree; parked as evidence/patches/cast-shadow-zoom.patch within ~30 s and restored the
  tree to c89365e. The overlap hit the unit stage only (the edit was API-compatible: a defaulted param);
  unit is re-run at the final HEAD. Rule for me: no tree edits while tools/evidence/run.mjs runs.
- Evidence at c89365e (03:44-03:58, `node tools/evidence/run.mjs`, all PASS): lint 13/13, unit 214,
  scenarios 8, parity bit-exact + mutation caught, selftest PASS (junction goldens 10/10 + block 3/3 worst
  0.00; accents clean at both sites; world lock 0.00 % x3), bench (release export, 3 x 4 x 60 s) p99 2.75 ms
  (iter 10: 2.83), 1% low 226 fps, worst swap 33.3 ms, 1 frame > 50 ms (cause `present`, 0 unexplained),
  riot rigs p99 0.432 ms per frame. With every iteration-11 change on (warm tones, aquatint, hatched cast
  shadows, no world accents). Copied to evidence/pof (+ pof/block), evidence/bench-*-iter11.json.
- MILESTONE (d5785a9) the cast-shadow material gets the camera zoom (ChunkView.update(focus, res, zoom), one
  changed call in CityView._process, off n-noir's hunks; merge-tree still JOURNAL-only x3). Goldens
  bit-identical at both sites (worst 0.00). Checked above 64 px/m (scratch: block site moved to x 448 so
  the band is in a 128 px/m view, SITE_CASES [d4 128]; both reverted, never committed): with vs without
  the zoom feed the frames differ only in the shadow-band columns (diff bbox x 665-984) - finer strokes.
  First 128 px/m try (x 456) had no shadow on screen (0 px differ = inconclusive, not counted).
  Frames 36-shadow-zoom/ (cmp2-128.png).
- OWNER OPTION (rendered, NOT shipped): paper #F2E8D5 -> #F0E1C6 toward the mock's sepia. Frames
  35-paper-option/ (shipped vs warm at the block, + mock strip; ladder 35). Reads coherent with the warm
  charcoal; the rigs' sticker rims stay on print_part's own cream, so they pop a touch more. One hex in
  palette.json if the owner wants it (re-bless both sites' goldens after).
- Iteration 11 tally: frames rejected for camera 0 (all engine captures, straight down); approaches rejected
  3 (smooth tone mottle; sin-hash grain; per-asset debt rows instead of the world-plate rule) + 1
  inconclusive probe discarded (128 px/m without a shadow in view). No AI images (no codex), so no
  provenance lines. Scratch scenes (zz_scratch_*), the chunk probe and the temporary SITE_CASES / site
  edits all deleted or reverted; /tmp scratch deleted. Ladder 1280 x 16354 (rows 29-35).

NEXT (iteration 12 / morning, in order):
1. Director merge (JOURNAL.md-only conflicts with n-d4 / n-d5 / n-noir at 03:59). After it:
   - n-d4: the traffic atlas goes live (7bfb6b9) -> re-bless the junction AND block goldens, LOOK at them.
   - n-d5: cast_shadows.json then prefers look_d5_shadow automatically (same uniforms, takes `zoom`);
     apply evidence/pass-cost/look_d5-early-outs-lattice.patch THEN look_d5-tones.patch; re-bless the -ov
     goldens. Do NOT apply n-d4's traffic_atlas_wiring*.patch.
   - Run `node tools/selftest/run.mjs`: both sites must pass (accents clean, world lock 0.00 %).
2. Owner calls, frames ready: warm charcoal (29, shipped - revert = 2 hex), aquatint at 32 px/m vs the lots'
   hatch legibility (30), cast shadow length 1.1 m (34), paper warmth option (35, not shipped); older:
   objective vermilion vs paper (16), cop accent (17), 15 Hz outer rigs (15), overlay amount at 48 px/m.
3. For d4-production: barrel_cluster red barrels now print cream (world carries no accent - if they are an
   explosive hazard, that is a world_markers cue / actor); the road tile's dark asphalt patch hatches like a
   shadow with no caster (34-buildings/square-64-flat-vs-hatched.png).
4. print_part (characters / n-noir file): take ink_tone / paper_tone like look_d4_item (rig ink is 23,19,27
   vs the world's 27,21,23: invisible today, drifts if the palette moves).
5. Traffic states (unchanged): sim custom.y (intact / d1 / d2 / hijacked) -> CrowdLayers picks n-d4's atlas.
6. Rig 0.43 ms p99 per frame in the riot (bench at c89365e) vs the 0.3 target: native RigArm / RigGait.
- Evidence at c57bef5 (HEAD code, 04:02-04:1x, --no-bench; the bench at c89365e above predates only the
  zoom feed, bit-identical at <= 64 px/m): lint 13/13, unit 214, scenarios 8, parity PASS, selftest PASS
  (junction 10/10 + block 3/3 worst 0.00, accents clean at both, world lock 0.00 % x3). Copied to
  evidence/pof. Session end: tree clean, no Godot of mine running, my /tmp scratch deleted.

## Iteration 12 (04:04 - , BUILD)

Weakest point picked: item 4's night grade - the one look piece still on a raw hex and never looked at
since iteration 6 ("needs the owner's eye"). A flat multiply by #6E6878 (B > R): after iteration 11's
warm re-tone it cast lavender over the warm paper / charcoal, flattened the paper-street contrast and
dimmed the vermilion / teal below the palette gates along with everything else (before frames: block
and junction at 32 / 48, the light showcase at 32 / 48 / 64).
- MILESTONE (c31559a) grade_ink.gdshader: the grade rect reads the screen and re-prints luminance as
  paper_level * l^gamma, hue kept; accent pixels (palette gates) keep accent_keep of their value. Grades
  are lights.json rows (paper_level / gamma / accent_keep; schema updated); night 0.58 / 1.5 / 0.85; day
  is the identity and HIDES the rect (the old day drew a white multiply over the whole screen every frame;
  that saving is unmeasured). Look: paper -> warm grey, streets -> near ink, cops' vermilion holds = noir
  spot colour; the lights (hatched paper / vermilion bands) read harder on the near-ink street.
  Day print: selftest goldens 10/10 + block 3/3 worst 0.00, accents unchanged, world lock 0.00 % x3.
  Unit 216 (+2: day hides / night shows the rect with the row's uniforms; night darkens paper and
  hardens the paper / street ratio). light_showcase now also measures `gpu_ms_night_grade_delta`
  (interleaved day / night blocks): RTX 4090 +0.04 ms; 2-CU iGPU 1280x800 +0.46 / +0.46 ms (2 runs) =
  the screen copy + one pass, night only, inside the Deck's 25 ms. evidence/light-cost/night-grade/.
  Frames 37-night/ (cmp-block-*, cmp-junction-*, cmp-lights-32/48/64); ladder 37 / 37b / 37c.
  Rejected: 0 frames (all engine captures, straight down). The lavender car quad in the night frames
  is the car placeholder's own colour (traffic atlas lands with n-d4), not the grade.
- Measured (palette gates on the frames, python over 37-night/): pixels passing the vermilion gate at
  night, BEFORE (multiply) 0 in every frame (block / junction 32 / 48, light showcase 32 / 48 / 64) - the
  old night erased the doctrine accents (cops / threats indistinguishable); AFTER block 9980 / 7616,
  junction 8853 / 6154, showcase 9221 / 9438 / 2523 vs day 9455 / 9639 / 2547 = 97-99 % kept.
- MILESTONE (fe63853) night golden: look_golden SITE_CASES rows take a grade column; block-d4-48ppm-night
  (LOOKED at before blessing). The 3 existing block goldens re-blessed byte-identical. Selftest: junction
  10/10, block 4/4 worst 0.00, world lock 0.00 % x3.
- MILESTONE (09a1962) car lights at night (item 4's headlights / siren, until now only in the showcase):
  features/city/view/city_headlights.gd reads the snapshot CityFxFeed already gets (once per sim tick, no
  extra sim call); lights.json `car_lights` (schema updated): on `night` the 6 cars nearest the focus
  within 40 m hold 2 headlight cones at the nose corners, police cars a siren; day returns after one
  check once released. Directions checked in frame: right-hand traffic (eastbound south lane, westbound
  north lane; the block's southbound car in the west lane) - all cones point ahead of the nose.
  Cost 38 us per tick at night, 0 work by day (editor build, headless scratch probe, 400-actor snapshot
  with 57 cars; scratch deleted). Unit 219 (+3). Junction night golden d4-48ppm-night (cars lit; LOOKED at);
  the block night golden did not move (its one car drives south, cones below the frame - checked in the
  frame, not assumed). Frames 38-car-lights/ (32 + 48 at both sites); ladder 38 / 38b. Siren on a police
  car not seen in a frame (no police car near either site): unit-tested only.
- MILESTONE (f8863d8) street lamps at night: features/city/view/city_prop_lights.gd + lights.json
  `prop_lights` / kind `street_lamp` (4.5 m paper pool, 2 bands, intensity 0.38). The lamp head = the
  oval at 83 % of lamp_post.png's width -> at_m [1.05, 0] in the sprite frame; heads read once per
  resident chunk from its draw commands (baked shadow commands skipped), cached until the chunk leaves;
  8 nearest within 32 m, re-picked when the focus moved 2 m. max_lights 32 -> 40 (18 car + 8 lamps held,
  timed keep 14). Frames 39-street-lamps/: the block's 4 kerb lamps light pools on the pavement edge,
  each centred on its head (checked in frame); the junction has traffic-light posts, no lamp posts, so
  it is unchanged. Block night golden re-blessed (only the pools moved, mean 4.49 before; LOOKED at),
  other block goldens byte-identical. Unit 220 (+1). Cost (editor build, headless scratch on the
  generated city, deleted): first pick 123 us (reads 9 chunks), then 5.9 us mean per frame at 20 m/s,
  worst 212 us (a new chunk entering the radius). Day: one check per frame.
- Evidence at 56d23e7 (04:28-04:42, `node tools/evidence/run.mjs`, all PASS; commit 5d18ef9): lint 13/13,
  unit 220, scenarios 8, parity bit-exact + mutation caught, selftest PASS (junction 11/11 + block 4/4
  goldens worst 0.00 incl. both night goldens; accents clean at both sites; world lock 0.00 % x3), bench
  PASS but CONTENDED: p99 3.25 ms (iter 11: 2.75), 1% low 219 fps, worst swap 14.3 ms, 0 frames > 50 ms,
  riot rigs p99 0.653 ms (iter 11: 0.432, rig code unchanged). Six other-lane Godot processes were running
  (tasklist at 04:43). My day-path changes are one early-return per frame (prop lights) and one fewer
  full-screen rect (grade hidden); not a credible +0.5 ms, but NOT proven: an idle or interleaved bench
  re-run is owed. evidence/bench-*-iter12-contended.json.
- iGPU light cost with max_lights 40 (light_showcase --gpu-index 1, 2 runs): full budget +0.59 / +0.60 ms
  (32 lights was +0.42 / +0.45), night grade +0.40 / +0.43 ms. evidence/light-cost/night-grade/.
  FOUND: `dropped` 161 -> 2577 in the showcase - its probe fills the budget with held fires, and at night
  CityHeadlights retries its refused adds every tick (cheap, but inflates the counter). Fix candidate:
  back off a refused slot until the next re-pick / count refusals apart.
- FIX (96d76a8): CityHeadlights backs off 30 ticks after the budget refuses an add (unit 221: one refusal,
  then none inside the back-off). Goldens unchanged.
- MILESTONE (99211fc) night golden at arena zoom: block auto 64 px/m night (the D5 overlay under the grade;
  LOOKED at: vermilion held, lamp pools at both kerbs, rigs readable). Block goldens 5/5 worst 0.00.
- OWNER OPTION (rendered, not shipped): night tuning, same scene (block, no fx-moment) at 32 / 48:
  soft 0.66 / 1.3 keeps the street's cracks and grain; shipped 0.58 / 1.5; hard 0.50 / 1.8 sinks the street
  to flat ink. 40-night-options/night-options-block-{32,48}.png; ladder 40. lights.json was edited for the
  renders and restored (git clean). First sheet mixed an --fx-moment shipped frame with plain option
  frames (different sim moment) - caught on looking, re-rendered; the mixed sheet was overwritten.
- Merge check (04:50, merge-tree): my first README append (grade_ink at the end of assets/shaders/
  README.md) conflicted with n-d5's end-of-file section; moved it above the D4 section -> JOURNAL.md-only
  conflicts again with n-d4 / n-d5 / n-noir. n-noir's city_view.gd hunks (NoirLook, set_noir,
  noir.light_street) auto-merge with mine (prop_lights, tex_table); merged file ~226 lines (< 300).
- Iteration 12 tally: frames rejected for camera 0 (all engine captures, straight down); 1 option sheet
  rebuilt (mixed sim moments); 0 approaches reverted. No AI images (no codex) -> no provenance lines.
  Scratch probes (zz_scratch_headlights / zz_scratch_lamps) deleted, lights.json option edits restored,
  /tmp scratch deleted. Ladder rows 37-40 (1280 x 19350).

NEXT (iteration 13 / morning, in order):
1. Director merge (JOURNAL.md-only conflicts at 04:50). After it:
   - n-d4: traffic atlas live -> re-bless junction AND block goldens INCLUDING the 3 night goldens
     (d4-48ppm-night, block-d4-48ppm-night, block-auto-64ppm-night); LOOK at them. Check the headlight
     lamps_m [2.3, +-0.7] against the drawn car noses (placeholder quad today).
   - n-d5: as iteration 11 NEXT 1 (cast_shadows prefers look_d5_shadow; apply the two look_d5 patches).
   - n-noir: NoirLook.light_street and my night lights (CityHeadlights / CityPropLights) both light the
     street. Decide: noir = a LOOK, night = a GRADE; if noir is on at night, one of the two street-light
     paths should yield (simplest: noir's light_street skips when lights.grade has prop_lights).
   - `node tools/selftest/run.mjs`: both sites, 16 goldens, accents clean, world lock 0.00 %.
2. Bench owed on an idle machine: iteration 12's run was contended (p99 3.25 ms, rigs 0.65 ms vs 2.75 /
   0.43 at iter 11 with 6 other-lane Godots running). Expect no change (day path: one early return + one
   fewer full-screen rect); prove it.
3. Owner calls with frames: night tuning (40-night-options: soft / shipped / hard), the night look as a
   whole (37-39: grade, car lights, lamp pools), plus iteration 11's open calls (warm charcoal 29,
   aquatint 30, cast shadow length 34, paper warmth 35) and the older ones (16, 17, 15).
4. Gameplay hook for the grade: nothing sets `night` outside the selftests yet (acts / missions own
   when it is night); the API is CityView.lights.set_grade(&"night").
5. Unchanged: print_part ink / paper tones (characters / n-noir file); traffic states from sim custom.y;
   rig 0.43 ms p99 vs 0.3 target (native RigArm / RigGait); d4-production asset notes (barrels, road patch).
- Evidence at 4d83199 (HEAD code, --no-bench, ~04:55): lint 13/13, unit 221, scenarios 8, parity PASS,
  selftest PASS (junction 11/11 + block 5/5 goldens worst 0.00, accents clean at both, world lock
  0.00 % x3). Copied to evidence/pof. Bench: the contended run at 56d23e7 above (owed idle, NEXT 2).
  Session end: tree clean, no Godot of mine running, my /tmp scratch deleted.
## Iteration 13 (04:52 - , BUILD)

- 04:53 tasklist: no Godot process running on the machine -> the idle bench owed from iteration 12 runs first.
- 04:57:36 two other-lane Godot runs started 14 s after my bench (dev/noir/showcase_fight.tscn d3d12, and
  a headless tests/load_all.gd) -> this bench is CONTENDED too (recorded as such when it lands).
- FOUND (item 6, weakest item): half of camera feel was dead in the real game. `CityView.follow_vel_mps`
  (the look-ahead input) was declared and never set by anything, so the car look-ahead never moved the
  camera outside the unit test; `CameraRig.hitstop_ticks()` had no consumer, so no hit-stop ever held.
- Checked main (721fbbb): features/combat/combat_arena.gd emits actor_killed (killer_id, victim, &"shot")
  and player_hit(&"robo-tazer") - real emitters for the hit-stop cues once merged (my branch has no
  combat feature; the arena's player id must be handed to FxTriggers.player_id where its view is built).
- Bench at 4d83199 (05:01-05:05, exported release, 3 x 4 scenarios x 60 s): PASS - p99 2.81 ms, 1% low
  209 fps, worst swap 32.3 ms, worst frame 48.2 ms, 0 frames > 50 ms; riot rigs p99 0.448 ms per frame.
  CONTENDED (other-lane Godot runs from 04:57:36; 4 Godot processes listed at 05:05). Vs iteration 11
  (2.75 / 0.432) and iteration 12's contended 3.25 / 0.653: iteration 12's jump was the contention, not
  the night code (the day path cost is within run-to-run noise). An idle run is still not had: other
  lanes keep a Godot running. evidence/bench-*-iter13-contended.json, bench-iter13-contended.txt.
- MILESTONE (7dcb210) camera feel wired in the game path:
  - Look-ahead: CameraRig.follow(tick, focus) differences the focus between the ticks it sees
    (frames with no new tick lead nothing; > 90 m/s = a jump, leads nothing); CityView calls it instead
    of the dead follow_vel_mps (removed). Whatever moves CitySystem.focus feeds it (the input free
    camera today, a car / cutscene later).
  - Hit-stop: fx_triggers.json rows take `hitstop` (schema updated): player_hit -> rivet_hit (3 ticks,
    new camera.json row), new event cue rivet_kill = Events.actor_killed with killer_id = Rivet's id
    -> kill (6). CameraRig.hitstop(id, tick): 0 under reduced motion / inside hitstop_cooldown_ticks 20
    (new camera.json key). FxTriggers holds the clock: SimClock.hold(seconds) (core/clock, shared:
    +14 lines) withholds that much clamped frame time from the accumulator - no tick changes content,
    SimLoop.replay steps ticks directly, headless has no views. World sets fx_triggers.player_id =
    CityCharacters.RIVET_ID (boot/world.gd, shared: +1 line).
  - Unit 228 (+7, test_hit_stop.gd). Lint 13/13. Scenarios 8/8 (replay_60s identical).
  - Frames (dev/selftest/lead_showcase.tscn: junction seed 91, focus driven east 15 m/s, pickup ring =
    focus, --fixed-fps 60): car 48 px/m BEFORE (HEAD city_view swapped in for the run, then restored)
    lead 0 m at ticks 30 / 60 / 150; AFTER 4.13 / 4.78 / 4.93 m (cap 5.25 m at 15 m/s; the capture
    frame itself does not move the focus, so one zero-velocity tick takes 6 % off). LOOKED at: Rivet
    sits left of centre with the road ahead open; on foot 32 px/m before = after (look_ahead 0 by data).
    gtai-masters/night/visual-engine/41-lead/cmp-lead-{car,on_foot}.png; ladder 41 / 41b.
  - In-engine hit-stop: ticks read at successive process_frame starts around Events.player_hit:
    [268, 268, 268, 268, 268, 269, 270] = exactly 3 frames held (process_frame fires before the
    frame's _process), stops 1. evidence/camera-iter13/lead-showcase-*.json.
  - Rejected: 0 frames (engine captures, straight down); one run re-done (on_foot pass forgot --mode).
- Selftest at 7dcb210 (05:15-05:2x): PASS - junction goldens 11/11 + block 5/5 worst 0.00 (no rig in the
  selftests, as designed: nothing moved), accents clean at both, world lock 0.00 % x3.
- MILESTONE (2a50244) the arena zoom has a trigger: CameraRig.listen also follows Events.boss_engaged ->
  `arena` (64 px/m) and contract_completed -> `on_foot` (main's combat arena emits boss_engaged).
  dev/selftest/arena_showcase.tscn (Events emitted like the game, rig wired like World): ease 32.1 /
  38.0 / 49.3 / 60.0 / 64.0 px/m every 9 ticks, the auto look's D5 weight 0 / 0 / 0.02 / 0.84 / 1.00, at
  the junction AND the block. LOOKED at both strips and the 64 px/m block frame (Rivet's collar, D5
  cracks + grime, straight down). Before (7dcb210's rig swapped in, then restored): stays on_foot 32 px/m.
  Observation for the owner: the D4 -> D5 blend lands inside ~15 ticks of the 36-tick ease (49 -> 60
  px/m is where look_profiles' smoothstep sits), so the grime arrives late and fast; a gentler
  start_ppm (e.g. 40) would spread it - not changed (it also moves the auto goldens at 48 / 56).
  Frames 42-arena/strip-arena-{junction,block}.png; ladder 42. Unit 229 (+1). Rejected: 0 frames.
- Trial merge (05:17, my own scratch worktree gtai-wt/scratch-visual-trial13, detached at 02719bb, merged
  main 721fbbb = quest 1 + combat arena; removed after): textual conflicts none; lint 13/13 over 253
  files, unit 253/253, scenarios 8/8. merge-tree vs n-d4 / n-d5 / n-noir: JOURNAL.md-only conflicts (as
  at 04:50; my new world.gd / sim_clock.gd / fx_triggers.gd hunks merge clean).
- FIX (5557cfe) photosensitivity: lights.json `fire` alternated vermilion / paper at flicker_hz 7 = 7
  saturated-red flashes a second (WCAG 2.3.1 / Harding allow 3; a riot holds up to 40 fires on screen).
  fire -> 2.5 Hz (the siren's rate); lights.json max_flash_hz 3 (schema) + LightLayer.MAX_FLASH_HZ clamp
  any faster alternating row at load with a Log.warn. Unit 230 (+1). No frame: a rate is temporal (a
  single frame cannot show it); the test reads the loaded table. Owner option: fire as a steady
  vermilion pool with an intensity-only flicker (no colour flash at all).
- Selftest at 5557cfe (flash cap): PASS, goldens 11/11 + 5/5 worst 0.00, accents clean, lock 0.00 % x3.
- FOUND + FIXED (zoom swim, now that the zoom eases are live): world_px = camera.position * zoom, so a
  world point X prints at X * zoom and a rig zoom ease slid the print by X * dz a tick (~600 px at the
  block). CityView._print_px(): an offset moves by -camera * dz on each RIG zoom step (screen centre
  keeps its print, pans stay locked; no rig = offset 0 = goldens bit-identical). Evidence
  (dev/selftest/arena_showcase.tscn gained --skip / --shots / --stride; block, 4 consecutive mid-ease
  ticks 44.0 / 45.3 / 46.7 / 48.0 px/m, before = 2a50244, after = fix, same sim moments):
  - first metrics (full-res residual of frame k warped onto k+1, building box; then by radius bands)
    showed NO difference (21.35 vs 21.28): dominated by edge resampling and moving actors, and the 1 px
    grain re-rolls in both (any slide > 1 px decorrelates it). LOOKED at street crops: grain boils in both
    rows - true and unavoidable with constant-screen-size grain; it settles when the ease ends.
  - low-passed (the grime blotches, ~30 px): street trimmed-mean residual 1.76 -> 0.89 (sigma 3),
    1.50 -> 0.67 (6), 1.21 -> 0.54 (10) = the large-scale print swim halved. Same-tick before/after
    frames differ in 85 % of pixels (the grain sits elsewhere; the fix applies). Kept (measured better,
    not worse). gtai-masters/.../43-zoom-swim/ (crops, residual maps, swim_metric.py / .txt); ladder 43.
- Selftest at f3d6fc1 (zoom anchor): PASS, goldens 11/11 + 5/5 worst 0.00 (bit-identical: no rig),
  accents clean, world lock 0.00 % x3.
- Skipped on purpose: a `--reduced-motion` launch flag (QA path until a settings feature exists). It
  needs boot/launch_args.gd KNOWN_FLAGS, a line n-noir also changed (identically, adding --look): my
  edit would turn that clean merge into a conflict. After the merge: KNOWN_FLAGS + 2 lines in World
  (view.rig.reduced_motion / view.markers.reduced_motion).
- FOUND (integration): main's quest 1 (boot/collect_call/view/) draws with its own `Ink` constants (ink
  #17131B, not palette tokens), its own fixed Camera2D at 48 px/m and its own FX drawing: none of the
  visual engine (layers, print, rig, FX, lights, doctrine audit) reaches the first real gameplay.
- MILESTONE (d5ac536) PrintStage (core/render/print_stage.gd, 144 lines): the engine as one node for
  any non-city view - camera + rig + zoom-anchored world_px, D4 print + D5 overlays by look and zoom,
  the actors canvas + item print, lights, the 3 FX twins, world-UI markers, all on declared layers.
  CityView untouched (it composes the same pieces; moving it onto PrintStage after the merge avoids a
  conflict with n-noir's city_view hunks). Unit 234 (+4). README "Plugging a view in".
  Demo (dev/selftest/print_stage_demo.tscn, quest-1 placeholder shapes): off vs d4 at 32 / 48, auto 64.
  LOOKED at: concrete takes wash + grime, the dark lane hatches, crates ink; the world's vermilion
  barrel prints cream (no accent plate in the world) and the actor threat keeps vermilion. 44-print-stage/.
- PROOF on main's real quest 1 (my scratch worktree scratch-visual-q1 = n-visual + main, removed after;
  NOT committed anywhere): CollectCallView onto PrintStage = 47-line patch (its 48 px/m drawing scaled
  by 32/48 into world px, stage zoom 1.5; stage_view on `ground`, cast_view / fx_view on the actors
  canvas with the item print, HUD on the `hud` canvas). Quest 1's own frame grabber, same 9 shots
  (ticks 261 .. 11435), before / after. LOOKED at 4: works mechanically (paper tooth, bolder Sobel ink,
  accents held on guards / flames / Rivet's collar + eye, HUD unprinted), BUT the quest's 12 % WASH zone
  floors fall under the first D4 wash step and flatten to paper (Factory Row / Dock 9 lose their zone
  read) - worse for zone readability: the placeholder tints need >= the wash step (or real ground art)
  before this ships. Patch + frames: gtai-masters/night/visual-engine/45-quest1/
  (collect_call_view-on-print_stage.patch, cmp-quest1.png); ladder 45.
- Evidence at a275142 (05:33-05:35): lint 13/13, unit 234, scenarios 8, parity bit-exact + mutation
  caught, selftest PASS (11/11 + 5/5 goldens worst 0.00, accents clean, world lock 0.00 % x3). The first
  attempt FAILED unit on import churn: print_stage_demo.gd.uid was not committed (rule 8) - committed in
  a275142, re-run green. Copied to evidence/pof (7846d47).
- FIX (9f6c7b3) review: PrintStage applied the look's params before re-assigning the item shader on an
  off -> printed switch; shader first now (+ unit assert).
- MILESTONE (72d631b) print_stage_demo drives FX (explosion + muzzle) and the night grade + a fire light
  through PrintStage. LOOKED at: smoke puffs + paper light rings at the barrel, muzzle cone at the threat;
  night re-prints darker, the fire is a vermilion pool, the threat's vermilion holds. The crackle spawned
  at a person was NOT visible at the capture tick (not claimed). 7/7 frames byte-identical across two runs.
- 05:38 idle check for the bench: other lanes' Godot (noir_frames, run_parity, an n-d5 import) running ->
  no idle bench this session either.
- MILESTONE (a103850) FX item 5's electroshock crackle had no trigger: FxTriggers fires player_hit then
  player_hit_<weapon> when the table has it; fx_triggers.json player_hit_robo_tazer -> crackle (main's
  arena emits player_hit(&"robo-tazer")). Unit 235. In-engine: fired 1, 4 emissive FX alive in the held
  impact frame - but LOOKED: nothing readable (paper bolts on Rivet's cream body).
- FIX (90fe24c) the bolt's rim came from the generic p * 1.18 trick (< 1 px on a thin zigzag): now an ink
  band (0.17) around a paper core (0.07) from the same zigzag distance; crackle size_m 0.8 -> 1.4. Held
  impact frame (lead_showcase, before = HEAD shader + fx.json swapped in, restored, git diff checked):
  48 px/m before nothing / after ink-rimmed zigzags around the core; 32 px/m visible but small.
  46-tazer/cmp-tazer*.png; ladder 46 / 46b. When n-d4's FX sheet lands the crackle draws its sheet cell
  (atlas size_m 1.6) and this analytic bolt is moot: re-check the crackle ON RIVET then (paper on cream).
- Crackle with n-d4's real FX sheet (copied in for the capture only, removed after; the sheet then
  replaces my analytic bolt): FIRST ATTEMPT WAS WRONG - I copied `git show n-d4:...fx_atlas.png`, which
  is a Git LFS pointer (130 bytes of text), so the "sheet" drew opaque white squares over Rivet; caught
  on looking + checking the file, NOT a sheet bug, frames deleted. Re-done with n-d4's checked-out png
  (1108005 bytes = the LFS size; read-only copy). Real result: 48 px/m - a cream spark star at Rivet's
  core with a little crackle, readable; 32 px/m - nothing readable on Rivet. For d4-production: the
  shock_1..4 cells read on asphalt (their iteration-4 check) but not on Rivet's cream / grey body at
  32 px/m (46-tazer/cmp-sheet-crackle.png). Also: my cleanup `rm -rf project/features/fx` removed the
  tracked features/fx/README.md - restored from HEAD at once (git checkout --), tree verified clean.
- Tint ladder checked on main's quest 1 (scratch scratch-visual-q1b = n-visual + main + the 45-quest1
  patch, Ink.WASH alpha 0.12 -> 0.30 = luma ~0.66 / density ~0.34; removed after, nothing committed):
  Factory Row's zone (02-collect-call) prints as a wash and reads again; Dock 9's floor (04 / 06) is
  STILL paper - it is drawn with another, lighter tint than Ink.WASH (needs the same <= ~188 grey rule).
  45-quest1/cmp-quest1-wash.png (own view | PrintStage | PrintStage + WASH 0.30); ladder 45b.
- Evidence at 90fe24c (05:41-05:43, `node tools/evidence/run.mjs --no-bench`, all PASS): lint 13/13,
  unit 235, scenarios 8, parity bit-exact + mutation caught, selftest PASS (junction 11/11 + block 5/5
  goldens worst 0.00, accents clean at both, world lock 0.00 % x3). Copied to evidence/pof. Bench: the
  contended run at 4d83199 above (camera / flash / PrintStage changes are not on the bench's path: no rig,
  fire flicker only changes a toggle rate).
- docs/decisions.md (shared, appended after my own iteration-11 lines; merge-tree re-checked: still
  JOURNAL.md-only): DECISION render hit-stop (SimClock.hold, SIM-01 / SIM-05 safe) and DECISION render
  PrintStage.
- MILESTONE (7e3eb68) PrintStage.listen(bus, clock, player_id, at): the game feel in one call (a CameraRig
  on the F-04 events incl. boss_engaged -> arena, the FX cues, the hit-stops). Unit 236 (+1). For quest 1
  after the merge: the 45-quest1 patch + `print_stage.listen(Events, <its clock>, <Rivet's id>, ...)`
  (CollectCallView has no SimClock today: the play steps ticks itself - give it one or pass the stage's).
- Evidence at 7e3eb68 (05:48-05:50, all PASS): lint 13/13, unit 236, scenarios 8, parity bit-exact +
  mutation caught, selftest PASS (11/11 + 5/5 goldens worst 0.00, accents clean, world lock 0.00 % x3).
  Copied to evidence/pof.
- Reduced motion in-engine (lead_showcase --reduced-motion, a dev flag; the game's launch flag waits
  for the merge): lead 2.74 / 3.17 / 3.29 m at ticks 30 / 60 / 150 (normal 4.13 / 4.78 / 4.93) - the
  table halves the look-ahead CAP (7 -> 3.5 m), not the lead (README said "halves the look-ahead":
  corrected); the Robo-tazer hit: crackle fired, offset y exactly 0 (no shake), ticks
  [268, 268, 269, 270, ...] = 0 frames held, stops 0. 47-reduced/; ladder 47;
  evidence/camera-iter13/lead-showcase-reduced-motion.json.
- Iteration 13 tally: frames rejected for camera 0 (all engine captures, straight down); approaches
  reverted 0 (the zoom anchor measured better at low frequency, equal on the 1 px grain - kept); re-runs:
  1 (on_foot lead pass forgot --mode), 1 (print_stage_demo parse errors -> hung run, my PID 32332 + child
  killed by PID). Swaps of old files for before-frames (city_view.gd, camera_rig.gd) restored and
  verified by git diff each time. Scratch worktrees scratch-visual-trial13 / -q1 / -q1b (mine) removed;
  1 false alarm caught (an LFS pointer copied as the FX sheet), 1 slip fixed at once (rm -rf removed the
  tracked features/fx/README.md, restored from HEAD); scratch-m16 / scratch-q1 are not mine (untouched). No AI images (no codex) -> no provenance.
  Ladder rows 41-47 (1280 x 24058).

NEXT (iteration 14 / morning, in order):
1. Director merge: JOURNAL.md-only conflicts vs n-d4 / n-d5 / n-noir; main merges clean (trial: lint,
   unit 253, scenarios 8). After it:
   - move CityView onto PrintStage (it composes the same pieces; n-noir's city_view hunks land first);
   - quest 1: apply 45-quest1/collect_call_view-on-print_stage.patch ONLY with its zone tints raised to
     <= ~188 grey (README tint ladder) or real ground art - as patched today its zone floors print as
     paper (Ink.WASH 0.30 fixes Factory Row; Dock 9's floor tint too); then one
     `print_stage.listen(Events, clock, <Rivet's id>, <Rivet px>)` gives it the boss zoom (64 px/m, D5),
     the hit-stops on main's actor_killed / player_hit and the tazer crackle;
   - `--reduced-motion` in boot/launch_args.gd KNOWN_FLAGS + World (rig + markers), held back tonight to
     keep n-noir's identical KNOWN_FLAGS edit merge-clean;
   - n-d4's FX sheet replaces the analytic crackle: re-check the Robo-tazer hit on Rivet at 32 px/m
     (unreadable with the sheet today, 46-tazer/cmp-sheet-crackle.png);
   - iteration 12 NEXT 1 items (n-d4 atlas -> re-bless goldens incl. 3 night goldens; n-d5 patches;
     noir vs night street lights).
2. Idle bench still not had (two contended runs: 3.25 then 2.81 ms p99; iteration 11 2.75).
3. Owner calls: night tuning (40), fire flicker as colour flash at 2.5 Hz vs steady vermilion pool with
   intensity-only flicker (photosensitivity), the D4 -> D5 ramp start (48 px/m today; 0.35 at 48 was
   d5-close's ask), plus iteration 11/12's open calls.
4. Unchanged: rig 0.448 ms p99 (contended) vs 0.3 target (native RigArm / RigGait, characters owner);
   print_part tones; traffic states; d4-production asset notes.
- Final at 72b7845 (05:53): unit 236/236, scenarios 8/8 (the last commit touched a dev scene + README only;
  full evidence at 7e3eb68 above). Session end: tree clean, no Godot of mine running, my /tmp scratch and
  scratch worktrees deleted.
- (05:56) test_render_layers: CityView's zoom anchor unit-tested on the real city view (no rig: world_px =
  camera x zoom, the goldens' contract; with a rig easing 32 -> 48 the centre's print holds within 1 px;
  it would jump ~7.3k px without the fix). Unit 237/237.

## Iteration 14 (05:54 - , BUILD)

- 05:54 tasklist: 2 other-lane Godot processes running -> no idle bench again. All 7 items evidenced;
  weakest point picked from a FRESH 4-lane trial merge (the last one with frames was iteration 9; every
  lane has moved since).
- Trial merge (my scratch worktree gtai-wt/scratch-visual-trial14, detached at 3bf80d1, merged main 721fbbb,
  n-d4 5b05873, n-d5 f1bc6e2, n-noir 65c7bc3; JOURNAL = ours): conflicts JOURNAL.md (x2) and a NEW one,
  `evidence/README.md` add/add between n-d4 and n-d5 (both lanes' evidence index; for the Director - took
  n-d4's for the trial). Native bin copied in (git-ignored), import clean, bake 256 chunks.
  Selftest on the merged build: frames OK (72 art textures, 0 placeholders), accent gate PASS (0.94 / 0.96 /
  0.24 %, block 1.05 / 0.70 / 0.32 %), world lock 0.00 % x3; goldens fail as expected on the new art
  (worst 22.9; the block "255" = the `-ov` overlay frames have no golden yet, not a broken frame).
  LOOKED at junction 48, block 32 / 48 / 64: n-d4's cars print as inked cream (lavender boxes gone), roofs /
  pavements / street close to the mock at 32 px/m.
- FOUND (merge-time, my lane): at 64 px/m n-d5's look_d5 ages the WORLD print (paper 246,222,192) but the
  actors canvas above it keeps D4 cream (234,222,204): every body read cool lavender-grey on the paper
  (crop 48-trial14/z-crowd64.png).
- MILESTONE (a84bd39) page age: LookOverlay takes `age` / `age_floor` out of the world-only overlay
  (sends 0 to it) and reports page_age() = max(age x amount, age_floor) while the look has the overlay
  (0 for d4 / d1 / off); CityView and PrintStage hand LookOverlay.page_age_of(_overlays) to
  LightLayer.set_page_age; grade_ink warms neutral pixels by look_d5's mock-median gains before the grade.
  The rect draws when grade != identity OR age > 0.004. Unit 241 (+4, test_page_age.gd). Lint 13/13.
  On this branch alone (no look_d5) nothing changes.
- Frames (trial scratch, cherry-picked a84bd39, look_golden before / after = deterministic): 32 / 48 px/m
  and every d1 / d4 frame BYTE-IDENTICAL (0 px); the 5 `-ov` frames change 38-58 %. Measured at 64 px/m:
  cool light px (r > 180, b >= r - 14) 10 911 -> 0 (block), 12 218 -> 0 (junction); cool mid-tones 4 467 -> 0;
  pavement (247,222,194) and street (89,73,69) unchanged (the age moved, not doubled); accent shares
  unchanged. LOOKED: bodies now share the paper's warmth; night + age: vermilion cops / collar hold.
  (The city_selftest frames differ 0.4 % - same code run twice differs as much: not frame-locked; the
  goldens are.) 48-trial14/{before,after}/, crop64-*.png, cmp-night64.png; ladder row 48 (1280 x 24486).
- Cost (pass_cost.gd --ppm=64, iGPU 1280x800, 2 interleaved pairs, age files reverted / HEAD): frame
  6.58 -> 7.12, 6.70 -> 7.17 ms; the light canvas' share 0.09 / -0.10 -> 0.59 / 0.55 ms => the page age
  pass is ~+0.5 ms at arena zoom only, 0 at gameplay zoom. evidence/page-age-cost/. Docs: both READMEs
  (ce0db12).
- Merged build (scratch + a84bd39): lint 13/13 over 323 files, unit 309/309, scenarios 8/8 (replay_60s
  identical). n-noir's city_view hunk lands after my zoom-anchored world_px and reads that member:
  consistent. merge-tree after my decisions.md line (06:12): still JOURNAL.md-only conflicts vs n-d4 / n-d5 /
  n-noir, main clean.
- Known limit (README): lights, the 5 emissive FX kinds (all `paper`) and markers draw above the
  grade rect, so they are not aged (a paper flash prints D4 cream on the aged page at 64 px/m).
- Quest 1 patch v2 (49-quest1-v2/quest1-on-print_stage-v2.patch, 78 lines, applies on the merged tree and on
  main): the 45-quest1 PrintStage move + every zone floor on Ink.WASH at 30 % (Factory Row 0.12, Toner Room
  0.22 - only 0.06 inside the first wash edge, it would mottle - and Dock 9 0.08 -> 0.30 = density ~0.33,
  the first wash). NOT wired: print_stage.listen() - quest 1 steps its own stage.tick with no SimClock, so
  the rig / hit-stop need World's clock (after the merge).
- Bench on the merged build (scratch, exported release, 06:12-06:25; CONTENDED: another lane's MovieWriter
  capture + 5 other Godot processes): PASS section 20 - p99 2.47 ms, 1% low 214 fps, worst swap 32.5 ms,
  worst frame 46.4 ms, 0 frames > 50 ms; riot rigs p99 0.439 ms per frame. All 4 lanes' art + n-noir's
  shadows + n-d5's tier in: within the branch's run-to-run range (2.55-2.81). evidence/trial-merge14/.
  (First attempt: export failed, build/export/windows-bench missing in a fresh worktree - mkdir, re-run.)
- Quest 1 frames, patch v2 on the merged tree (49-quest1-v2/, 9 shots, before = own view): LOOKED at 4 -
  all three floors print as the first wash and read (Dock 9's edge clear); accents and the HUD hold. Trade:
  the Toner Room is no longer darker than Factory Row. Ladder row 49.
- FOUND + FIXED (patch v3): v2 broke n-noir's dev/noir/quest_fight.gd (it builds a CollectCallView and
  adds its blood / flash / stains in Ink px): the noir pass stacked on the D4 print (busy double hatch) and
  the blood left its place (noir-fight/cmp-f300.png). v3: CollectCallView.printed (default true; false =
  the raw view under its own Camera2D) + 1 line in quest_fight (`_view.printed = false`). Noir frames
  before vs v3: same frame, blood in place (0.08-0.34 % px > 8 spread thin); printed frames v2 vs v3 <= 26 px.
  Merged + v3: lint 13/13, unit 309, scenarios 8. v3 = 49-quest1-v2/quest1-on-print_stage-v3.patch
  (apply AFTER n-noir; README.txt there). Frames rejected for camera: 0 (engine captures).
- Evidence at b0f98ab (06:31-06:33, --no-bench, all PASS): lint 13/13, unit 241, scenarios 8, parity bit-exact
  + mutation caught, selftest PASS (11/11 + 5/5 goldens worst 0.00, accents clean, world lock 0.00 % x3).
  Copied to evidence/pof.
- OWNER OPTION (rendered, NOT shipped): n-d5's `age_floor` 1 (aged paper below the D5 zoom), which page age
  now applies to the WHOLE page (before a84bd39 it would have left every body cool on sepia paper).
  Merged tree, city_selftest auto, block 32 / 48 px/m: pavement (235,225,207) -> (249,224,196) (mock
  243,218,188), street (86,76,77) -> (89,74,69) (mock 81,71,72: a touch too red). LOOKED: reads like the
  mock's sepia, bodies warm with it. Cost at 48 px/m (iGPU 1280x800, 2 interleaved pairs, pass_cost):
  frame 3.01 / 2.93 -> 3.33 / 3.50 ms (the grade rect now draws at gameplay zoom).
  evidence/age-floor-cost/, 50-age-floor/ab-32-shipped-agefloor-mock.png, ladder 50. vs iteration 11's
  zero-cost option (paper hex #F0E1C6): that warms only the paper token; age_floor warms every neutral
  incl. the street and the rigs' print_part cream. One number in n-d5's look_d5.params.json either way.
  Note: n-d5's `grain_floor` can NOT work in this engine yet - LookOverlay hides the overlay at amount 0,
  so a floor below the ramp needs the whole overlay drawn at gameplay zoom (~+2 ms iGPU, iteration 9).
