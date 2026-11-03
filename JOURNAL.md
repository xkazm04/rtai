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
- BENCH (release export windows-bench, CONTENDED, 11:37-11:40, lock held + released): run.mjs --secs=30 --runs=2
  finished and JUDGED: **MISSES p99CpuMs**: p99 7.676 ms (riot), 1% low 78 fps, worst frame 76.5 ms, hitches >25 ms 55,
  >50 ms 1. At 11:06 the same riot was p99 4.86 ms / 165 fps. Attribution: the riot hitches are cause `present`
  (render_gpu 0.09 ms, render_cpu 0.7 ms, draw 26-45 ms waiting on present) = the shared GPU (7 lanes). My new nodes
  measured: CorpseStains 12.9 us a step (debug, city riot, 14 deaths); MuzzlePop = one textured quad on a lit tick.
  CORRECTION of iteration 1: city_bench only drops the FX feed under --fx-feed=off; the bench riot runs the blood.
  Evidence: evidence/d5-combat/bench/iter2/. Owner/Director: re-bench on a quiet machine before trusting the miss.
- MILESTONE 0f08bd1: quest 1's dead guards soak (CorpseStains.step_bodies with CombatArena's dead; 64 nodes: quest
  bodies never despawn, 49 by the payout; the 16-node ring recycled the on-screen guards' stains: first grab showed
  1 dot on 4 bodies, fixed). Grabber: 49 soaked, 0 missed. Before = the same grab with the view file reverted (patch).
  Still: in a pile of bodies a kill may soak a neighbour (nearest dead within 1.5 m).
- Item 5 audit: the electroshock crackle (robo-tazer on Rivet -> crackle + sparks + his oil) already fires
  (iteration 1); Rivet's real kills are `shot` (CombatArena), so a melee crackle has no trigger in the real game.
  Hit-stop length (camera.json) and knockback (sim) are not my files: REQUEST 3 stands.
- CLIP: masters clip-it2-stains-pop-{48,64}ppm.mp4 (15 s, --fixed-fps 60, every 2nd frame), strip
  frames/clip-it2-64-strip.png. 15 deaths, 13 soaked, 2 missed. VISIBLE GAP: orphan pools (bodies despawn at 8 s,
  pools stay minutes) - next item.
- MILESTONE 082e0d3: quest 1 soaks by victim id (CombatBlood.bled_body -> CorpseStains.on_bled_body): no nearest-body
  guess in a pile. Visible frame unchanged (each guard already had its own soak); one top guard's sprite seems drawn
  offset from its sim pos, so its stains sit on the body under it (cast_view, not my file).
- e9f1fa1: city_fight --pop-strength; owner A/B sheet frames/pop-strength-ab-64ppm.png (off / 0.20 / 0.32 / 0.45):
  at 0.45 the ink lifts to grey; 0.32 kept.
- 971a118: stain.corpse v2 (11 spots, r 1.2-3.0, spread 7): at the 128 px/m kill-cam the v1 soak printed as a grape
  cluster; v2 is ragged. FRICTION: a run with --zooms=2,4 gives the 128 frame cream rims a --zooms=4 run does not
  (the look/LOD state depends on the zoom history): compare only runs with identical --zooms.
- Disk: deleted my 1.3 GB clip PNG scratch after encoding (masters clipraw2).

NEXT (iteration 3), in order:
1. Owner sync picks: --blood (noir proposed), --kill-beat (off/panel/flash/both), muzzle pop strength (0.32 or off).
2. Re-bench on a quiet machine (the iter2 p99 miss is attributed to present waits, CONTENDED; prove it with a
   riot-only rerun when the lock is free and few lanes render).
