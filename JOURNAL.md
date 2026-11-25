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
- 03:36 MILESTONE session 3 start. No `NEED cast` in the other lanes' journals. 03a thug cut is in (`75b0374d0`).
- 03:38 DECISION thug step 2 and door8 run in parallel on split files: the thug builder owns `cast_cards.json`,
  `cast_cards.gd`, `cast_card_kinds.gd`, `arena_robot_rigs.gd`, `cast_feet*.gd/.py/.mjs` and new `cast_thug_*`; the door builder
  owns `cast_door_anchors.gd`, `foe_shield_card_view.gd`, `cast_foe_eight.py`, `cast_foe_soles.py`, `cast_door_*.py`,
  `test_cast_door.gd`, `cast-audit.md`, provenance, and makes the WALK switch live inside the generated anchors file (or ships
  WALK = FOUR with a NEED diff). Both commit with a pathspec; one lane Godot lock.
- 03:38 BUILDER RUNNING cast-03b-thug-card (opus) since 03:38: `evidence/briefs/n29-cast-03b-thug-card.md`, row off, hard stop 04:50.
- 03:38 BUILDER RUNNING cast-06-door8 (opus) since 03:38: `evidence/briefs/n29-cast-06-door8.md` (+ Added 03:45), hard stop 04:50.
- 03:37 MILESTONE teal check closed (director, by read): `shield_robot_armed_walk.png` px with hue 160-200, S >= 0.35,
  V >= 0.35 = 33 (p70) / 68 (p55) of ~0.4 M opaque, all single specks on the blue-steel plate rims (e.g. 46,93,115);
  marked crop `build/look/dir3/door_teal_p70.png`: no teal read anywhere, not a souls-colour conflict. Without the V floor the
  count is 9035 (near-black ink with a cyan cast): the n29-05 count of 34 matches the V-floored one.
- 03:37 MILESTONE looked at `size_after_32.png`: the one patrol cop in each panel is jittered small (43 px at 32 = 0.86), so
  the contractor (49) and warden (51) read 1.14-1.19x a cop. Matched to the unjittered cop (50 at 32) they are 0.98-1.02.
  The owed 32 px/m clip (brief `n29-cast-08-films.md`, written) shows three cops with their heights labelled.
- 04:04 BUILDER cast-03b-thug-card 26 accepted: `19c72dfdb` (row off, FoeThugCardView, CastThugAnchors via new
  `cast_thug_soles.py`, test), `d49ce6eb5` (measured, row off). body_scale 1.45 (his cells are ~190 texels like the gunner's;
  1.0 = cop size). 32 px/m: sole 0.00 px all four, body jump <= 9.60 (walk/stop/turn/reversal, both pitches), 8.44
  drawings/s, height 144/154 at 64 (0.935 of Rivet, head to claw tip). Walk step scaled by body_scale (raw 0.1959 m gave 12.25
  drawings/s). run_unit full 4228/0/2 (FLAKY test_audio_driving). Looked at `thug_beside_64ppm_tilt70.png`: hulking amber-
  striped brawler with box head + amber lens, a head under Rivet, broad, claw hangs in front of the feet; feet on the lane
  line, shadow under. Open: 70 down/dr cells put the claw tip on the foot line (shoes 10-30 texels above), so attack/hit/fall
  may float: the cutter needs a shoe-based foot line. Ink, rim, shadow, palette, attack/hit/fall film, 55 size not done.
