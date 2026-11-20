# n20 kerf JOURNAL (director: Opus; builder: Astra)

- 00:15 START iteration 1 BUILD. No astra.lock / calls for kerf. Other lanes: no NEED kerf.
  Flight 00:25 interface shape: GhostLook (`--ghost-look`), `look` field per row in ghost_forms.json,
  GhostHover/GhostTail/GhostShadow/GhostFlight; GhostDrawn.hover holds the standing cell, top-view rigs
  get speed 0 under spectral. Not yet committed on n20-flight.
- 00:20 Looked at the plate kerf_a.png and the first take. Plate: long teal dart, lens at the nose,
  horseshoe cable loops, hazard cross-beam stubs, two folded arms, three straight trailing beams.
- 00:25 DECISION body plan: rigid art, no cycles. Top view = cutout parts (hull, cables, arm, three
  lens states) moved by KerfRig; tilted views = one packed grid per tilt, 5 facings x 3 moods
  (POISED idle/cocked, CRUISE dart, LUNGE cut) instead of walk/run grids. Lens states (open/half/slit)
  make the eye; cable loops raised = hackles in POISED. The three beams are code-drawn (straight teal
  lines from the tail), so they can be the charges and stretch with speed. Rejected: drawn cycles
  (legless body needs none), and generating p55 independently (consistency: p55 is redrawn from the
  accepted p70 sheet).
- 00:25 DECISION key on #00B140 by border flood, not hue, because the body is teal.
- 00:19 ASTRA RUNNING body since 00:19 (brief evidence/briefs/n20-kerf-01-body.md)
- 00:38 ASTRA body 19 accepted (f47c96fb8). Parts take 3 (takes 1-2 fused arms+cables into the hull),
  hover 70 take 1, hover 55 take 1 (redrawn from 70). 91.67 px/m grid, cruise profile 1.5 m = 137.5 px.
  Looked at all five takes and the contact sheet: legless, plate silhouette, lens reads as an eye.
  Weak: POISED arm needles point down a little in the profile row (reads faintly as legs at 3x, not at 32).
- MILESTONE 00:38 body art committed: body_contact_sheet.png, body_scale_32ppm.png in masters/n20/kerf.
- 00:39 ASTRA RUNNING wire since 00:39 (brief evidence/briefs/n20-kerf-02-wire.md; flight interface not committed yet: steps 1,2,4 first, step 3 only after merge)
- 01:07 ASTRA wire 28 accepted (merge 69431c358 of n20-flight 0e7d91e46; 3e2aacee0). KerfSpectral +
  KerfBeams + KerfRig spectral path + KerfStage.recharge_k (view-only). Unit 3199/0/2 skip, quick ok
  6 files, legacy 76 frames byte-identical, write_state unchanged. Mutate kerf_spectral 4/12 (33 %): weak.
  Looked at wire_idle_32 / cruise_32 / close_64 / idle_32_top: tilted body legless and on-plate, cruise
  dart with three straight beams reads. Top view reads as a bare small jet (cable arch under the hull,
  arms pointing forward), beams low-contrast on the pale boulevard. Sent back inside brief 03 Part A.
- 01:07 NEED flight (handled as a one-line call site by kerf, named here): ghost_form_view.gd
  GhostFormView.make `v._bodies.kerf.stage = stage` (the live rig needs KerfStage for charges/blinks/lock).
- 01:08 DECISION attack read: after-image = ONE snapshot of the pre-blink pose at trail_from (not three
  echoes along the path); the path is one thin full-length slot on the press tick that retracts toward
  him; render-only overshoot 0.5 m for 6 ticks so his body never covers the victim; no flare/star on the
  victim on the press tick, cut mark from +3 ticks. Victim split delay/flash live in combat files (not
  ours): Astra reports exact NEED lines. Rejected: delaying the cut in time (sim decides; must stay instant).
- 01:07 ASTRA RUNNING slice since 01:08 (brief evidence/briefs/n20-kerf-03-slice.md: Part A review fixes, Part B blink-slice)
- 01:10 NEED flight: project/data/tables/ghost_hover.json kerf row: lag_ticks 3 -> 1 and bank_deg 24 -> 12
  (brief: "hard turns are sharp, almost no bank lag: he is the one ghost with no weight"). Or say in your
  JOURNAL that each ghost lane may edit its own ghost_hover row, and kerf will do it.
