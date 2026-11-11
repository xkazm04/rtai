# n16 tools lane JOURNAL (day run 2026-11-11, branch n16-tools, cut from main 5843f5a28)

## Session 1 (iteration 1, BUILD) 11:00-12:30

- 11:00 read: brief, common rules, n15 tools REPORT (Calls, Not done, Next steps), tools/README.md, film kit
  (film.mjs, shots.mjs, sheet.mjs), kill_lab.gd, brutality_hook.gd, gunplay_hook.gd, signature_kills.json.
  Sibling journals (n16-kills-new, n16-kills-polish): none yet at 11:15, so no REQUEST tools: lines to serve.
- DECISION tools/kill-reel-on-the-lab: the kill reel films the KillLab on the city block (`--arena=city
  --sig-lab --sig-gun=<id> --sig-solo=start`), not the `weapon:` lone-kill shot: the lab arms every gun AND
  every blade (katana, plasma sword, chainsaw), stands one guard 3 m from Rivet, and its trigger tick is
  fixed (KillLab.FIRST_SHOT 60), so one stills window catches the anticipation for every weapon. Rejected:
  the `weapon:` shot (guns only, the pit picks where the victim stands, so no directions).
  Two dev-only game lines make directions and kinds possible: `--sig-dir=<deg>` turns the solo line about
  Rivet (KillLab.turn_deg; 0 east, 90 south), and the lab honours `--victim=<kind>` (GunplayHook.victim, so
  film's "lone victim" check holds). Neither touches the sim of a non-lab run (dev args under --sig-lab).
- 11:05 PROOF (one film): `node tools/film/film.mjs kill:rocket_launcher --out=build/film/kr_try --ppm=32
  --on=kill:1+4 --stills=60 --victim=thug -- --sig-dir=90` -> `fire at 61; kill at 63`, PASS, 17 s; t65 shows
  the gib south of Rivet (screen down).
- 11:06-11:21 PROOF (first reel): `node tools/film/kill_reel.mjs --out=build/kreel/t1 --weapons=katana,rocket_launcher
  --victims=thug --dirs=0,90 --clips` -> 8 films PASS (kill at 68 for both at dir 0, rocket at 63 at dir 90),
  sheets `katana_{32,64}.png`, `rocket_launcher_{32,64}.png`, 8 clips, reel.json. Looked at the sheets: dir 0 reads
  (trigger 60, katana slash 68-70, the split and the blood trail to 218; the rocket burst 68-88, smoke, scorch).
  DEFECT found by looking: the dir-90 rows were cropped off the kill (bottom-right of the view): the probe has no
  screen point for the turned guard (`draw -1`, screen 9010,8368), so the crop centre was garbage. Fix: the
  victim is placed from the sim (Rivet's screen point + metres x ppm), test pinned on the 9010,8368 row.
  Also: each film ~80 s (blade) to ~150 s (rocket), mostly saving ~170 PNGs; later zooms now reuse the first
  zoom's kill tick and save the 12 beat frames only (a kill on another tick at another zoom = unverifiable).
  Known: at dir 0 the guard stands into a knot of city cops east of Rivet's start; the rocket takes them too.
  Dirs 90/180/270 film the guard alone (the cops stand east).
- 11:25 item 2 started: `CAR_DEAD_END_TILES` 1 -> 65 in tools/gen_constants/sim_constants.json (doc shortened to fit
  the 100-char line), `node tools/gen_constants/gen.mjs` -> sim_constants.gd + sim_constants.h. Native rebuild waits
  until my film Godot exits (it holds the DLL).
- 11:28 DEFECT found by looking (t2 t60 at 64 px/m): with `--victim=thug` the lab guard STANDS as the riot cop (the
  combo zoom draws whole-figure walker cards, which ignore StreetCrowdCards.victim) while its gib pieces follow the
  row. film.mjs's victim check reads only the log line, so it passed. Not fixed this session; the reel prints a
  WARNING whenever --victims is given. NEXT: the probe reports each fighter's drawn card row, film checks that.
  Finding for the kill lanes (t2 katana_32.png): at 32 px/m the katana split turned south reads as a red blot,
  no halves visible; turned west (t3) the halves read.
- 11:29 debt-ratchet refused kill_lab.gd growing 213 -> 219: the turn moved to `KillLabTurn` (14 lines,
  first-author unit test `test_kill_lab_turn.gd` 2/2), kill_lab.gd untouched. Re-proved: `kill_reel.mjs
  --out=build/kreel/t3 --weapons=katana --dirs=180 --ppm=32` PASS kill at 68, 54 s; the sheet shows the cut west.
- MILESTONE 11:31 afe581336 the kill reel v1 (lint 19/19 in the hook), bd5b63ce4 `all` reads the filmed tree.
- SERVED: kill lanes, the kill reel. From YOUR worktree (cwd = your tree, so `all` includes your new rows):
  `node C:/Users/kazda/kiro/gtai-wt/n16-tools/tools/film/kill_reel.mjs --out=<dir> --weapons=all --dirs=90,270`
  (`--victims=<kind,...>`, `--ppm=32,64` default, `--clips`, `--before=<sha> --rev=<sha>` for a same-tick A/B,
  `-- --gore=reduced`). Sheets `<dir>/<weapon>_<ppm>.png`, rows in `reel.json`. Non-zero `--dirs` and
  `--victims` need the two lab lines: cherry-pick afe581336 (brutality_hook.gd +2 lines, kill_lab_turn.gd new)
  or the film refuses `--sig-dir` (nothing launched). Proven: dry-run from n16-kills-new lists 13 weapons incl.
  pistol, and refuses `--dirs=90` there until the pick.
- Item 3 (`test_quest_blade` under --select): `run_unit.mjs --select=test_kill_lab_turn,test_quest_blade` ->
  test_quest_blade 5/5 pass. The fix (5e41c66bc, `_actions.install()` before with_keys, 00:12) never reached the
  n15-combat branch, whose 04:30 FRICTION ran without it (`git merge-base --is-ancestor 5e41c66bc 4df42554a` ->
  not an ancestor). Nothing left to fix on main.
- Item 4 (merge-clash in quick.mjs): already done in n15 (6d77d2204); seen today: `quick.mjs` prints
  `merge-clash: no new code conflict with n16-kills-new, n16-kills-polish`.
- 11:38 item 2 native: the copied godot-cpp had no object files, so scons began rebuilding all of godot-cpp; stopped
  it, copied int-n15's 2178 godot-cpp .obj + `.sconsign.dblite`, then `scons ... template_debug` and
  `template_release` compiled only the 17 sim sources. **NATIVE REBUILT 11:46-11:47 (debug + release) with
  CAR_DEAD_END_TILES 65.** View lanes: keep your DLLs; the view does not read the routing.
- 11:49 PROOF c-2: `node tools/tests/run_parity.mjs` -> bit for bit over 1200 steps, planted fault caught at 629,
  `final_sha_a/b 94b2865f7f17d778` (unchanged from n15: no re-bless). `run_unit --select=test_sim_car_route,
  test_sim_car_route_break,test_sim_car_route_break_exits,test_sim_car_route_t4` 21/0. `car_route_trails.gd
  --tier=a` -> no car dies, cars equal to n15's `evidence/c2_tier_a/a65.json` (at 1, car 0 died); tier B no deaths.
  Commit 7850111df (+ decisions lines sim/c-2-dead-end-65 and tools/kill-reel).
- 11:52 the drawn-victim check (748aa7332): the probe records each fighter's card row; film judges --victim on the
  row of the first hostile to die. PROOF: `film.mjs kill:rocket_launcher --victim=thug -- --sig-dir=90` ->
  UNVERIFIABLE "the victim (id 1) had no card the tick before it died" (was a false PASS); `film.mjs weapon:pistol
  --victim=thug --on=kill:1` -> PASS on the drawn row. Found: the lab guard has no rig `FilmCard.rig` finds
  (game.cast.rigs.rig_for -> null; draw -1), while the far pit cops (1000, 1001) were drawn as thug. The reel's
  warning says a lab film with --victims comes out UNVERIFIABLE (bc7878960).
- 11:57 GATES started: `node tools/gate/run.mjs --rev=bc7878960 --reels --timeout=40`, log
  `C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s1.log`.
- Evidence: `gtai-masters/n16/tools/frames.json` (9 entries: kill reel sheets, the crop defect before, the victim
  gap still, c-2 tier A after / n15 before / tier B).
- Codex ledger: 0 tasks this session (no finished fix needed testers yet).
- 12:03 c6191736b `kill_reel --gore-check` (goreWhole: the victim still drawn as one lying card 20 ticks after the
  kill under --gore=reduced, else FAIL naming it; no card before = UNVERIFIABLE). Unit 10/10; NOT yet proven on a
  real run (the gate held Godot). First thing next session.
- Hypothesis (not checked): the lab guard has no rig for the probe because LOD 0 is the 16 nearest within 14 m
  (RigSelect) and the knot of pit cops at Rivet's start outranks it, so it draws from the crowd atlas
  (`rig_for` -> null). If so, a signature death of an atlas victim may lose its rig-based look: worth a film with
  the knot cleared (e.g. a dev `--sig-alone` that empties the pit) before telling the kill lanes.

NEXT: (0) prove --subject=kill on a real compare, then build kills-new REQUEST (2) `--victim-wall`. (1) read the gate verdict (`C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s1.log`, snapshot
build/gate/bc7878960400); fix anything red first. (2) prove `kill_reel --gore-check` on a real run (katana +
rocket, dirs 0,90) and record whole/not per death. (3) the lab guard's missing rig: test the LOD-0 hypothesis, then
either clear the pit knot in the lab (`--sig-alone`) or make the probe find atlas-drawn guards, so `--victims`
and the gore check see the victim. (4) beat readout, measured side: hit-stop/held/aftermath from frames (the
first tick the kill window stops changing, and how long marks stay) beside the table values. (5) read the kill
lanes' journals for REQUEST tools / FRICTION (none at 11:35). Gate on the final commit before 19:30.
- 12:08 SERVED (pending a real-run proof): kills-new REQUEST tools (1) (their JOURNAL :149): `--subject=kill` for
  film.mjs and compare.mjs (dfccc7f0d): the first kill's victim, placed from the sim once the signature death
  hides his rig. Unit 2/2 (`tools/film/subject.test.mjs`); film suite 203/0. Run from your worktree:
  `node C:/Users/kazda/kiro/gtai-wt/n16-tools/tools/film/compare.mjs weapon:gloria --a=<sha> --b=<sha> --subject=kill`.
  Their (2) (a weapon shot with a wall ~1 m behind the lone victim, `--victim-wall`) is open: NEXT.
- 12:12 gate on bc7878960 (snapshot `%TEMP%/gtai-gate-bc7878960400`, copied the rebuilt DLLs): lint 19/19,
  unit 2642 tests / 0 failures (2640 passing, 2 skipped); scenarios in progress (11/55 ok at 12:08). The later
  commits (c6191736b gore-check, dfccc7f0d subject=kill) touch tools/ only; their node suites pass (film 203/0) and
  the hook's full lint passed on each. Final verdict: the log named above.
- Lead for kills-new REQUEST (2), NOT tested: the lab already takes `--sig-solo=start:dx,dy`. In
  build/film/kr_try/t65.png (32 px/m, Rivet at screen 646,354) a grey barrier runs about 186 px = 5.8 m south of
  Rivet's start, so `film.mjs kill:gloria --ppm=64 --on=kill:1+60 -- --sig-dir=90 --sig-solo=start:0,2` should
  stand the guard 5 m south with the barrier ~0.8 m behind him along the shot. Needs the afe581336 pick for
  --sig-dir, and a look whether the barrier is a solid wall in the sim (cells) before relying on it.
- 12:12 7ec219f13 the measured side of the beat readout: per film `settled by +N` and `aftermath X %` of the kill
  window (proved on t2/t3 frames: rocket dir 90 6.34 % / 6.36 % at 32 / 64 px/m, settled only by +150; katana dir 90
  1.71 %, by +80; dir 180 2.84 %, by +80). The table side (hit-stop, held, crumble) prints per weapon. Gate:
  scenarios 55/55 ok; parity, look goldens, reels still running.
- 12:16 gate on bc7878960 so far: lint 19/19, unit 2642 / 0 failures, scenarios 55/55, parity final_sha
  94b2865f7f17d778 both sides (snapshot `build/evidence/parity-result.json`), look goldens 12/12 `ok: true`, selftest
  frames ok. Reels still running at 12:16: the verdict is the last lines of
  `C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s1.log` (`gate exit N`). Session 1 ends here.
- 12:18 gate evidence stage on bc7878960 PASS: lint 19/19, unit 2640 passed / 0 failed / 2 skipped, scenarios 55,
  parity bit for bit 1200 steps (planted fault caught at 629), selftest + look goldens 12/12 ok, release-compile
  683/0. Reels still running (verdict at the end of gtai-n16/scratch-tools/gate_s1.log).
- 12:26 reel gate still running at session end (tilt70 chapter 19 electro_chain 4/4 down; no failure so far in
  build/gate/bc7878960400/reels.log). NEXT session: read `gate exit N` at the end of
  C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s1.log before anything else. Godot of mine still running: only
  the gate's reel runner (it frees itself on exit).

## Session 2 (iteration 2, BUILD) 12:31-14:01

- 12:31 read: JOURNAL, git log, sibling journals. The s1 gate (`gate_s1.log`) has NO `gate exit` line: its node died
  with session 1 during the reel stage (reels.log last line 12:26 combo chapter 19 4/4 down, no failure). Evidence
  stage was PASS on bc7878960. The reel gate is re-run on the final commit.
- kills-new is already filming with the reel (`kill_reel.mjs --weapons=pistol --dirs=0,90,225 --clips`, pid 40460).
- FOUND in kills-new JOURNAL :220: "Its `--before=d6a4fb1a8` refuses (native differs)". Cause: `side.mjs`
  resolveSide defaulted `root` to the KIT's repo (n16-tools, whose HEAD has the c-2 native change), so a lane running
  the kit by path had its own commits compared against my native/, and its snapshots would have got MY DLLs.
  Fix beba004e8: `filmedRoot()` = the cwd's game tree, else the kit (film.mjs's default tree too); and since film
  snapshots are keyed by commit and shared by every lane (`%TEMP%/gtai-film-<sha12>`), `copyRuntime` re-copies
  `project/native/bin` when its bytes differ from the caller's donor. Checked the 9 cached snapshots first: all hold
  main's DLL (md5 E80BF89C, = kills-new/kills-polish), none got my c-2 DLL (99329EF1). Tests 2 new, tools suites 445/0.
  PROOF: from n16-kills-new `node ../n16-tools/tools/film/kill_reel.mjs --out=build/kreel/x --weapons=pistol
  --before=d6a4fb1a8 --dry-run` -> `before --rev=d6a4fb1a8 films snapshot d6a4fb1a ...`, 4 films planned (was the
  refusal); from n16-tools `--before=5843f5a28` still refuses (my native differs from main: correct).
- SERVED: kills-new, `--before=<your sha>` on the kill reel now works from your worktree (beba004e8, tools only, no
  pick needed: you run the kit by its path). The before commit needs the lab turn for non-zero dirs (yours from 64be75e2a on).
- 12:40 8cb956f7e kills-polish REQUEST (step_guard timeout test flakes beside a gate, their JOURNAL :114): the
  grandchild's late write came 1 s after the timeout, and the kill itself spawns taskkill (a cold start, seconds under
  load). That window is now `budgetMs(1000, 1)` from the same measured start as the limit (death wait too). Could not
  reproduce on this machine (4/4 pass before and 2/2 after, without loading the box: kill lanes come first); the
  failing assertion in their run was not logged, so this is the likeliest cause, not a proven one.
