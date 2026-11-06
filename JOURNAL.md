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
