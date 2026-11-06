# JOURNAL - n8 lane `hud` (branch n8-hud)

## Iteration 1 (BUILD, 20:28-21:28)

- 20:30 Read: git log (main at 8e9eeb78, d8 merged), AGENTS.md, decisions.md tail (owner's d8 verdicts:
  combo pitch, Rivet + held weapons frozen, two weapon art forms), `pickups_view.gd`, `pickup_look.gd`,
  `weapon_rack_view.gd`, `arena_weapon_rack.gd`, `arena_armory.gd`, `weapon_art.gd`, `view_mode.gd`.
  Library: `LIBRARY.md`, `catalog.json` (no weapon showcase sheet; `hud_icons_55` A is the HUD frame
  look; 13 portraits at 55, of which 7 are DESIGN PROPOSALS), the asset lane's JOURNAL tail
  (`tools/mk_round_weapon_icons.py` is READY but references the game's OLD held.png, not the
  owner-approved r2 designs). Other n8 journals: no REQUEST to hud yet.
- 20:34 Looked at `rivet-r2/out/arm_hand_cannon.png`: the approved weapon is drawn in Rivet's claw
  across 8 poses; the claw overlaps the grip in every pose, so a clean showcase cut from it is not
  possible -> the showcase sheets must be drawn fresh (as the brief says).

