# JOURNAL - lane d5-combat (day run 2026-11-03)

Branch `d-combat`, cut from merged main 089400e. Masters/evidence: `C:\Users\kazda\kiro\gtai-masters\day-d5\d5-combat\`.

## Iteration 1 (10:06-11:36)

- 10:06 read brief, AGENTS, fx code. Finding: noir's blood (features/fx/noir) was wired ONLY in dev scenes
  (showcase_fight, quest_fight, blood_clip); the real city fired `death` -> fx.json `ink_splat` only.
- FINDING: the D4 world print (look_d4) maps any red (r - max(g,b) > 0.12) to its VERMILION plate, so blood cannot
  draw under the print: it goes on the actors canvas (new band `blood`, z -100) with its own print shader.
- MILESTONE e42ab84: CombatBlood (features/fx/combat_blood.gd) + boot/city_blood.gd glue. Real city riot (city_fight.tscn,
  seed 91, 40 rioters + 8 cops): 16 sim deaths -> 16 blood kills, 15/16 sprays aimed along the killing round.
  `-- --blood=noir|ink|both`, default noir; ink = the old D4 splat (fallback).
- FRICTION/PERF: noir's BloodFx drew each splat with ~11 draw_circle: **61.5 ms per redraw at 400 decals** in the riot.
  Fixed: splats -> one MultiMesh written once on landing (shader fade), pools -> cached fans via
  canvas_item_add_triangle_array (draw_colored_polygon re-triangulated: ~100 us/ring), drops -> width-bucketed
  draw_multiline (7.6 ms -> 0.13 ms for 279 drops). Riot average **0.35 ms/frame** over 1214 frames (debug, CONTENDED).
- SHARED FILE CHANGES (minimal): `boot/launch_args.gd` +`--blood`, +`--kill-beat`; `data/tables/render_layers.json`
  +band `blood` (actors, z -100); `data/schemas/render_layers.schema.json` z minimum 0 -> -4000;
  `core/render/fx_triggers.gd` +signal `cued` (emitted per fire); `core/render/README.md` band line.
- FLAKE: test_noir_shadows `test_only_shadow_commands_with_a_length_are_swept` failed once ("Parameter t is null"),
  green on rerun; not touched by this lane.
- Gates at e42ab84: lint 13/13, unit 331/0, scenarios 8/0 (replay_60s final cbeb734ff9b97c41 unchanged).
- MILESTONE 150cc72: quest 1 bleeds: CombatBlood.listen(Events, locate, rivet id) on CollectCallView's PrintStage path
  (CollectCallStage gains read-only events()). Frames: quest1 04-dock-wave / 06-crates-burning (blood under dead guards).
- MILESTONE 97bef5f: Rivet's oil reads on asphalt: cream rim on oil splats (fluids.oil.halo 0.16), bigger robot_hit drops,
  OilLeak trail after each hit. Before frame rendered from a temp worktree at 150cc72 (removed after).
- MILESTONE f003d55: kill beat A/B `--kill-beat=off|panel|flash|both` (default off), noir ImpactFrame on a new declared
  `beat` canvas (layer 6, under the HUD), shared FlashBudget, calm under --reduced-motion. Shared: render_layers.json
  +canvas `beat` +band `kill_beat`.
- 8bbbe11: city_fight --clip (with --fixed-fps 60 = one tick per frame, real-time clip).
- FLAKE (CONTENDED): scenario_city_chase once failed the 2 ms nav budget (2696 us), green on rerun (283 us).
- EVIDENCE: masters `C:\Users\kazda\kiro\gtai-masters\day-d5\d5-combat\` frames.json (13 entries), ladder.png,
  clip-blood-noir-48ppm.mp4 / -64ppm.mp4 (15 s each), raw/ (all frames). Repo: evidence/d5-combat/ (ladder, contacts,
  frames.json, logs). Camera breaks rejected: 0 (every frame straight down).
- CAVEAT: the --beat-frames captures run without --fixed-fps: PNG saves slow the frames, several ticks pass per frame,
  so the beat sequence in those stills is compressed (re-shoot with --fixed-fps 60 for a timing-true beat clip).