- 12:55 kills-new REQUEST (2) `--victim-wall`: built as the lab's `--sig-wall[=<gap m>]` (KillLabTurn.wall: the solo
  guard stands gap m short of the first push_out wall along the shot, the direction whose guard is nearest SOLO_OFF's
  3 m) and `kill_reel --dirs=wall`. Unit test_kill_lab_turn 5/5 (3 new, first author).
  FOUND by looking at the first real run (build/film/wall1, Rivet at start): `--sig-wall: dir 85, guard 5.60 m`, the
  kill lands (fire 61, kill 67, blood at the barrier) but NO guard is drawn at his spot at t60 (probe id 1 draw -1,
  row ""). The probe rows at t60: 19 station dummies (ids 1000-1018, hp 1e6) and street cops (3000+) stand around
  Rivet's start, so RigSelect's 16 nearest are all theirs and the lab guard (an arena fighter, no crowd atlas
  fallback on the city) is drawn by NOTHING. That is session 1's "no rig" hypothesis, confirmed. It also explains
  s1's dir-90 crop defect. Fix: the `kill:` shot stands Rivet at `--sig-solo=start:-10,0` (west of the knot). PROOF
  build/film/wall2: `--sig-wall: dir 235, guard 3.95 m, wall 1.00 m behind him` (a parked car), guard drawn (rig, draw
  28x46), t65 the kill throws him back against the car, t95 he lies at it with the blood up the car's side.
  NOTE kill lanes: from this commit on, reel/kill films stand Rivet 10 m west of his start (before AND after sides use
  the same shot, so an A/B stays same-tick); sheets filmed earlier at the start had the victim invisible in some dirs.