REQUEST to assets: weapon_showcase_<class>, 70 + 55 + icon, the SHOWCASE form of the 12 owner-approved
weapons (rivet-r2 triage, 2026-11-06 evening), drawn ALONE as display pieces. Four sheets, one per
weapon class, each a 3 x 3 grid on green #00B140 (anything teal/green in magenta #FF00FF):
rows = the three weapons, columns = (1) the weapon lying on the ground seen from a 70-degree camera
(three-quarter from above, its top AND a sliver of its side body, muzzle pointing right), (2) the same
at 55 degrees (more side body), (3) a flat pure side-profile icon, muzzle right, for the HUD
(the `hud_icons_55` A ink weight). Same design, parts and colours as the weapon in the reference
`C:/Users/kazda/kiro/gtai-art/rivet-r2/out/arm_<id>.png` (attach that sheet; the claw is NOT drawn).
  - `weapon_showcase_sidearms`: pistol, machine_pistol, hand_cannon
  - `weapon_showcase_long`: gloria, plasma_rifle, gatling
  - `weapon_showcase_heavy`: rocket_launcher, flamethrower, molotov (the bottle standing for 70/55)
  - `weapon_showcase_melee`: katana, electro_baton, chainsaw
  NOT the five in redesign (electro_gun, homing_shard, ray_gun, mini_nuke, plasma_sword): they keep
  their shipped parts until the owner picks. Please do NOT run `mk_round_weapon_icons.py` as is: it
  draws the OLD held.png designs, which the owner rejected. Where I will read them:
  `keyed/weapon/weapon_showcase_<class>_<pitch>.png` (any path is fine; name it in your journal).
  Why: vendors, crates, floor pickups and the HUD icon are all cut from one drawing per weapon per
  pitch (the owner's 19:10 split: a) showcase, b) equipped).

REQUEST to assets: portrait emotion for the quest-1 cast (don_fax is voice-only: no face needed).
Low priority, after the showcase sheets: a 70 twin is NOT needed for portraits (the dialogue box is
screen space, one drawing serves every pitch).

Registry rules applied (read the index; per slug): `sprite-and-atlas-production` (one source drawing
per subject per pitch, cuts derived by tool, never hand-painted variants), `depth-ordered-layered-art`
(the pickup's shadow draws under the art, the art over the disc), `generative-artifact-gating` (no C
sheet enters; design proposals stay on contact sheets).
- 20:58 MILESTONE `WeaponShowcase` (d5db8300): showcase drawings keyed by the view's art key
  (`showcase/<p70|p55|icon>/<id>.png`); PickupsView rebuilds on the form (combo swaps live), stands a
  drawing up without the spin; HudFeed fills `HudState.weapon_icon` (showcase icon, else the shipped
  `icon.png`) and HudView draws it left of the ammo ticket. `--showcase=off`, `--pickup-hover=off`
  in KNOWN_FLAGS. Lint 15/15, unit `--select=test_weapon_showcase,test_hud_art,test_arena_armory` 14/14.
- 21:00 FRICTION: `OS.get_cmdline_user_args()` in new code trips the debt ratchet
  (direct_cmdline_reads); read flags through the `LaunchArgs` autoload (`LaunchArgs.value(flag)`).
- 21:05 FRICTION: filming `--armory` needs the scene arg `res://dev/arena/arena.tscn` (the editor's
  main scene is the city; the showcase export's main scene is the arena).
- 21:10 Evidence: `gtai-masters/n8/hud/armory_{tilt70,tilt}_48_before.png` (frame 89, seed 1, 0 SCRIPT
  ERROR, 16 weapons laid). Every gun is a stand-in (no showcase drawing exists yet): honest BEFORE.
- DECISION hud/showcase: see docs/decisions.md (the route, the stand-in rule, hover kept).
- 21:16 Unit `--fast`: 1473 tests, 0 failures (junit), 89 s. Not yet run this iteration: the full
  no-arg unit run (slow tier), scenarios, evidence --no-bench.

NEXT:
- Read `gtai-art/library/JOURNAL.md` for the answer to the showcase REQUEST; when sheets land: a cut
  tool `tools/art/showcase_cut.py` (3x3 grid -> `showcase/p70|p55|icon/<id>.png`, key tol >= 12,
  trim, declared anchor = the drawing's ground contact centre), provenance lines in
  `steam/ai-provenance/2026-11.jsonl`, then film the armory after (same seed, frame 89) at 70/55, 48 px/m.
- WeaponRackView: under a form, hang the showcase drawings horizontally on pegs (a vendor rack) and
  rebuild on the form; add a crate prop (library `crates_55` B) for an open-crate display.
- Film quest 1 with the HUD icon on the ticket (res://boot/quest1.tscn, gloria) at 1080p and 1280x800.
- Item 2: the dialogue box with a face (HudView._subtitle): portrait only for approved looks
  (gunsmith, nurse, scientist, mertz, dock_guard = quest-1 concept-matched; krump boss), device frames
  for Don Fax / Patch; the 7 DESIGN PROPOSAL portraits go on a contact sheet for the owner only.
- Run the full gates (unit no-arg, scenarios, evidence --no-bench) before calling anything done.

## Iteration 2 (BUILD, 20:44-21:44)

- 20:44 Read JOURNAL, git log, the assets JOURNAL: my showcase REQUEST is served as round 2155
  (`rounds/20261106-2155`), the cuts land as `library/keyed/weapon/<id>_<70|55|icon>.png`. No REQUEST
  to hud in the other n8 journals.
- 20:55 MILESTONE c99ff149 the dialogue box with a face: `data/tables/portraits.json` (+schema),
  `PortraitBook`, `HudDialogue` (child node of HudView; the face rises in over 0.18 s on a new
  speaker, the box fades out over 0.22 s after the last line; play never waits). Approved looks only:
  gunsmith, nurse, scientist, quartermaster-mertz, dock-guard (quest-1 concept-matched library
  portraits), krump (the approved boss target); Don Fax + Patch get the payphone (library payphone_55
  A, first facing): voice-only by design. Rivet has no row (his look is in triage), the 7 DESIGN
  PROPOSAL portraits have none. The mood bust is shown on the lines named per speaker in the table
  (presentation data keyed by the quest's stable line ids; quest.json untouched): juno-real-name,
  brass-someday, kilohm-come-to-me, guard-who-do-we-call, mertz-appliances. Cut tool
  `tools/art/portrait_cut.py`. Unit `--select=test_hud_dialogue,test_hud_art,test_story_forms,
  test_weapon_showcase` 26/0.
- 21:00 FRICTION: HudDialogue read `delta` -> banned-api (SIM-01). Stepped one TICK_DT per drawn
  frame instead (BossBar's precedent).
- 21:05 Showcase sheets arrived (sidearms 70 A, long 70 B: column 1 near side view, the 55 cut stands
  in for p70 until redo round 2156). `tools/art/showcase_import.py` -> `showcase/<p70|p55|icon>/<id>.png`
  for pistol, machine_pistol, hand_cannon, gloria, plasma_rifle, gatling. Provenance lines appended.
- 21:12 MILESTONE eb9decbb armory AFTER at tilt70 and tilt, 48 px/m, the before's exact command
  (frame 89, seed 1, --rigs): `gtai-masters/n8/hud/armory_{tilt70,tilt}_48_{after,before_after_crop2x}.png`,
  0 SCRIPT ERROR. Look: the drawings read warmer and on-design (Gloria's heart plate, the gatling's hose).
- 21:08 MILESTONE aa830e68 dialogue stills, every quest-1 speaker at 1080p and 1280x800 (`dev/showcase/
  dialogue_board.gd`, a -s launcher + a run node, since -s scripts cannot name autoload classes):
  `gtai-masters/n8/hud/dialogue_contact_{1080p,1280x800}.png`, `dialogue_1080p_{patch_payphone,brass,
  dock_guard_mood}.png`, `dialogue_1280x800_brass.png`. Found and fixed on the stills: the narrower
  text column ran the 4th line through the paper's bottom edge -> the size is fitted on the WHOLE line
  (HudState.full_words) so the typewriter never changes it.
- 21:10 FRICTION: the debt ratchet counts any new dev/ code (dev_loc) and the launcher's cmdline read;
  recorded with `--update --accept-regression` (the reason names the board).
- 21:15 heavy + melee showcase delivered by assets (B both: heavy's icon column washed out -> the icon
  is cut from the 70; melee columns near-identical side profiles). Imported rocket_launcher,
  flamethrower, molotov, katana, electro_baton, chainsaw. The molotov stands at 70/55 (a bottle), so
  PickupsView spans a showcase drawing's LONGER side (a standing drawing no longer blows up in height).
  12 of 12 approved weapons now have a showcase drawing; the 5 in redesign keep their shipped parts.
- 21:20 Full unit no-arg run (over aa830e68 + the pickups/rack edits in flight): 1495 passed, 0 failed
  (`gtai-n8/scratch/hud/unit_full.log`). After the rack change: `--select=test_weapon_showcase,
  test_gatling,test_arena_armory,test_pickup_look,test_pickups_hover` 24/0.
- 21:22 MILESTONE ec55285f all 12 approved weapons have a showcase drawing at p70/p55/icon; the wall
  rack (WeaponRackView) hangs the icon cuts under an angled view and rebuilds on a form change (combo).
  Armory re-filmed (same command as the before, 0 SCRIPT ERROR): `armory_{tilt70,tilt}_48_after.png`
  and `..._before_after_crop2x.png` (the crop now includes the rack). Look: the floor reads as one
  tan, inked family; the 5 in redesign (parts) now look the odd ones out, as expected until the pick.
- 21:25 `gtai-masters/n8/hud/portrait_proposals_contact.jpg`: the 7 DESIGN PROPOSAL portraits for the
  owner (never in game) + Don Fax's concept-matched bust, kept OUT of the game (voice-only brief).
  Call for the owner: Don Fax as the payphone (built) vs his concept bust (one table row).

Registry rules applied this iteration: `short-form-cards-and-barks` (a line's face is a fast read: a
bust left, name above the words, enter <= 0.2 s, never blocking play), `accessibility` (text fitted
to the box at 30-20 px at 1080p, ink on paper; legibility checked at 1280x800), `sprite-and-atlas-
production` (one source cut per subject per pitch by tool: portrait_cut.py, showcase_import.py).

NEXT:
- Scenarios gate result (started 21:23, `gtai-n8/scratch/hud/scen.log`); then `node tools/evidence/run.mjs
  --no-bench`. Not run yet this session: evidence. The director reel 19/19 in top and tilt70.
- Long guns at 70: the assets lane's redo 2156 is C; Gloria/plasma rifle/gatling p70 still use the 55
  cut (SOURCE in tools/art/showcase_import.py). Watch the assets JOURNAL for another redo.
- Crate display: library `crates_55` B -> an open crate holding a showcase drawing (arena + vendor).
- Film quest 1 in game with the face (needs a walk to the payphone; quest1.tscn has no bot: look for
  a story pilot / StagePilot driver, or film the opening line + the HUD icon on the ticket).
- HUD pass (item 3): soul cards teal, heat police blue, danger vermilion; 1080p + 1280x800 stills of
  the in-game HUD. Then the boss bar crest/portrait (item 4): no library portrait of the King or Servo
  yet -> REQUEST to assets (portrait_king_55, portrait_servo_55 from their approved art) or cut a
  crest from the shipped p55 bust card.
- Export the exe at the freeze; REPORT Calls: hover vs crate, portrait side/size, dialogue never
  pauses play, Don Fax payphone vs bust.
- 21:29 Scenarios (raw `run_scenarios.gd`, head 4afd59d9): 52 ran, 2 failed, 0 SCRIPT ERROR. The two
  fails are the two wall-clock budgets only: city_chase nav (max 13870 us > 2 ms) and rig_stress p50
  (1.028 > 1.000 ms), while 4 other lanes ran. Re-run through `node tools/tests/run_scenarios.mjs
  --only=scenario_city_chase,scenario_rig_stress --quiet-wait=3`: city_chase PASS; rig_stress
  CONTENDED (1.073 ms, 3 other runs, the machine never went quiet in 3 min): NOT judged, not a pass.
  This lane touched neither nav nor rigs (HUD, pickups view, rack view only).
- 21:37 Session end. Not run this session: `tools/evidence/run.mjs --no-bench`, the director reel in
  top/tilt70, rig_stress on a quiet machine. All work committed (c99ff149..4afd59d9 + this journal).
