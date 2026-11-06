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

## Iteration 3 (BUILD, 21:37-22:37)

- 21:40 Read JOURNAL, git log, the other journals: no REQUEST to hud (view's card-set note is for
  head cards; the HUD registers none). Assets lane (21:33) noted my planned King/Servo portrait ask
  was not a REQUEST line; it is not needed now (the crest is cut from the shipped approved cards).
  `rivet-final/out/` does not exist yet: the 5 redesigned weapons' showcase sheets have not landed.
- 21:42 FINDING: there is no boss taunt line system (no `taunt` anywhere in features/boot/data):
  "film one boss taunt" has nothing to film; the boss's face shows on the boss bar instead.
- 21:50 MILESTONE 65505423 boss bar crest (work item 4): `portrait_cut.py --card=N` takes frame 0
  of a shipped card strip (never scaled up); `portraits.json` rows `king` (p55 king_bust_card, 216x254)
  and `servo` (p55 head, 86x98); BossView.attach hands BossBar the PortraitBook face; BossBar draws
  it on an ink-ringed cream disc left of the bar (crown may rise past the ring), the ring vermilion
  during a transition (danger). Unit `--select=test_boss_crest,test_hud_dialogue,test_hud_art` 15/0,
  lint 15/15. Stills (arena, `--rigs --boss=<id> --view=combo --seed=2`, frame 150, 0 SCRIPT ERROR,
  1280x800 window): `gtai-masters/n8/hud/bossbar_{king,servo}_combo_1280x800_after.png`,
  `bossbar_king_combo_1280x800_before.png`, `bossbar_king_before_after_crop2x.png`. Look: the King's
  crown and cape read at once at 80 px; Servo's faceplate fills the disc and its top rises past it.
