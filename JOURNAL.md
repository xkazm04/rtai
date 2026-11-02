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

NEXT (iteration 3 / morning):
1. FIRST: bench on an idle machine (no other lane benching), A/B `ad2078b` vs `n-visual` HEAD, 3 runs.
   If the 20-item chunk split costs, merge ground+decals and props+roofs (12 items) per the DEVIATION.
2. Rig p99 (0.56 ms tick frames vs 0.3 target): profile CutRig.drive vs _assign/RigInput; candidate:
   quarter-rate for ranks >= 10 (characters scope: coordinate with its owner).
3. Wire gameplay: positional events (shot_fired, bullet_hit, exploded at a world pos) -> FxSystem +
   LightLayer + CameraRig.kick; vehicle_entered/exited -> rig.set_mode(car/on_foot). Needs events.json
   (shared file, owner OK).
4. D5 params from the d5-close lane into look_profiles.json `d5`, then re-bless the goldens with
   before/after frames; the riso D1 pass if the owner still wants D1 as a live profile.
5. Accent audit: split `actors` into cops / peds / Rivet (hide rigs by kind) so a vermilion ped shows up;
   make it gating once the traffic light is redrawn.
6. Lights GPU cost on an idle GPU + the Deck; the night grade needs the owner's eye (frames 04b).
7. FX sheet from d4-production -> replace the analytic shapes (texture + frames per kind).
