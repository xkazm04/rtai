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
- 04:56 IMAGES 21/60: one edit job (director-run gen.mjs, `gtai-art/foes-n29/door8b/`, 187 s, no stall) of
  `door8/out/door8_70_right.png`: only drawing 7 redrawn (support boot back ~30 px of drawing 6, other boot lifts and passes),
  1-6 and 8 kept. Looked at `door8b/out/door8_70_right_f7.png`: drawing 7 now reads as the mirror of drawing 3, same robot,
  shield fixed, key green. Not cut yet (next: brief 11, re-pack p70 right + one-value EIGHT switch + door height test).
- 05:00 MILESTONE `c0a1b816e` (cast-10 commit 1): `ArenaRobotRigs._react` calls new `RigClips.flash()` (hit_t = HIT_S, no
  shove) beside the robot's own 40 px shove; test `test_arena_robot_flash.gd`; `cast_flash_fight` `_flinch` removed. Read the
  diff: 1 + 5 lines, rendering only. Film pending.
- 05:07 MILESTONE `588c7b706` (cast-03c commit 1): thug cutter `replant` moves CUT cells by whole texels onto the shoe sole
  (gap up to 26 -> <= 1 texel); resting fall cells' body bottom on the ground row; p70 four-walk kept (support shoe hidden
  behind the claw, row walks the planted8). Looked at `build/look/n29-thug/foot/fall70_after.png`: every fall cell on the
  line; BUT the up-facing column (5th) never falls: all three drawings stand (art, not cutter). Checklist item for 03d.
- 05:12 MILESTONE `8d665f61e` (cast-10 commit 2): `flash_street_32.mp4` re-shot on the live path, ffprobe 1920x1080 60/1
  25.02 s. Looked at `gtai-masters/n29/cast/flash_live_64.png`: left panel door carrier flashed (black/cream ink silhouette,
  shield and pack readable), gunner unflashed; right panel the reverse; Rivet and the street unchanged, no red, no teal.
