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
  camera (engine camera, straight down). Art note for d4-production: smoke cells read cream/paper, not the
  charcoal the doc wants ("smoke: charcoal puffs") - a darker smoke row would read better on the cream crossings.
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
6. d4-production asks: traffic_light.png lamps (vermilion in the world); a charcoal smoke row (smoke cells read
   cream); optionally a vermilion-free tracer (it is emissive and fine as is).
7. Lights on the Deck: cap fires at 8-16 or a smaller radius if the Deck shows the same fill cost.
- MILESTONE final bench 23:00-23:04 (fd1703f, CPU 7 % / GPU 10 % before): PASSES - p99 3.78 ms, 1% low 155 fps,
  worst swap 32 ms, 0 frames > 50 ms (49 > 25 ms, all vsync/present). Riot rig 0.457 ms per tick, p99 0.501
  (idle HEAD run: 0.474 / 0.511): in the release build the selection decimation is only -2..-4 %; the 0.3 ms
  target is NOT met. evidence/bench-*-final.json, evidence/bench-final-iter4.txt.
