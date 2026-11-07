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
- 22:39 MILESTONE 23ca86f1 quest 1 filmed LIVE for the first time (new debug flag `--autostart`:
  Quest1Card emits Start; `res://boot/quest1.tscn -- --view=tilt70 --seed=1 --autostart`). FOUND on
  the live frame at 1280x800: the subtitle box's paper (inset MARGIN*4 = 144, paper -10) lay over the
  ghost-form card's edge in every quest-1 line (pre-existing geometry). Fix: `HudDialogue.SIDE_X` 166 +
  `box_of(screen)`; unit `test_the_box_paper_clears_the_folded_ghost_card` (planted the old 144: FAILS
  134 < 148; 166 passes). `--select=test_hud_dialogue,test_story_forms,test_hud_art` 23/0, lint 15/15.
  Stills: `gtai-masters/n8/hud/quest1_dialogue_card_before_after_crop2x.png` (before / after --rigs /
  after shipped), `quest1_opening_tilt70_1280x800_after.png`, `..._rigs_1280x800_before.png`.
  FINDING (dev path, not shipped): under `--rigs` quest 1's form card never folds (StoryForms has no
  form view there; quest1_game.gd l.29 "null under --rigs"). FINDING for `view`: quest 1 under
  `--view=tilt70` still draws its street top-down (dumpster, props, Rivet); no REQUEST from hud, the
  view lane owns the call.
  FINDING: Rivet speaks quest 1's opening lines with NO face (no PortraitBook row: his look is in
  triage). Proposal for the owner only (never in the game): `gtai-masters/n8/hud/
  proposal_rivet_dialogue_face.png`, the bottom-left bust of the approved `rivet-final/refs/
  rivet_v01_amber_visor.png` beside today's live box.
- DECISION lines: hud/showcase redesign, hud/dialogue layout (docs/decisions.md).
- Masters `frames.json` rebuilt to 15 entries (after17 crops at 70/55, quest-1 card crop and live
  opening added; the it2 full-frame afters replaced by the after17 one).
- 22:50 Gates (`node tools/evidence/run.mjs --no-bench`, evidence commit 87f1c8e8 = every game-code
  change of this iteration; `gtai-n8/scratch/hud/evidence_run_it4.log`): lint 15/15, unit 1502 passed
  0 failed, scenarios 52/52 (both wall-clock budgets passed), parity bit-exact + planted mutation
  caught at step 629, selftest look goldens 11/11 + block 5/5 (top did not move), export-audit 555/0.
  The unit step is marked FAIL only for "tree changed during run" (I committed JOURNAL/decisions
  mid-run: FRICTION, mine; do not commit while evidence runs). 0 failing tests.