- 05:19 BUILDER cast-10-flash-live 23 accepted: `c0a1b816e`, `8d665f61e`. Only robot host is `ArenaRobotRigs` (street,
  arena, gauntlet); door, gunner, thug views `sync_tint` -> all three flash live now; turret and war views have no
  `sync_tint` (do not flash; outside the owner's item). No extra flinch pose (robot feed ignores `active()`). Flashes 20
  door / 20 gunner in 25 s. run_unit --changed full 4231/0/2 (FLAKY test_audio_driving). Mutate 5/6 = 83.3 % (survivor:
  the shove direction sign). Item 2 (hit flash door + gunner) DONE on the live path.
- 05:19 BUILDER RUNNING cast-11-door8-f7 (opus) since 05:19: `evidence/briefs/n29-cast-11-door8-f7.md`, hard stop 06:12.
- 05:22 MILESTONE `f867fd556` (cast-11 commit 1): door eight p70 right drawing 7 re-packed from the f7 edit (only that cell),
  EIGHT70 regenerated, provenance. Feet table pending.
- 05:30 MILESTONE `a679e3fa5` (cast-03c commit 2): `thug_poses_64ppm_tilt70.png`, `thug_fight_32.mp4` (ffprobe 1920x1080
  60/1 20.02 s). Looked at the still: wind-up, lunge, snap, hit, fall rest read, soles on the shadows, a head under Rivet,
  but the five poses OVERLAP (spacing ~1.3 m for a 2 m reach): hard to read each; re-space next time. Looked at 5 clip frames
  (every 4 s, crop): three thugs ring Rivet with claws out, one goes pale on a hit (the live flash), dead ones lie dark on
  the street with debris; no teal; the red star on Rivet at 12 s is combat's impact spark on him (not our art).
- 05:33 BUILDER cast-03c-thug-footline 38 accepted: `588c7b706`, `a679e3fa5`. Gaps up to 26 -> <= 1 texel on every
  attack/hit/fall/p55-walk cell (moved cells pure translations, others byte-identical); p70 four-walk kept (support shoe
  hidden behind the claw; the row walks the planted8). Tell 48 ticks before the snap, hits hold 12 ticks (0.20 s), falls
  reach rest (frames 638 / 765 / 891). Flash visible (frame 288). Strict red 1-5 px per sheet, all shipped rust edges (75b0374d0).
  run_unit full 4231/0/2. Open: the stop after a walk-in floats 8-10 px (frame 640, by eye); the lunge needs `guard_tell`,
  which the live game sets (`gunplay_hook.gd:47`, `arena_arsenal.gd:56`): checked by grep, fine.
- 05:33 FINDING `cast_flash_fight.gd` (`8d665f61e`) has CRLF/LF mix + a long line: quick --no-godot red. Fix in 03d-B first.
- 05:34 BUILDER RUNNING cast-03d-B (sonnet) since 05:34: `evidence/briefs/n29-cast-03d-thug-checklist.md` PART B, hard stop 06:12.
- 05:36 MILESTONE `62aa13f5a` (cast-11 commit 2): door walk switch is ONE value now (`WALK70/55`, `WALK_STEP_M` derived
  from `WALK`), tests follow WALK, height formula test. Feet with f7 (tool's 32 px/m unit, sole / jump): 70 right four
  2.42/4.34, eight 2.83/6.47 -> 2.04/6.47; 70 dr four U/10.50, eight 1.39/12.21; 55 right four 2.03/5.09, eight 2.16/9.61;
  55 dr four U/10.43, eight 3.45/13.28. WALK stays FOUR (eight's jump worse in every facing). The codex edit re-encoded
  every drawing (mean 4.6-4.9 levels): the builder spliced only drawing 7's cell, 39/40 p70 cells byte-identical. Good catch.
- 05:37 DECISION door eight: no more image edits for it tonight. Looked at `door8/out/door8_55_right.png`: row 2 repeats
  row 1's leg sequence and drawing 8 swaps the support early (the 7 -> 8 jump); fixing it needs 3+ one-row edits with
  uncertain hits (one edit moved one number by 0.79), while the war machine's walk is still the four with no exchange
  (sole 24.75). The eight stays one value away (`CastDoorAnchors.WALK`); next edits named in `docs/art/cast-audit.md`
  "Door eight with the redrawn drawing 7": p55 drawing 8 (right, down-right), p70 down-right drawing 1.
- 05:44 BUILDER cast-11-door8-f7 24 accepted: `f867fd556`, `62aa13f5a`. One-value switch (`EIGHT70 if WALK == EIGHT else
  FOUR70`), test for derived tables + door height formula, mutate foe_shield_card_view lines 6,8,80: 4/4 = 100 %.
  run_unit full 4231/0/2. Film `door8_walk_32.mp4` re-shot as eight+f7 from a staged copy (25.85 s), still updated.
  Hook: `step_guard.break.test.mjs` flake once (passed alone).
- 05:45 BUILDER RUNNING cast-07-war8 PART 1 (opus) since 05:45: `evidence/briefs/n29-cast-07-war8.md` (+ Added 05:44), hard stop 06:15.
- 05:45 MILESTONE `996160bb4` (cast-07 part 1): `war_machine_planted8_armed_walk.png` p70 + p55, new `tools/art/cast_war_eight.py`,
  provenance 2 lines. Looked at `build/look/n29-war8/war8_70_1x.png` (rows 1-4 the shipped four, 5-12 the eight, 5 facings):
  same machine and size as the four, striped pads lift in turn in down/dr/right, amber louvres, no red/teal. Not on yet
  (view, anchors, feet table = part 2).
- 05:48 BUILDER cast-07-war8-p1 4 accepted: `996160bb4`. Heights within 0.4 px of the four at both pitches, key-lead 0,
  strict red 0 (the four ships 149/189 burnt-orange px; the cutter lifted them to amber). First-pass planted-pad table in
  `foes-n29/war8/STATE.md`: 70 dr and 55 dr exchange cleanly (L x3, R x5), 70 ur weak (R alone in 1 of 8), 70 up shifted by 2.
- 05:49 BUILDER RUNNING cast-07-war8-p2a (opus) since 05:49: anchors + view switch at WALK = FOUR + feet into STATE.md, hard stop 06:14.
- 05:51 BUILDER cast-03d-B 17 accepted: `c8b794054`. Palette PASS (strict red <= 60 px of 867k, isolated; teal 6 px; navy
  1.9-2.9 %, the war machine/door are navy-plated too, shipped look), shadow PASS (394 vs patrol 161), up-facing fall PASS
  (drawing 1 stands, 2-3 lie: I misread `fall70_after.png` at 05:07, the back view lying feet-first looked standing).
  FAIL: size at 55, 64 px/m: 151 vs Rivet 150 (1.007); FAIL: the stop at 70 (soles 4 px above the ground row at 64, the ring
  25 px below it). Flash scene: the committed blob was LF already (working copy only). Quick's `test_cast_door_walk.gd`
  would-reformat is working-copy only too: `gdformat --check` on the HEAD blob = unchanged.
- 05:51 DECISION thug `body_scale` 1.45 -> 1.42 (one value; 55 at ~0.99 of Rivet, 70 at ~0.92): the owner's rule keeps
  enemies near Rivet's size, never taller; 1.40 fallback if 55 still > 1.00.
- 05:52 BUILDER RUNNING cast-03e-thug-fixes (sonnet) since 05:52: `evidence/briefs/n29-cast-03e-thug-fixes.md` (+ Added 05:51), hard stop 06:15.
- 05:53 STATE of the owner's four items: (1) card foe scale: measured + applied in session 1-2 (`31df5170f`, `51de13fb6`,
  decisions.md line 1570), films `size_after_{64,32}.png`, `size_beside_32.mp4` (nominal labels, three cops). DONE.
  (2) hit flash door + gunner: on the live path (`c0a1b816e`), film + 64 still. DONE. (3) robot thug A: cut, card, foot
  line, poses + fight film, palette/shadow/fall PASS; open: size 55 (03e running), stop at 70, ink, rim; row OFF.
  (4) walk art: door eight shipped one value away, FOUR kept (measured worse); war eight cut in, anchors/view (p2a running).
- 05:52 MILESTONE `d9bfe36a7`: thug body_scale 1.45 -> 1.42 (one value). Measured in the beside frames: 55 deg 147/150
  (64) and 73/75 (32) of Rivet = 0.98 / 0.97; 70 deg 141/154 and 70/77 = 0.92 / 0.91. Size point PASS at both pitches.
- 05:56 BUILDER cast-03e-thug-fixes (call 1) 4 accepted: `d9bfe36a7` (size), `b9e434fc4` (stop cause, unconfirmed: the ring child
  at the card origin, solved onto the torso mark by the walk placement). drawings/s ~8.6 computed (not observed).
- 05:56 BUILDER RUNNING cast-03e-thug-fixes call 2 (sonnet) since 05:57: the stop fix, hard stop 06:16.
- 05:56 MILESTONE `20be6ffaa` (war8 p2a): `cast_war_anchors.gd` generated by new `tools/art/cast_war_soles.py` (FOUR/EIGHT,
  one-value `WALK` = FOUR, WALK70/55/STEP_M/ROWS derived), `FoeWarCardView.walk_sheet/walk_rows/walk_step_m`, `_walk_row`;
  FOUR_STEP_M = STRIDE_M / 4 so the four's stride is bit-identical (read the diff: old `stride_frame(walked/STRIDE_M)` ->
  `posmod(floor(walked/cycle_m*rows))`, cycle_m = STRIDE_M for the four; standing row = STAND_FRAME). Test pins the switch.
  run_unit FULL 4234/0/2. EIGHT_STEP_M 0.3244 m measured. Feet not yet.
- 05:58 BUILDER cast-07-war8-p2a 12 accepted: `20be6ffaa` (WALK = FOUR, no behaviour change). Feet NOT measured: needs a
  pad placement in the view (pin each drawing's registered pad, door `_rescale` model), a `war_machine` step entry in
  `project/dev/cast/cast_feet.gd` and a war copy of `tools/film/cast_door_films.mjs` (allowlist next call). By its read of
  `soles_70.png`: p70 right support F,F,R,R,F,F,F,R (not 4+4); p70 dr L x4, R x3, L again in 8 (drawing 8 repeats 4).
  STATE.md updated.
NEXT (session 5), in order. Use `date`: my journal times this session ran ~3 min ahead of the clock.
  0. `git log --oneline -12`; check what 03e call 2 (thug stop fix, sonnet, hard stop 06:16) committed: `evidence/n29/thug/fixes.md`.
     If the stop fix is not in, a sonnet call finishes it from fixes.md (`foe_thug_card_view.gd`, test, re-measure 70/55).
  1. In parallel at the session start (two builders, disjoint files), both hard stop 07:10, last commit 07:08:
     a. war8 p2b (opus): pad placement in `foe_war_card_view.gd`, `cast_feet.gd` war entry, `tools/film/cast_war_films.mjs`
        (copy of the door's), feet table four vs eight (both pitches, right + dr), audit section "Pile-driver on eight
        drawings, n29", WALK = EIGHT only if no worse than the four in every facing (the four: sole 24.75 / 22.97, jump
        13.22 / 13.35, all FAIL, so the bar is low), film `war8_walk_32.mp4` + 64 still if time. Brief: write `n29-cast-07b-war8.md`.
     b. thug 03d PART A (sonnet): ink + live rim (`evidence/briefs/n29-cast-03d-thug-checklist.md`, fill times, "PART A").
        If both pass and the stop is fixed, the director orders the switch call (row on, `docs/decisions.md` line,
        re-film `thug_fight_32.mp4` with the row on in the live game, no forced preview) only if it can commit by 07:15;
        else REPORT "Calls for the owner": thug ready, switch is one value.
  2. DONE 06:00: decision lines `f404e09cb` (cast-12, sonnet, 1 min).
  3. 07:15 last commit. 07:30 final gate `node tools/gate/run.mjs --rev=HEAD` (director, alone in the lane lock).
  4. After the gate: frames.json in `gtai-masters/n29/cast/` 8-15 entries best first (17 now: drop scratch-ish ones such as
     `flash_door_gunner_32ppm_tilt70.png`, the 3-hits sheets), REPORT.md, `node tools/evidence/cites.mjs REPORT.md`.
  IMAGES 21/60. Open owner calls: the thug's fall now lies up-screen of where he stood (feet at the point), unlike the
  gunner's centred fall; turret and war views have no hit flash (`sync_tint`); door eight one value away.
- 06:00 BUILDER cast-12-decisions 1 accepted: `f404e09cb` (three DECISION n29 cast lines). Brief `n29-cast-07b-war8.md`
  written for session 5 step 1a (fill HARDSTOP/COMMIT1/LASTCOMMIT).
- 06:01 BUILDER RUNNING cast-07b-war8 step 1 (opus) since 06:01: pad placement + test, hard stop 06:16 (the brief's
  times are this call's; the next call re-fills them and does steps 2-3).
- 06:07 MILESTONE `5d8e4b6f8` (07b step 1): `FoeWarCardView._plant` pins the registered pad (`pad_local` from CastWarAnchors)
  for a whole contact (key = contact half-cycle x facing x flip), re-derived after the scale every frame; replaces the
  old hold-within-one-drawing. Read the diff. NOTE: the shipped FOUR now gets this placement too (look change for the
  four: the next call must quote the four's feet before/after it, from `20be6ffaa` vs `5d8e4b6f8`).
- 06:09 BUILDER cast-03e-thug-fixes call 2 15 accepted-partial: `839ce02d8`. Ring now on the ground point
  (`FoeThugCardView.ground_local`, `_shadow.position` after draw_pose/_hold_stop): ring centroid 542.0 vs row ~540 (64),
  540.7 (32); was 25 / 12 px below. Test fails without the fix. run_unit FULL 4236/0/2. OPEN: soles still ~4 px above the
  row at 64 (bar 2): shift `_planted.origin.y` in `_hold_stop` by the stand cell's sole gap from `CastThugAnchors`;
  55 not re-measured; walk feet not re-run (body transform untouched, so they stand).
NEXT update (session 5): step 0 = the thug soles-at-stop call (sonnet, `fixes.md` plan, `foe_thug_card_view.gd`, re-measure
  70 + 55, walk feet re-run); it shares `foe_thug_card_view.gd` with nobody, so it can run beside 07b steps 2-3 (opus,
  re-fill the brief's times; step 1 is in `5d8e4b6f8`). 03d PART A (ink + rim) after whichever finishes first.
- 06:09 BUILDER cast-07b-war8 step 1 9 accepted: `5d8e4b6f8` (pad placement, test: pad world point holds within 0.01 px
  over a contact; held-walk test re-pinned to the pad; run_unit FULL 4236/0/2; debt accepted, view 214 lines / test 228).
  The four now follows the pinned pad inside a contact: its after-numbers are owed (next call step 2 measures four before
  = `20be6ffaa`, after = HEAD, and the eight).
- 06:10 MILESTONE session 4 end. No builder running. Builders this session: 10 calls (10, 03c, 11, 07p1, 03d-B, 07p2a,
  03e x2, 12, 07b-1), all accepted (03e call 2 partial). IMAGES 21/60. BUILDER RUNNING: none.

## Session 5 (06:08)
- 06:09 No NEED cast in the other lanes' journals. 03e call 2 is in (`839ce02d8`, ring on the ground point); soles open.
- 06:12 BUILDER RUNNING cast-03f-thug-soles (sonnet) since 06:12: `evidence/briefs/n29-cast-03f-thug-soles.md`, hard stop 06:50.
- 06:12 BUILDER RUNNING cast-07b-war8 steps 2-3 (opus) since 06:12: brief "Added 06:11", hard stop 07:10, commit 2 by 06:50.
- 06:24 BUILDER cast-03f-thug-soles 12 accepted: `1115a7e30`, `b15cd2909`. `_hold_stop` shifts the held drawing by
  `sole_gap(h)` (registered sole from `CastThugAnchors` to `h.pos.y * PX_PER_M`, no px constant); read the diff. Soles vs
  ground row after: 70/64 1 px (was 4), 70/32 0.5, 55/64 2 (at the bar), 55/32 1. Test fails without (2.82 px vs 1.0),
  three facings at 70. Walk feet hold: sole 0.00, jump <= 9.60. Ring rows centre on the row. run_unit --changed 5/0,
  then test_cast_thug 7/0. Looked at `thug_stop_after_64.png`: the shoe sits on the red ground line; the claw hangs in
  front, below it (drawn so). Thug stop point PASS.
- 06:26 BUILDER RUNNING cast-03d-A (sonnet) since 06:26: ink + live rim, measure only, brief "Added 06:20", hard stop 07:14.
- 06:27 FINDING (07b, `bd0638f78`): the pad placement `5d8e4b6f8` made the SHIPPED four worse: body jump (32 px/m unit)
  70 R 16.82 -> 23.80, 70 DR 12.87 -> 28.77, 55 R 11.78 -> 32.50, 55 DR 12.87 -> 27.19 (it pins a registered point that is
  not one physical pad through the contact). Eight on the pad view worse still (30.8-41.5). Eight on the OLD held-foot
  view: jump PASSES every facing (10.73 / 10.37 / 10.74 / 9.93) but sole slides 18-27 (four held: 12.5-21.9).
- 06:28 DECISION revert the war view to the held-foot placement (`20be6ffaa` behaviour): a regression in the shipped look
  never ships; WALK stays FOUR (the eight held is not no-worse: sole worse in 3 of 4); the eight held vs four held goes to
  the owner as a call (one value). Sent to the running 07b builder: revert by 06:45, then the before/after still.
- 06:36 BUILDER cast-07b-war8 steps 2-3 24 accepted: `bd0638f78` (feet table, `cast_war_films.mjs`, `cast_war_feet.py`,
  `cast_feet.gd` war entry, audit section), `480975cdd` (revert: `foe_war_card_view.gd` diff vs `20be6ffaa` is EMPTY; four
  re-measured = before column, 0.00 px). run_unit FULL 4236/0/2 (FLAKY test_audio_driving). WALK stays FOUR. Film
  `war8_walk_32.mp4` (eight held, staged preview, 25.85 s 1920x1080 60) + `war8_feet_before_after_64.png`: looked, four
  left / eight right, contact boxes spread on both. Mutate 8/10 on lines now reverted (does not apply). Planted pad per
  drawing p70 R: R R L L R R R L (not a 4/4 exchange). Fix idea (not tried): one registered pad window per contact.
- 06:38 BUILDER RUNNING cast-13 (sonnet) since 06:38: decision lines (revert, war eight call) + heights measured in
  `size_beside_32.mp4` frames, hard stop 07:14.
- 06:44 BUILDER cast-03d-A 17 accepted: `804e5c0c8`. Live 64 px/m rim 0 on walk/attack/hit/fall at 70 and 55 (bar 0).
  Ink runs at y 70/75/80 (planted-8, 192 cell): 70 e.g. 3,15,2 / 7,4,2 .. 3,3,3; 55 five of eight have a 6-13 px run at
  y 75 vs patrol 3,3,4 / 3,3,3: FAIL on the numbers; cause the contour crossing the dark hose rubber (RGB < 48), the
  cause the gunner's row accepted. Closure PASS. Looked at `build/look/n29-thug/ink/live_32_64_x4.png`: outline closed
  and even at 32 and 64, claws and hands whole, no double hatching; the long runs are the hose, not a heavy line.
- 06:45 DECISION robot thug row stays `enabled: false` tonight: the brief's rule is "on only when every point passes"
  and ink fails on its numbers (by eye it reads clean); a switch + live re-film cannot commit and pass the hook before
  07:15. Owner call in REPORT: every other point passes (size 0.92-0.98 of Rivet, feet, stop, palette, shadow, fall,
  rim 0); the switch is one value (`cast_cards.json` `robot_thug.enabled`).
- 06:46 mutate (director, background) `foe_thug_card_view.gd --lines=72-100 --max=10 --tests=test_cast_thug` -> `build/dir5/mutate_thug.out`.
- 06:47 BUILDER cast-13 10 accepted: `a04e542c9` (two decision lines: war placement revert, war eight one value),
  `ff06ff086` (heights in `size_beside_32.mp4`, median of 50 frames, `tools/art/cast_film_heights.py`, background = per-pixel
  median of the static camera): warden 51 (still 51), contractor 50 (49), gunner 55 (55), Mulroney 54 (53), lancer 48 (51,
  walk vs aim cell), cops unjittered 50.0 / 48.2 / 48.6 (50.3), Rivet 80 (77), DOOR CARRIER 63 (56: +7, cause unknown),
  turret not separable (label), war machine by eye 64-68 (65). The film's nominal labels are now backed by measured numbers.
- 06:48 BUILDER RUNNING cast-14 (sonnet) since 06:48: door height film vs stills, measure only, hard stop 07:12.
- 06:48 mutate (director) `foe_thug_card_view.gd --lines=72-100 --max=10 --tests=test_cast_thug`: 62.5 % = 5 / (5 + 3),
  invalid 2, 284 s. Every `sole_gap` line (95-99) killed; survivors on line 84 (`_planted_row >= 0` boundary/literal: no
  test holds row 0).
- 06:48 MILESTONE final gate started detached on `42ac8613b` (code final; later commits are docs, journal, report and
  cast-14's tools/art py): `node tools/gate/run.mjs --rev=HEAD --timeout=60`, PowerShell Start-Process pid 12516, out
  `build/gate-final.out`, `.err`. No `--reels` yet (after the freeze, next session if time).
- 06:52 MILESTONE masters `frames.json` curated to 15 best first (size, flash live, thug x4 incl. new `thug_stop_after_64.png`,
  war8, door8, then 32 px/m and harness extras); size film note now quotes the measured heights; three dropped stills moved to
  `gtai-masters/n29/cast/extra/` (not deleted). ffprobe: all five clips 1920x1080 60/1, 20.0-33.75 s. Looked at
  `war8_walk_32.mp4` at 12 s: the feet harness on the grey plate (contact boxes per step), the machine beside Rivet; not a street take.
- 06:55 BUILDER cast-14 7 accepted: `a36fab587`. Door carrier height in the film by facing (32 px/m): down 62, right 55,
  up 69 (door top held above the head, back view), left 54; still 56 = the side/three-quarter. Rivet down 77, sides 78,
  up 81.5. Cause: facing, not scale. The door stays under Rivet in every facing.
- 06:56 REPORT updated (ledger, film heights). No builder running. Gate pid 12516 on `42ac8613b` running.