- 04:05 MILESTONE door8 part 1 in: `073321ae7` (sheets, key-clean, provenance). Part 2 in progress.
- 04:06 BUILDER RUNNING cast-08-films (sonnet) since 04:06: `evidence/briefs/n29-cast-08-films.md`, hard stop 04:58.
- 04:14 BUILDER cast-06-door8 38 accepted (result: eight NOT shipped): `073321ae7` (sheets p70/p55, body heights match the
  four within 0.4 px, key-clean 0/0, strict red 0 after lifting 129/148 burnt-orange stripe shadows to amber, provenance),
  `fac845dd9` (anchors carry FOUR + EIGHT tables, `SHEET = WALK`, `WALK = FOUR`; `FoeShieldCardView.walk_sheet`; audit
  section; film `gtai-masters/n29/cast/door8_walk_32.mp4` 1920x1080 60/1 25.85 s rendered from a staged copy with EIGHT;
  still `door8_feet_before_after_64.png` tick 150). Feet (tool's 32 px/m unit), four -> eight: 70 right sole 5.08 -> 8.88,
  70 dr jump 11.01 -> 13.71, 55 right 3.29 -> 6.16, 55 dr jump 10.31 -> 13.02: the eight is worse; p70 right drawing 7 steps
  forward (second contact not planted in the art). run_unit full 4228/0/2. Mutate 1/1 (one mutant only). Looked at the
  still: footprint boxes spread along the line on both walks; Rivet beside for scale.
- 04:14 FINDING (door8 builder): `FoeShieldCardView.update_fighter` rescales (0.824 px/texel) after the anchored placement at
  base scale (0.584), so every sole lands 1.41x (p55 1.2x) from the pivot and slides: a placement bug, not only art. Its
  re-plant probe halves the shipped four's slide (70 right 5.08 -> 2.42, 55 right 3.29 -> 2.03).
- 04:16 DECISION ship the re-plant first (it fixes the shipped walk for everyone), then judge the eight again with the fix;
  if the eight still fails the right facing, one image edit row per failing facing (70 right, 55 right) next session.
- 04:16 BUILDER RUNNING cast-09-door-replant (opus) since 04:16: `evidence/briefs/n29-cast-09-door-replant.md`, hard stop 04:58.
- 04:16 BUILDER RUNNING cast-08-films (sonnet) since 04:06 (size clip with three cops, flash street clip, mutate far card).
- 04:45 BUILDER cast-09-door-replant 29 accepted: `61c383438`. `FoeShieldCardView._rescale` keeps the anchored sole's world
  point through the height rescale (walking only); `CastCardKinds.rows()` keys 4 on `FOUR`, `cell_ratio()` 1.0 for FOUR and
  EIGHT. Read the diff: placement re-derives position every frame, so no drift. Feet (tool unit), four before -> after:
  70 right 5.08/6.04 -> 2.42/4.34, 55 right 3.29/6.29 -> 2.03/5.09, dr jumps 10.50 / 10.43 (soles hidden by the slab);
  eight after: 70 right 2.83/6.47, 70 dr 1.39/12.21, 55 right 2.16/9.61, 55 dr 3.45/13.28. Nothing passes every bar; WALK
  stays FOUR. Size unchanged 111 px at 64. No other card view rescales after an anchored placement (gunner/thug scale only
  the shadow; war/turret have no anchored contact). run_unit full 4230/0/2 (FLAKY test_audio_driving). Mutate 7/11 = 63.6 %
  (3 survivors: line 80 height formula, no test pins the door height; 1 facing index right/left symmetric).
- 04:45 FRICTION quick gate's Godot parse step fails "Failed to compile depended scripts" on untouched files (gunner view)
  in this checkout: every builder ran it `--no-godot` and relied on GUT. Not investigated (30+ min).
- 04:46 MILESTONE session 3 end: no new builder (last 30 min). IMAGES 20/60 (none this session).
- 04:46 BUILDER RUNNING cast-08-films (sonnet) since 04:06, hard stop 04:58: untracked at 04:44 = `project/dev/cast/
  cast_flash_fight.{gd,gd.uid,tscn}`, `cast_size_beside_walk.{gd,gd.uid,tscn}`, `tools/film/cast_n29_films.mjs`, modified
  `tools/debt/baseline.json` (its "films for n29 cast" entry). Not committed yet at 04:44.
NEXT (session 4, from ~05:05), in order:
  1. Films: `git log --oneline -5`; if the 08 builder's files are still uncommitted, a sonnet call commits them (gate first)
     and finishes what is missing (`size_beside_32.mp4` with three cops, `flash_street_32.mp4`, mutate cast_far_card). Look
     at both clips yourself (extract frames).
  2. Thug: `evidence/briefs/n29-cast-03c-thug-footline.md` (opus; fill HARDSTOP/COMMIT1/LASTCOMMIT): shoe foot line in the
     cutter, attack/hit/fall on the ground, poses still + `thug_fight_32.mp4`. Then 03d = remaining checklist (ink, live rim,
     shadow toggle, palette, 55 size), one point per call where it can fail; switch on only when all pass.
  3. Door: a call that (a) makes the EIGHT flip one value inside `cast_door_anchors.gd` (generator emits the selected tables;
     today it needs WALK, WALK70, WALK55, WALK_STEP_M), (b) adds a door height test (kills the line-80 survivors), then
     (c) image edits for the eight's failing facings: p70 right (drawing 7 steps forward, second contact unplanted) and the dr
     body jump (13.3/12.2): one row per job of `foes-n29/door8/out/door8_70_right.png` etc., director-run gen.mjs.
  4. War 8: `evidence/briefs/n29-cast-07-war8.md` (opus); it shares `cast_foe_eight.py`/`cast_foe_soles.py` (door used
     `cast_door_eight.py`, so they are free). Mind the owner's size rule (war machine 0.84 of Rivet now).
  5. NEED combat (`kill_fall_cells.gd` card scale) stays open in combat's lane.
  Last commit 07:15, final gate `node tools/gate/run.mjs --rev=HEAD` by 07:30. IMAGES 20/60.
- 04:51 BUILDER cast-08-films 44 accepted-partial: `bdad87c60` (scenes `cast_size_beside_walk`, `cast_flash_fight`, tool
  `tools/film/cast_n29_films.mjs`, debt accepted). `size_beside_32.mp4` 1920x1080 60 fps 33.75 s: 8 card foes, 3 cops
  (x0.92/0.85/1.10), Rivet walking; BUT its labels are nominal (50 px x actor scale), not measured in the frames: the
  measured numbers stay the stills' table (`51de13fb6`). `flash_street_32.mp4` 1920x1080 60 fps 25.0 s, door (FOUR) and
  gunner, 20 flashes each. Looked at `flash_door_3hits_x3frames_32.png`: the door turns a black silhouette with cream
  speckle for ~3 frames per hit, no red, no teal; readable at 32 px/m. Mutate cast_far_card not run (time). frames.json 14.
- 04:51 FINDING (films builder, important for item 2): in a street fight `ArenaRobotRigs._react`
  (`project/features/arena/arena_robot_rigs.gd:101`) only shoves the rig on a hit (`rig.hit(away, HIT_SHOVE)`); no hit clip
  tints a robot rig there, so the card flash of `7ca036a93` (card tints while the rig is tinted) never fires on the street:
  the clip drives `RigClips.hit` from the dev scene. Next: check whether the gauntlet/arena path tints robot rigs (grep
  `RigClips.hit` callers); if no live path does, a cast call adds the tint to `_react` (cast owns that file, smallest edit,
  rendering only) and re-films the flash without the scene driving it. Until then item 2 is NOT live for robots in the street.
NEXT addendum (session 4): insert as step 1b, before the thug: the robot flash live-path check + fix above (sonnet, small),
  and measure heights in `size_beside_32.mp4` frames (not nominal labels) in the same call if cheap.

## Session 4 (04:50, iteration 4, BUILD)
- 04:50 read JOURNAL, git log (HEAD `416c47a21`, tree clean), grep `NEED cast` in keys/combat/yard journals: none.
- 04:52 checked the flash live-path finding by read: `set_tint` is called only from `RigClips.sample` (`hit_t >
  HIT_TINT_FROM`); `hit_t` is set only by `RigClips.hit` / a feed `Clip.HIT` row (cops in `arena_rigs.gd:212`);
  `ArenaRobotRigs._react` calls only `rig.hit(away, 40)`. Confirmed: no robot card flashes in a live fight.
- 04:58 BUILDER RUNNING cast-10-flash-live (sonnet) since 04:58: `evidence/briefs/n29-cast-10-flash-live.md`, hard stop 06:00.
- 04:58 BUILDER RUNNING cast-03c-thug-footline (opus) since 04:58: `evidence/briefs/n29-cast-03c-thug-footline.md`, hard stop 06:05.
