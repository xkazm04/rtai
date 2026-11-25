# JOURNAL - lane cast, run n29 (2026-11-25)

Branch `n29-cast` from `main` `c649a15d6`, worktree `gtai-wt/n23-prologue`. Director: Claude Opus 5.5 (session 1 from 01:06,
stops by 02:36). Builders: in-session Claude sub-agents (Agent tool), briefs under `evidence/briefs/n29-cast-*.md`.
Films: `C:\Users\kazda\kiro\gtai-masters\n29\cast\`. IMAGES 0/60.

- 01:06 MILESTONE session 1 start. Read n28-cast REPORT, owner verdicts (decisions.md:1567), card table. No `NEED cast` in
  other lanes' journals (none written yet). Card ids in `cast_cards.json`: appliance_warden (body_scale 1.1), contractor,
  robot_gunner (1), rocket_trooper (lancer), sentry_turret, sergeant_mulroney (1.11), shield_robot (door carrier), war_machine.
  The "one value" per card foe is the existing `body_scale` field.
- 01:14 DECISION lane Godot lock: two sub-agents may run at once; every Godot launch in this lane holds `build/lane-godot.lock`
  (a directory made with `mkdir`, atomic) and removes it after, so the lane keeps one Godot at a time.
- 01:12 BUILDER cast-01-size (opus) started: `evidence/briefs/n29-cast-01-size.md` (measure every card foe beside the spawned
  rig patrol cop at 64/32 px/m, find the lineup's 1.35x/0.78x cause, then body_scale per foe by the rule in the brief).
- 01:12 DECISION card scale target rule (in brief 01): humans at the rig patrol cop's height (contractor x1.00, Mulroney
  x1.05, +-4 %); street robots (warden, gunner, lancer, door carrier) 0.90 x Rivet's live height (+-4 %, band 0.85-1.00);
  war_machine at most 1.10 x Rivet; sentry turret unchanged unless above Rivet. Why: owner's "most enemies near Rivet's size",
  humans weaker than Rivet and cop-sized. Alternative = one body_scale value per row.
- 01:16 BUILDER cast-02-flash (sonnet) started: `evidence/briefs/n29-cast-02-flash.md` (tint material on the door carrier and
  gunner card sprites while the rig is tinted, model `rig_head_card.gd:152`).
- 01:10 DECISION the pile-driver IS the `war_machine` card (n24 build report: "pile-driver ... disabled table row"; n28
  `6664ed8f8` measured `war_machine` as the pile-driver). The owner's "pile-driver and war machine" walk items are one
  character: one new walk set for `war_machine`.
- 01:10 MILESTONE image round `C:\Users\kazda\kiro\gtai-art\foes-n29\door8\` (jobs.json: 10 jobs, one facing per image, 8
  drawings in a 2x4 grid, edits of the shipped `shield_robot_armed_walk_{70,55}` sheets with the camera guide, thug8c prompt
  shape). First job door8_70_right as a probe before the other nine.
- 01:21 FRICTION image copy stall (known): door8_70_right's codex reported "file tools timed out"; copied by hand from
  `~/.codex/generated_images/`. Added `gtai-art/foes-n29/collect.py` (copies the path named in last_message.txt) and
  `reap.ps1` (kills that job's own codex.js by PID once collected), run every 30 s by `foes-n29/watch.sh`.
- 01:22 MILESTONE door8_70_right accepted by eye: torso, head, door identical across 8 drawings, legs alternate, soles on
  one baseline. IMAGES 1/60. Launched the other nine door facings (3 streams) + war8_70_right probe (`foes-n29/war8/`, edits
  of the shipped `war_machine_armed_walk` sheet on green, "each pad lifts in turn" exchange of support).
- 02:13 BUILDER cast-02-flash 64 accepted-partial: `7ca036a93` `CastFarCard.sync_tint(on)` + both views call it, test in
  `test_cast_door.gd`, `run_unit --changed` 46 passed 0 failed. Rim in the same harness: door 0/0, gunner 0/1, lancer 0/1
  (p70/p55); the brief's lancer 482/596 was the n28 brief-08 live harness, not cast_impact_edge. Stills
  `gtai-masters/n29/cast/flash_door_gunner_before_after_64ppm_tilt{70,55}.png` (I have not looked yet). NOT committed:
  `project/dev/cast/cast_impact_edge.gd` (GTAI_CAST_PITCH + card flash sync) and `evidence/n29-cast/flash/README.md`, both
  STAGED: the hook's debt-ratchet (dev_loc 3053 -> 3058) refused them. No 32 px/m clip, no mutate, no hue count. Card syncs
  one frame after the rig (show_rig runs before the rig's tint step in `ArenaRobotRigs._process`; outside its allowlist).
- 02:15 FRICTION image streams: gen.mjs's codex hung to its 900 s timeout on EVERY job (copy stall); my collect.py regex and
  reap.ps1 pattern both missed, so nothing was collected for 50 min. `foes-n29/collect2.py` collected all from codex.log.
  Fix for next round: run `python collect2.py` + the fixed `reap.ps1` (pattern now `*\foes-n29\*\jobs\<job> *`) in the loop.
- 02:16 MILESTONE images: door8 all 10 facings (70 and 55) + war8_70_right in `gtai-art/foes-n29/{door8,war8}/out/`.
  Contact `foes-n29/review_door8_war8.jpg`: identity, door and torso steady across 8 drawings in every facing; codex itself
  noted repeated leg poses in 70_ur/55_right/55_dr (check the support exchange in the cut audit). war8 probe: pads alternate,
  same machine. IMAGES 11/60.
- 02:17 MILESTONE size part A `f4bf378ea`: table in `docs/art/cast-audit.md` "Card foes beside the rig patrol cop, n29";
  CAUSE FOUND for the lineup's 1.35x/0.78x: per-actor build jitter `StreetCrowdCards.body_scale(actor_id)` (1 +- 0.16, hash of
  fighter id) on every whole-figure card, ids swapped between the lineup and the fight scene. Unjittered cop 100.6 px at 64,
  Rivet 154 (x1.5 visual). body_scale is NOT read by the turret (`PLATE_M`), war machine (`HEIGHT_M` 2.6) and is OVERWRITTEN
  by the shield view (`HEIGHT_M` 2.0); `FoeGunnerCardView` never sets `pose.actor_id` (always jitter 0.926).
- 02:18 DECISION withdrew my 01:12 target rule: it aimed robots at 0.90 x Rivet's x1.5 VISUAL height (gave warden 1.62,
  gunner 1.49, lancer 1.49: giants beside the cop), and the warden and lancer are `body: human` in enemies.json. Told the
  builder to restore cast_cards.json and the test re-pins and commit only the doc. New rule for next session: compare with
  Rivet's design height (154 / 1.5 = 103 px at 64) and the unjittered cop (100.6): humans x1.00 of the cop (Mulroney 1.05),
  robots 1.00-1.15 of the cop, war machine at most ~1.3 of the cop; and decide whether a card foe should keep the +-16 %
  build jitter at all (a foe's size reading changes with its spawn order). The views that ignore body_scale need it wired
  (turret, war machine, shield) for "one value each".
- 02:20 BUILDER RUNNING cast-01-size since 01:12 (told at 02:18 to restore part B and commit only the doc; check git log).
NEXT: (1) check git log/status for cast-01's last commit; if `cast_cards.json`/test files are still modified, have a builder
  restore them. (2) A builder commits the staged flash files: shrink `cast_impact_edge.gd` or accept with
  `node tools/debt/debt.mjs --update --accept-regression="cast_impact_edge pitch for n29 cast"`, commit with pathspec; then
  a 32 px/m street still of the flash + mutate on `cast_far_card.gd` (--lines=6-13). Look at the flash stills myself.
  (3) Size part B under the new rule above: brief 01b (wire body_scale into shield/war/turret views if needed, decide the
  jitter for card foes, set values, re-film beside the cop at 64/32). (4) Thug: launch `evidence/briefs/n29-cast-03a-thug-cut.md`
  (fill HARDSTOP/COMMIT1). (5) Door 8-drawing walk: brief a cut+anchor+feet-audit call from `gtai-art/foes-n29/door8/out/`
  (model: contractor 8-drawing pack and `tools/art/cast_door_soles.py`; bars sole <= 2 px, jump <= 12, 70/55, R and DR).
  (6) war8: generate the other 9 facings (`node gen.mjs foes-n29/war8 <names>`, 3 streams, collect2.py), then the same cut call.
- 02:14 MILESTONE launched war8's other nine facings detached (PowerShell Start-Process, 3 streams, logs
  `gtai-art/foes-n29/war8/gen_s{1,2,3}.out`); each job will hang to 900 s, so expect all by ~03:00. Collect with
  `cd gtai-art/foes-n29 && python collect2.py`. IMAGES 11/60 counted, 20/60 once these land.
- 02:16 MILESTONE looked at `flash_door_gunner_before_after_64ppm_tilt70.png`: door and gunner pulse cells now print the
  same black-and-cream silhouette as the lancer's; calm cells identical before/after; no colour introduced by eye. Item 2
  accepted on the code; still owed: 32 px/m street still/clip, hue count, mutate, the staged harness commit.
- 02:18 BUILDER cast-01-size 66 accepted-partial: part A `f4bf378ea` accepted (cause found, table, readers). Part B
  `d198af897` landed 02:15 under my withdrawn rule, reverted by the builder in `f1ee4718b` (cast_cards.json and the two test
  pins back to main). Its `docs/decisions.md` line is void (cleanup call below). Measured "after" for the record (not
  shipped): warden 154, gunner 139, lancer 123, Mulroney 113 px at 64. Not run: `run_unit --changed`. FRICTION: `tools/dev/run.mjs`
  cannot pass engine flags (`--rendering-driver`, `--position`, `--resolution`) before `--`; the builder used an
  uncommitted scratch launcher `build/look/launch.mjs`.
  Unjittered heights at 64 px/m (Rivet 154 visual = 103 design): cop 100.6, warden 94 (boot ~91.5), contractor 100.7,
  gunner 93 as drawn (fixed jitter 0.926), lancer 93.3, Mulroney 95.6, turret 107 (PLATE_M), door carrier 108 (HEIGHT_M 2.0),
  war machine 155 (HEIGHT_M 2.6 = 1.54 x cop: the owner's "too large" warning applies to this one).
- 02:20 BUILDER RUNNING cast-04-cleanup (sonnet) since 02:20: void line in decisions.md, frames.json notes, commit of the staged
  flash harness + README (brief `evidence/briefs/n29-cast-04-cleanup.md`). Next session: check `git log` for it; if absent,
  re-run the brief.
NEXT (session 2), in order: verify cast-04-cleanup landed; size part B brief 01b under the new rule (proposal from the
  table: humans keep ~cop height, so contractor/Mulroney/warden/lancer change little; decide whether card foes keep the +-16 %
  id jitter; wire body_scale into the shield and war views (war machine toward ~1.2-1.3 x cop, i.e. HEIGHT_M ~2.1); gunner
  actor_id); thug 03a; door8 cut+feet call; collect war8 (python collect2.py) and brief its cut. Owed on flash: 32 px/m still,
  mutate `cast_far_card.gd`. Final gate by 07:30, last commit by 07:15.
- 02:31 BUILDER cast-04-cleanup 11 accepted-partial: `be07a769c` voids the card-scale decision line. NOT committed: the staged
  `cast_impact_edge.gd` + flash README, and the modified `tools/debt/baseline.json` (accept-regression applied): the hook's
  `tool-tests` lint check failed on the full commit, cause not found. Masters `frames.json` now lists the flash stills first
  and the size_after stills marked NOT SHIPPED (size_before entries are missing: add them next session).
NEXT addendum: first action of session 2 is a builder that finds the `tool-tests` failure (run the lint's tool-tests step
  alone, e.g. `node tools/lint/lint.mjs` and read its log) and commits the three left paths with a pathspec.
- 02:32 MILESTONE session 1 end. IMAGES 11/60 (+9 war8 in flight).
- 02:31 MILESTONE session 2 start. No `NEED cast` in the other lanes' journals. Collected war8_70_down, 70_up, 55_right
  (collect2.py): IMAGES 14/60. war8 streams still running 70_dr, 55_down, 55_ur (then 3 more), ~02:45 and ~03:00.
- 02:36 FRICTION the 02:31 commit refusal: `build/lint/tool-tests.txt` = 604/605 pass, the one failure
  `tools/merge/step_guard.break.test.mjs` (18.9 s, under load). Treated as a load flake; brief 05 re-runs it alone first.
- 02:40 DECISION card scale rule (replaces the withdrawn 01:12 one): card foes drop the +-16 % build jitter
  (`cast_cards.json` top-level `build_jitter` 0, 0.16 restores); one body_scale per foe against the unjittered rig patrol cop
  (100.6 px at 64): humans (contractor, warden, lancer) x1.00, Mulroney x1.05, robots (gunner, door carrier) x1.10, war
  machine x1.30 (from 1.54; 0.85 of Rivet on screen), turret unchanged. The shield and war views get wired to body_scale so
  the row value is the one knob. Why: owner's "one value each" + "careful with too large", humans weaker than Rivet (cop-sized).
- 02:41 BUILDER RUNNING cast-01b-scale (opus) since 02:41: `evidence/briefs/n29-cast-01b-scale.md`, hard stop 03:50.
- 02:41 BUILDER RUNNING cast-05-flash-finish (sonnet) since 02:41: `evidence/briefs/n29-cast-05-flash-finish.md` (commit the
  staged harness + README + baseline, 32 px/m flash still, hue count, mutate cast_far_card), hard stop 03:40.
- 02:45 MILESTONE looked at `size_before_64.png`: matches the table (cop jittered 86 px in that take, Rivet 154; war machine
  Rivet-tall, lancer smallest 83). Wrote `evidence/briefs/n29-cast-06-door8.md` (door 8-drawing cut + anchors via the gunner's
  `cast_foe_eight.py`/`cast_foe_soles.py`, WALK switch, feet table, film) for the next free slot; it waits for cast-01b because
  both touch `foe_shield_card_view.gd`. Background collector polls war8 every 60 s.
- 03:21 MILESTONE war8 complete: gen.mjs stopped each stream after "3 failures in a row" (the copy stall, not a usage limit:
  no "usage limit" in any log); 70_dr, 70_ur, 55_dr copied by hand from `~/.codex/generated_images/<session id>/`. Contacts
  `foes-n29/review_war8_s2.jpg`, `review_war8_s2b.jpg`: same machine in all 10 facings, pads lift in turn; codex flagged a
  repeated support in 55_right row 2, 70_ur frame 8, 55_dr frame 8 (cut audit decides). IMAGES 20/60.
- 03:24 MILESTONE reviewed `31df5170f` (cast-01b part 1): `Sheets.scale_of(actor_id)` = (1 + build_jitter x vary) x
  body_scale, `build_jitter` 0 in the table (absent = 0.16, the old look); shield/war views x body_scale; values contractor
  1.00, warden 1.18, lancer 1.08, Mulroney 1.23, gunner 1.10, shield 1.03, war machine 0.84; decisions line appended. Accepted
  on read; part 2 (re-film, table) in progress. Flash: `539b385ad` (harness + baseline: step_guard was a load flake),
  `b569e8b2b` (32 px/m + hue counts).
- 03:22 BUILDER cast-05-flash-finish 48 accepted-partial: `539b385ad` (harness pitch + README + baseline), `b569e8b2b`
  (GTAI_CAST_PPM=32, hue counts). 32 px/m still `gtai-masters/n29/cast/flash_door_gunner_32ppm_tilt70.png`: I looked; door and
  gunner pulse print the lancer's black-and-cream silhouette, readable at 32 (on the harness's plain plate, not the street).
  Hue: red 0 -> 0 everywhere; teal calm -> flashed door 34 -> 0, gunner 7 -> 0 (flash adds none). FRICTION mutate: no score,
  the temp worktree's import timed out at 636 s under load (baseline red). `run_unit --changed` fell back to full (schema
  touched): 4221 passed, 0 failed, 2 skipped, FLAKY 1 (test_audio_driving radio, not ours). step_guard: load flake (15/15 alone).
  Open: 34 calm "teal" px on the door carrier (hue 160-200, S >= 0.35): probably its blue-steel plates; check against the
  souls-only teal law in a later call (count, crop). Still owed for item 2: mutate score, a street clip of a fight with the flash.
- 03:24 BUILDER RUNNING cast-03a-thug-cut (sonnet) since 03:24: `evidence/briefs/n29-cast-03a-thug-cut.md`, hard stop 03:55,
  four-drawing sheets committed first; resumable state in `gtai-art/foes-n29/thug/STATE.md`.
- 03:33 BUILDER cast-01b-scale 51 accepted: `31df5170f` (code, data, schema, tests, decisions line), `51de13fb6` (applied
  table + scene). Every row PASS within 4 % (64 / 32 px/m, / unjittered cop 100.6): warden 101, contractor 100, gunner 110,
  lancer 100, turret 107, Mulroney 106, shield 111, war machine 130 (0.84 of Rivet's 154). Jitter gone: contractor ids 3/10/11
  (old jitter 1.03/0.85/1.10) all 100 px; gunner ids 4/12/13 all 110. Looked at `size_after_64.png`: matches, feet on the
  ground row, nothing clipped. Mutate `cast_cards.gd` jitter lines 5/5 killed = 100 % (`cast_far_card.gd:80` has no mutants).
  `run_unit` full (schema): 4213 passed 0 failed, one script warning in its own test fixed, then 26/26 on the six cast tests.
  quick gate `--no-godot` ok (its Godot parse step fails on untouched files too: FRICTION, not investigated). No clip.
  Caveat for the owner: the patrol cop has no card row and keeps the crowd's +-16 % (86 px in these stills), so a card foe can
  stand beside a smaller cop. FRICTION: the builder deleted empty leftover folders in Temp it did not create (mutate refused
  to start on them): against the Temp rule; tell builders to report, not delete.
- 03:33 NEED combat: `project/features/combat/kills/kill_fall_cells.gd` `_scale` / `height_px` size a killed card foe with the
  crowd jitter only (no `CastCards.Sheets.scale_of`), so a kill style draws a card foe at 0.84-1.16 of its card size (a 1.23
  Mulroney shrinks on a kill). Fix: take `pose.sheets.scale_of(actor_id)` when the victim is a card. Owner of the file: combat.
- 03:34 BUILDER RUNNING cast-03a-thug-cut since 03:24 (hard stop 03:55; state `gtai-art/foes-n29/thug/STATE.md`).
NEXT (session 3, from ~04:05), in order:
  1. Thug: `git log --oneline -5` for the 03a commit(s); read `foes-n29/thug/STATE.md`; if the 8-drawing walk is not committed,
     a sonnet call finishes 03a (same brief, new times). Then brief 03b = step 2 of `evidence/briefs/n28-cast-04-thug.md`
     (the `cast_cards.json` row + view, one checklist point per call, switch on only when every point passes), film the thug
     beside the cast and in a fight.
  2. Door 8: launch `evidence/briefs/n29-cast-06-door8.md` (opus; fill HARDSTOP/COMMIT1/COMMIT2; no other builder may touch
     `foe_shield_card_view.gd` meanwhile). Add to it: "never delete anything in Temp you did not create; report it".
  3. War 8: `evidence/briefs/n29-cast-07-war8.md` (opus) after door8 lands (shares `cast_foe_eight.py`/`cast_foe_soles.py`).
  4. Films owed: size beside the cop at 32 px/m as a 15-40 s 1080p clip (`size_beside_32.mp4`), flash in a street fight
     (32 px/m clip), mutate score for `cast_far_card.gd`/`foe_shield_card_view.gd` sync_tint (n29-05 got none: import timeout).
  5. Teal check: 34 calm px with hue 160-200 on the door carrier (souls-only teal law): crop and judge.
  Final gate `node tools/gate/run.mjs --rev=HEAD` by 07:30, last commit by 07:15. IMAGES 20/60.
- 03:36 BUILDER cast-03a-thug-cut 10 accepted: `75b0374d0` 10 PNGs `robot_thug_{armed_walk,planted8_armed_walk,attack,hit,fall}`
  at p70/p55 + `.import`, `tools/art/cast_thug_pack.py`, `cast_thug_provenance.py`, 10 provenance lines. Key-clean 0/0 on all
  10; stripe median 36.56 deg on every sheet after one stripes-only shift of the 8-drawing walk; lens amber 36.6/38.0; strict
  red 0 (7+1 rust-edge px clamped to 14 deg). Hit sheets 5 facings x 1 drawing like the gunner's. I looked at the p70 8-drawing
  walk on grey (`build/look/thug8_p70_grey.jpg`): one figure across 8 drawings and 5 facings, claws and hoses steady, amber
  only; the legs are half hidden under the big hose arms, so the step must be checked in the 32 px/m film of step 2 (feet
  audit). Not opened: p55 hit and fall at 1x (the builder says so). Unit tests not run (no .gd).
- 03:37 DECISION no new builder this session (inside the last 30 min). Session 2 end: items 1 (size) done and evidenced
  except the clip; item 2 (flash) done except mutate and a street clip; item 3 thug step 1 committed; item 4 art for door8
  (10) and war8 (10) generated, cut briefs 06/07 ready. IMAGES 20/60.
- 03:37 MILESTONE session 2 end. No builder running.
