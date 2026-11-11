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
