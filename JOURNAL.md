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
- REQUEST 1 -> d5-city: when palette.json gains `blood` / `cop_blue`, CombatBlood should read `blood` instead of
  blood_fx.json colour.blood (0.64, 0.02, 0.035; noir's protected arterial red). I will switch it once the token lands.
- REQUEST 2 -> owner of lights.json (n-visual heirs / d5-city): brief item 5 wants the muzzle starburst to "light the
  scene for one frame"; lights.json `muzzle_flash` is a 1.6 m cone for 4 ticks. Proposal: a second, 1-tick, ~5 m
  radial `muzzle_pop` light (paper, intensity ~0.5) spending FlashBudget.spend_light; fx.json muzzle would name it.
- REQUEST 3 -> owner of camera.json: kill hit-stop is 6 ticks; noir tuned 8 (look_noir.params impact.hit_stop_ticks).
  With the kill beat on, 8 lets the silhouette hold one more beat. Only if the owner picks a beat mode.
- NOTE: bench/run.mjs does not create build/export/windows-bench in a fresh worktree (export fails: "export path
  doesn't exist"); I created the folder by hand. Worth a mkdir in run.mjs (tools owner).
- BENCH (release export windows-bench, CONTENDED, 11:00-11:07, lock held + released): run.mjs was killed at the
  harness's 10-min background limit during the 4th scenario (drive48vsync), so the JUDGE never ran; results from
  build/bench/*.json (copied to evidence/d5-combat/bench/): riot p50 0.77 / p99 4.86 ms, 1% low 165 fps (400 actors);
  drive p99 6.79 ms (under the 7 ms hard limit, over the 5 ms target), one 1.4 s max frame; drive48 p99 6.27 ms.
  NOTE: city_bench sets fx_feed = null, so its riot has no death cues: the bench proves the blood node does not
  regress the base; the blood's cost under deaths is city_fight's 0.22-0.35 ms/frame average (debug, CONTENDED).
  Killed my orphaned RTAI-bench.exe by PID after the timeout.
- Timing-true kill-beat clips (--fixed-fps 60) at 64 px/m: masters beat-both-64ppm-realtime.mp4, beat-flash-...mp4.

NEXT (iteration 2):
1. Item 5 hit feel, in my files: blood on a human hit that is NOT a kill (quest 1 boss has hp > 1: CombatArena
   damage -> listen to a hurt signal if one exists, else a `player_hit`-like cue for hostiles); spurt + body stain
   (port BloodStains onto CombatBlood with the events locate). Then REQUEST 2/3 (muzzle pop light, kill hit-stop 8).
2. Re-run the bench in the FOREGROUND with a 20-min timeout split per scenario (or run.mjs flags), so the judge runs.
   Add a riot variant with the fx feed ON to measure blood under deaths in a release build.
3. Blood colour from palette `blood` once d5-city lands it (REQUEST 1).
4. Stains on bodies in the city (dead sim bodies are static: draw BloodStains above the rigs, keyed by sim slot).
5. Orphan pools: the sim despawns bodies; consider fading pools faster once their body is gone (render-side).
- NEXT item 1 re-scoped: quest 1 humans have 1 hp (tuning.human.hp), so every human hit is a kill and already bleeds;
  "blood on a non-lethal human hit" has no trigger in today's game. It becomes real when a human gets hp > 1 (a boss
  phase); the hook is Fighter.hurt_tick (render-side read in CollectCallView) -> blood.splash(..., "player_hit").
- FINDING + FIX aa1661d: evidence/run.mjs selftest FAILED at 6fee0e8: the junction look goldens (a riot with deaths)
  now carry blood (d4@48/64, auto@56/64 over the 2 % far cap). Re-blessed the junction (11), check run bit-identical;
  decision line in docs/decisions.md. Block site untouched (5/5).
- GATES at aa1661d (evidence/run.mjs --no-bench): lint 13/13, unit 338/0, scenarios 8/8, parity exact (1200 steps,
  mutation caught), selftest PASS. Bench: partial (see above), judge not run.

NEXT (iteration 2), in order:
1. Bench in the foreground under the lock with a long timeout so run.mjs judges it; add a riot-with-deaths variant.
2. Item 5 hit feel: REQUEST 2/3 (muzzle pop light, kill hit-stop 8) or, if no owner answers, a fx.json-only muzzle
   tweak; body stains on dead sim bodies (BloodStains above the rigs, keyed by sim slot).
3. Palette `blood` token (REQUEST 1) when d5-city lands it; re-bless the junction goldens afterwards (they will move).
4. Owner sync: pick --blood default (noir proposed) and --kill-beat (off / panel / flash / both).

## Iteration 2 (11:16-12:46)

- 11:16 bench.lock held by `vehicles` (fresh): bench skipped at start, retry later.
- FINDING: d-city (e9b9323) landed palette tokens blood #A30509 (= blood_fx.json colour.blood, same value),
  blood_dark #540005 (noir shader BLOOD_DARK 0.33; blood_fx.json's pool body is 0.46, #750008), cop_blue, cop_blue_hi.
  CombatBlood now reads palette `blood` when the token exists (else blood_fx.json): zero visual change today, follows
  the doctrine after the merge. blood_dark NOT adopted (it would darken every pool body and move the junction goldens
  at merge time): REQUEST 4 -> d5-city: blood_dark #540005 vs the pool body #750008; I keep #750008 unless you want
  the doctrine value, then I switch and re-bless.
- MILESTONE 13c4f9d: CorpseStains: blood soaked into the city's dead (brief item 1 "stains on bodies", noir's
  BloodStains made riot-cheap: one cached node per body, drawn once; transform follows the sliding body, scale grows
  the soak; leaves with the body at the 8 s despawn / slot reuse). city_fight seed 91: 7/7 deaths soaked, 0 missed,
  run bit-deterministic (before/after logs identical). Frames: masters frames/stains-t480-{32,48,64}ppm-pair.png +
  stains-t480-64ppm-crop.png (before = --no-stains, same run). Camera breaks: 0.
- FRICTION: a `body_stains` band between actors (100) and vehicles (200) breaks test_render_layers (bands in the
  actors canvas must be BAND_SPAN 100 apart, rig parts use the z range). Stains sit on the actors band, each body
  node z +60 relative (rig parts stay under +30). No shared-file change.
- MILESTONE 3464242: MuzzlePop (brief item 5 "a muzzle starburst that lights the scene for one frame", my REQUEST 2
  done in my own files instead of lights.json): stepped 3-band ADD paper pool, 5 m, 1 sim tick, round nearest the
  focus within 12 m, <= 1 per 20 ticks AND spend_light on the kill beat's FlashBudget (~1 lit tick a second in the
  riot; tested), none under reduced motion. FRICTION: first cut picked the first shot of a tick anywhere in the riot:
  the pops landed off-screen (diff of before/after = 0 soft-lift pixels); fixed with the focus gate. FRICTION: an
  --at=<tick> still misses a 1-tick pop (the clock steps once after time_scale 0): new dev capture
  city_fight --pop-shots=<k> (freeze at the k-th pop, shoot on then off, same moment). First version was a smooth
  gradient: looked like airbrush haze next to the stepped D4 lights -> 3 hard bands (kept). Frames: masters
  frames/pop-after|before-{32,48,64}ppm.png, pop-3-64ppm-crop.png. Camera breaks: 0.
- FINDING: the evidence run at 13c4f9d FAILED selftest (junction d4@48/64, auto@56/64) only because it ran while I
  was writing MuzzlePop: city_blood.gd referenced the not-yet-imported class, the glue failed to compile, the riot
  drew no blood (the exact inverse of the aa1661d re-bless). Re-run at 3464242 on a clean tree: selftest PASS, look
  goldens 11/11 (worst 0.40), block 5/5 (worst 0.93), no re-bless needed (stains/pop move < the tolerance).
  LESSON: never edit the tree while evidence/run.mjs runs.
- 11:37 bench.lock taken (d5-combat); bench run.mjs --secs=30 --runs=2 in the background.