- 01:18 brief 03 Part A committed b51c8b3b9 (stage call site, arch over the hull, arms swept back). Looked at wire_idle_32_top at 3x: reads as the plate's top inset now.
- 01:28 flight DECISION 01:27 (message): each ghost lane owns its ghost_hover.json row; kerf call site in ghost_form_view.gd accepted. My NEED of 01:10 is withdrawn: kerf sets its own row (lag_ticks 1, bank_deg 12) in brief 04 step 1.
- 01:37 brief 03 Part B committed f36c0a161 ("Draw Kerf's spectral blink from the previous pose on the
  press tick"); Astra still making the slice strips / mutate at session end.
- 01:38 ASTRA RUNNING slice since 01:08 (lock C:\Users\kazda\kiro\gtai-n20\logs\kerf\astra.lock; output
  C:\Users\kazda\kiro\gtai-n20\logs\kerf\slice.out.txt; 75 min cap = ends by 02:23 at the latest).
NEXT:
  1. Wait for the slice call to end (lock gone), read slice.out.txt: test/scenario/gate lines, mutate scores
     (kerf_spectral target >= 8/12; the slot/view file), NEED lines for combat files (victim flash/star,
     split delay). Log `ASTRA slice <min> accepted|bounced`.
  2. LOOK at slice_strip_top_32.png, slice_strip_70_32.png, slice_strip_64.png, slice_strip_legacy_32.png
     in C:\Users\kazda\kiro\gtai-masters\n20\kerf\: at +0 the after-image (where he was), him past the
     target, and the slot through a STANDING target must all read from the top view; no star/flash on the
     victim at +0. Bounce with a precise --resume brief if not.
  3. Write the combat-file NEED lines into JOURNAL (no lane owns combat/kills: they become Calls in REPORT
     with a still, unless Astra found a one-line call site).
  4. Start brief 04 (evidence/briefs/n20-kerf-04-films.md, ready): kerf ghost_hover row (lag 1, bank 12),
     films kerf_move_32 / kerf_attack_32 / kerf_close_64 (+ legacy attack), plate-vs-game still, creature
     still, frames.json, three decisions.md lines. It needs flight's tools/film/ghost_films.mjs (flight
     package 2, after their 1b): if not landed, the brief lets Astra use the driver's own capture + ffmpeg.
  5. Then raise the weakest item: transformation in/out, hit reaction (the act grid has no hit cell:
     consider a 4th hover column via an image prompt YOU write), HUD chip/card if the old drawing no longer
     matches. Do NOT flip the kerf look row to spectral until body+flight+all attacks are filmed in both
     tilts and the gate is green.
  6. Last new work committed by 06:00; final gate `node tools/gate/run.mjs --rev=HEAD` from 06:15.
- 01:44 ASTRA slice 35 accepted (b51c8b3b9 Part A, f36c0a161 Part B). Unit 3208/0/2, scenarios 65/0,
  20 s city + 60 s replay byte-identical vs 3e2aacee0, Kerf quest hash same. Mutate kerf_spectral 11/12,
  kerf_slot 7/12. Call site ghost_form_view.gd:62 (accepted by flight).
  LOOKED at slice_strip_top_32.png: at +0 was (after-image), cut (slot) and is (past the guard) all read
  from above. Still wrong: (a) the combat cream star + slash on the victim at +0 (combat files, NEED below);
  (b) the after-image is nearly as opaque as the live body, so two Kerfs read at +0: make it fainter and
  more washed (alpha ~0.35, stronger teal wash); (c) a small red/vermilion speck near the victim at +3:
  find what draws it (red is blood only; kerf_split is dry).
- NEED (no owner lane; Call for the owner unless a one-line site is found):
  project/features/combat/kills/kill_marks.gd: flash_ticks 0 for spectral kerf_split (table value alone
  changes legacy). project/features/combat/kills/kill_split_fx.gd: intact posed copy to +3, halves from +4,
  no slash streak for spectral Kerf.
NEXT (supersedes 01:38 steps 1-3): bounce (b) and (c) as a short --resume brief, then brief 04 (films),
  then the 01:38 steps 5-6.