- MILESTONE 13:00 bbee28a9c `--sig-wall` + `kill_reel --dirs=wall` + the kill shot at start:-10,0 (full lint 19/19 in
  the hook). Real reel (build/kreel/s2wall, `--weapons=gloria,katana --dirs=90,wall`): gloria dir 90 PASS kill at 64
  (32 + 64 px/m, settled by +20, aftermath 3.5 / 3.4 %), gloria dir wall PASS kill at 65 (2.6 % both zooms).
- SERVED: kills-new REQUEST (2), the wall case. From your worktree, after cherry-picking bbee28a9c's game side
  (project/features/combat/kills/kill_lab_turn.gd + brutality_hook.gd line 67 + test_kill_lab_turn.gd):
  `node C:/Users/kazda/kiro/gtai-wt/n16-tools/tools/film/kill_reel.mjs --out=<dir> --weapons=gloria --dirs=wall,90`
  (or `film.mjs kill:gloria --ppm=64 --on=kill:1+90 -- --sig-wall`; `--sig-wall=1.4` for another gap). The game log
  says `kill_lab: --sig-wall: dir D, guard X m, wall 1.00 m behind him`; on the city block the nearest wall from
  start:-10,0 is a PARKED CAR (dir 235), not a building: Gloria's push_out counts cars as walls.
- 13:05 188ef2658 Codex n16t-break-film-root (gpt-5.6-sol, 1 round, 119 s): 10 adversarial node tests for filmedRoot /
  resolveSide / copyRuntime / plan. Review changed: Codex pinned "a cwd BELOW a game tree films the kit" as the
  promise; that is a weakness (a lane in its project/ dir would film my tree), so filmedRoot now walks the cwd's
  ancestors and the test asserts the lane's tree; kill_reel's after side reads filmedRoot() too. Ledger:
  accepted-after-revision; discarded. Proof: from n16-kills-new/project, `kill_reel --before=d6a4fb1a8 --dry-run` plans.
- 13:08 PROOF `--gore-check` on a real run: `kill_reel.mjs --out=build/kreel/s2gore --weapons=katana,rocket_launcher
  --dirs=90 --ppm=32 --victims=thug --gore-check` -> PASS 2/2, reel.json `whole: true` for both (probe: victim id 1
  row thug, drawn 44x41 at kill, 40x55 at kill+20). Control without --gore=reduced (s2wall katana d90): victim draw -1
  at kill+20, which goreWhole FAILs: the check discriminates. And `--victims=thug` now PASSes the drawn-row check (was
  UNVERIFIABLE in s1: the guard had no rig), so the reel's victim WARNING is gone (README updated).
- 13:15 kills-new REQUEST (3) (their JOURNAL :233): "the reel's lab never kills with --weapons=gatling, nor the pistol
  at --dirs=90". Reproduced: `film.mjs kill:gatling -- --sig-dir=90` -> "fire at no tick". Cause: KillLab held the
  trigger 1 tick per shot and the Gatling's barrels need spin_s (30 ticks) held (Trigger.spin). Fix: `_held_ticks`
  holds a spun gun through its spin-up + 3 rounds (same line count, debt ratchet). PROOF `kill:gatling --sig-dir=90`
  -> fire at 90 93, kill at 95. Unit test_kill_lab_held 2/2 (first author; the old code gives 1 < 36, caught).
  Pistol dir 90: at the new spot (start:-10,0) `kill:pistol --sig-dir=90` -> fire 61, kill 63 (at the start the
  dummy knot stood south of Rivet; the spot fix cured it, no code).
- SERVED: kills-new REQUEST (3): cherry-pick the gatling commit (kill_lab.gd + test_kill_lab_held.gd + .uid), and run
  the reel as before; the pistol dir 90 needs only this tools tree (the shot spot is tool side).
- 13:08 06af9e9db the beat readout's measured hold + `kill_reel --feel=on|off|auto`. FOUND while building it: the reel
  locks the camera, and film's `--feel=auto` turns the hit feel OFF under a lock (FeelCam's hit-stop freeze, kick and
  shake), so NO reel film so far showed the owner's "hit-stop plus camera punch". `--feel=on` films them. measureHold
  counts the ticks from the kill that the kill window holds still (< 0.2 % per frame), first zoom only. Real frames
  (gat2, wall2, pis90, wall1: standard deaths in this tree, feel off): held 0 each. NOT yet proven on a signature row
  with --feel=on (katana, hit-stop 6): Godot is held by the gate. First thing next session:
  `kill_reel --out=build/kreel/s3feel --weapons=katana --dirs=90 --ppm=32 --feel=on` vs the same with --feel=off.
- Kill lanes, NOTE: judge pacing (hit-stop, punch) only on a `--feel=on` reel; default reels have the feel off.
- 13:06 GATE started on 0b5c55fc7 (`node tools/gate/run.mjs --rev=0b5c55fc7 --reels`, log
  C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s2.log, ends with `gate exit N`). Later commits are tools/docs only.