3. After d5-city merges: palette `blood` is read already; REQUEST 4 (blood_dark #540005 vs pool body #750008).
4. Orphan pools: the sim despawns the dead at 8 s, pools stay minutes (per noir's persist-and-fade); if the owner
   finds bodiless pools odd, fade a pool faster once its body leaves the feed (render side, CorpseStains knows).
5. Stains draw above Rivet when he stands on a corpse (z +60 above the actors band); clip them under Rivet's rig
   (Rivet's node z above the soaks) if it shows in play.
6. REQUEST 3 (kill hit-stop 8 for the beat) and knockback held a beat: camera.json / sim owners.
- GATES at 971a118 (evidence/run.mjs --no-bench, 12:1x): lint 13/13, unit 347/0, scenarios 8/8, parity exact (1200 steps,
  mutation caught), selftest PASS (look goldens 11/11, block 5/5). Bench: judged at 11:40, MISS p99 (CONTENDED, above).
- EVIDENCE gap closed: kill beat real-time at 48 px/m (brief item 4 wanted 48 and 64): masters beat-{flash,panel,both}-48ppm-realtime.mp4 + frames/beat-modes-48ppm-realtime-strip.png (--fixed-fps 60, --beat-frames=60). 12:06 bench.lock held by vehicles (12 min): repeat bench skipped.
- BENCH repeat (12:10-12:14, lock held + released, CONTENDED), code 9892177 (= 971a118 + docs): riot p99 15.175 ms,
  1% low 34 fps, hitches >25 ms 136 (riot 38, all `present` but 1 unexplained). MISSES p99CpuMs, low1Fps,
  over50.unexplained. Same riot p99 across today: 4.86 (11:06) -> 7.68 (11:40) -> 15.18 (12:14) with no
  hot-path change between the last two (stain tuning data only): the swing is the shared GPU, not the FX. The
  bench is NOT a valid judge on this machine today; re-bench at the 18:00 sync on an idle machine.
  Evidence: evidence/d5-combat/bench/iter2b/.

NEXT (iteration 3): the NEXT list above stands (owner picks; quiet-machine bench; REQUEST 4 blood_dark; orphan
pools; stains over Rivet; REQUEST 3). Session stopped 12:16 with a clean tree at the commit after 2b8145a; all gates
green at 971a118.

## Iteration 3 (12:16-13:46)

- 12:16 read JOURNAL, git log. NEXT list: owner picks (owner away), quiet bench (machine contended), REQUEST 4,
  orphan pools, stains over Rivet, REQUEST 3. Started with the stains-over-Rivet bug (my files only).
- MILESTONE 6370b54: a corpse's soak fades while Rivet stands on the body (CorpseStains.walkers: Rivet from the rig
  feed in the city, arena.rivet in quest 1; smoothstep 0.4-0.9 m). Before: red stain dots printed on Rivet's chassis
  (robots never bleed). New dev switch city_fight --dev=rivet-on-dead[,no-walker-fade] (A/B, same seed 91 run, t480).
  Frames: masters frames/walker-fade-t480-{32,48,64}ppm-pair.png (raw/walker/). Camera breaks: 0 of 6.
  Unit 348/0, lint 13/13. Stains step 34-38 us (debug, CONTENDED; it was 12.9 us at iter 2 on a quieter machine,
  the change adds one Rivet compare per soak).
- FINDING: no shipped path emits Events.actor_killed / player_hit in the city (only quest 1's bot-driven CombatArena
  and dev scenes), and quest 1 has no player entry yet: the real city's combat FX are the sim cues (shot,
  projectile_end, death). Quest 1 has no hit-stop at all (FxTriggers lives in the city view only). Rigs step on
  TICK_DT, so a SimClock.hold does hold the pose. Humans have 1 hp and the tazer chain only hops metal: "blood on a
  non-lethal human hit" still has no trigger today.
- 12:24 bench.lock held by `collisions` (12:17, fresh): bench skipped, retry later.
- MILESTONE 9671d9e: pools print as liquid at the kill-cam: BloodMarks.ring 28 -> 56 points + a 13th-harmonic
  wet-edge scallop + a broad rounded run lobe ((0.5+0.5 cos)^2; the cos^2 lobe ran to a point). Before at 128 px/m:
  straight chords, cut-paper capes. Cost: settled pools redraw every 6 ticks (was 4; growth 0.04 px/tick): city_fight
  seed 91 -> t900, back to back: 28 pts/4 ticks 369 us/frame, 56 pts/4 ticks ~420, 56 pts/6 ticks 293-294 (debug,
  CONTENDED; an earlier 28-pt run read 270: the machine drifts ~100 us run to run). Frames (same run, identical
  --zooms 1,1.5,2,4): masters frames/pool-edge-t900-{32,48,64,128}ppm-pair.png (changed px 5.7k/10.8k/19k/27k).
  Camera breaks: 0 of 8. frames.json: walker + pool pairs replace stains-48 and pop-48 (kept at 15); ladder +2 rows.
- GATES at ff5d3da (evidence/run.mjs --no-bench, 12:30): lint 13/13, unit 348/0, scenarios 8/8, parity exact (1200
  steps, mutation caught at 629), selftest PASS (look goldens 11/11 worst 0.44, block 5/5 worst 0.96): the liquid pool
  ring and the walker fade stay inside the golden tolerance, no re-bless.
- BENCH iter3 (12:32-12:36, lock taken + released, CONTENDED), code ff5d3da: release export, 2 runs x 4 x 30 s.
  Riot (400 actors, blood on): avg 2.26 ms, p99 9.87 ms, 1% low 45 fps, hitches >25 ms 58 ALL `present` (render_gpu
  0.17 ms, game 0.01 ms), >50 ms 0. Overall JUDGE: MISSES p99CpuMs + over50.unexplained (the 2 unexplained >50 ms
  are in the drive scenarios, not the riot). Riot p99 across today: 4.86 / 7.68 / 15.18 / 9.87 ms: the shared GPU.
  Evidence: evidence/d5-combat/bench/iter3/.
- MILESTONE (next commit): pool body = doctrine blood_dark #540005 (answers d5-city's REQUEST 2/4 and closes my
  REQUEST 4): blood_fx.json colour.blood_dark 0.46,0,0.03 -> 0.329,0,0.02 (hard-coded until the tokens merge),
  CombatBlood also reads palette `blood_dark` (BloodFx.set_dark) when the token exists: same value, zero change at the
  merge. Corpse stains' dark spots follow (same json). Frames: masters frames/pool-dark-t900-{32,48,64,128}ppm-pair.png
  (same run, same --zooms). At 128 the bright meniscus rim over a dark body reads deeper and wetter; at 32 the pools
  still read red on asphalt. Camera breaks: 0 of 8.