- 22:53 `tools/art/design_cut.py --showcase` (15ac8128): ready for the assets lane's
  `showcase_<id>_{70,55}` sheets (the middle of five rotations = the side view; checked on
  crates_70's row: one clean piece). Still not landed at 22:55.
- 22:55 Armory at the SHIPPED 32 px/m (tilt70, seed 1, frame 89, 0 SCRIPT ERROR):
  `gtai-masters/n8/hud/armory_tilt70_32_{before,after}.png` (before = `--showcase=off`) +
  `armory_tilt70_32_before_after_crop2x.png`. Look: ~40 px per weapon; the showcase pieces read by
  colour and silhouette, the parts were one grey-tan family, and the wall rack's black part prints
  become inked icons.
- 22:55 Call still: `gtai-masters/n8/hud/call_pickup_hover_vs_floor_tilt70_48_crop2x.png` (built:
  hover 0.35 m vs `--pickup-hover=off`). Hover reads better (the drawing's shadow spot on the disc
  lifts it off the floor: "take me"); kept as built. The crate display still waits for the open-crate
  REQUEST (22:12).

Registry rules applied this iteration: `sprite-and-atlas-production` (one cut per subject per pitch
by tool, keyed on the sheet's own background, masked to its own piece; the import is re-runnable
when the better sheet lands), `generative-artifact-gating` (only owner-picked AI art entered, 15
provenance lines; the Rivet bust stays a proposal off-game), `concept-scene-parity` (the
redesigned weapons are the owner's design sheets themselves, no redraw), `motion-quality-gating`
(judged live in quest 1 and the armory at 32 and 48 px/m), `short-form-cards-and-barks` + 
`accessibility` (the subtitle box never covers the ghost card; the text refits, 20 px floor).

NEXT:
- Watch `gtai-art/rivet-final/out/showcase_<id>_{70,55}.png` (round 2215, after Rivet's equipped
  sheets): `python tools/art/design_cut.py C:/Users/kazda/kiro/gtai-art/rivet-final <ids> --showcase`,
  look at each cut, provenance lines (round 2215 + prompt hash from its jobs.json), re-film the armory
  at 32/48 px/m tilt70 and tilt.
- Crate display: waits for `weapon_crate_open` (REQUEST 22:12); then an open crate in the armory
  holding a showcase drawing, filmed at tilt70/tilt 32 and 48 px/m.
- Long guns' true p70 (Gloria, plasma rifle, gatling use the 55 cut): no redo planned by assets
  (their finding: a weapon lying on its side IS its side profile at 70); consider closing as built.
- Quest 1 live: film a named speaker's face (needs a walk: Brass or the payphone); `--autostart`
  exists now; no bot drives quest 1, so consider a short recorded input (`--record`) to replay into a
  movie, or film the dialogue board instead (done in it2).
- Freeze 08:30: export `build/export/windows/RTAI.exe` (int-day recipe in docs/decisions.md); REPORT
  Calls: hover vs crate (still: call_pickup_hover_vs_floor...), portrait side/size, the dialogue never
  pauses play, Don Fax payphone vs bust, boss crest disc vs bust, Rivet's dialogue face (proposal).
- 23:07 Director reel (headless, `arena.tscn --fixed-fps 60 --quit-after 14000 -- --bot=reel
  --reel=director --loadout=pistol --rigs --view=<v>`) at 62096f63: `tilt70` 19/19 chapters all down,
  `top` 19/19 all down, 0 SCRIPT ERROR both (`evidence/director-reel-n8hud-it4-{tilt70,top}.log`).
- 23:08 Session end. All committed; masters `frames.json` 15 entries (32 px/m armory pair second).

## Iteration 5 (BUILD, 23:09-00:09)

- 23:12 Read JOURNAL, git log, the other journals (no REQUEST to hud), the assets JOURNAL: DELIVERED
  to hud `weapon_crate_open_70` (B: thin outline, the straw the wood's value) and `_55` (A) in
  `library/keyed/prop/` (my 22:12 REQUEST, served 23:05-23:06); `showcase_electro_gun_70` (B, design
  drift) and `_55` (A) in `rivet-final/out/` (23:00). Round 2215 stopped after the electro gun (exit
  4, spawn failures): the other 4 showcase sheets are not made yet.
- 23:25 MILESTONE 1a22bfcb the crate display (work item 1, "in an open crate"): `ShowcaseCrate` +
  `tools/art/crate_cut.py` (70 = rotation 1, 55 = rotation 5: the lid always leans BEHIND the hollow;
  the 70's straw darkened warm 0.86/0.72/0.6, its notes' fix: a flat 0.78 read olive). PickupsView
  under `--pickup-crate=on`: the crate stood up for its camera, 1.6 m long, an ink shadow under it,
  the gun still with its bottom edge on the straw's front edge (first try centred it on the hollow:
  at 55 the 3/4 drawings covered the crate's front wall), at most 1.3 m long, the molotov's standing
  bottle at most 0.7 m. Unit `test_showcase_crate` (5) + pickups/showcase `--select` 15/0, lint 15/15.
  New flag `--pickup-crate` in LaunchArgs.
- DECISION (docs/decisions.md hud/pickup crate): the hover stays the DEFAULT; the crate is
  `--pickup-crate=on` and a Call for the owner. Judged side by side at the shipped 32 px/m (tilt70 +
  tilt, the armory): the paper disc pops "loot" off the grey floor at a glance; the 16 tan crates
  merge into one band at 32 (they read as a stocked armory, best at 48). Alternative = one flag
  (or `ShowcaseCrate.DEFAULT_ON`).
- 23:27 MILESTONE e90a4514 the electro gun's showcase from the assets sheet: p55 AND p70 = the middle
  (side) cut of `showcase_electro_gun_55` (A, the owner's design exact); the 70 sheet (B) is not used
  (no tape band, no back cap, a glyph: drift from the owner's pick). `design_cut.py` SHOWCASE_SOURCE.
  4 provenance lines (crates round 20261106-2300 hashes 23a5dcfacb7a / 545a35569fdd; electro gun
  round 20261106-2215 e8b793d29d8a).
- Stills: `gtai-masters/n8/hud/armory_crate_48_tilt70_tilt_crop2x.png` (crates at 70 top / 55 bottom,
  48 px/m, seed 1, frame 89, 0 SCRIPT ERROR).
- 23:32 Full unit run (no-arg) at c06f18c3: 1507 passed, 0 failed (`gtai-n8/scratch/hud/it5/unit_full.log`).
- 23:33 FRICTION: filming the boss bar "at 1080p" with `--resolution 1920x1080` (or 1600x900) still
  records 1280x800: Movie Maker records at the project viewport (1280x800), and the bigger window's
  `canvas_items`/`expand` layout pushed the ghost-form panel ~35 px off the left edge in the capture.
  A filming artifact, not a game bug (the same scene without `--resolution` lays out right; the
  1080p HUD is evidenced by the dialogue board). For a true 1080p live capture, the movie needs
  `display/window/size/viewport_*` overridden, not `--resolution`. Captures deleted.
- 23:37 MILESTONE 5febcad2 the crate wears the pickups' bold ink (PickupLook.dress on the crate): at
  32 px/m the 70 crates no longer merge into one tan band (the B sheet's note 1, thin outline).
  Still `crate_ink_32_before_after_crop2x.png`; the call still `call_pickup_hover_vs_crate_32_crop2x.png`
  (hover left, inked crate right; 70 top, 55 bottom) re-cut with it. Masters `frames.json` 14 entries.
- 23:38 Director reel started at 5febcad2 (tilt70 + top, headless; logs `evidence/director-reel-n8hud-it5-*.log`).
- 23:40 Combined clip being captured (`gtai-n8/scratch/hud/clip.sh`: armory hover 70 / crates 70 and
  55 at 48 px/m / the King's boss bar at combo / quest 1's live opening at tilt70).
- 23:40 MILESTONE the combined clip of the set: `gtai-masters/n8/hud/hud_set_combined_it5.mp4` (41 s,
  1280x800, at 5febcad2; 5 segments, 0 SCRIPT ERROR each; raw .avi deleted). Looked at a contact
  sheet of 6 frames: armory hover (32), crates 70 / 55 (48), the King on his throne-car with the
  crest + bar at combo, quest 1's live opening (Rivet's line box, heat in blue pips, cash). Masters
  `frames.json` 15 entries (the clip second).
- 23:42 MILESTONE 23cebe4c the homing shard's and the ray gun's showcase from the assets lane's round
  2215 (all four sheets A, design exact; delivered 23:23-23:36): p70/p55 = each sheet's side view
  (`design_cut.py --showcase`), looked at side by side with the interim cuts
  (`gtai-n8/scratch/hud/it5/shard_ray_compare.png`): the same design, one consistent lying side view
  like the other 12. 4 provenance lines. Mini nuke and plasma sword sheets: not made yet (chain B).
- 23:44 Director reel (headless, `arena.tscn --fixed-fps 60 --quit-after 14000 -- --bot=reel
  --reel=director --loadout=pistol --rigs --view=<v>`) at 5febcad2: `top` 19/19 chapters all down,
  `tilt70` 19/19 all down, 0 SCRIPT ERROR both (`evidence/director-reel-n8hud-it5-{top,tilt70}.log`).
- 23:44 Call still at 48 px/m with all 17 showcase drawings (23cebe4c): `gtai-masters/n8/hud/
  call_pickup_hover_vs_crate_48_crop2x.png` (hover left, inked crate right; 70 top, 55 bottom).
- 23:56 Gates (`node tools/evidence/run.mjs --no-bench` at c3c21e4b, every game-code change of this
  iteration; `gtai-n8/scratch/hud/evidence_run_it5.log`): lint 15/15, unit 1507 passed 0 failed,
  scenarios 52/52, parity bit-exact + planted mutation caught at step 629, look goldens 11/11 + block
  5/5 (top did not move), export-audit 556/0. The unit step is marked FAIL only for "tree changed
  during run": FRICTION, mine again: I committed the tilt70 reel log at its last chapter line while
  Godot was still writing its exit lines; the finished log is committed now. 0 failing tests.

Registry rules applied this iteration: `sprite-and-atlas-production` (one cut per subject per pitch
by tool from the library's keyed sheets, the B sheet's named fix applied in the tool, re-runnable),
`depth-ordered-layered-art` (crate behind its ink, the gun and its ink over the crate, the shadow
under both, all inside PickupsView's draw order), `concept-scene-parity` (the electro gun's 70
sheet rejected for drift from the owner's design; the A 55 cut serves both pitches),
`generative-artifact-gating` (only A/B-graded library art entered, 10 provenance lines),
`motion-quality-gating` (the combined clip; the reel 19/19 in top and tilt70),
`accessibility` (the crate call judged at the shipped 32 px/m, where the readability is decided).

NEXT:
- Watch `gtai-art/rivet-final/out/showcase_{mini_nuke,plasma_sword}_{70,55}.png` (round 2215 chain B):
  `python tools/art/design_cut.py C:/Users/kazda/kiro/gtai-art/rivet-final mini_nuke,plasma_sword
  --showcase`, look at each cut beside the interim (grade A only, else keep the interim), 4
  provenance lines (catalog `showcase_<id>` round + prompt_hash), re-film the armory call stills.
  The plasma cleaver's sheet: check that its middle rotation is the side view (its design sheet's
  steep view stood end-on).
- Freeze 08:30: export `build/export/windows/RTAI.exe` (int-day recipe in docs/decisions.md);
  REPORT Calls: pickup hover vs open crate (`call_pickup_hover_vs_crate_{32,48}_crop2x.png`,
  `--pickup-crate=on`), portrait side/size, the dialogue never pauses play, Don Fax payphone vs
  bust, boss crest disc vs bust, Rivet's dialogue face (proposal only).
- A vendor counter: no vendor exists in the game (grep: none); the wall rack and the crate are the
  showcase's display forms. Raise as a note in REPORT, not a build.
- Optional: a true 1080p live capture needs the viewport overridden (Movie Maker records at the
  project's 1280x800), e.g. a dev-only override.cfg copy; the board covers 1080p meanwhile.
- 23:57 Session end. All committed.

## Iteration 6 (BUILD, 23:58-00:58)

- 00:00 Read JOURNAL, git log, the other lanes' journals (no REQUEST to hud). The assets lane's
  round 2215 chain B landed: `showcase_mini_nuke_{70,55}` (A, A) and `showcase_plasma_sword_{70,55}`
  (A, A) in `rivet-final/out/` (23:41-23:58).
- 00:05 MILESTONE 54ef2527 the mini nuke's and the plasma cleaver's showcase from the assets sheets
  (`design_cut.py --showcase`): looked at beside the interim cuts (`gtai-n8/scratch/hud/it6/
  nuke_sword_compare.png`): the same designs, now the one lying side view the other 15 have (the
  interim nuke p55 was a 3/4, the cleaver's p55 a diagonal). Armory re-filmed at 48 px/m tilt70 and
  tilt (seed 1, frame 89, 0 SCRIPT ERROR): the nuke on the floor and the rack, the cleaver standing
  on the rack. 4 provenance lines (prompt hashes ada84edabbd4 / 4267ae870f2c / ce9f6b87abf4 /
  afbed06b43ea). `--select` showcase/crate/pickup/armory 19/0, lint 15/15. All 5 redesigned
  weapons now come from the assets lane's showcase sheets (electro gun p70 from its A 55 sheet).
- 00:08 FINDING (corrects my it4 NEXT): quest 1 HAS a bot that films: `dev/frames/quest1_clip.gd`
  (CollectCallInputDriver, the real Quest1Game + HUD). It rejected `--view`; added it (dev only).
  The payphone beat: the call's lines run ticks ~2200-4100 (`--stills` sweep, 0 SCRIPT ERROR).
- 00:14 FRICTION: under `--rigs` (dev-only, debug builds) quest 1's ghost card never folds while a
  line is up (the rig cast's own GhostFormView; only StoryForms sets `GhostFormHud.compact`), so the
  subtitle paper covers its 3 other chips. The shipped path folds right. Filmed the shipped path.
- 00:28 FIXED: `StoryForms.fold_rigs` (Quest1Game._dev_rigs calls it after the rig cast attaches):
  the rig cast's card folds the same way (no lift, no voice). Unit test_story_forms 10/0 (a planted
  RigCast with a ghost_view; a cast without one adds nothing); a `--rigs` still at tick 4000 shows
  the folded card beside Don Fax's box (`gtai-n8/scratch/hud/it6/q1rigs_fold.png`). Debt: accepted
  +3 lines (quest1_clip --view +2, quest1_game +1), reason in tools/debt/baseline.json.
- 00:24 MILESTONE the payphone call filmed LIVE in quest 1 under tilt70 at 32 px/m (shipped path,
  CollectCallInputDriver through real InputEvents, ticks 2150-4100, 0 SCRIPT ERROR):
  `gtai-masters/n8/hud/quest1_payphone_call_live_tilt70.mp4` (32 s): Patch's payphone rises in,
  Rivet's line (no face: proposal only), Don Fax's payphone; the ghost card folded beside the box.
  Stills `quest1_payphone_{patch,fax}_live_tilt70_32.png`. Looked at a contact sheet of 8 frames.
- 00:39 Gates (`node tools/evidence/run.mjs --no-bench` at 6fd17433, every change of this iteration;
  `gtai-n8/scratch/hud/evidence_run_it6.log`): lint 15/15, unit 1508 passed 0 failed, scenarios
  52/52, parity bit-exact + planted mutation caught at step 629, look goldens 11/11 + block 5/5 (top
  did not move), export-audit 556/0. No commit during the run this time (the it5 friction).
- 00:44 FRICTION (caught by looking): the 00:05 armory shots showed the INTERIM mini nuke at 55: a
  game run (not the editor) draws the stale `.godot/imported` cache of a PNG replaced on disk; the
  gate run's `--import` refreshed it. Re-shot after the import: `gtai-masters/n8/hud/armory_{tilt70,
  tilt}_48_before_after_crop2x.png` (17 final drawings, notes updated) and the call still
  `call_pickup_hover_vs_crate_48_crop2x.png` (hover left, crate right; 70 top, 55 bottom), 0 SCRIPT
  ERROR. Rule for me: after replacing art, run `--import` (or any gate) BEFORE filming.
- Masters `frames.json` 15 entries: the live payphone clip third; `dialogue_1080p_patch_payphone.png`
  (the board's still, superseded by the live call) dropped; the stale after17 armory stills deleted.
- FINDING: the car radio carries no speech (3 placeholder music loops, `audio_radio.json`): there
  is no speaker to frame; a PortraitBook `kind: device` row is the hook when a DJ line exists. For
  REPORT (draft in `gtai-n8/scratch/hud/it6/report_notes.md`).

Registry rules applied this iteration: `sprite-and-atlas-production` (the last 2 weapons' cuts by
the same re-runnable tool from A sheets), `generative-artifact-gating` (A only, 4 provenance
lines), `concept-scene-parity` (cuts compared with the owner's design sheets), `motion-quality-gating`
(the payphone call judged live in motion, not on the board; every still looked at, the stale-cache
frame caught and re-shot), `short-form-cards-and-barks` + `accessibility` (the card never under the
subtitle paper on either cast path).

NEXT:
- All 5 redesigned weapons now come from the assets sheets: work item 1 is complete. Remaining
  quality: a true 70 long-gun sheet (Gloria, plasma rifle, gatling use their 55 cut) only if the
  assets lane makes one; otherwise close as built in REPORT.
- Film one combined clip v2 (30-90 s) at the end: armory hover/crate 48 px/m (final 17), the
  payphone call live (`quest1_clip.gd --ticks=2150-4100 --view=tilt70`), the King's crest at combo.
  Run `--import` (or a gate) first.
- Optional: a true 1080p live capture (Movie Maker records at the project's 1280x800).
- Freeze 08:30: export `build/export/windows/RTAI.exe` (int-day recipe in docs/decisions.md);
  REPORT from `gtai-n8/scratch/hud/it6/report_notes.md` (works / findings / Calls: pickup hover vs
  crate, portrait side/size, dialogue never pauses play, Don Fax payphone vs bust, boss crest disc
  vs bust, Rivet's dialogue face proposal).
- 00:47 Session end. All committed.
- 00:48 MILESTONE the combined clip v2: `gtai-masters/n8/hud/hud_set_combined_it6.mp4` (42 s, at
  ec53cc46, 0 SCRIPT ERROR): armory hover at 70 with the 17 final drawings (48 px/m), crates at 55,
  the payphone call live. Looked at frames. Masters `frames.json` 15 entries (the it6 clip third;
  the opening still superseded by the live call dropped). Raw .avi deleted. NEXT's "combined clip v2"
  is done; the King's crest stays in the it5 clip.
- 00:49 Session end. All committed.

## Iteration 7 (BUILD, 00:47-01:47)

- 00:48 Read JOURNAL, git log, the other lanes' journals (no REQUEST to hud; view notes my SIDE_X
  166 fix reaches its path at the merge). The work order is evidenced; the weakest item is
  "film one boss taunt" (not filmed: no boss line system, `grep -ri taunt` empty; the King's voice
  bible `pof/games/gtai/voices/king.md` has only ILLUSTRATIVE lines, not owner-signed). HudView
  lives only in quest 1; the boss arena has the boss bar alone.
- DECISION: film the taunt as a dev-only layout shot, not a shipped feature: `dev/showcase/
  boss_taunt.gd` runs the live arena (`dev/arena/arena.tscn`, the game's own args) and lays
  HudDialogue with the boss's PortraitBook face (the bust the boss bar's crest uses) over the fight;
  words from `dev/showcase/boss_taunt_lines.json` (the voice bible's illustrative lines 1 and 3,
  labelled as such; dev/ is dropped from release). Settings via env (GTAI_TAUNT_AT/_HOLD) so the
  arena's LaunchArgs see only its flags. Line text and a boss line system stay out of this lane.
- FRICTION: first take ran `boot/main.tscn`, which ignores `--boss` (boss fights run via the arena
  scene); killed my own run (PID 5764 tree) and re-pointed at the arena.
- 00:58 FINDING (by looking at the live take): in the King fight at combo (1280x800) the quest
  dialogue box with the bust covers the lower third of the field AND the arena's ghost-form card
  (unfolded there: only quest 1's StoryForms folds it). A taunt in a fight should be a bark, not
  a conversation (`short-form-cards-and-barks`).
- 01:00 MILESTONE 8fd8aa0b `BossTaunt` (features/bosses): the taunt as a short paper strip under
  the boss bar, its tail at the crest (the face is already there), ink on cream, 2 lines max
  (22/20/18 fit), top quarter, fade 0.18/0.22 s, never waits on play; FORM = &"strip" (the box one
  value away). Unit test_boss_taunt 4/0 (+ test_hud_dialogue: 11/0). b129ae24 the dev shot
  (`GTAI_TAUNT_FORM=strip|box`), debt +118 dev lines accepted with the reason. Lint 15/15.
- DECISION (docs/decisions.md hud/boss taunt): strip under the bar is the default; the box is the
  owner's call.
- 01:01 Evidence: `gtai-masters/n8/hud/call_boss_taunt_box_vs_strip_combo_1280x800.png` and
  `boss_taunt_box_vs_strip_king_combo.mp4` (12 s, side by side, seed 2, 0 SCRIPT ERROR both).
  Looked at 4.5 s / 7.5 s / 8.5 s: at 7.5 s the King's attack wedge reaches Rivet, the strip
  covers nothing of it. frames.json 15 (dropped the it5 clip, superseded by it6 + this clip for
  the King's crest, and the crate-ink still; both files deleted).
- 01:13 Gates (`node tools/evidence/run.mjs --no-bench` at 4632084a, every change of this
  iteration; `gtai-n8/scratch/hud/evidence_run_it7.log`): lint 15/15, unit 1512 passed 0 failed,
  scenarios 52/52, parity bit-exact + planted mutation caught at step 629, look goldens 11/11 (top
  did not move), export-audit 557/0. Nothing committed during the run.
- 01:14 Director reel started at 4632084a (top + tilt70, headless, in parallel; logs to scratch
  then `evidence/director-reel-n8hud-it7-*.log` once finished).
- 01:22 Director reel at a91232c4 (headless, `arena.tscn --fixed-fps 60 --quit-after 14000 --
  --bot=reel --reel=director --loadout=pistol --rigs --view=<v>`): `top` 19/19 chapters all down,
  `tilt70` 19/19 all down, 0 SCRIPT ERROR both (`evidence/director-reel-n8hud-it7-{top,tilt70}.log`).
- DECISION (not built): no `--taunt` arena flag for the exe: the showcase preset exports only
  data/ and quests/ JSON, so the dev lines would have to be hard-coded text (rule 4). The taunt
  call is shown by the masters still + clip; the dev shot command is in frames.json.
- 01:35 MILESTONE 952317a2 the taunt strip in the print style: the dialogue box's torn memo paper
  (HudArt 9-slice) instead of flat cream. First paper take (looked at a 2x crop) put the hatched
  edge on the words and the tape over the bar: the paper now grows 14/16 px outside the words,
  the strip sits 34 px under the bar (tape clear), the tail 32 px to the crest. Masters re-shot
  (box vs strip still + clip, 0 SCRIPT ERROR both) and `boss_taunt_strip_flat_vs_paper_crop2x.png`.
  Unit fast suite (`--changed` fell back to it) 1496/0, lint 15/15. Not re-run after 952317a2:
  the full evidence run (the change is BossTaunt only, which no shipped scene attaches).

Registry rules applied this iteration: `short-form-cards-and-barks` (a taunt in a fight is a bark:
one strip, 2 lines max, no second face, never blocking), `accessibility` (judged at the Steam Deck
1280x800 capture: 22 px ink on cream, the field and the telegraphs stay visible),
`motion-quality-gating` (the layout judged live in the King fight, the problem found by looking at
the real take, not the board), `depth-ordered-layered-art` (the strip on the boss bar's HUD layer,
the tail over the paper), `concept-scene-parity` (the strip wears the dialogue box's own paper).

NEXT:
- Work items 1-4 are evidenced. it7 closed "film one boss taunt" (live, strip default, box the
  call). Run the full gates once at the start of the next session (`node tools/evidence/run.mjs
  --no-bench`; 952317a2 only touched BossTaunt).
- Polish candidates, weakest first: Servo has no voice bible (no taunt words to film); a Servo
  strip shot only when lines exist. Long guns' p70 closed as built (assets: a lying gun IS its
  side profile at 70).
- Freeze 08:30: export `build/export/windows/RTAI.exe` with the `windows-showcase` preset
  (recipe in `gtai-n8/scratch/hud/it6/report_notes.md`, updated it7: Calls incl. the boss taunt
  strip vs box); REPORT from those notes.
- 01:40 Session end. All committed.

## Iteration 8 (BUILD, 01:31-02:31)

- 01:32 Read JOURNAL, git log, the other lanes' journals (no REQUEST to hud; city's note: quest 1
  under tilt70 is flat on n8-hud because the city art is on n8-city, a clean merge for the Director)
  and the assets JOURNAL: NEW `weapon_crate_open_70_v2` (round 20261107-0150, B: values fixed, deep
  amber planks / cream straw / dark hollow / bold outline; camera ~55-60, shallower than 2300's
  ~65-70; "for hud: v2 view 1 has the better value read, 2300 view 1 the steeper camera").
- 01:33 Gates started at fc2736f3 (`evidence_run_it8.log`): lint 15/15, unit 1512 passed 0 failed,
  parity bit-exact + planted mutation caught at 629, look goldens 11/11 + block 5/5, export-audit
  557/0; FAIL scenario_corpse_horde (wall-clock: "the step grew with the dead 1304 -> 3235 us", a
  budget not under the CONTENDED rule) and unit flagged FAIL "tree changed during run".
- FRICTION (mine): I wrote the new crate cut and crate_cut.py into the worktree while the gate run
  ran; the evidence run marks unit FAIL on any tree change. Rule (again, it5): nothing into the
  worktree during a gate run, JOURNAL included; draft in scratch.
- corpse_horde re-run alone (`node tools/tests/run_scenarios.mjs --only=scenario_corpse_horde`):
  1 passed. A contended wall-clock miss on the shared machine; nothing of mine touches corpses.
- 01:36 Judged the v2 crate before wiring: mock with the pistol, plasma rifle and chainsaw lying in
  each cut, full size and at 32 px/m (`gtai-n8/scratch/hud/it8/crate70_mock_guns{,_32x4}.png`):
  v2 reads as a crate, the tan guns pop off its dark hollow; 2300 is one flat yellow mass.
- 01:45 MILESTONE 91a864ac the 70 open crate from the v2 sheet: `crate_cut.py` VIEW["p70"] =
  ("70_v2", 0) (the 2300 sheet one value away; its straw fix keyed to that sheet only), BED p70
  re-measured on the cut 0.58 -> 0.62 (a luminance profile down the middle: hollow 0.50-0.60,
  straw front 0.61-0.64, rim 0.66), 1 provenance line (prompt_hash f74a4af6fc14). Lint 15/15.
- Filmed after `--import` (the it6 rule): `arena.tscn -- --armory --ppm=<32|48> --view=tilt70
  --rigs --seed=1 --pickup-crate=on`, frame 89, 0 SCRIPT ERROR both. Masters:
  `crate_v2_tilt70_{32,48}_before_after_crop2x.png` (before = the 2300 inked crate, the same
  command at it6), and the call stills `call_pickup_hover_vs_crate_{32,48}_crop2x.png` re-cut with
  the v2 70 crate (only the 70 crate quadrant replaced; aligned by template match, mean diff 1.7).
  Looked at all of them: the 32 px/m armory now shows 16 wooden crates with X-bracing instead of a
  tan band; at 70 and 55 the crates now share one value family. Weaker read: the katana's dark
  blade on the dark hollow.
- DECISION (docs/decisions.md hud/pickup crate 70 art): v2 over 2300 for the value read at the
  shipped zoom; the hover stays the default (the call unchanged).
- frames.json 15: +2 crate pairs; dropped `call_pickup_hover_vs_crate_48` (the crate 48 pair is
  the close-up) and `dialogue_contact_1080p` (superseded by the live call); kept the 1280x800 HUD.
- 02:05 Gates (`node tools/evidence/run.mjs --no-bench` at 91a864ac, the tree untouched during the
  run; `gtai-n8/scratch/hud/evidence_run_it8b.log`): lint 15/15, unit 1512 passed 0 failed,
  scenarios 52/52 (rig_stress missed under contention, re-judged alone: within budget;
  corpse_horde passed this time), parity bit-exact + planted mutation caught at step 629, look
  goldens 11/11 + block 5/5 (top did not move), export-audit 557/0.
- Director reel not re-run: 91a864ac changes only the crate art drawn under `--pickup-crate=on`
  (no reel chapter turns it on); the last reel 19/19 in top and tilt70 is at a91232c4 (it7).
- FINDING (not built): the katana's dark blade reads weakest on the v2 crate's dark hollow (48 px/m).
  Candidates if it matters to the owner: bed thin blades on the cream straw band, or a paper rim
  on a pickup in a crate. Noted in the REPORT notes.

Registry rules applied this iteration: `sprite-and-atlas-production` (the v2 crate cut by the same
re-runnable tool into the same cell, the alternative sheet one value away), `generative-artifact-
gating` (a B sheet used for what its notes name as fixed; its named weakness, the shallower
camera, weighed and accepted; 1 provenance line), `concept-scene-parity` + `motion-quality-gating`
(judged in the real armory at the same seed and frame before/after, at 32 and 48 px/m, not only on
the mock), `accessibility` (the call decided at the shipped 32 px/m), `depth-ordered-layered-art`
(the gun's bed re-measured so its bottom rests on the straw front, never over the front wall).

NEXT:
- Work items 1-4 evidenced; it8 raised the open crate at 70. Remaining polish, weakest first: the
  Servo's taunt waits for lines (the katana checked at 02:08: it reads).
- Freeze 08:30: export `build/export/windows/RTAI.exe` with the `windows-showcase` preset (recipe
  in `gtai-n8/scratch/hud/it6/report_notes.md`, updated it8); REPORT from those notes. Run
  `--import` (or a gate) before any filming; write nothing into the worktree during a gate run.
- 02:08 The katana FINDING checked at 5x on the 48 px/m frame (`scratch/hud/it8/katana_x5.png`):
  the wrapped hilt, the guard and the blade's highlight all read on the hollow; closed, no change.
  Scratch frame sequences deleted (the crops are in masters).
- 02:09 Session end. All committed.

## Iteration 9 (BUILD, 02:05-03:05)

- 02:06 Read JOURNAL, git log, the lane journals (no REQUEST to hud) and the assets JOURNAL (nothing
  new for hud: fall strips, props, vehicles). Items 1-4 evidenced, so I looked for the weakest piece
  on the masters stills: the dialogue box is 236 px + paper (~30 % of the 1280x800 viewport) for
  every line, even a one-line bark with two thirds of the paper empty (hud_full_1280x800_after.png).
- 02:17 MILESTONE 5e667105 the box fits its line (HudDialogue.FIT_BOX): its height comes from the
  words at their fitted size (150-236 px, bottom-anchored, eased over ENTER_S between lines; the size
  is still fitted against the full box, so the words never change size as the box moves); the
  252 px bust keeps its size and stands out over the paper's top edge on a short box. Unit
  test_hud_dialogue +1 (a bark gets 150-170 px, a long line 236), `--changed` 1497/0, lint 15/15.
- Looked: (1) live quest 1 at tilt70 (`quest1_clip.gd --view=tilt70 --stills=2300..4050`,
  0 SCRIPT ERROR): the payphone call is unchanged, because 21 of quest 1's 23 lines are over 110
  characters (13 over 165) and run 3-4 rows; no clipping on Don Fax's 4-row line. (2) The dialogue
  board at 1280x800, FIT_BOX false vs true: the short line (Brass's "Bring her back...") gains ~76 px
  of field, the bust over the paper reads as intentional; the 3-4 row lines are unchanged.
  Master: `dialogue_fitbox_1280x800_before_after.png` (frames.json 15: replaces the it5
  `quest1_dialogue_card` pair, whose file stays in masters).
- DECISION (docs/decisions.md hud/dialogue height): fitted over a fixed short box (quest 1's
  monologues would drop to 20 px or clip) and over shrinking the bust with the box; FIT_BOX = false
  is the fixed box.
- Side effect noted: the boss taunt's BOX form (the call's alternative) now gets the fitted box too,
  so the call still `call_boss_taunt_box_vs_strip_combo_1280x800.png` shows the old taller box.
- 02:30 Gates at 5e667105 (`node tools/evidence/run.mjs --no-bench`, the tree untouched during the
  run; `gtai-n8/scratch/hud/evidence_run_it9.log`): lint 15/15, unit 1513/0, scenarios 52/52, parity
  bit-exact + planted mutation caught at 629, look goldens 11/11 + block 5/5 (top did not move),
  export-audit 557/0.
- 02:36 MILESTONE 15fe68d7 the weapon wall hangs the seven pistol-grip guns flat (WeaponRackView.FLAT:
  pistol, machine pistol, Gloria, hand cannon, electro gun, ray gun, homing shard), muzzle forward,
  from a peg and a cord at the board's middle, at 0.9 of their length (the ray gun and the shard
  share 1 m slots); long guns, blades, the baton and the bottle stand muzzle up; `top` unchanged.
  Why: on the 32 px/m armory still every icon stood muzzle up, so a pistol read as a small upright
  totem. Filmed `arena.tscn -- --armory --ppm=<32|48> --view=tilt70 --rigs --seed=1`, frame 89,
  0 SCRIPT ERROR, before = HEAD's file; the frame diff's bbox is only the rack. Looked at both and at
  `--view=tilt` 48: the handguns read as guns on hooks at both pitches. Masters
  `rack_handguns_flat_tilt70_{32,48}_before_after_crop2x.png`; frames.json 15 (replaces the crate
  v2 32 pair; the 48 pair stays the crate's close-up). Unit test_weapon_showcase +1; full unit
  1514/0 at 15fe68d7.
- FRICTION (mine): the first take of the rack failed to parse (PackedVector2Array.append returns a
  bool: a discarded-value warning is an error here); caught by the SCRIPT ERROR count on the take,
  fixed to Array[Vector2]. `tools/godot/check.mjs` FAILs every file in this dependency chain
  (pickup_look.gd too, untouched): it is not a usable parse check for the weapon art scripts; the
  real scene run is.
- DECISION (docs/decisions.md hud/weapon rack): a named FLAT list over a length threshold (the bottle
  and the baton would lie flat); the board's width kept. An empty FLAT is the it8 wall.

Registry rules applied this iteration: `motion-quality-gating` + `concept-scene-parity` (both changes
judged on the real scenes: the live quest-1 call showed the fitted box barely moves for its long
lines, which kept the claim honest; the rack before/after on the same seed and frame),
`short-form-cards-and-barks` (a bark gets a bark-sized box; the face keeps its size),
`accessibility` (the words keep their fitted 30-20 px; nothing shrinks to make room),
`sprite-and-atlas-production` (the rack reuses the icon cut, only its pose changes, by data),
`depth-ordered-layered-art` (the bust drawn over the paper's top edge; the cord under the gun).
- 02:45 Scenarios at 15fe68d7 (`node tools/tests/run_scenarios.mjs`): 52 passed.
- 02:48 The boss taunt call re-shot (the box form now gets the fitted box): `GTAI_TAUNT_FORM=box
  boss_taunt.gd -- --boss=king --view=combo --rigs`, frame 239, 0 SCRIPT ERROR; pasted over the box
  half of `call_boss_taunt_box_vs_strip_combo_1280x800.png` (frames.json note says so). Looked: the
  box is ~40 px shorter and the crown stands over the paper, but it still covers the ghost card's
  chips (Dent/Kerf/Ohm) in the fight: the strip stays the default, the call unchanged.
- Director reel not re-run this session: 5e667105 changes the dialogue box's height (render only;
  no reel chapter speaks a quest line), 15fe68d7 the hub wall's pose under an angled view (render
  only). The last reel 19/19 in top and tilt70 is at a91232c4 (it7). Run it at the freeze.
- Scratch: the it9 take frames (rack/, taunt/, after/, board_*) stay in `gtai-n8/scratch/hud/it9/`
  only until the freeze session; the masters hold the crops.

NEXT:
- Work items 1-4 evidenced; it9 raised the dialogue box (fits its line) and the weapon wall (the
  handguns hang flat). Weakest left: the HUD's notice ("Saved.") floats free above a short box
  (could ride the box's top); the Servo taunt waits for lines; the long guns standing on the wall
  overlap the cops in front at 55 (the hub layout, not the art).
- Freeze 08:30: run the director reel (top + tilt70) and `node tools/evidence/run.mjs --no-bench`,
  export `build/export/windows/RTAI.exe` with the `windows-showcase` preset (recipe in
  `gtai-n8/scratch/hud/it6/report_notes.md`, updated it9), REPORT from those notes. Delete the it9
  scratch frames after the REPORT. Nothing into the worktree during a gate run.
- 02:51 Session end. All committed.
- 02:50 The NEXT candidate "the notice floats above a short box" checked in code (HudView._notice):
  it sits at a fixed height that clears the full box, with or without a line up. Riding the fitted
  box would make it jump between lines; a stable notice is the better read. Closed, no change.
  Scratch it9 trimmed to the frames the masters crops came from (1.3 GB -> 42 MB).

## Iteration 10 (BUILD, 02:50-03:50)

- 02:51 Read JOURNAL, git log, the lane journals (no REQUEST to hud; view notes the SIDE_X fix
  reaches its path on merge) and the library catalog: the assets lane landed
  `weapon_crate_open_70_v3` (round 20261107-0305, A: v2's three values at a ~65-70 camera, "supersedes
  2300 and v2 for hud's ShowcaseCrate rotation 1"): the re-check trigger of the it8 v2 decision.
- 03:04 MILESTONE 507d037c the 70 open crate from the v3 sheet: `crate_cut.py` VIEW["p70"] =
  ("70_v3", 0) (p55 re-cut byte-identical), BED p70 re-measured on the cut 0.62 -> 0.66 (a luminance
  profile down the middle: hollow 0.42-0.64, straw front 0.65-0.74, rim 0.76), 1 provenance line
  (prompt_hash 62342be542e3), docs(decisions) hud/pickup crate 70 art v3. Lint 15/15,
  `--select=test_showcase_crate,test_weapon_showcase` 13/0.
- Filmed after `--import`: `dev/arena/arena.tscn -- --armory --ppm=<32|48> --view=tilt70 --rigs
  --seed=1 --pickup-crate=on`, frame 89, 0 SCRIPT ERROR all; before = v2 + bed 0.62 (HEAD's art),
  the frame diff's bbox only the crate rows. Looked at both: with v3 each gun lies inside a straw
  ring on the dark hollow, seen from above like the 70 camera; with v2 the guns' bottoms rode over
  the front wall (gatling, mini nuke). The mini nuke still overhangs the hollow's top (it is big):
  accepted. Masters `crate_v3_tilt70_{32,48}_before_after_crop2x.png`; frames.json entry 8 now the
  v3 48 pair (the v2 48 file stays in masters).
- FRICTION (mine): the showcase PNGs are git LFS: `git show HEAD:<png> > file` writes the pointer,
  not the image, and the import then marks the texture invalid (the `.import` lost its path; the
  scene ran with "Failed loading resource" and 0 SCRIPT ERROR). Caught on the log, the `.import`
  restored from HEAD, the before re-shot from a copy of the real PNG taken first. Rule: for a
  before take keep a file copy, never `git show` a binary.
- 03:10 The owner's call still `call_pickup_hover_vs_crate_32_crop2x.png` re-shot whole at 507d037c
  (hover/crate x tilt70/tilt, 32 px/m, seed 1, frame 89, 0 SCRIPT ERROR all four): it now shows the
  v3 crate and the flat handgun wall (the it8 cut predated both).

Registry rules applied: `generative-artifact-gating` (an A sheet taken over the B it supersedes,
judged in the scene before adopting; 1 provenance line), `sprite-and-atlas-production` (the same
re-runnable cut tool, the alternative one value away), `concept-scene-parity` +
`motion-quality-gating` (the real armory, the same seed and frame, 32 and 48 px/m),
`depth-ordered-layered-art` (the bed re-measured so the gun's bottom rests on the straw front inside
the near wall).
- 03:12 Full unit at 507d037c: 1514 passed, 0 failed (`gtai-n8/scratch/hud/it10/unit_full.log`).
- Looked for the next weakest piece on a fresh full-HUD still at HEAD (`dialogue_board.gd --size=1280x800
  --ground=<a tilt70 city frame>`): the fitted dialogue box (it9) left the two top panels as the
  biggest empty paper on screen: the beat panel a fixed 640 px for "4/6  Get Gloria back" (~300 px
  empty), the cash frame a fixed 420 px for "$12,450" (~200 px empty).
- 03:14 MILESTONE 7d907818 the beat panel fits its words and heat pips (`HudView.BEAT_FIT`,
  `beat_width`: the longer of the head at 30 px and the heat row, + 30 px, at most 640): 640 -> ~330
  px; the frame diff is only that panel. Unit test_hud_art +1.
- 03:19 MILESTONE d847c440 the cash frame fits its sum (`HudCash`, a new 46-line file so hud_view.gd
  stays under 200 lines; the debt ratchet failed the first take at 222 lines): the drawn frame's
  banknote end and its torn right end (120 source px) kept at the 420 px scale, the plain middle cut,
  260-420 px, right-aligned so it stands over the 260 px ammo ticket as one column: 420 -> 260 px.
  Looked at 1280x800, 1920x1080, and the seam at 4x (`hud_cash_fit_seam_x4.png`: a 2 px step in the
  torn top edge, reads as torn paper). Unit test_hud_art +1. Rejected a 9-slice stretch (it stretches
  the hatching).
- Masters: `hud_fit_1280x800_before_after.png` (frames.json entry 12, replaces
  `hud_full_1280x800_after`, whose file stays), `hud_cash_fit_seam_x4.png` (not in frames.json).
- DECISIONS (docs/decisions.md): hud/beat panel width, hud/cash frame width.
- FINDING (not built): at 1080p the beat panel's right pad is tight (the "k" of "back" ~25 px from
  the torn edge, the rim eats ~10): BEAT_PAD 30 -> 40 is a one-value raise if it reads cramped.
- 03:27 Gates at d847c440 (`node tools/evidence/run.mjs --no-bench`, the tree untouched during the
  run; `gtai-n8/scratch/hud/evidence_run_it10.log`): lint 15/15, unit 1516/0, scenarios 52/52,
  parity bit-exact + planted mutation caught at 629, look goldens 11/11 + block 5/5 (top did not
  move), export-audit 558/0.
- 03:29 MILESTONE 20cefbe7 the FINDING built: BEAT_PAD 30 -> 40 (at 1080p the words now clear the
  hatched rim; `hud_beat_pad_1080p_30_vs_40.png`). test_hud_art 9/0, lint 15/15.
- Director reel not re-run: this session's changes are the 70 crate art under `--pickup-crate=on`
  (no reel chapter turns it on) and quest 1's HUD panels (no reel chapter draws HudView). The last
  reel 19/19 in top and tilt70 is at a91232c4 (it7). Run it at the freeze.
- Scratch it10 trimmed to the frame-89 stills the masters crops came from.

Registry rules applied (HUD items): `accessibility` (the words keep their 30/32 px sizes; only empty
paper is cut; checked at 1280x800 and 1080p), `short-form-cards-and-barks` (the panels sized to
what they say), `sprite-and-atlas-production` (the cash frame's drawn ends kept at their authored
scale, never stretched).

NEXT:
- Work items 1-4 evidenced; it10 raised the 70 crate (v3) and the top HUD panels (fitted). Weakest
  left: the weapon's showcase icon sits on the field left of the ammo ticket with no paper under it
  (reads as HUD by its place, but could be mistaken for a floor pickup on a busy street; a paper tab
  under it is the candidate); the Servo taunt waits for lines; the long guns on the wall overlap
  the cops at 55 (the hub layout).
- Freeze 08:30: run the director reel (top + tilt70) and `node tools/evidence/run.mjs --no-bench`,
  export `build/export/windows/RTAI.exe` with the `windows-showcase` preset (recipe in
  `gtai-n8/scratch/hud/it6/report_notes.md`, it10 lines appended), REPORT from those notes. Delete
  the it9/it10 scratch frames after the REPORT. Nothing into the worktree during a gate run.
- 03:33 TRIED and dropped (not committed): a memo-paper tab under the HUD weapon icon (NEXT 1).
  On the 1280x800 board the 9-sliced memo at icon size is a cramped torn scrap, Gloria overhangs
  its left edge, and it reads busier than the bare icon beside the clean ticket
  (`gtai-n8/scratch/hud/it10/icon_tab_rejected.png`). If it returns: a drawn tab (one piece of art
  with the ticket, like the cash frame's banknote end), not the memo 9-slice; or an ink drop shadow
  under the bare icon.
- 03:34 Session end. All committed.

## Iteration 11 (BUILD, 03:32-04:32)

- 03:33 Read JOURNAL, git log, the lane journals (no REQUEST to hud; city's it12 note on quest 1's
  flat street stands: it is n8-city's work, clean on merge) and the library catalog: the asset lane
  raised the portraits overnight (rounds 2050, 0400, 0410), but the game's quest-1 faces were still
  the 20:55 cut of round 1540 (B, eye-level camera). Worse: the in-game nurse wore the 1540 sheet's
  VERMILION chest stripe (a colour-law break I had not caught at it1).
- 03:45 MILESTONE 41b4692d the quest-1 cast's faces re-cut by `tools/art/portrait_cut.py` from the
  newest sheets: gunsmith, scientist, Mertz (2050 A), dock guard v2 (0400 A), nurse v3 (0410 B, the
  stripe muted plum in the raw sheet; camera still short). Looked: the old/new busts side by side
  (`gtai-n8/scratch/hud/it11/portraits_old_vs_new.jpg`), then the dialogue board at 1280x800 before
  (old busts swapped in by FILE COPY, then `--import`) / after and at 1080p close, over the tilt70
  city frame, 0 SCRIPT ERROR all. Every emotion pair now differs at a glance. Side effect accepted:
  Mertz's mood bust is 23 px wider, so his line fits one size down, the size the others have.
  10 provenance lines, docs(decisions) hud/dialogue faces raised. `--select=test_hud_dialogue,
  test_hud_art,test_story_forms,test_boss_taunt` 31/0, lint 15/15.
- Masters: `dialogue_faces_1280x800_before_after.png` (frames.json 11; entry 15, Servo's crest,
  dropped from the list, its file stays), `dialogue_faces_1080p_close_after.png`,
  `hud_full_1920x1080_after.png` re-shot at HEAD (fitted panels + the new Brass).
- Not taken: `portrait_don_fax_55_v2` (A): Don Fax is voice-only by design (the payphone frame);
  the three DESIGN PROPOSAL raises (valet, sister suction, lady cathode) stay off the game.
- 03:44 Colour audit of every PNG this branch adds (`git diff --name-only main...HEAD -- '*.png'`,
  228 files; red / vermilion / teal / police-blue pixel shares by hue, then the flagged ones LOOKED
  at with the hits masked, `gtai-n8/scratch/hud/it11/red_audit.png`): the five owner-redesigned
  weapons flag on copper coils and wire wraps (warm metal, the owner's designs) and small hazard
  stripes (danger marks): kept. The dock guard's orange-vermilion hard hat and hi-vis vest are his
  approved concept (assets graded A): kept, a FINDING for the REPORT (vermilion is reserved; hi-vis is
  hazard gear). Nothing else.
- 03:46 9af4190d unit guard: the nurse's busts carry no vermilion (the 1540 cut counts 320/329
  sampled px, v3 15/12, threshold 60: the planted old art fails it by the same count in Python).
- 03:47 MILESTONE 69c3b200 the HUD weapon icon's ink drop shadow (HudView.ICON_SHADOW 5,6 px, alpha
  0.5; ZERO = the bare icon): it10's NEXT alternative after the paper tab was dropped. The board at
  1080p and 1280x800, the frame diff's bbox only the icon's box: the icon now lifts off the street
  the way the cash frame and ticket do from their drawn shadows. Unit test_hud_art +1 (the offset
  stays in the 8 px gap before the ticket). docs(decisions) hud/weapon icon shadow.
- 03:54 Gates at 69c3b200 (`node tools/evidence/run.mjs --no-bench`, the tree untouched during the
  run; `gtai-n8/scratch/hud/evidence_run_it11.log`): lint 15/15, unit 1518/0, scenarios 52/52,
  parity bit-exact + planted mutation caught at 629, look goldens 11/11 + block 5/5 (top did not
  move), export-audit 558/0.
- 03:55 Live: `quest1_clip.gd --resolution 1280x800 -- --view=tilt70 --stills=4300..9100/400`,
  0 SCRIPT ERROR: Juno's mood bust (6700) and Brass (9100) in the real Toner Room beat read; the
  shadowed Gloria icon over the crosswalk reads as HUD. Masters `quest1_live_faces_tilt70_1280x800.png`,
  `quest1_live_icon_shadow_tilt70_x2.png`, `hud_icon_shadow_1080p_before_after_x2.png`,
  `portrait_proposals_contact_v2.jpg` (the six DESIGN PROPOSALS at their latest raise + Don Fax's
  v2 bust, kept off the game: for the owner only).
- Director reel not re-run: this session changed quest-1 portrait art and the HUD icon's draw (no
  reel chapter draws HudView). The last reel 19/19 in top and tilt70 is at a91232c4 (it7). Freeze.

Registry rules applied: `generative-artifact-gating` (the newest graded sheet per id, the colour law
checked on the cut, a C never; 10 provenance lines), `sprite-and-atlas-production` (the same cut
tool re-run, nothing hand-edited), `concept-scene-parity` + `motion-quality-gating` (board
before/after on the same ground, then the live quest at tilt70), `accessibility` (the words keep
their fitted sizes; the shadow adds contrast on the field), `short-form-cards-and-barks` (the
emotion pair must differ at a glance: the 1540 gunsmith's did not).
- 04:00 REQUEST to assets: portrait_nurse_55 v4, 55: the camera raise v3 fell short of (~20-25
  vs the cast's 40-50, your own v3 note); keep v3's raw colours (plum stripe, amber eyes, no
  vermilion) and its emotion pair. Why: in the dialogue box she now sits beside Brass, Kilohm, Mertz
  and the dock guard, all seen from above; she is the one bust at eye level. hud re-cuts with
  `tools/art/portrait_cut.py` the session it lands.
- 04:00 REQUEST to assets: weapon_showcase_melee raise, 70 only, the CHAINSAW: your 2155 B note
  ("the chainsaw at 70 should show more of its top"). One lying side view with the top plane of
  the body and bar visible (~60-70 camera), the 2155 design and mustard palette, on #00B140. Why:
  in the open crate and on the floor at tilt70 it is the one long piece drawn dead side-on. Low
  priority after the nurse.
- 04:04 MILESTONE d60b7f4c the ghost-form card (the soul cards, bottom left; seen in the arena, the
  boss fights, the reel and quest 1) on the HUD's torn memo paper (`HudPaper`, a 12-line helper
  over HudArt's 9-slice; `GhostFormHud.MEMO`, false = the flat D5 card) instead of the flat cream
  rectangle with a hard ink rim, the last HUD panel outside the print style. First take: the tape ran
  across "Dent"/"Kerf" and the hatch touched "Tonnage" -> `paper_of` grows 16/34/10/16; the right
  held to 10 because the folded card's paper must clear the dialogue box's (156 px at 1080p):
  test_hud_dialogue's clearance test now measures `paper_of`. The debt ratchet failed the first
  take (209 lines past the soft cap) -> the paper draw moved to HudPaper, the card file at 200.
  Looked: the armory tilt70 32 px/m seed 1 frame 89 (the frame diff only the card's box) and quest 1
  at 6700 (the folded card beside Juno's box), 0 SCRIPT ERROR. Master
  `ghost_card_paper_tilt70_before_after.png` (frames.json 11). docs(decisions) hud/ghost-form card paper.
- 04:12 Gates at d60b7f4c (`gtai-n8/scratch/hud/evidence_run_it11b.log`, tree untouched during the
  run): lint 15/15, unit 1518/0, scenarios 52/52, parity bit-exact + planted mutation at 629, look
  goldens 11/11 + block 5/5 (top did not move), export-audit 559/0.
- frames.json: a list trim dropped the 55 armory pair; restored (entry 15), the boss-taunt mp4
  entry removed instead (its file stays; the call still's note points at it).
- Director reel not re-run: d60b7f4c draws the ghost card in the arena (render only, the same code
  path the armory film ran with 0 SCRIPT ERROR). The last reel 19/19 in top and tilt70 is at a91232c4
  (it7). RUN IT AT THE FREEZE (the card is in every chapter's frame).

NEXT:
- Work items 1-4 evidenced; it11 raised the quest-1 faces (newest sheets, the nurse's vermilion
  gone), the HUD icon (ink drop shadow) and the ghost-form card (memo paper). Weakest left: the
  nurse's camera (REQUEST v4 out), the chainsaw's side-on 70 drawing (REQUEST out), the chips inside
  the card are flat D5 discs (a drawn chip set would match the paper; a REQUEST or keep), the Servo
  taunt waits for lines, the long guns on the wall overlap the cops at 55 (the hub layout).
- On a nurse v4 or chainsaw raise in the catalog: re-cut (`portrait_cut.py`, `showcase_import.py`),
  provenance, film, and the nurse guard test stays.
- Freeze 08:30: the director reel (top + tilt70), `node tools/evidence/run.mjs --no-bench`, export
  `build/export/windows/RTAI.exe` (`windows-showcase` preset, recipe in
  `gtai-n8/scratch/hud/it6/report_notes.md`, it11 lines appended), REPORT from those notes (FINDING
  for the owner: the dock guard's concept-approved orange-vermilion hi-vis). Delete it9-it11 scratch
  frames after the REPORT. Nothing into the worktree during a gate run.
- 04:14 Session end. All committed.
- 04:21 Director reel (headless, `arena.tscn --fixed-fps 60 --quit-after 14000 -- --bot=reel
  --reel=director --loadout=pistol --rigs --view=<v>`) at 236c2f13 (= d60b7f4c's code: the memo
  card in every chapter): `top` 19/19 chapters all down, `tilt70` 19/19 all down, 0 SCRIPT ERROR
  both (`evidence/director-reel-n8hud-it11-{top,tilt70}.log`). The freeze still re-runs it.
- 04:22 Session end. All committed.

## Iteration 12 (BUILD, 04:23-05:23)

- 04:24 Read JOURNAL, git log, the lane journals. REQUEST to hud from view (it11, l.862): the quest 1
  Dock 9 "Gloria drawing" ~7 m at tick 13700 tilt70. LOOKED at view's still
  (`gtai-masters/n8/view/quest1_merge_preview_dock9_gloria_pickup_crop2x.png`): it is not a pickup,
  it is the HUD weapon icon (bare on the street left of the ammo ticket, it6; shadowed it11), at
  that window size over the crate row and the "PROJECT TUG..." label. A teammate reading it as loot
  is the it10 worry confirmed.
- Assets delivered to hud (their it48): portrait_nurse_55_v4 B (camera fixed, raw colours; rust a
  step redder), weapon_showcase_chainsaw_70 B (view 1 cut -> keyed/weapon/chainsaw_70_v2.png).
- 04:40 MILESTONE 93c8bd2a the HUD weapon icon on the ammo ticket's paper (`HudTicket`, 3-slice:
  stub and torn end at the drawn scale, the plain middle stretched; fitted to the words + an 80 px
  icon, at most 180 wide). Looked: the board at 1280x800 and 1080p before/after
  (`gtai-masters/n8/hud/hud_icon_on_ticket_1280x800_before_after_x2.png`), 0 SCRIPT ERROR; the
  street left of the ticket is the street again, the icon reads as part of the ticket. Unit
  test_hud_art +1 (planted ON_TICKET false fails it: the icon over the name). Lint 15/15.
  `HudTicket.ON_TICKET = false` = the bare icon with its shadow. docs(decisions).
- ANSWER to view (REQUEST l.862): the Dock 9 Gloria at 13700 is the HUD's weapon icon, not a floor
  pickup (quest 1 draws no PickupsView). Fixed on n8-hud 93c8bd2a: the icon now sits on the ammo
  ticket's paper, the street left of the ticket (the crates, the label) is clear.
- 04:36 MILESTONE d63fb403 Juno Stitch's busts re-cut from portrait_nurse_55_v4 (assets 0505, B, my
  REQUEST l.819): the head box from above at ~45-50 like the cast (v3 eye level). Raw key, not the
  brown pass (it greys her tan body, looked side by side `gtai-n8/scratch/hud/it12/nurse/
  v3_v4raw_v4brown.png`); raw rust under the nurse vermilion guard (sampled 21/57 vs 60). Board
  at 1280x800 before/after (`dialogue_nurse_v4_1280x800_before_after.png`), 0 SCRIPT ERROR. 2
  provenance lines. Not taken: sister_suction v3 (a DESIGN PROPOSAL, stays off the game).
- 04:38 MILESTONE 3b7cdeb2 the 70 showcase chainsaw from the 0505 raise (B, my REQUEST l.824,
  view 1 = keyed/weapon/chainsaw_70_v2.png; `showcase_import.py` SOURCE override, only p70 moved).
  Filmed in the armory tilt70 at 32 and 48 px/m, seed 1, frame 89, 0 SCRIPT ERROR; the frame diff
  only the chainsaw's crate: the engine top under the arched handle, it lies in the crate like its
  neighbours (`chainsaw_v2_tilt70_{32,48}_before_after_x3.png`). 1 provenance line.
- 04:46 Gates at 3b7cdeb2 (`gtai-n8/scratch/hud/evidence_run_it12.log`, the tree untouched during the
  run): lint 15/15, unit 1519/0, scenarios 52/52, parity bit-exact + planted mutation at 629, look
  goldens 11/11 + block 5/5 (top did not move), export-audit 560/0.
- 04:40 Live quest 1 at Dock 9 (`quest1_clip.gd --resolution 1280x800 -- --view=tilt70
  --stills=13700,13800`, 0 SCRIPT ERROR): Gloria on the ticket, the first crate of the row beside it
  (`quest1_dock9_icon_on_ticket_tilt70_1280x800(_x2).png`). The rest of the row and the label still
  sit under the HUD's top-right corner at this camera: the stage's crate placement, not the icon.
- 04:48 MILESTONE 6e8daf39 the ticket for all 17 showcase weapons (the dialogue board now saves
  `ticket_<id>.png`; contact `hud_tickets_all_weapons_1280x800_contact.png`): every icon fits the
  paper and the long names (Rocket Launcher, Machine Pistol) clear the icon; the name's first
  letter touched the perforation -> TEXT_SRC 140 -> 152. Debt +22 dev lines accepted with the
  reason. Thin pieces (katana, baton, plasma sword) are small at 180 px wide but read.
- Director reel not re-run: no reel chapter draws HudView (quest 1 only) and the chainsaw/nurse are
  art swaps on paths the reel at 236c2f13 already ran. The freeze re-runs it.
- frames.json: entry 13 = the icon on the ticket (1280x800 before/after); entry 12's 1080p full HUD
  re-shot at 93c8bd2a.
Registry rules applied it12: `concept-scene-parity` (a teammate's read of the real quest scene taken
as the defect report, verified on the live Dock 9 still), `generative-artifact-gating` (newest
graded sheet per id, the colour guard on the cut, raw over a post pass that hurt the read; 3
provenance lines), `sprite-and-atlas-production` (the cut tools re-run, nothing hand-edited; the
ticket a 3-slice of the drawn art, not a stretch), `accessibility` (the names keep 24 px with paper
between them and the perforation), `motion-quality-gating` (armory film, same seed and frame).
- 04:55 ANSWER to view (NOTE l.835, fold_rigs): no objection. Take view's `StoryForms.follow` over
  hud's `fold_rigs` in the merge (it also lifts and voices, and my unfold-on-silence case lives in
  your follow test 8ecf8f2d). For your next trial merge: it12 adds `features/hud/hud_ticket.gd`
  (new file) and touches `hud_view.gd`, `dialogue_board_run.gd` (dev), `test_hud_art.gd`, the nurse
  busts, the 70 chainsaw cut, `tools/art/showcase_import.py`, and `tools/debt/baseline.json` (dev_loc
  +22 accepted): none of them yours.
- 04:53 Full unit at 6e8daf39: 1519 passed, 0 failed, 0 FLAKY (`gtai-n8/scratch/hud/it12/unit_full.log`).
- 04:55 006aeaba the board's ticket crop in proportion to the window; all 17 tickets looked at 1080p
  (`hud_tickets_all_weapons_1920x1080_contact.png`).
- 04:57 Combined clip v3 recording (`gtai-n8/scratch/hud/it12/clip3.sh`: armory 70/55 at 48 px/m,
  the King at combo, quest 1's payphone call 2150-3500 and Dock 9 13560-13860 at tilt70).

NEXT:
- Work items 1-4 evidenced; it12 answered view (the Dock 9 "7 m Gloria" was the HUD icon: now on
  the ticket), took the nurse v4 and chainsaw 70 v2 raises. Weakest left: the thin pieces on the
  ticket (katana, baton, plasma sword at 180 px wide read small; ICON_MAX_W is one value), the
  Servo taunt waits for lines, the long guns on the wall overlap the cops at 55 (the hub layout),
  quest 1's Dock 9 crate row sits under the HUD's top-right corner at the tilt70 camera (stage
  placement: a note for the REPORT, not hud's to move).
- If the combined clip v3 is not in `gtai-masters/n8/hud/` yet: its frames/avis are in
  `gtai-n8/scratch/hud/it12/clip/`; encode (ffmpeg, 1280x800, 30 fps), look at a contact sheet, put
  it in frames.json in place of the it6 clip (entry 1), then delete the raw .avi/png frames.
- Freeze 08:30: the director reel (top + tilt70), `node tools/evidence/run.mjs --no-bench`, export
  `build/export/windows/RTAI.exe` (`windows-showcase` preset, recipe in
  `gtai-n8/scratch/hud/it6/report_notes.md`, it12 lines appended), REPORT from those notes
  (FINDING: the dock guard's concept-approved orange-vermilion hi-vis). Delete it9-it12 scratch
  frames after the REPORT. Nothing into the worktree during a gate run.
- 04:59 MILESTONE the combined clip v3: `gtai-masters/n8/hud/hud_set_combined_it12.mp4` (49 s,
  1280x800, at 8b34ee77, 5 segments, 0 SCRIPT ERROR each): the armory at 70 and 55 (48 px/m, hover
  default), the King at combo (crest + bar, the memo ghost card), quest 1's payphone call (Patch's
  device frame) and Dock 9 (Gloria on the ticket). Looked at a 7-frame contact sheet
  (`gtai-n8/scratch/hud/it12/clip/contact.png`). frames.json entry 1 (replaces the it6 clip; its file
  stays). Raw .avi and png frames deleted. NEXT's "combined clip v3" item is done.
- 05:01 MILESTONE 7aa9611e the thin pieces on the ticket (wider than 5x their height: katana,
  electro baton, plasma sword) run to 240 px instead of 180 (`HudTicket.THIN_MAX_W`; = ICON_MAX_W is
  the single cap): at 180 the katana drew 29 px tall; at 240 the baton's coil and the sword's blade
  read (`hud_ticket_thin_icons_1280x800_before_after.png`; all 17 re-shot in
  `hud_tickets_all_weapons_1280x800_contact.png`). Unit test_hud_art +1. docs(decisions).
- 05:04 Full unit at 7aa9611e: 1520 passed, 0 failed, 0 FLAKY (`gtai-n8/scratch/hud/it12/unit_full2.log`).
  Lint 15/15 (hook). The scenarios/parity/goldens ran green at 3b7cdeb2; since then only HUD
  ticket drawing (quest 1 only), a dev board and tests changed: the freeze gate re-runs all.

NEXT (supersedes the 04:57 NEXT):
- Work items 1-4 evidenced, the combined clip v3 done. Weakest left: the Servo taunt waits for
  lines; the long guns on the wall overlap the cops at 55 (the hub layout); the 1080p ticket
  contact is from 006aeaba (before the thin cap: re-shoot with `board.sh` at 1920x1080 if it goes
  in the REPORT); quest 1's Dock 9 crate row under the HUD corner (stage placement: REPORT note).
- Watch the catalog for raises to hud's ids (portraits of the quest-1 cast, weapon_showcase_*):
  re-cut with `portrait_cut.py` / `showcase_import.py`, provenance, film.
- Freeze 08:30: the director reel (top + tilt70), `node tools/evidence/run.mjs --no-bench`, export
  `build/export/windows/RTAI.exe` (`windows-showcase` preset, recipe in
  `gtai-n8/scratch/hud/it6/report_notes.md`, it12 lines appended), REPORT from those notes
  (FINDING: the dock guard's concept-approved orange-vermilion hi-vis). Delete it9-it12 scratch
  frames after the REPORT. Nothing into the worktree during a gate run.
- 05:05 Session end. All committed.

## Iteration 13 (2026-11-07 05:04, BUILD)
Read: JOURNAL (it12 NEXT), git log, the four lane journals (no new REQUEST to hud; view's it13 is
the held-art key fix and the trial merge on hud d63fb403), the library catalog since 0505: no
raise for hud's ids (sister_suction v3 A, lady_cathode v3 A are portraits hud does not show:
design proposals, not in PortraitBook).
- 05:06 Looked fresh at the armory on HEAD (tilt 48, tilt70 32, seed 1, frame 89, 0 SCRIPT
  ERROR): the wall/cop overlap at 55 is the dev hub's sparring line in front of the board (the
  arena's layout, a dev station): not worth the hour. The shipped screen is quest 1.
- MILESTONE 05:28 39b6a8e6 the see-through corners (HudSee, HudCorner): the beat panel and the
  cash + ticket corner ease to 35 % in 0.2 s while Rivet, the objective's goal, a living hostile or
  (heat > 0) a police patrol is under them or within 40 px. HudState.clear_px, filled by
  HudFeed.fill_view (quest 1's view: 0 lines added; HudView 197 lines, ink_digits moved to
  HudCash). Found the moment by a temporary tick log over a still scan of the whole quest
  (1000-19000 step 100): Hot Walk Home t16399-16499 and t17199-17399, a patrol under the ticket.
  Filmed `quest1_clip.gd --resolution 1280x800 -- --view=tilt70 --ticks=16300-16620` after and
  with SEE false (before), 0 SCRIPT ERROR each: the fade at frame ~21, held to ~135, back by ~147
  (measured on the cash paper's mean); looked at frame 80: the cop and the dead pile show through,
  GLORIA and $0 stay readable. Masters `hud_see_through_cop_tilt70_1280x800_before_after(_x2).png`,
  `hud_see_through_cop_tilt70_after.mp4`; frames.json entry 4 (replaces the fit-box pair).
- FRICTION (mine): the first scan counted the patrols at heat 0 (CastView draws them only while
  hot): the ticket faded over nothing on Hot Walk Home (frames 10-130 of the 17400 clip). Fixed
  (heat > 0) with a test; re-filmed 17400-18990: no false fade. The feed's points were checked
  against the objective ring and the living guards by a temporary log (goal (122,305) on the ring
  at (122,297); the guards on their bodies); civilians (the crowd) do not count, by design.
- DECISION (docs/decisions.md hud/see-through corners): fade over shrink (the names keep their
  size) and over moving corners; SEE false = the opaque HUD. Unit test_hud_see 6/0, lint 15/15.
Registry rules applied it13: `accessibility` (nothing shrinks: the HUD gets out of the way by
alpha, text keeps its size; 35 % keeps the words readable), `concept-scene-parity` +
`motion-quality-gating` (judged on the live quest scene, before/after on the same ticks, the ease
measured frame by frame, a false trigger caught in motion that a still could not show),
`depth-ordered-layered-art` (the HUD stays the top layer; it yields rather than reorders).
- 05:39 Gates at 4e31d5b3 (`node tools/evidence/run.mjs --no-bench`, the tree untouched during the
  run; `gtai-n8/scratch/hud/evidence_run_it13.log`): lint 15/15, unit 1525/0 (0 FLAKY), scenarios
  52/52, parity bit-exact + planted mutation at 629, look goldens 11/11 + block 5/5 (top did not
  move), export-audit 562/0. Scratch: it13 raw frames deleted (masters hold the pair + clip).
- Director reel not re-run: no reel chapter draws HudView (quest 1 only); the freeze re-runs it.

NEXT (supersedes it12's):
- Work items 1-4 evidenced + it13's see-through corners. Weakest left: the Servo taunt waits for
  lines; the 1080p ticket contact is from 006aeaba (before the thin cap: re-shoot with
  `gtai-n8/scratch/hud/it12/board.sh tickets 1920x1080` if it goes in the REPORT); the
  see-through alpha (HudSee.SEE_A 0.35) could be a Call for the owner (35 vs 50 %, one value).
- Watch the catalog for raises to hud's ids (quest-1 cast portraits, weapon_showcase_*): re-cut
  with `portrait_cut.py` / `showcase_import.py`, provenance, film.
- Freeze 08:30: the director reel (top + tilt70), `node tools/evidence/run.mjs --no-bench`, export
  `build/export/windows/RTAI.exe` (`windows-showcase` preset, recipe in
  `gtai-n8/scratch/hud/it6/report_notes.md`, it12 + it13 lines appended), REPORT from those notes
  (FINDING: the dock guard's concept-approved orange-vermilion hi-vis; add the see-through corners
  to "what works"). Delete it9-it13 scratch frames after the REPORT. Nothing into the worktree
  during a gate run.
- 05:45 The 1080p ticket contact re-shot at e3b1e573 (`it13/board.sh tickets 1920x1080`, 0 SCRIPT
  ERROR): all 17 showcase weapons on the ticket at 930x405 crops, the thin pieces (katana, baton,
  plasma sword) at the 240 px cap span the paper and read; the names clear the icons. Replaces
  `gtai-masters/n8/hud/hud_tickets_all_weapons_1920x1080_contact.png` (it12's was before the cap).
  NEXT's "1080p ticket contact" item is done. Session end: all committed.

## Iteration 16 (2026-11-07 05:42, BUILD)
Read: JOURNAL (it13 NEXT; it14/it15 left no entry), git log, the four lane journals (no new
REQUEST to hud; view's it14 answered vehicles' bay-number ink), the catalog since 0505: no raise
for hud's ids (sister_suction v3, lady_cathode v3 are proposals; rivet_eq_* is the equipped form,
frozen tonight).
- MILESTONE 9e2b05cc the ghost chip faces (GhostChipFace): each chip on the ghost-form card shows
  that ghost's own drawn face, frame 0 of its approved p55 card strip cut to an 84 px disc
  (`tools/art/ghost_chip_cut.py`), at 0.92 of the chip's radius, instead of the D5 ink glyphs (the
  last learned-symbol piece on the HUD). The current form keeps its teal ring + size; the cooldown
  pie sweeps over the face. Looked: armory tilt70 32 and 48 (seed 1, f89; diff only the chips'
  box), the Tonnage morph via `forms_lineup.gd --morph` under --write-movie (teal ring at f60, the
  sweep at f150/f190), inset 0.84 vs 0.92 (0.84 faces ~44 px: too small). 0 SCRIPT ERROR each.
  Masters `ghost_chip_faces_tilt70_{32,48}_before_after_x2.png`, `ghost_chip_faces_morph_cooldown_x2.png`;
  frames.json entry 11 (replaces the it11 paper pair). 4 derived provenance lines.
- FRICTION (mine): python's text-mode write turned ghost_form_hud.gd CRLF (git warned); sed'd back
  to LF before staging. The debt ratchet held the card file at 200 lines: the header rewrapped.
- DECISION (docs/decisions.md hud/ghost chip faces): faces over glyphs; one HUD icon in every view
  (screen space, like the weapon icon cut); FACES false = the glyph card.
Registry rules applied it16: `sprite-and-atlas-production` (cut by a re-runnable tool from the
shipped strip, sized to 1:1 at 1080p, no hand edits), `generative-artifact-gating` (only owner-
approved art in the game; provenance carried to the derived file), `accessibility` (a face reads
without learning a symbol; the current form keeps two cues, colour and size), `motion-quality-
gating` (the sweep and the ring judged across the morph, not one still).
- 05:57 Full unit at 9e2b05cc: 1527/0, 0 FLAKY. Quest 1's folded card at 6700 (1280x800 + 1080p):
  Tonnage's face reads (`ghost_chip_faces_quest1_folded_1280x800_1080p.png`).
- MILESTONE 2e5f39d3 quest 1's control prompt ("Answer the payphone: [E]", ObjectiveView) on the
  memo paper (`ObjectiveView.prompt_paper`, grow 26/30/44/24) instead of the flat cream box, the
  last flat panel on quest 1's screen; the tape tucks under the beat panel. Looked: ticks
  600/2400/13700 at 1280x800 and 1080p; the 1080p take put the last glyph on the hatch at right 34
  -> 44. Masters `quest1_prompt_paper_1280x800_1080p_before_after.png` (frames.json 9, replaces
  crate_v3), `quest1_prompt_paper_three_prompts_1280x800.png`, `hud_full_1920x1080_it16.png`.
  Unit test_objective_prompt_paper (new). DECISION hud/prompt paper.
- 06:12 Gates at 610da507 (`evidence_run_it16.log`, the tree untouched; the first try refused the
  dirty JOURNAL: commit it first): lint 15/15, unit 1528/0, scenarios 52/52, parity bit-exact +
  mutation at 629, look goldens 11/11 + block 5/5 (top did not move), export-audit 563/0.
- MILESTONE 009f8050 + 8ee9483f the boss bar as a paper banner hanging from the screen's top edge
  (`BossBar.paper_of`: top -40 so the torn top band and tape are off screen, 26 left / 44 right /
  30 below), the name and count in ink, the crest pinning its left end. The bar keeps its place:
  `BossCam.HUD_PX` and every view's framing unchanged. Takes: paper top 2 put the torn band on the
  name; -24 left the bottom edge through the bar and a tape sliver; -40/30 clean; right 26 put
  "1 / 3" on the hatch at 2x -> 44. Looked: King + Servo at combo (arena --rigs --seed=2 f150,
  1280x800), 0 SCRIPT ERROR. Masters `bossbar_paper_king_combo_before_after_x2.png` (frames.json
  12), `bossbar_paper_king_servo_combo_1280x800_before_after.png`. DECISION hud/boss bar banner.
- FRICTION: `--resolution 1920x1080` on arena.tscn still renders 1280x800 (the 1080p boss bar
  is untested live; the quest-1 clip honours it).
- 06:27 Full unit at 8ee9483f: 1529/0, 0 FLAKY. Lint 15/15 (hook).
- Director reel not re-run this session: the boss bar is drawn in its boss chapters (render only,
  the same path the arena films ran with 0 SCRIPT ERROR). RUN IT AT THE FREEZE, top + tilt70.
Registry rules applied (it16, the 2nd half): `accessibility` (the words keep size and place; they
gain contrast, ink on paper over cream-on-outline over a busy arena; every take checked for a glyph
on the hatch at 2x), `concept-scene-parity` (judged on the live quest and boss scenes),
`depth-ordered-layered-art` (the crest over the banner, the banner over the arena, never the reverse).

NEXT (supersedes it13's):
- Work items 1-4 evidenced; it16 put the last three off-style pieces on the paper style (ghost chip
  faces, the quest-1 prompt, the boss bar banner). Weakest left: the 1080p boss bar is unlooked
  (arena.tscn ignores --resolution: try `--window-size` / override.cfg, or the dialogue board);
  the Servo taunt waits for lines; HudSee.SEE_A 35 vs 50 % (a Call).
- Watch the catalog for raises to hud's ids (quest-1 cast portraits, weapon_showcase_*): re-cut
  with `portrait_cut.py` / `showcase_import.py`, provenance, film.
- Freeze 08:30: the director reel (top + tilt70; it covers the boss banner and the chip faces),
  `node tools/evidence/run.mjs --no-bench`, export `build/export/windows/RTAI.exe`
  (`windows-showcase` preset, recipe in `gtai-n8/scratch/hud/it6/report_notes.md`, it16 lines
  appended), REPORT from those notes (FINDING: the dock guard's concept-approved orange-vermilion
  hi-vis; "what works" adds the see-through corners, chip faces, prompt paper, boss banner; Calls:
  the boss banner vs the bare bar, chip faces vs glyphs). Delete it9-it16 scratch frames after the
  REPORT. Nothing into the worktree during a gate run.
- 06:30 Session end: all committed (15ecfd9c + this line). Scratch it16 raw stills deleted (masters
  hold the pairs). The 1080p boss bar left for NEXT (arena.tscn renders 1280x800 under
  --resolution; the HUD is canvas_items-stretched, so 1080p is the same layout x1.35).

## Iteration 19 (2026-11-07 06:29, BUILD)
Read: JOURNAL (it16 NEXT; it17/it18 left no entry, the log ends at a47b382a), the four lane
journals (no new REQUEST to hud; view's l.862 Dock 9 REQUEST was answered it12), the catalog since
0505: one raise for hud's ids, `weapon_showcase_heavy_v3` (round 20261107-0745, B: "COLUMN 3 FIXED:
the icons are rust-brown steel with brass bands ... For the HUD the icon column is now usable as
is"). The library has no per-weapon cut of it (keyed/weapon/ still the 21:06 files).
- MILESTONE 6dff9553 the rocket launcher, flamethrower and molotov HUD icons re-cut from v3's
  icon column. `showcase_import.py` learned SHEET: (id, form) -> (keyed sheet, column, row), the
  cell found by the alpha's column/row runs (the sheet is a clean 3 x 3). p70/p55 re-imported
  byte-identical. Checked against `rivet-r2/out/arm_{rocket_launcher,flamethrower,molotov}.png`:
  v3's flamethrower ring nozzle and single-tank look match the approved arm closer than the 2155
  cage nozzle; the floor p70/p55 keep the 2155 drawings (same palette and silhouette).
  Looked: tickets at 1280x800 (dialogue_board, before = the it2 cuts restored, after), the armory
  wall rack tilt70 32 + 48 px/m (seed 1 f89; the frame diff only the rack's three icons), 0 SCRIPT
  ERROR each. The molotov no longer melts cream-on-cream into the ticket; the grips show. On the
  rack the v3 rocket launcher reads chunkier (icon 384x186 vs 384x114), still inside its slot.
  Masters `hud_heavy_icons_v3_tickets_1280x800_before_after.png` (frames.json 14, replaces the it8
  icon-on-ticket pair; that file stays), `armory_rack_heavy_icons_v3_tilt70_48ppm_before_after_x2.png`.
  Unit test_hud_art + test_weapon_showcase 20/0; lint 15/15 (hook); 3 provenance lines.
Registry rules applied: `sprite-and-atlas-production` (cut by the re-runnable import tool, never
by hand; the source cell named in the tool and the provenance), `generative-artifact-gating` (a B
taken only for the column its notes clear; checked against the owner-approved arm design before
integrating), `accessibility` (value contrast of the icon on the cream ticket).
- MILESTONE (evidence, no code) the boss banner at 1920x1080, it16's open item: the King and
  Servo at combo (arena --rigs --seed=2 f150), 0 SCRIPT ERROR. The name and "1 / 3" sit on clear
  paper, the crest pins the left end, the bar centred at x 420-1500; the HUD is the 1280x800
  layout x1.35 with the 16:9 expand. Masters `bossbar_paper_king_servo_combo_1920x1080_top.png`
  (named in frames.json 12's note).
- FRICTION (solved): `--write-movie` renders at the project window size whatever `--resolution`
  says (1600x900 and `--main-scene` also gave 1280x800; the quest-1 clip honours it because it
  grabs the viewport, not the movie writer). Recipe: append `window/size/window_width_override=1920`
  and `window_height_override=1080` to the local, git-excluded `project/override.cfg` for the shot,
  then restore it from `gtai-n8/scratch/hud/it19/override.cfg.bak` (restored; the base 1280x800
  and the canvas_items stretch untouched, so this is the shipped 1080p layout).
- 06:47 Director reel at 2a8a045c started (headless, top + tilt70 in parallel, the it7 recipe;
  `gtai-n8/scratch/hud/it19/reel.sh`).
- GATE director reel on 5108b040 (the project tree = 6dff9553; headless, top + tilt70 in parallel,
  `--fixed-fps 60 --quit-after 14000 -- --bot=reel --reel=director --loadout=pistol --rigs`): `top`
  19/19 chapters down, `tilt70` 19/19 down, 0 SCRIPT ERROR both
  (`evidence/director-reel-n8hud-it19-{top,tilt70}.log`). It covers the boss banner and the chip faces.
- MILESTONE the combined clip v4: `gtai-masters/n8/hud/hud_set_combined_it19.mp4` (61 s, 1280x800,
  7 segments, 0 SCRIPT ERROR each; `gtai-n8/scratch/hud/it19/clip4.sh` + `encode.sh`): the armory at
  70 and 55 (48 px/m), the King and Servo at combo (paper banner + crest, ghost chip faces), quest
  1's payphone call (Patch's device frame, the prompt on paper), Dock 9 (Gloria on the ticket), the
  Hot Walk Home (the corners see-through over a patrol). Looked at an 8-frame contact sheet
  (`it19/clip/contact.png`). frames.json entry 2 (replaces v3; its file stays). Raw .avi and png
  frames deleted.
- REPORT.md drafted (it19) from `it6/report_notes.md`: the freeze session updates the gates line,
  the exe and anything after it19. Flags it names checked to exist (FORM, FACES, SEE_A, PAPER,
  ON_TICKET, FIT_BOX, --pickup-crate).
Registry rules applied (2nd half): `motion-quality-gating` (the set judged as one clip across seven
scenes, not stills), `concept-scene-parity` (the real arena, boss and quest scenes).
- GATE 07:00 full evidence run at 38bc8bee (`gtai-n8/scratch/hud/evidence_run_it19.log`, the tree
  untouched during the run): lint 15/15, unit 1529/0, scenarios 52/52, parity bit-exact + planted
  mutation caught at 629, look goldens 11/11 + block 5/5 (top did not move), export-audit 563/0.
- NOTE from view's JOURNAL l.1282 (no REQUEST): on the merged tree, Mertz's 3-line engage intro
  fills the dialogue box to its fitted max (~35 % of the 1280x800 height) over the lower street
  while play runs. Looked at view's clip frame (`it19/mertz_view.png`): Mertz and the crate row stay
  clear; the lower street (where Rivet comes from) is under the box. Added to REPORT ("does not
  work" + options); not built: a see-through dialogue must keep its text legible (a fork for the owner).

NEXT (supersedes it16's):
- FREEZE 08:30 (the next session): the gates are green at 38bc8bee and the reel 19/19 top + tilt70
  at the same project tree, so on an unchanged tree only export + REPORT remain: export
  `build/export/windows/RTAI.exe` (`windows-showcase`, the recipe in REPORT "Exe"), smoke it
  (`RTAI.exe -- --armory --view=tilt70 --rigs` for a few seconds), fill REPORT's "FILL IN" (exe time
  and size), drop "DRAFT" from its title, commit. If code changes before the freeze, re-run the
  gates and the reel first.
- If time before the freeze: the dialogue box over a fight (REPORT "does not work"): the cheapest
  form is HudSee for HudDialogue at a legible alpha (~0.7) over Rivet/a hostile; film Mertz's engage
  (quest1_clip --ticks=15200-15600 --view=combo) before/after. A DECISION + Call either way.
- Delete it9-it19 scratch frames after the REPORT (the masters hold every referenced still/clip;
  keep the logs).
- 07:01 EXE exported at 1fab97c0 (`windows-showcase`, 0 errors): `build/export/windows/RTAI.exe`
  262 MB + the sim DLL. Smoke (`--log-file`, 240 frames each): `-- --armory --view=tilt70 --rigs`
  and `-- --boss=king --view=combo --rigs`, 0 errors, frame 239 looked at
  (`it19/exe_smoke.png`). REPORT's Exe filled. The freeze re-exports only if code changes.