- 13:14 3d40b2ca2 beat line gains the aftermath lifetime from data: KillMarks is a ring of `leftover_budget` (12) kill
  marks, so a death's scorch and spray stay until 12 later kills recycle them (no timer). Real table: `katana:
  katana_split (split) hit-stop 6, held 6 (grind 0, stand 0), crumble 0, flash 2 ticks; its scorch and spray stay until
  12 later kills recycle them`.
- 13:15 looked: `--victims=thug` at the new spot DRAWS a different figure (build/kreel/thug_vs_guard_t60.png: the
  default guard is the capped patrol cop; thug = grey hood/torso, pistol raised), not only the probe row. Session 1's
  "thug stands as riot cop" was most likely a station dummy beside an undrawn guard.
- 13:16 GATE evidence stage PASS on 0b5c55fc7 (the last commit touching project/; later ones are tools/docs/evidence):
  lint 19/19, unit 2645 passed / 0 failed / 2 skipped, scenarios 55, parity bit for bit 1200 steps (planted fault at
  629; final_sha_a/b 94b2865f7f17d778, unchanged from n15: c-2 moved no digest), selftest look goldens 11/11 worst 0.00,
  release-compile 683/0. Reel stage running: `build/gate/0b5c55fc7cfd/reels.log`; verdict = `gate exit N` at the end of
  C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s2.log.
- 13:31 GATE PASS on 0b5c55fc7 including the REEL gate (`gate exit 0`; reels top / tilt70 / combo OK, ~5 min each;
  build/gate/0b5c55fc7cfd/gate.json). All gates green on the last project/ commit of this branch.
- 13:35 FOUND: the hit-stop is `SimClock.hold` (it eats frame time; no tick advances while held), and film saves ONE
  STILL PER TICK, so no still, sheet or clip ever shows the freeze: katana `--feel=on` and `--feel=off` both read
  "window still 0" (build/kreel/s3feel_on/off). Each probe row records its process `frame`, so a tick held N frames
  is a gap of N + 1 to the next row. `measureStop` sums those from kill-1 to kill+12 (no game change; works on --rev
  snapshots and older probes). PROOF build/kreel/s3stop_on vs s3stop_off, katana dir 90 32 px/m: `--feel=on` ->
  "hit-stop 6 frames" (tick 70 held 6) = the row's hitstop_ticks 6; default -> 0. A probe-side counter
  (film_probe held_frames) gave the same 6 but grew dev_loc (debt ratchet), so it was dropped for the row gaps.
- Kill lanes, NOTE: to judge pacing, run the reel with `--feel=on` and read `hit-stop N frames` on each film line;
  the sheets cannot show a hit-stop (it has no tick of its own). The beat line now also gives the aftermath lifetime.
- Codex ledger this session: 1 task (n16t-break-film-root, gpt-5.6-sol, 1 round, 119 s, accepted after revision).
- Item status: (1) kill reel: v1 + --before from any lane tree + --dirs=wall + --gore-check (proven) + beat readout
  table+measured (hit-stop frames, window still, settled, aftermath share, lifetime from data) + --feel; (2) c-2 done,
  parity digest unchanged, gate PASS; (3) test_quest_blade: nothing to fix on main (s1); (4) merge-clash: done in n15;
  (5) served kills-new REQUESTs 1, 2, 3 and kills-polish's step_guard REQUEST.

NEXT: (0) read the sibling journals for new REQUEST tools / FRICTION first. (1) re-run the gate on the final
project/ commit only if a later commit touches project/ (0b5c55fc7 is gate PASS incl. reels; since then tools/docs
only). (2) a `--feel=on` sheet still shows no freeze: consider printing the measured hit-stop on the sheet's kill
column label, and filming the reel's clip from a Godot --write-movie run when --feel=on (frames, not ticks), so the
freeze is SEEN. (3) kill reel throughput: `--weapons=all` films ~13 weapons x dirs x 2 zooms at 60-150 s each; a
`--quick` (32 px/m only, dirs 90) for builders' inner loop. (4) Gloria's pin counts cars as walls (Call for owner
candidate, still at kill-lanes' side). (5) REPORT.md at 19:40 (Calls: kill shot spot moved, reels have the feel off
by default). (6) the s1 frames.json entry "thug stands as riot cop" is superseded: retire it at REPORT time.
- 13:46 evidence: gtai-masters/n16/tools/frames.json 12 entries (retired the s1 "thug stands as riot cop" still and its
  file; the s1 dir-90 sheets are marked as filmed before the spot fix; added guard-vs-thug t60). In-tree copies under
  evidence/n16-tools/ (+ reel_s3stop_on/off.json, the hit-stop proof).
- DECISION tools/kill-reel-feel: the reel's default stays feel OFF (stable sheets and A/B); `--feel=on` for pacing; the
  hit-stop is read as `hit-stop N frames` (probe frame gaps), never from sheets. Line in docs/decisions.md.
- 13:48 session 2 end: tree clean, no Godot of mine running (the gate and all reels exited). Branch tip below.

## Session 3 (iteration 3, 2026-11-11 13:43, BUILD; stop 15:13)
- 13:43 read JOURNAL, git log, both sibling journals: no new `REQUEST tools:`. kills-new FRICTION 13:18 (their
  branch's compare.mjs has no `kill:` shot) is the expected cross-branch gap: run the tools tree's copy
  (`node ../n16-tools/tools/film/compare.mjs kill:<w> ...`), it films the caller's tree (filmedRoot). kills-new's
  NEXT (4) says `--victim-wall` is still open: it was served in session 2 as `kill_reel --dirs=wall` / `--sig-wall`.
- Plan: (a) `kill_reel --quick` for the builders' inner loop; (b) the measured hit-stop on the sheets' kill column;
  (c) a frame-true clip with --feel=on so the freeze is SEEN; then the weakest item.
- 13:48 PROOF `kill_reel --out=build/kreel/s3quick --weapons=katana,rocket_launcher --quick --feel=on` -> 2 films (32
  px/m, dir 90), PASS, ~5 min beside the other lanes: katana kill 68 `hit-stop 6 frames`, settled +80, 3.2 %; rocket
  kill 68 `hit-stop 8 frames`, settled +40, 4.9 %. Sheet labels looked at (katana_32.png): `60 -8 AFTER GUARD D90
  32`, `68 KILL HS6`, `69 +1` ... `218 +150`. FOUND: the rocket holds 8 frames though its signature row says
  hitstop_ticks 0: the hold is FeelCam's (camera.json class/weapon feel), not the signature row. Kill lanes: the
  row's hit-stop is not the whole hold; read the measured `hit-stop N frames`.
- 13:52 frame-true clip: `--clips --feel=on` passes film `--movie` and cuts clip.mp4 from the movie at the probe rows'
  process frames (`movieSpan`), kill-30 to kill+after. CALIBRATED on build/kreel/s3movie (katana, --keep-frames,
  scratch script gtai-n16/scratch-tools/calib_movie.mjs): movie index = row `frame` (7 ticks: 3.0-3.8 % pixels off at
  that index, 18-44 % at +-1; x264 loss). PROOF build/kreel/s3movie2: clip.mp4 384x288 60 fps, 187 frames = 181 ticks +
  6 held; frames 28-39 looked at: t66, t67, the kill flash t68, t69, then t70 (the blade streak + spray) for 7 frames,
  then t71. The held frames match the kill still: the screen truly freezes (the camera offset is tick-driven).
- MILESTONE 1e54a3b50 kill_reel `--quick`, labelled sheet cells, `--clips --feel=on` from the movie. Node film tests
  226/0, lint 19/19, debt ok, quick gate (merge-clash none).
- SERVED (kill lanes): the inner loop is now
  `node C:/Users/kazda/kiro/gtai-wt/n16-tools/tools/film/kill_reel.mjs --out=<dir> --weapons=<w> --quick --feel=on`
  (one 32 px/m film per weapon, ~2.5 min; the kill cell reads `KILL HS<n>`); add `--clips` for a clip that PLAYS the
  hit-stop and camera punch at game timing (judge pacing there, not on the sheet).
- 13:53 started `kill_reel --out=build/kreel/s3all --weapons=all --quick --feel=on` (12 weapons): every signature
  weapon must kill in the lab.
- FOUND (kill lanes, read this): a signature row's `hitstop_ticks` does NOT freeze the screen. SignatureKills.hold
  makes the pieces (gibs, halves, marks) wait that many sim ticks; the screen freeze is FeelCam's: a lethal hit takes
  hit_feel.json `kill_hitstop` (camera.json `kill`, 6 ticks) or its class's bigger stop (rocket = class blast =
  `boss_hit` 8: measured 8 frames with row hit-stop 0). To change how long the screen holds on a kill, change
  hit_feel.json (a per-weapon `hitstop` in `weapons`), not the signature row. a505c1c63 words the beat line so.
- 14:0x fe765cc94 Codex n16t-break-reel-movie (gpt-5.6-sol, 1 round, 188 s): 10 adversarial tests; 3 kept red, all
  accepted in review and fixed in code: cellLabel `hs` only for a positive integer, sheet `label` = drawText (returns
  the count), movieSpan refuses from > to. Ledger: accepted (tests verbatim, 3 code fixes); discarded.
- 14:20 PROOF full coverage: `kill_reel --out=build/kreel/s3all --weapons=all --quick --feel=on` (12 films, ~25 min):
  11 PASS (rocket, hand cannon, flamethrower, molotov, electro gun, katana, plasma rifle, plasma sword, chainsaw, ray
  gun, homing shard: every signature weapon kills in the lab); mini nuke UNVERIFIABLE only because Rivet is thrown
  out of the locked frame (screen y -10..-25 from the kill on). Measured freezes: 8 frames for rocket, electro gun,
  nuke (class stops), 6 for the rest (hit_feel kill). Looked at the overview: the nuke window (12 x 9 m between Rivet
  and a victim ~25 m off) showed neither well; at 32 px/m the flamethrower and electro deaths read weakly (a small
  dark figure), kill lanes' call.
- Built (uncommitted until the nuke proof): `reel_<ppm>.png` overview (a row per film, every weapon) + `reel.md`
  (beat table per film), `--resheet=<reel dir>` (rebuild from reel.json, no Godot: run on s3all, overview looked at),
  output code split to tools/film/kill_reel_out.mjs; the reel judges `--subject=kill`, and killWindow centres on the
  victim when he and Rivet cannot share the window with 2 m to spare. Unit 239/0. Re-filming nuke + katana: s3nuke.
- 14:19 MILESTONE a2288fc70 overview + reel.md + --resheet + subject=kill + far-victim window. PROOF build/kreel/s3nuke
  (`--weapons=mini_nuke,katana --quick --feel=on`): both PASS (nuke kill 127 HS8, katana kill 68 HS6); looked at
  reel_32.png: the nuke's window now holds the blast on the victim (kill flash to +40). Known limit: with the feel on
  the nuke's BlastLead drifts the camera, so its t60 and +80/+150 cells show Rivet's street (the window is fixed on
  screen). NOISE: katana `settled` read +150 here and +80 in s3quick/s3all on the same game commit (city traffic in
  the window): `settled` is a coarse upper bound, compare it only within one run.
- DECISION tools/kill-reel-subject: the reel judges the death on screen and gives a far victim the window (line in
  docs/decisions.md; rejected: a window grown to hold both).
- Evidence: gtai-masters/n16/tools/frames.json 13 entries (added the all-weapon overview, the frame-true katana clip +
  its frames 28-39, the nuke window; retired the v0 crop defect, katana d180 and c-2 tier B stills and deleted their
  files). In-tree: evidence/n16-tools/ (overview and nuke at half size, clip, strip, reel_s3all.{md,json}, reel_s3nuke.md).
- SERVED (kill lanes): one image of every death: `kill_reel.mjs --out=<dir> --weapons=all --quick --feel=on` writes
  `reel_32.png` (a row per weapon) + `reel.md` (paste into REPORT); `--resheet=<dir>` relabels an older reel with no
  Godot. Today's overview of this tree: gtai-masters/n16/tools/kill-reel-overview-all-weapons-quick-feel-on-32ppm.png.
- 14:28 CORRECTION of 14:19/14:20: the mini nuke does NOT throw Rivet. In the s3nuke probe Rivet's world pos stays
  (514, 524) while the canvas origin y goes -15493 (t60) -> -15766 (kill 127) -> -15621 (t207): the camera drifts
  ~273 px toward the blast (FeelCam BlastLead, feel on) and Rivet's screen y 264 -> -10 matches. a2288fc70's message
  says "throws"; README and the decisions line are corrected. Built from it: every sheet cell is anchored to the
  street by the probe camera shift from the kill tick (`anchorShifts`/`boxAt`, reel.json `shifts`), also used by the
  measured beats; the clip keeps the screen (punch included). Unit 240/0. Proof run: build/kreel/s3anchor (nuke +
  rocket, --quick --feel=on).
- 14:36 `--resheet` computes the street anchor from each film's kept probe.json when an older reel.json has no
  `shifts`. PROOF: `kill_reel.mjs --resheet=build/kreel/s3all` -> shifts per film (katana/plasma sword/chainsaw kick
  the view 48-51 px on the kill tick, rocket/electro 15, nuke 273); overview looked at: the blade rows no longer
  jump at the kill. Unit 241/0. Masters overview replaced with the anchored one.
- 14:38 PROOF before/after: `kill_reel --out=build/kreel/s3ab --weapons=katana,ray_gun --quick --feel=on
  --before=8723ec8b4` (the same project/ as HEAD): 4 PASS, labels `KATANA BEFORE GUARD D90 32` fit. A/A floor: the
  sim is bit-identical across the two runs (every fighter, every tick, kills 68/63, fires; probe frames equal) and the
  frames differ 0.00-0.29 %, BUT the katana's measured aftermath read 5.8 % vs 3.2 %. Diffed t218 (looked at
  build/kreel/s3ab/diff218.png): only RIVET'S POSE differs (strike held vs at rest), and his drawn facing differs from
  tick 1 (facing_off 94 vs 103 deg). CAUSE: the arena's LiveInput aims at the desk mouse
  (`viewport.get_mouse_position()`), so every film depended on where the cursor sat (also the `settled` +80/+150 noise).
- FIX (game side, dev only): FilmProbe pins `session.live.cursor_px` to the view centre + (0, -280) while filming
  (stride_film.gd's idiom), so a film never reads the desk mouse. dev/frames 193 -> 200 lines (debt ok). Only the film
  tools attach the probe (`--film-dir`/`--cam-lock`; no gate, reel or test uses them). Proof running: two pinned runs
  (build/kreel/s3pin1, s3pin2) with the desk cursor position logged before each (read, never moved).
- 14:43 PROOF the pin: build/kreel/s3pin1 vs s3pin2 (katana --quick --feel=on, back to back): Rivet's facing_off equal on
  414/414 ticks (81.56 at tick 1; unpinned runs read 94 and 103), frames 0.00 % apart at t60, the kill and +150, and
  the aftermath 3.2 % both (unpinned A/A: 5.8 vs 3.2). The cursor read before each run printed nothing (no claim that
  it moved). Kill lanes, NOTE: reels and films before this commit can differ run to run in RIVET'S aim/pose only
  (the sim was identical); re-film a before/after whose difference is Rivet's pose.
- 14:48 caccc825d (the lambda form, +2 dev lines, debt accepted with the reason) RE-PROVEN on the commit: s3pin3 vs
  s3pin4 facing equal 414/414 (and equal to s3pin1), frames 0.00 % at t60/68/218, aftermath 3.2 % both.
- DECISION tools/film-cursor: films pin the cursor (line in docs/decisions.md; rejected: a flag, parking the desk
  cursor). REPORT draft updated (finding for the kill lanes, gate note).
- Evidence: masters frames.json 14 entries (added the desk-mouse A/A diff at t218 on top; retired rocket d90 64 px/m
  and deleted its file); in-tree copy evidence/n16-tools/film-desk-mouse-aa-katana-t218-before-after-diff.png.
- Codex ledger this session: 1 task (n16t-break-reel-movie, gpt-5.6-sol, 1 round, 188 s, 10 tests, 3 defects
  accepted and fixed in code). Day total 2 tasks.
- 14:50 GATE started on caccc825d (`node tools/gate/run.mjs --rev=caccc825d`, no reels; log
  C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s3.log, ends with `gate exit N`).
- Item status s3: (1) kill reel: + `--quick`, labelled cells, frame-true clips (`--clips --feel=on`), overview +
  reel.md, `--resheet`, death judged on screen, far-victim window, street-anchored cells, all 12 weapons proven to
  kill; + the film cursor pin (films were reading the desk mouse). (2) c-2 done (s1). (3)(4) done. (5) no new REQUEST.

NEXT: (0) read `gate exit N` at the end of C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s3.log (evidence stage on
caccc825d, the last project/ commit: dev-only film_probe change); then run the REEL gate on it
(`node tools/gate/run.mjs --rev=<last project/ commit> --reels`, ~40 min; start it only when no other Godot work of
mine is due, kills-polish FRICTION). (1) read the sibling journals for REQUEST tools / FRICTION. (2) tell the kill
lanes in their terms (JOURNAL NOTE is there): pre-caccc825d before/afters may differ in Rivet's aim/pose only. (3)
optional: the reel's per-film time (~2.5 min at 32 px/m quick); a world-anchored crop for the clip too (the clip
keeps the screen on purpose: punch); flamethrower/electro read weakly at 32 px/m (kill lanes' call). (4) REPORT.md
at 19:40: the draft is in the tree; fill Next steps, the gate verdicts, final Codex ledger.
- 15:00 GATE on caccc825d so far (snapshot build/evidence): lint 19/19, unit 2647 tests / 0 failures; scenarios
  running. Verdict: `gate exit N` at the end of gtai-n16/scratch-tools/gate_s3.log (if this session stops first,
  read it next session; results also in build/gate/caccc825d4a8/).
- 15:09 GATE PASS on caccc825d (`gate exit 0`, build/gate/caccc825d4a8/gate.json): lint 19/19, unit 2645 passed / 0
  failed / 2 skipped, scenarios 55, parity bit for bit 1200 steps (planted fault at 629), selftest look goldens 11/11
  worst 0.00, release-compile 683/0. The REEL gate on caccc825d is still owed (NEXT 0). Session 3 end: tree clean, no
  Godot of mine running (gate and reels exited).

## Session 4 (iteration 4, 2026-11-11 15:10, BUILD; stop 16:40)
- 15:10 read JOURNAL, git log, sibling journals. kills-new FRICTION 15:15: "the kill reel's after side films the live
  tree: uncommitted code (a new class not yet imported) broke 'after gatling dir 0 64' with SCRIPT ERROR". No new
  `REQUEST tools:` in either lane; kills-polish gate on 49c7c0be9 PASS (their reels running).
- 15:12 REEL gate started on caccc825d (`node tools/gate/run.mjs --rev=caccc825d --reels`, log
  C:/Users/kazda/kiro/gtai-n16/scratch-tools/gate_s4_reels.log, ends `gate exit N`).
- MILESTONE 469298728 (serves kills-new FRICTION 15:15): the reel stamps the live tree (tools/film/live_tree.mjs: HEAD +
  every uncommitted project/ path, untracked files included, with size and mtime) before it starts and before each
  film. Uncommitted paths at the start print one line naming them and the fix (`--rev=HEAD`); a film whose tree moved
  prints `the live tree moved since the reel began (HEAD a -> b; N project/ path(s) changed (...))` and its reel.json
  film gets `tree_moved`; a failing film on such a tree says commit and re-run `--rev=HEAD`. A `--rev` side is never
  asked (a snapshot cannot move). Tests: live_tree.test.mjs 4 (a throwaway git repo, no inherited config: edit, new
  untracked class in a new folder, deletion, a commit mid-reel, the dry-run line once, --rev side unasked); film tests
  245/0; full lint 19/19. PROOF (real tree): an untracked project/dev/zz_live_tree_proof.txt, then
  `kill_reel.mjs --out=build/kreel/s4dry --weapons=katana,rocket_launcher --quick --dry-run` printed
  `kill_reel: the after side is this live tree with 1 uncommitted project/ path(s) (project/dev/zz_live_tree_proof.txt);
  each of the 2 film(s) loads project/ as it stands at its start ... commit and pass --rev=HEAD`; file removed, the
  clean tree prints nothing. The per-film "moved" line is unit-proven; a real reel proof follows when Godot is free.
- SERVED (kills-new FRICTION 15:15): a live-tree reel now names its uncommitted project/ paths before it films and
  names the film where the tree moved; to keep editing while it runs: commit, then `--rev=HEAD`.
- 15:22 Codex n16t-break-live-tree (gpt-5.6-sol, 1 round, 196 s): 8 adversarial tests, 1 kept red: CRLF porcelain
  output corrupts every path (live_tree.mjs:19 split on '\n'). Accepted. Review found a second, real defect the tests
  did not: git C-quotes non-ASCII paths as octal UTF-8 bytes (`?? "project/\303\274.gd"`, checked on a throwaway
  repo), which the parser left escaped, so the file stat-ed as `gone`; and a quoted rename `"a b" -> "c d"`. Fixed:
  `unquote` (C escapes, octal bytes -> UTF-8) + `porcelainPath` (new name of a rename) + split /\r?\n/; my first-author
  test on a real repo (a space folder, `ü.gd`, a rename to `new name.gd`: every path stat-ed where it lies). 7c0e91fcd:
  live_tree 13/13, film tests 254/0, full lint 19/19. Ledger recorded (`dispatch.ts record ... accepted`), discarded.
- 15:25 queued (scratch-tools/after_gate_gore.sh, log scratch-tools/reel_s4gore_new.log): when the reel gate exits,
  `kill_reel --weapons=all --quick --gore-check --rev=8f7fe6e6e` run FROM the kills-new worktree (their tip, their DLLs
  in the snapshot; out in this tree build/kreel/s4gore_new): 17 films, every kills-new death under `--gore=reduced`
  (the brief's "every death drops whole" over the whole table, not 2 weapons).
- 15:30 MEASURED where a reel film's time goes (film.json `ran` + file mtimes of build/kreel/s3all): per film ~70 s
  wall, of it Godot 58-68 s with ~165 stills; 12-still films (64 px/m later zooms in s2wall/t2) ran 15-21 s; the Node
  side (PNG decode ~0.1 s a frame, diffs) ~5 s. So the PNG writes are ~45 s of each film.
- MILESTONE 7a16ac85d: without `--clips` the first zoom SCOUTS (same flags, seed, camera lock `spawn`, ticks 420;
  stills 60 + `kill:1`) to learn the kill tick, then films `filmTicks` = beats + hold run kill..kill+12 (~20 PNGs).
  A kill on another tick than the scout is UNVERIFIABLE, naming the scout. `--clips` keeps the full window. Tests
  kill_reel 18/18 (scout/film share lock, extra, ticks; every beat still filmed); film tests 254/0; lint 19/19.
  Real-run proof = the queued kills-new gore reel (it loads the kit after the gate: it runs this commit).
- 15:49 REEL GATE PASS on caccc825d (`node tools/gate/run.mjs --rev=caccc825d --reels`, `gate exit 0`,
  build/gate/caccc825d4a8/gate.json): lint, unit, scenarios 55, parity bit for bit 1200 steps (planted fault at
  629), selftest look goldens 11/11 worst 0.00, release-compile 683/0, reels exit 0 (top/tilt70/combo, chapter 19
  electro_chain 4/4 down last). caccc825d is the last project/ commit on this branch: every gate is green on it.
- 15:49 gore-check reel started on kills-new 8f7fe6e6e (17 films, scout mode).
- 16:02 PROOF gore check over the WHOLE kills-new table + the scout's real run: from the kills-new worktree,
  `node ../n16-tools/tools/film/kill_reel.mjs --out=<n16-tools>/build/kreel/s4gore_new --weapons=all --quick
  --gore-check --rev=8f7fe6e6e` -> `kill_reel: PASS`, `reel exit 0` 15:49:35-16:02:16: 17 films, every one PASS and
  `whole: true` (rocket 68, hand cannon 63, flamethrower 237, molotov 182, electro gun 129, katana 68, plasma rifle 65,
  plasma sword 68, chainsaw 68, ray gun 63, homing shard 69, mini nuke 126, pistol 63, machine pistol 174, gloria 64,
  gatling 95, electro baton 68). Looked at gatling_32.png and katana_32.png: the guard falls and lies whole (no
  halves, no shred pieces) at every cell from the kill to +150. No film's kill differed from its scout.
  SCOUT TIME: films now 34-46 s wall each (Godot 17-21 s per run x 2: scout + beat film); s3all took 62-137 s each
  (hand cannon 130 -> 46 s, flamethrower 137 -> 34 s); 17 films in 12.7 min vs 12 films in ~25 min.
- Evidence: masters frames.json 15 entries (added the gatling gore-reduced sheet on top); in-tree
  evidence/n16-tools/kill-reel-gore-reduced-{gatling,katana}-kills-new-32ppm.png + reel_s4gore_new.md.
- SERVED (kills-new): every one of your 17 signature deaths at 8f7fe6e6e drops whole under `--gore=reduced`
  (evidence/n16-tools/reel_s4gore_new.md). Reels are ~2-3x faster since 7a16ac85d (scout), same command.
- 16:02 the same gore check on kills-polish a56501ee5 started (scratch-tools/reel_s4gore_polish.log).
- 16:02 FOUND: kills-polish's tree has no `--sig-dir` (it never took the kill-lab turn): the reel refused with
  `film: no script in <snapshot> reads --sig-dir`, nothing launched (exit 2). MILESTONE 613b488e0: that refusal now
  says `this tree predates the kill-lab turn ...: film --dirs=0 (the lab's own facing, no turn flag), or cherry-pick
  that commit's game side` (and `drop --victims` for --victim). PROOF: dry run from the kills-polish worktree at
  a56501ee5 printed it; kill_reel tests 19/19; lint 19/19.
- 16:10 PROOF gore check over the kills-polish table: from its worktree, `kill_reel.mjs --weapons=all --quick
  --gore-check --dirs=0 --rev=a56501ee5` -> PASS, `reel exit 0` 16:03:07-16:10:28 (12 films, 7.3 min), all 12 PASS
  `whole: true` (same kill ticks as kills-new's tree: rocket 68 ... nuke 126). Looked at chainsaw_32.png (saw chunks
  are kills-polish's A5: none thrown under reduced, the guard lies as one body in a blood smear) and
  rocket_launcher_32.png (the body lies whole; the grey shards are the blast fx's concrete, no torn pieces).
  Evidence: evidence/n16-tools/kill-reel-gore-reduced-chainsaw-kills-polish-32ppm.png, reel_s4gore_polish.md.
- SERVED (kills-polish): every one of your 12 signature deaths at a56501ee5 drops whole under `--gore=reduced`
  (evidence/n16-tools/reel_s4gore_polish.md). Your tree has no `--sig-dir`: reel it with `--dirs=0`, or cherry-pick
  the game side of afe581336 (kill_lab_turn.gd) for the directions.
- 16:12 kills-new REQUEST (their JOURNAL ~line 540): "kill_reel's row line should resolve a burn death through
  KillFireSource" (the molotov reel line named burn_char, the film shows the torch). Cause: tableRows took the first
  row whose weapons include the id, and the `burn` row (every fire weapon) is listed before `molotov_torch`.
  MILESTONE a7369529f: a weapon's own row (`weapon`/`also_weapons`) first, then the `burn` fallback, as
  SignatureKills does after KillFireSource names the fire. PROOF on the kills-new live table (read only):
  `tableRows(<n16-kills-new>, ['molotov','flamethrower'])` -> `molotov_torch torch | burn_char`; test (burn row listed
  first, molotov takes its own, flamethrower falls back, each filmed once); film tests 256/0; lint 19/19.
  Note: reel_s4gore_new.md (filmed before this) still prints burn_char for the molotov: reel.json keeps the table as
  filmed; the next reel prints molotov_torch.
- SERVED (kills-new REQUEST, row line via KillFireSource): a7369529f; the reel line now names molotov_torch.
- Codex ledger this session: 1 task (n16t-break-live-tree, gpt-5.6-sol, 1 round, 196 s, 8 tests, 1 defect accepted
  and fixed; review found a 2nd). Day total 3 tasks.
- Item status s4: (1) kill reel: + live-tree guard, scout (2-4x faster films), gore check proven over BOTH kill lanes'
  full tables (17/17 + 12/12 whole), older-tree hint, own-row-before-burn. Full gate with reels PASS on caccc825d (last
  project/ commit). (2)(3)(4) done. (5) served kills-new FRICTION 15:15 and REQUEST (molotov row); kills-polish
  told how to reel its tree (`--dirs=0`).

NEXT: (1) read the sibling journals for REQUEST tools / FRICTION (kills-new FRICTION 15:30, the Gatling coded-scrap
`Invalid polygon data` flood that times films out at 305 s, is THEIR bug, they own the fix; a tools option: film could
stop early on a flooding log, as it does on SCRIPT ERROR). (2) the 64 px/m close-up and a `--clips --feel=on` clip of
a scout-era reel were not re-proven since 7a16ac85d (clips never scout; a 2-zoom reel's second zoom reuses the
scout's tick): run `kill_reel --weapons=katana --dirs=90 --ppm=32,64 --out=build/kreel/s5two` and check both PASS
and kill ticks equal. (3) Codex adversarial tests for the scout (filmJob scout path, filmTicks, olderTreeHint,
tableRows own-row) under id n16t-break-reel-scout. (4) REPORT.md at 19:40: fill Next steps and final ledger; the
draft is current to 16:12. No project/ commit since caccc825d: the gate PASS stands unless one lands.
- 16:14 PROOF NEXT (2) done in s4: `kill_reel.mjs --out=build/kreel/s5two --weapons=katana --dirs=90 --ppm=32,64` ->
  PASS, exit 0, 16:13:42-16:14:37 (55 s for both films: scout + 32 px/m beat film + 64 px/m beat film reusing the
  scout's tick): kill 68 at both zooms (= main's s3 tick), aftermath 3.2 / 3.1 %. Looked at katana_64.png: every
  beat cell present (flash at 68, streak +1/+2, the halves and blood +20..+150). Remaining NEXT: (1), (3), (4).
- 16:15 session 4 end: tree clean, no Godot of mine running (every reel and the gate exited).

## Session 5 (16:15-17:45)
- 16:16 read JOURNAL, git log, both kill journals: no new REQUEST tools since the molotov row (served a7369529f).
  kills-new FRICTION 16:?? (two Godot for a few s: their parse check beside their reel) is theirs. Plan: (a) film stops
  early on an error-flooding log (kills-new FRICTION 15:30: the Gatling coded-scrap `Invalid polygon data` flood timed
  films out at 305 s twice); (b) Codex adversarial tests for the scout (n16t-break-reel-scout); (c) REPORT.
- 16:25 FOUND (kills-new FRICTION 15:30 re-read against their logs): the error flood was NOT what timed the Gatling
  films out. ../n16-kills-new/build/reel/gatling_cells/gatling/before_guard_d0_32/film.log: `TIMED OUT after 305 s`
  with 134 `Invalid polygon data` errors (one per frame, from t100), and the film's last still was t239 of the ~245 it
  needed (a `--clips` window: stills 54-70 + kill 95..+150); boot + 46 stills took 134 s, then ~1.2 s a still (my gate
  ran beside it). Films with 314 such errors passed in 45 s (kreel/gatling/after_guard_*). So the fix is the timeout,
  not a flood stop (that idea dropped: it would have failed films that pass today).
- MILESTONE b74d9d007: a reel film without `--timeout` is timed by the stills it saves: 120 s + 2.5 s a still, never
  under 300 (`stillCount`, `filmTimeout`): a full window 540 s, a scout or beat film keeps 300; `--timeout` still wins.
  Test (the t239 case, scout/beat floor, --timeout wins); film tests 257/0; lint 19/19. Real-run proof queued: the
  very film that died, `kill_reel --weapons=gatling --dirs=0 --ppm=32 --clips --rev=590902959 --native=donor
  --out=build/kreel/s5clip` (scratch-tools/reel_s5clip.log), started 16:27.
- 16:30 Codex n16t-break-reel-scout dispatched (base b74d9d007; scope tools/film/kill_reel_scout.break.test.mjs:
  filmTicks, planFilm scout/known/clips, stillCount/filmTimeout, main's scout-once-per-combo with a fake runner,
  olderTreeHint, tableRows own-row). A suspect for it: a first zoom whose beat film kills on another tick than its
  scout stores THAT tick (kills.set(film.kill)) for the later zooms.
- 16:21 PROOF b74d9d007 on the very film that died: `kill_reel --out=build/kreel/s5clip --weapons=gatling --dirs=0
  --ppm=32 --clips --rev=590902959 --native=donor` -> PASS, kill 95, clip.mp4, `exit 0, 52.9 s`, 314 `Invalid polygon`
  errors in its log (quiet machine: the flood alone does not time a film out).
- MILESTONE 3ca83cd2a: film.json records `timeout_s` (the run ledger drops a run's entry at its end, so nothing showed
  the budget a film had). PROOF: same command -> build/kreel/s5clip2: PASS, `"ran": "exit 0, 46.3 s"`,
  `"timeout_s": 540` (the clip window's 168 stills; was a flat 300). Looked at gatling_32.png: hit at 95, the
  collapse into the blood fan, the heap lying +40..+150. film tests 257/0, lint 19/19.
- SERVED (kills-new FRICTION 15:30): a `--clips`/`--before` reel film is no longer killed at a flat 300 s; it gets
  120 s + 2.5 s a still (540 s for a full window), and film.json says what it got. Your Gatling timeouts were the
  timeout under contention (t239 of 245), not the polygon flood (one error a frame; 314-error films pass in 45 s).
- 16:35 MILESTONE 19df35c79 Codex n16t-break-reel-scout (gpt-5.6-sol, 1 round, 743 s, 10261 tokens out): 9 adversarial
  tests (filmTicks, planFilm scout/known/clips, stillCount/filmTimeout incl. --timeout=0, olderTreeHint near-miss flags,
  tableRows own/also_weapons over an earlier burn row, main scouting exactly once per combo over 2 victims x 2 dirs x
  2 zooms = 12 launches / 4 scouts, a scout timeout or empty kill never launching the beat film, clips never scouting).
  1 kept red: `filmTicks(0, 1)` holds tick 60 past kill+after. REVIEW: not a defect: 60 is pickBeats' fixed trigger
  column (the reference frame before the kill; lab kills come at 63+), my task text ("never past kill+after") was
  looser than the design; the test now exempts 60 (commented). Codex also pinned that a first zoom whose beat film
  disagrees with its scout hands ITS tick to the later zooms (the mismatch is already UNVERIFIABLE on that film): kept.
  Film tests 266/0, lint 19/19. Ledger `accepted-after-revision`, discarded. Day total 4 tasks.
- 16:37 kills-polish FRICTION 14:20 (unserved till now): "the plasma commit's full lint failed json-canonical on my
  NEXT item's unstaged schema edit". Their log: 0dce9f3b6 (plasma, 14:30) did not stage the schema, af3f9af1c did, so
  it really was unstaged drift. REPRODUCED their case here (font.mjs staged, signature_kills.json unstaged and not
  canonical, `node tools/gate/precommit.mjs`): the hook named the drift, linted a 5530-file export of the index, 19/19,
  exit 0. So the hook is right when the export works; the only tree-linting path is the fallback when the export
  throws (their first try; the retry worked), and that line did not name the unstaged paths.
- MILESTONE 826b4035a: the hook retries a failed export once, then the fallback line ends `it reads your unstaged
  <paths>: a failure there is not in the commit`. PROOF (real git, TMP pointed at a missing dir so mkdtemp fails both
  tries): `pre-commit: no staged snapshot (ENOENT ... mkdtemp ...): linting the WORKING TREE, ...; it reads your unstaged
  project/data/tables/signature_kills.json, ...`; tree restored, no lint process left. Tests gate 143/0 (the n15 break
  test's "export called once" now says twice when it throws), lint 19/19.
- SERVED (kills-polish FRICTION 14:20): 826b4035a. If a commit's lint ever reads your work tree again, the hook line
  now names the unstaged paths it read, and a one-off export failure is retried first.
- 16:47 kills-new REQUEST 16:28: `kill:claw_shock` refused (`unknown sigweapon claw_shock`: shots.mjs listed weapons.json
  + melee only); their workaround `--weapons=electro_gun -- --sig-gun=claw_shock` named electro_shock on the row line.
- MILESTONE 8784c592b: `labWeapons(tree)` reads `PlayerShock.WEAPON` (`const WEAPON: StringName = &"claw_shock"` in the
  filmed tree's player_shock.gd); film's `kill:` ids and the reel's `all` take it, the row line its own row. Test (no
  player_shock.gd -> unknown; with it known; `all` films it once a row names it; tableRows -> claw_throw); film tests
  267/0, lint 19/19. On this tree / kills-polish's, `all` now adds claw_shock (electro_shock's also_weapons there).
- PROOF from the kills-new worktree: `node ../n16-tools/tools/film/kill_reel.mjs --out=<n16-tools>/build/kreel/s5claw
  --weapons=claw_shock --dirs=0 --ppm=32,64 --rev=9ac925431` -> PASS, exit 0, 16:48:55-16:50:07 (72 s, scout + 2
  films), kill 127 at both zooms, row line `claw_shock: claw_throw (throw) row hit-stop 4`. Looked at claw_shock_64.png:
  the charge crackle at -2 and the kill, thrown east along the blow, on his back by +20, skid line to +150.
  Evidence: evidence/n16-tools/kill-reel-claw-shock-kills-new-9ac925431-64ppm.png + reel_s5claw.md; masters frames.json
  on top (rocket d90 dropped, 15 entries, no unreferenced file).
- SERVED (kills-new REQUEST 16:28): 8784c592b. `kill_reel.mjs --weapons=claw_shock` (or `all`) films the charged claw
  on its own claw_throw row; drop the `-- --sig-gun=claw_shock` workaround.