- FRICTION: `--boss=` is an unknown arg on the city main scene; filming needs `res://dev/arena/arena.tscn`.
- 22:00 MILESTONE 76a6d4ad HUD pass (work item 3), judged on the full HUD over a game frame (the
  dialogue board's new `hud_<w>x<h>_full.png`: heat 2/3, Gloria + its showcase icon + x12, the
  notice, Brass's line) at 1920x1080 and 1280x800. Found and fixed: (1) the ammo ticket's bullet was
  signal RED (3585 px; red is for blood only) -> re-hued to brass by `tools/art/hud_recolor.py`
  (hue 0.1, sat x0.7, val x0.8), guarded by `test_hud_art::test_the_drawn_panels_carry_no_red`
  (planted the red ticket back: the guard FAILS with 919 sampled red px; brass passes); (2) the
  notice ("Saved.") drew a 900 px strip -> as wide as its words (min 240, max 900); (3) the weapon
  name on the ticket 20 -> 24 px (thin at 1280x800). Heat pips are police blue (68,109,181 mean),
  danger is vermilion (the boss bar), teal only on the ghost-form meter's tick (souls). Soul cards
  stay undrawn (descoped by owner verdict 3, 2026-11-03). Stills: `gtai-masters/n8/hud/
  hud_full_{1920x1080,1280x800}_after.png`, `hud_full_1920x1080_before.png`. Debt ratchet: dev_loc
  +33 accepted (the board's full-HUD still). Unit `--select=test_hud_art,test_hud_dialogue,
  test_boss_crest,test_story_forms` 25/0, lint 15/15.
- 22:11 Gates at e1288012 (`node tools/evidence/run.mjs --no-bench`, `gtai-n8/scratch/hud/evidence_run.log`): lint 15/15, unit 1501/0, scenarios 52/52 (both wall-clock budgets passed this run), parity bit-exact + planted mutation caught at step 629, selftest look goldens 11/11 + block 5/5, export-audit 555/0. `top` look goldens did not move.
- 22:12 DECISION lines in docs/decisions.md: hud/boss bar (the crest) and hud/colour (the brass bullet).
- REQUEST to assets: weapon_crate_open, 70 and 55: ONE open wooden weapon crate drawn ALONE, lid
  off and leaning on its side, empty, straw/packing lining visible inside (the interior floor must
  read from above: at 70 the open top is the big plane), the same plank wood, X-bracing and black
  corner brackets as `keyed/prop/crates_70.png` (A, attach it as the reference), five rotations,
  no stencils or text, no red. Size: about 1.2 m x 0.6 m (a long gun fits lying in it). Why: the
  showcase weapon goes INTO the crate (the brief's "open crate" display and the pickup-hover call);
  the library crates are closed piles. Until it lands the crate display waits; pickups keep the
  hover.
- 22:19 Director reel (headless, `arena.tscn --fixed-fps 60 --quit-after 14000 -- --bot=reel
  --reel=director --loadout=pistol --rigs --view=<v>`) at 3f3d5281: `top` 19/19 chapters all down,
  `tilt70` 19/19 all down, 0 SCRIPT ERROR both (`evidence/director-reel-n8hud-it3-{top,tilt70}.log`).
  The one engine `custom_samplers` shader ERROR (kill_char_fx.gd:189) is pre-existing (same line in
  `evidence/director-reel-it13-final.log`), not this lane.
- Masters `frames.json` now 14 entries (bossbar crop + Servo, hud_full 1080/1280 after + before).

Registry rules applied this iteration: `short-form-cards-and-barks` (the boss's face beside its
bar: who you fight is read in one glance, no words added), `accessibility` (the HUD judged at
1080p and 1280x800; the ticket name raised to 24 px; colour meaning kept: blue = police, vermilion =
danger, teal = souls, red = blood only), `sprite-and-atlas-production` (crests cut by tool from the
shipped approved card, never scaled up; a one-command recolour tool, guarded by a test),
`generative-artifact-gating` (no new AI image entered the repo this iteration: the crests are
shipped art, so no provenance line), `motion-quality-gating` (the reel in top + tilt70).

NEXT:
- Crate display: waits for the REQUEST above (weapon_crate_open 70/55); then an open crate in the
  arena armory + a vendor counter holding a showcase drawing, filmed at tilt70 / tilt, 48 px/m.
- The 5 redesigned weapons: watch `gtai-art/rivet-final/out/showcase_<id>_{70,55}.png` (absent at
  22:20); import with `tools/art/showcase_import.py`, provenance lines, re-film the armory.
- Long guns' true p70 (Gloria, plasma rifle, gatling still use the 55 cut): watch the assets JOURNAL.
- Film the HUD live in quest 1 (collect-call) at tilt70 instead of the board: the payphone opening.
- Boss bar: consider the crest at 1080p in the live arena (filmed only at the 1280x800 window).
- Freeze 08:30: export `build/export/windows/RTAI.exe` (int-day recipe in docs/decisions.md), REPORT
  Calls: hover vs crate, portrait side/size, dialogue never pauses play, Don Fax payphone vs bust,
  boss crest as a disc vs a bust above the bar.
- 22:21 Session end. All committed.

## Iteration 4 (BUILD, 22:22-23:22)

- 22:25 Read JOURNAL, git log, the other journals (no REQUEST to hud), the assets JOURNAL: my crate
  REQUEST (weapon_crate_open 70/55) not served yet; assets is on Rivet production (round 2200/2215,
  owner TOP PRIORITY). Round 2215 queues the 5 redesigned weapons' `showcase_<id>_{70,55}` sheets
  after 15 Rivet sheets: not landed (`rivet-final/out/` has only rivet sheets at 22:25).
- 22:40 MILESTONE 19b011e6 the 5 redesigned weapons have showcase art NOW: their owner-picked
  design sheets (`rivet-final/refs/design_<id>.png`) already hold a hero side view, a 3/4 (~55) and a
  steeper (~60-70) view: `tools/art/design_cut.py` keys the sheet's own bg (green or magenta, corner
  median, TOL 60 + 40 ramp, spill clamp), labels the pieces (scipy), cuts icon = hero, p55 = bottom 1,
  p70 = bottom 2 (the plasma cleaver's bottom 2 stands end-on -> p70 = its side). Each piece masked
  to its own label (the ray gun's 55 caught a corner of the hero's grip before). 15 provenance lines
  (rivet-r3 job + prompt sha). 17 of 17 drawable weapons now carry p70/p55/icon (unit guard widened
  to all 17; `--select=test_weapon_showcase` 7/0, lint 15/15). Interim: the assets lane's showcase
  sheets replace p70/p55 when they land (the import tool is ready).
  Armory re-filmed (arena.tscn -- --armory --ppm=48 --view=<v> --rigs --seed=1, frame 89, 0 SCRIPT
  ERROR): `gtai-masters/n8/hud/armory_{tilt70,tilt}_48_after17.png` + `_after17_crop2x.png` (it2 vs it4).
  Look: the floor is now one inked family; the drum mini-nuke is the biggest piece (sized by its long
  side; a bulky launcher, reads as heavy, kept).