## Session 2 (iteration 2, 01:43)
- 01:45 No astra.lock; last call slice ended. No new NEED kerf in other journals (flight 01:27 already answered).
- 01:47 ASTRA RUNNING slicefix since 01:47 (--resume of slice thread; brief evidence/briefs/n20-kerf-03b-slice-fix.md:
  after-image alpha ~0.35 + teal wash, red speck at +3, skip Kerf's own cut_flare under spectral, kerf ghost_hover row
  lag 1 / bank 12). Output C:\Users\kazda\kiro\gtai-n20\logs\kerf\slicefix.out.txt.
- 01:55 Step 4 survey: the HUD chip `project/features/hud/art/ghost_chips/kerf.png` is the old biped head (cables +
  lens on a frame): no longer matches. `kerf_card.png` (p70 upright card) is hidden while a drawn grid stands in, so
  it does not show under spectral. Transformation/hit lean: flight package 3 (morph take + emerge, hit lean) covers
  them for all four.
- 01:55 NEED flight: `project/features/hud/ghost_chip_face.gd` loads `ghost_chips/<id>_spectral.png` when that form's
  look resolves to spectral and the file exists (else `<id>.png`). Kerf will ship `ghost_chips/kerf_spectral.png`
  (cut from the spectral p55 hover front cell with `tools/art/ghost_chip_cut.py`), new file, kerf prefix.
- 01:59 flight (message): accepts the chip rule as proposed: `ghost_chips/<id>_spectral.png` when GhostLook.of(id) ==
  SPECTRAL; item 0 of flight package 3, lands ~03:00-03:15. Kerf ships `kerf_spectral.png`.
- 02:00 DECISION victim read: use the night's one-line call-site exception in kill_marks.gd / kill_split_fx.gd, each
  routed into a new kerf-owned `KerfVictim` (spectral kerf_split -> no star flash, no slash streak), instead of a
  Call. Why: the brief names "no star or flash on top of the victim" and the strip at +0 is dominated by the star.
  Rejected: editing signature_kills.json flash_ticks (moves legacy too). Brief 05 written; runs after slicefix,
  before films (films must show the final press tick).
- 02:05 flight observation (afterimages with legs + a ground ring in their spectral film): both already gone on n20-kerf (f36c0a161: KerfEcho snapshot, _aura skipped under spectral); flight's tree lacks our commits. Replied.
- 02:46 ASTRA slicefix 59 accepted (52b595c9d echo wash 0.35/60 %, f6a830612 kerf hover lag 1 / bank 12). Unit 3208/0/2,
  scenarios 65/0, city 20 s + replay 60 s + quest byte-identical vs f36c0a161. Mutate kerf_echo 48/59 (81 %).
  LOOKED at slice_strip_top_32: the departure now reads as a ghost, not a second Kerf; slot through the guard to the solid
  body. Red speck = shooter's vermilion tracer (fx_view.gd:271), not ours: no action. Star + diagonal streak remain
  (combat files) -> brief 05 Part A. FRICTION: 61 min for a 4-fix resume (re-shooting strips and a full mutate dominate).
- 02:47 ASTRA RUNNING victim since 02:47 (--resume; brief evidence/briefs/n20-kerf-05-victim-chip.md: KerfVictim + one-line
  call sites in kill_marks.gd / kill_split_fx.gd (/ kill_view.gd) so spectral kerf_split draws no star, no streak, intact
  victim to +4; Part B ghost_chips/kerf_spectral.png). Lock pid 63788; output C:\Users\kazda\kiro\gtai-n20\logs\kerf\victim.out.txt.
NEXT:
  1. Wait for the victim call (lock gone), read victim.out.txt. Check: the call sites are truly ONE line each (git show on the
     combat files), nothing serialized changed (write_state / replay lines), legacy strip byte-identical. LOOK at
     slice_strip_70_32.png and _top_32 at +0: guard whole, no star, only the slot. LOOK at chip_compare.png. Log ASTRA victim.
     Log each call site file:line in JOURNAL (rule: one-line call sites outside our list are named there).
  2. Brief 04 films (evidence/briefs/n20-kerf-04-films.md, ready; step 1 already done). Fresh or --resume; flight's film tool
     may land in their package 2/3 (check `git log n20-flight`); merge n20-flight first (also brings the chip loader, ~03:15).
  3. After films: if everything filmed in both tilts and green, consider the kerf `look` row -> spectral (only then).
     Weakest item candidates: transformation in/out on kerf (flight pkg 3 does the shared morph), 55-tilt check.
  4. Last new work committed by 06:00; final gate `node tools/gate/run.mjs --rev=HEAD` from 06:15; REPORT by 07:40.