- GATES at 1a7174f (evidence/run.mjs --no-bench, 12:38): lint 13/13, unit 348/0, scenarios 8/8, parity exact,
  selftest PASS (look goldens 11/11 worst 0.49, block 5/5 worst 0.94): the darker pool body needs no re-bless.
- CLIP: masters clip-it3-pools-{48,64}ppm.mp4 (seed 91, ticks 300-1200, --fixed-fps 60, every 2nd frame = 15 s real
  time); strip frames/clip-it3-64-strip.png (+ repo evidence/d5-combat/). 16 deaths, 15 aimed, 14 soaked, 2 missed.
  Camera breaks: 0. Deleted the 1.3 GB PNG scratch after encoding. frames.json (15): the t900 48/64 hero frames now
  show iteration 3 (before = iteration 1), 128 kill-cam frame added, clip-it3 replaces clip-it2 (as its before).
- EVIDENCE gap closed (brief item 1 "wall splats" had no real-game frame): city_fight summary prints walls=<n>
  (BloodFx.wall_hits). Seed 91 to t900: focus 0 walls=2, focus 1 walls=19, focus 2 walls=0. Frame: masters
  frames/wall-splat-f1-t900-32ppm-crop.png (focus 1; the spray stops at the roof edge and piles along the wall base,
  never crosses onto the roof). Camera breaks: 0 of 3. frames.json: the wall entry replaces the beat-flash 64 clip
  (still in masters).
- REGRESSION caught + fixed (my own, 1a7174f): blood_fx.json colour.blood_dark is ALSO noir's pool body; at #540005
  the noir pass's blood gate printed the body black under --look=noir (only the rim red, sheen gone). Seen in
  dev/noir/showcase_fight at 64 px/m f322 (noir's own scene: the city_fight dev scene rejects --look). Fix: colour.blood_dark
  back to #750008 (noir unchanged: its f322 frame is pixel-identical to the pre-change one); the D4/D5 body moves to
  blood_fx.json game.pool_dark #540005, applied by CombatBlood only when NOT NoirLook.requested() (palette blood_dark
  wins once it lands); CorpseStains takes the blood's body (BloodFx.dark()) so D4/D5 stains follow it. City riot
  t900: pools identical to 1a7174f at 128, stains identical by eye at 32-64 (5k px of freeze-tick jitter).
  Evidence: frames/noir-pool-dark-check.png (old | 1a7174f | fix). LESSON: a shared fx table value has a noir
  reader; check --look=noir after any blood_fx.json colour change.
- GATES at 030eb10 (evidence/run.mjs --no-bench, 13:01): lint 13/13, unit 350/0, scenarios 8/8, parity exact,
  selftest PASS (goldens 11/11 worst 0.49, block 5/5 worst 0.94). e73ee34: decision line (fx pool body).
- Quest 1 check at e73ee34 (collect_call_frames, 1920x1080): 9 frames, no script errors, stains soaked 48 missed 0;
  the dock-wave pools under the dead guards carry the blood_dark body. masters raw/q1-it3/.

NEXT (iteration 4), in order:
1. Owner sync picks (18:00): --blood (noir proposed), --kill-beat (off/panel/flash/both), muzzle pop 0.32 or off,
   pool body blood_dark (frames/pool-dark-t900-*-pair.png) vs the brighter #750008.
2. Re-bench on a quiet machine: riot p99 today 4.86 / 7.68 / 15.18 / 9.87 ms with every riot hitch `present`
   (GPU shared by 7 lanes); the blood's CPU cost is ~0.2-0.4 ms/frame debug (city_fight avg_us_per_frame).
3. After the d5-city merge: palette blood + blood_dark are read already (CombatBlood); check the junction goldens
   once (expected unchanged: same values) and that the token blood_dark never reaches the noir path.
4. Orphan pools (bodies despawn at 8 s, pools stay): owner's read; a render-side faster fade once the body leaves
   is ready to build in CorpseStains/BloodFx if wanted.
5. REQUEST 3 (kill hit-stop 8 under a beat mode) stands; quest 1 has no hit-stop at all (no FxTriggers in
   CollectCallView): wire one when quest 1 gets a player entry.