- 02:52 flight: film tool on n20-flight (95d914ab8 + 073237b56): tools/film/ghost_films.mjs --ghost=kerf --look=spectral --takes=move,attack,close --stills=163. Added to brief 04 step 0. Chip loader = flight pkg 3 item 0 (sha to come).
- Brief 05, spectral Kerf only. kill_marks.gd:50 routes the non-serialized star duration through KerfVictim.flash_ticks. kill_split_fx.gd:110 routes the streak through KerfVictim.streak. kill_view.gd:142 routes the part holder through KerfVictim.holder to reveal both cut edges at press +4. The three call sites are in project/features/combat/kills/.
- 03:11 flight: chip loader landed n20-flight 4362c8109. Not merged now (Astra victim running in this worktree); brief 04 step 0 merges n20-flight. Tail 0b in progress.
- 03:11 Session 2 ends. ASTRA RUNNING victim since 02:47 (lock present, pid 63788). NEXT as at 02:47; brief 04 step 0's merge
  of n20-flight now brings the film tool (95d914ab8 + 073237b56) and the chip loader (4362c8109): merge only after the
  victim call ends.

## Session 3 (iteration 3, 03:13)
- 03:14 ASTRA RUNNING victim since 02:47 (lock pid 63788 alive; Astra committing the chip, victim combat call sites still unstaged). Waiting.
- Brief 05 gate decision pending. Chip committed c3e83779f. Victim changes staged; final changed-suite 3212/0/2, scenarios 65/0, both replays and kill bytes identical, legacy 14/14 frames identical. Default quick's standalone Godot check also fails on all three unmodified combat files at f6a830612 (Log/LaunchArgs unavailable, then PagedAllocator shutdown error). quick --no-godot passes, project import passes, staged pre-commit 18/18. Requested approval to use those checks for the victim commit; the mutate tool requires it at HEAD.
- 03:21 ASTRA victim 34 accepted. Chip c3e83779f; Part A was left staged (quick gate red). I checked: quick fails with only the "depended scripts" cascade (no root error, same as on untouched files per Astra); run_unit --changed 3212/0/2 incl. test_kerf_victim. Committed Part A myself (git only, no edits): cd4555736. LOOKED at slice_strip_top_32 + _70_32: at +0 the guard stands whole, no star/streak, after-image + slot + Kerf past all read from the top. Call sites: kill_marks.gd:50, kill_split_fx.gd:110, kill_view.gd:142.
- FRICTION 03:22 quick.mjs Godot parse check gives a false FAIL on combat/kills files (depended-scripts cascade); ~6 min.
- 03:29 ASTRA RUNNING films since 03:29 (fresh; brief evidence/briefs/n20-kerf-04-films.md + additions; output logs/kerf/films.out.txt)
- 03:29 ASTRA films 1 abandoned (merge refused: flight tracks a root JOURNAL.md, ours was untracked). FRICTION ~3 min.
- 03:31 Merged n20-flight myself (91af03d90, clean: film tool, chip loader 4362c8109, tail 0b, own_body). Replaced flight's root JOURNAL.md with kerf's and committed it + the briefs. MERGE NOTE: root JOURNAL.md is per-lane; the Director keeps each lane's copy.
- 03:33 ASTRA RUNNING films2 since 03:33 (fresh; brief 04 + additions; out logs/kerf/films2.out.txt)
- 04:00 ASTRA films2 29 accepted (f0676335f decisions lines; films move/attack/close/tilt55/legacy + posters, plate_vs_game, creature, hud chip, frames.json 15). Quick: cascade only -> --no-godot; unit 3232/0/2; mutate kerf_victim 18/18 (100 %).
  LOOKED: move_32 one legless dart both views, sharp turns; close_64 idle-to-slice: poised with aim line, long slot from after-image. WEAK: (a) 70-tilt body ~75 % of the top hull length (plate_vs_game 140 vs 185 px); (b) poised in play tilt is not turned onto the guard (_yaw only applied in the top view); (c) attack poster is a crowd with short slots. -> brief 06 step 3.
- 04:04 ASTRA RUNNING form since 04:04 (fresh; brief evidence/briefs/n20-kerf-06-form.md: step 3a size, 3b aim in tilt, 3c re-film; steps 1-2 need flight pkg 3 (not on n20-flight yet at 04:03)).
- 04:06 Brief 07 written (evidence/briefs/n20-kerf-07-finish.md): transform in/out + hit strips (flight pkg 3), then the
  kerf look row -> spectral only if every listed check holds; hard stop 06:00.
- 04:20 flight (message): tail 0b on n20-flight 5e906fd53 (dense bright root aft of body, soft round puffs near the tip, no chevrons); chip 4362c8109 (already merged). Merge before brief 07, after the form call ends.
- 04:16 form 3a committed 7b8d88100 (tilted cell 69 px/m p70 / 72 p55, was 91.67; beams seated in the rear sockets).
- 04:22 form 3b committed 7f009c5b0 (locked target -> tilted cell + beams take the octant of the bearing; view only).
- 04:33 LOOKED new kerf_attack_32.jpg poster (input tick 96, 32 px/m): after-image, one slot through a STANDING guard, Kerf
  past him, both views. Good poster. Re-films still running.
- 04:38 Session 3 ends. ASTRA RUNNING form since 04:01 (lock pid 2348; out C:\Users\kazda\kiro\gtai-n20\logs\kerf\form.out.txt;
  75 min cap = ends by 05:16).
NEXT:
  1. Wait for the form call to end (lock gone); read form.out.txt. LOOK at the re-made kerf_plate_vs_game.png (tilt hull
     length now ~ top hull?), kerf_creature_32.png (nose on the guard in play tilt?), kerf_close_64 / move_32 frames
     (ffmpeg tile: `ffmpeg -i X.mp4 -vf "select='not(mod(n\,24))',scale=640:-1,tile=4x3" -frames:v 1 out.png`).
     Log `ASTRA form <min> accepted|bounced`. Steps 1-2 of brief 06 (transform/hit) were deferred to brief 07.
  2. Merge n20-flight MYSELF (JOURNAL.md conflicts: `cp JOURNAL.md` aside, `git merge n20-flight`; on a JOURNAL.md
     conflict `git checkout --ours JOURNAL.md`; then restore kerf's copy and commit). Flight pkg 3 so far: 5e906fd53
     tail 0b; morph/emerge/hit lean may follow (check `git log n20-flight`).
  3. Start brief 07 (evidence/briefs/n20-kerf-07-finish.md, ready): transform strip, hit strip, then the look row ->
     spectral only if every check holds. HARD STOP 06:00 for code.
  4. 06:15 final gate: `node tools/gate/run.mjs --rev=HEAD` (export APPDATA first); quote its line + gate.json path.
     After 07:30 freeze: `--reels` once if time. REPORT.md by 07:40 (sections per the lane rules; Calls: the
     victim one-line call sites in combat/kills (kill_marks.gd:50, kill_split_fx.gd:110, kill_view.gd:142) for the
     Director to accept or move; quick.mjs false cascade FRICTION; JOURNAL.md merge FRICTION). Run
     `node tools/evidence/cites.mjs REPORT.md` before the final commit; commit JOURNAL.md + REPORT.md + briefs.

## Session 4 (iteration 4, 04:37)
- 04:38 ASTRA RUNNING form since 04:01 (lock pid 2348). Waiting; reading other journals for NEED kerf.
- 04:52 LOOKED (form call's re-made stills): kerf_plate_vs_game.png cruise hull 190 px tilt70 / 191 overhead: lengths match (was 140 vs 185). kerf_creature_32.png: tilted nose + lens laid on the guard's aim line: reads as a creature with an eye. Note: two short hooked cable ends curl under the hull tail in tilt (session 1 art) -> REPORT Call, not reworked tonight.
- 05:03 flight (message): n20-flight HEAD 5707d7198: ff370f539 set_emerge (body+tail+pool rise/retract with the transformation; film with `ghost_films.mjs --takes=morph`, 8589b0294), 5707d7198 soul line follows the fade. Their note: kerf's shared tail reads too straight at 32 px/m. DECISION: keep it straight: the plate's three beams are ruler-straight, Kerf is the one ghost with no weight; no curl in kerf's ghost_hover row.
- 05:10 ASTRA form 69 accepted (7b8d88100 hull 137->190 px tilt70 / 191 top at 64 px/m; 7f009c5b0 lens+nose on the target). Full GUT 3249/0/2; legacy strip byte-identical; mutate kerf_spectral changed lines 15/18 (83 %), remaining-line sample 41/52 (79 %); the exhaustive 166-fault run exceeded the budget. Transform/hit were skipped (flight pkg 3 absent then) -> brief 07.
- 05:13 Merged n20-flight (d0ba3b4c8, clean, JOURNAL ours): set_emerge ff370f539, morph film 8589b0294, soul line 5707d7198. ASTRA RUNNING finish since 05:13 (nohup; brief 07; out logs/kerf/finish.out.txt).
- 05:16 LOOKED kerf_transform_strip_32.png (finish call): in and out, both views, every 3 ticks: Rivet -> flight's teal morph disc -> Kerf fades in (+21..+30), beams appear only at +27; out: Kerf fades into the disc by +12, Rivet back by +27. No legacy legged Kerf frame, no frame with both bodies at full alpha. Good.
- 05:17 LOOKED kerf_hit_strip.png: whole body + beams tilt with the lean in both views at 32 and 64 (nose dips at +0/+3, level by +15); lens narrowed/dark at +0/+3, bright again by +8. Reads, modest. The 64 tilt row crops the nose (framing only).
- 05:24 flight (message): 696862ee0 tail curl grows with speed stretch (curl_m + min(width_m, 0.24 x stretch)); flight final gate at aa9ff166e, no more flight code. DECISION: accept for kerf. The plate's vapour wavers around ruler-straight beams; the beams are kerf's own and stay straight. Merge n20-flight after the finish call ends, before the final gate.
- 05:45 ASTRA finish 31 accepted (2827defd9: KerfHit lean 12 deg -> 0 by +15 + lens flinch 6 ticks; beams fade in/out with emerge; kerf hover curl_m 0). Scenarios 65/65; 16 look captures identical; mutate 11/13 (84.6 %). LOOK ROW STAYS legacy: full unit 3251/2/2 with spectral (test_ghost_card.gd:92 assumes Kerf's legacy card; test_ghost_flight_hosts.gd:114), 3252/1/2 with legacy.
- 05:47 BLOCKED (gate red): test_ghost_flight_hosts.gd:114 (flight, b0f2629c1) reads drawn.sprite().frame_coords; under spectral Kerf has own_body so sprite() is null -> SCRIPT ERROR. Merge-induced (passes on n20-flight, which lacks kerf's body). NEED flight sent (message 05:47): null-guard the sprite. Not editing flight's test (ownership). test_ghost_card.gd:92 only fires if kerf's row goes spectral.
- 05:46 flight (message): dent and tonnage carry a null-sprite guard at test_ghost_flight_hosts.gd:114 as an accepted call site; theirs win at the merge. DECISION: kerf carries tonnage's identical 2 lines (`if not drawn.own_body:`) so the gate is green; dent's version differs (Director picks one at the merge).
- 05:47 Merged n20-flight again (3a63413ff: 696862ee0 speed curl, apparition, flight REPORT/briefs). Root JOURNAL.md + REPORT.md kept kerf's. merge-clash WARNING: project/tests/unit/test_ghost_look.gd conflicts with n20-ohm (flight's file vs ohm's lines, not kerf's) -> Merge notes.
- 05:47 ASTRA RUNNING guard since 05:47 (nohup; brief evidence/briefs/n20-kerf-08-guard.md; out logs/kerf/guard.out.txt).
- 05:47 REPORT.md drafted (5 TBDs: gate line, guard result, next steps, what I'd brief differently).
NEXT (session 5, gate + report; this session ends by 06:06):
  1. If astra.lock exists: guard call (pid in lock, nohup, started 05:47) is still running; wait. Then read
     C:\Users\kazda\kiro\gtai-n20\logs\kerf\astra-10-guard.last.txt, `git show HEAD` must touch only
     project/tests/unit/test_ghost_flight_hosts.gd (2 lines, tonnage's `if not drawn.own_body:`). Log `ASTRA guard <min> ...`.
     If it is not committed by 06:05, commit nothing new: the gate runs on what is there (and REPORT says the test is red).
  2. 06:15 FINAL GATE: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf; export GODOT_BIN=...; node tools/gate/run.mjs --rev=HEAD`
     (Astra idle; JOURNAL/REPORT/briefs dirt is inert). Quote its line + gate.json path in REPORT.
  3. After the freeze (07:30), `--reels` once only if time remains.
  4. REPORT.md: fill the TBDs (grep TBD), run `node tools/evidence/cites.mjs REPORT.md`, commit JOURNAL.md + REPORT.md +
     evidence/briefs/* per path by 07:40. Film list is in frames.json (15 entries; transform + hit strips added by 2827defd9).
- 05:49 ASTRA guard 1 accepted-but-red (a79b0b861: tonnage's own_body guard; Kerf's own_body is false, sprite() null -> still 12/1). ASTRA RUNNING guard2 since 05:49 (--resume, brief 08b: dent's null-sprite check; commit only if green).
- 05:50 ASTRA guard2 1 accepted (f67fa2ea0: dent's null-sprite check; select run 13/0/0). The hook flags a same-file conflict with n20-tonnage (their own_body guard): Director picks the null-check form (covers all three).
- 05:50 FINAL GATE STARTED (nohup, detached) `node tools/gate/run.mjs --rev=HEAD` on 55c10028f (code HEAD f67fa2ea0), APPDATA kerf; log C:\Users\kazda\kiro\gtai-n20\logs\kerf\gate-final.out.txt. No code commits after this.
NEXT (session 5, supersedes the 05:47 NEXT): the final gate is running detached (started 05:50 on 55c10028f).
  1. Wait for it: `tail C:\Users\kazda\kiro\gtai-n20\logs\kerf\gate-final.out.txt` (no node tools/gate process left = done).
     Quote its verdict line + gate.json path in REPORT. If red: read the failure; it may only be fixed by a commit before
     07:30 if trivial, then re-run the gate on the new HEAD.
  2. After the 07:30 freeze: `node tools/gate/run.mjs --rev=HEAD --reels` once if time allows.
  3. REPORT.md: fill the TBDs (grep TBD: gate line, guard row in the ledger = guard 1 red + guard2 1 accepted, Next steps,
     what I'd brief differently: shorter mutate scope, check merge-induced tests right after each merge), update the What
     does not line on test_ghost_flight_hosts (now fixed f67fa2ea0). `node tools/evidence/cites.mjs REPORT.md`; commit
     JOURNAL.md + REPORT.md per path by 07:40.
- 05:52 REPORT.md filled except the gate line; cites 9 paths, 8 ok, 1 pattern.
- 06:01 Gate progress: lint + unit done, scenarios 65/65 ok; parity/bench/release next. Session 4 ends; gate still running detached (log logs/kerf/gate-final.out.txt). NEXT: see the 05:50 NEXT.

## Session 5 (iteration 5, STABILIZE, 07:30)
- 07:30 No astra.lock; last Astra call guard2 (05:50). Final gate finished: `gate: PASS` on 55c10028f (code = f67fa2ea0), lint 19/19, unit 3259/0/2, scenarios 65/65, parity exact, selftest goldens 11/11, release-compile 783/0; gate.json build/gate/55c10028f02c/gate.json. Filled REPORT gate line.
- 07:31 DECISION: no `--reels` pass (a reel gate does not fit the 9 minutes before the report). No code change this session.
NEXT: the Director merges n20-kerf in the morning. Merge notes in REPORT (test_ghost_flight_hosts.gd:114 null-sprite form vs tonnage's own_body form; test_ghost_look.gd flight/ohm clash). Kerf's ghost_forms row stays legacy until the owner answers Call 3.

## Session 6 (iteration 6, STABILIZE, 07:31)
- 07:31 Tree clean, no astra.lock, no Astra call since guard2 (05:50). REPORT.md has no TBDs; cites 9 paths, 8 ok, 1 pattern; gate line quotes `gate: PASS` on 55c10028f. Nothing to fix; no code, no Godot run, no `--reels` (would not fit before 07:40).
NEXT: none for this lane. The Director merges n20-kerf (see REPORT Merge notes); Kerf's ghost_forms row stays legacy until the owner answers Call 3.
