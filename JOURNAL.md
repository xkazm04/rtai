# JOURNAL: ghost-powers lane (branch `n6-ghost-powers`), night 2026-11-04/05

Note for the Director: this branch fast-forwarded to n5-cast's tip f96fe0dd at 23:55 (brief: every session
merges n5-cast), which brought n5-cast's root JOURNAL.md/REPORT.md; this file replaces that JOURNAL on this
branch. n5-cast's own journal lives on its branch (take n5-cast's on the morning merge, move ours to
docs/night/2026-11-05/ghost-powers/).

## Iteration 1 (23:51-00:51, BUILD)
- 23:52 read git log, TARGETS.md ghost section, the eve ghost-powers REPORT, features/souls/**, powers.json,
  the brutality hook/DeathPipe/SignatureKills, ArenaStage hooks, VehicleDamage. n6-ghost-forms JOURNAL has no
  REQUEST yet (its head = n5-cast f96fe0dd, no ghost commits).
- 23:55 MERGE n5-cast f96fe0dd (fast-forward from a1275c82): the slim Rivet base.
- DECISION data split: my attack tuning goes in a new `data/tables/ghost_attacks.json` (`gtai.ghost-attacks/1`),
  one block per ghost (tonnage, dent, kerf, ohm) + `upgrade_tier` per block (quest rewards later), so the
  forms lane can own `powers.json` (rows, names, aliases, morph) without both lanes editing one strict schema.

### REQUEST 1 -> n6-ghost-forms (the interface; reply in your JOURNAL, I adopt whatever you commit)
1. **Form ids**: `tonnage`, `dent`, `kerf`, `ohm` (+ `rivet` = base). Old power ids `hauler` (= tonnage) and
   `gearbox` (= dent) stay as aliases in powers.json until the morning merge (saves, quest 1).
2. **Enter/exit**: I listen to `SoulPowers.started(id, bark)` / `ended(id, reason, bark)` (already there).
   If you add a form switch class, please keep emitting those two signals with the form id, and expose
   `form_id()` (StringName) on whatever the StagePilot holds.
3. **Anchors** (metres, body-local: +x = facing, +y = right; I read them from data, you own the values):
   tonnage `press_head` (0.9, 0) = slam centre; dent `hands` (0.5, +-0.25); kerf `emitter` (0.45, 0);
   ohm `electrodes` (0.4, 0.15). Proposal: a `anchors` object per form row in your table; until then I
   use these defaults in ghost_attacks.json.
4. **Footprint/speed**: I read the body radius from `ArenaBodies.table().radius(form.body_class)` and the
   speed from your step(); Tonnage's attacks scale off that radius (slam radius = 4 m today).
5. I will not touch: rigs, part sheets, HaulerLook, morph, HUD, input_actions rows. I do touch
   `HaulerStage` (attack logic), `CombatArena` (one armour field, default 1.0), signature_kills.json
   (+ crush row), `KillStyles` (+ crush dispatch).

### Tonnage (item 1)
- Registry rules applied: `motion-quality-gating` (judge in motion at game zoom, a telegraph must be readable
  before the hit: wind-up 0.3 -> 0.5 s with a footprint), `depth-ordered-layered-art` (the telegraph and marks
  are ground-band, under the actors: TonnageView at actors z - 2; kills keep KillView's z).
- MILESTONE f54b56ef Tonnage attacks: `Fighter.damage_k` (plates 0.3 while on), the slam lands 0.9 m ahead
  (`HaulerStage.slam_point`), cars within 3.4 m wrecked (VehicleDamage rules), kills within 2 m = new signature
  style `crush` (KillCrushFx: body spread 1.28 x 1.5 and pressed dark, 6-tick overshoot, reduced motion = at
  once), the ring = `stomp_wave` standard thrown death, ram kill = row `tonnage_ram` (blowback). Numbers:
  slam 3 dmg, ram 2, powers.json hauler values only (no schema change there). unit test_tonnage_attacks 2/2,
  test_hauler* 18/18 (test_hauler_stage waits 40 ticks for the 0.5 s wind-up).
- FRICTION lint gdformat FAILed with no file named: at 810 files the one command line passed Windows' 32 KB
  limit. Fixed 00578fc0 (chunks of 200). Every lane adding files hits this; DECISION in docs/decisions.md.
- FRICTION `--telemetry` crashed on a station-less hook (ArenaStage.telemetry_dict): applied n5-look's
  10bb8eea hunk byte-for-byte (fe23db22).
- FRICTION headless `--quit-after N` runs only ~0.4 N sim ticks (real-time paced); film windowed with
  `--fixed-fps 60` for full beats and exact ticks.
- FINDING the arena has no robot fighters (robots exist only in dev/enemy_ai); the brief's "a robot" victim
  is missing from every ghost clip until a robot lands in CombatArena. Robot damage is in the numbers only.
- MILESTONE 848b521c the slam reads on the rigs path: CastView's HaulerMarks only draw on the sprite path, so
  the arena showed no telegraph or crack. TonnageHook (station hauler_pad `script`) + TonnageView: a die-plate
  footprint (1.8 m) with a teal edge inks in over the wind-up and an inner square drops in; then HaulerMarks'
  ring + D5 crack.
- MILESTONE (reel) `--bot=ghosts` (dev/ghost-powers/ghost_reel.gd, a sim-side hook like ReelDirector):
  3 cops + a riot cop + a cruiser, a far pair, then wave 2 behind with a sedan. Windowed 32 px/m 960 ticks:
  10/10 down, 2 slams, 2 cars crushed, crush 5 / blowback 4, 1 activation, 0 SCRIPT ERROR
  (`evidence/ghosts-tonnage-32.json`).
- Evidence (masters n6/ghost-powers): `tonnage-arena-32ppm.mp4` (16 s), `tonnage-slam-64ppm-halfspeed.mp4`,
  `frames/tonnage-slam-vs-target-64ppm.png` (target | telegraph | landing), `frames/tonnage-slam-keyframes-64ppm.png`,
  `frames/tonnage-beat-32ppm.png`. Judged: telegraph, crack and wrecked car read at both zooms; the flattened
  body reads at 64 but at 32 px/m it is close to the standard pile; the tank body is still base Rivet (forms lane).
- No before pair yet: the old Hauler never ran in the arena on rigs (eve clips are quest 1 captures,
  `masters/eve/ghost-powers/clips/quest-hauler-ram2/`). Before = eve still in a later composite.
- 00:20 scenarios 46 ran / 0 failed on the Tonnage head (`evidence/scenarios-it1.log`).

### Dent (item 2)
- MILESTONE 5406276a DentStage on StagePilot (G / RB, a no-op off an arena stage; StagePilot `_ghosts()`
  helper keeps drive() under 40 lines): seize = the car nearest the aim LINE (pick_on_line, gearbox lock
  radius 3 m, range 22 m), soul_hijack (the teal plate), GearboxLink.step drives it where Rivet aims (aim
  point 14 m: at 9 m the turn-limited car circled the point, turn radius ~5.7 m at 14 m/s), each fighter it
  touches is struck once (2 dmg, thrown 2.5 m along the nose; row dent_car_hit = blowback), heat over 4 s,
  armed at 0.3, blows on impact / melee / full heat: 4.5 m, 6 dmg (row dent_blast_gib = rocket's gib), car
  wrecked. DentView: teal tether from Rivet's hands sagging and trembling, amber -> white heat halo (pulse
  quickens when armed), ink blast ring with a hot core (none under reduced motion).
- DECISION Dent's heat is amber-to-white, not vermilion or teal: teal stays on the tether (the soul's link),
  vermilion is reserved for danger/objectives and the owner wants coloured effects without blood red.
- MILESTONE scenario_ghost_attacks (1 ran, 0 failed, `evidence/ghost-attacks.json`): Tonnage 10/10, 5 crush,
  2 cars; Dent seize 1, strikes 5, blast 1, 5/5; replay identical; same seed same state; planted crush_m 0
  (crush 5 -> 0) and blast_damage 0 (dead 5 -> 4) caught.
- Clip `dent-arena-32ppm.mp4` (7 s, --bot=ghosts --ghost=dent). Judged: the tether and heat halo read at
  32 px/m, A and B are thrown off the bonnet; BUT the car drove through the south wall (position set
  directly) and B died to car hits before it armed, so the blast came late at full heat on the riot cop.
  Fix in progress: walls push the car out and an armed car blows on a wall; arm_k 0.3.
- FINDING one SoulPowers per ghost stage (Hauler and Dent each own one): both powers can run at once. The
  forms lane's switch should own "one form at a time"; until then the pilot does not block it.
- 00:29 MILESTONE f3362eaa Dent's car stops on the arena walls (it drove through: DentStage sets the pose
  directly) and an armed car blows on a wall; arm_k 0.3. Re-filmed: the car strikes A, turns onto B, stops
  on the wall line and blows inside B: 5/5 (blowback 4, gib 1), 0 SCRIPT ERROR. scenario_ghost_attacks
  re-run on these values: 1 ran, 0 failed (`evidence/scenario-ghost-attacks.log`).
- COMBAT CHECK director reel headless `--quit-after 7200` on 5406276a: 7 chapters ran (headless pacing), all
  down (claw_combo 2/2, pistol 2/2, machine_pistol 4/4, rocket 1/1, flamethrower 1/1, electro 1/1, molotov
  1/1), 0 SCRIPT ERROR (`evidence/director-reel-it1.log`). The other 9 chapters NOT checked this session.
- Evidence: `dent-arena-32ppm.mp4`, `dent-64ppm-halfspeed.mp4`, `frames/dent-vs-target.png`,
  `frames/dent-beat-32ppm.png`; frames.json 9 entries. Judged: the tether + heat halo read; the blast is
  small and pale beside the target's fireball; at 64 px/m the camera stays on Rivet, so the strikes and the
  blast leave the frame.
- 00:30 MERGE n6-ghost-forms 513376e6 (38bcc40c): GhostForms, ghost_forms.json, GhostFormHud; only
  JOURNAL.md conflicted (kept ours); lint 13/13, import 0 script errors.

### REQUEST 2 -> n6-ghost-forms (inputs once GhostForms drives StagePilot)
I adopt your REPLY (ids `base/tonnage/dent/kerf/ohm`, anchors in ghost_forms.json, G = next ghost). Then:
1. Tonnage: HaulerStage keeps the attack logic; please gate it on `GhostForms.settled() and form_id() ==
   &"tonnage"` instead of its own `powers.try_activate(&"hauler")` (or hand me the GhostForms and I gate it).
   The slam centre moves to your `press_head` anchor + 0.4 m once the big rig is live (data: press_ahead_m).
2. Dent: today `power_gearbox` (G) seizes. Once G = next ghost, Dent's seize = the **fire** press while the
   Dent form is settled; the overload command stays the melee press. I will switch DentStage.drive's
   `power` argument to that as soon as your StagePilot hookup lands (one line in StagePilot._ghosts()).
3. Both stages keep a SoulPowers each until then; please let GhostForms own the one-power-at-a-time rule.

NEXT (iteration 2, ghost-powers):
1. Unit gate result on 38bcc40c (`evidence/unit-it1-merged.log`, started 00:31); if red, fix first.
2. Dent proof gaps: a camera that frames the seized car (the arena CameraRig: follow the midpoint of Rivet
   and the car while seized) for the 64 px/m close-up; a coloured blast (warm fireball core + debris, no red:
   reuse gunplay's rocket/barrel blast FX if it exists) so it reads beside ghost_dent_mechanic; Dent in the
   city block (`--arena=city`, a parked car or a traffic car via soul_hijack_traffic) and on a police car.
3. Kerf (brief item 3): ghost_attacks.json `kerf`: dash/blink, blink-behind-and-slice along a teal line
   (human one-shot = brutality split with a teal-white cauterised edge, robots heavy damage), a hanging cut
   line, chain of N blinks with a recharge; add to GhostReel (`--ghost=kerf`) and scenario_ghost_attacks.
4. Ohm (item 4): forked bolt from the electrode anchors, x machine multiplier, stun + burns on humans, the
   electro X-ray kill in teal; `mass` tier as a data hook only.
5. Tonnage polish: the flattened body at 32 px/m is close to the standard pile (a wider, flatter print or a
   die-plate imprint under it); armour sparks off the plates on a blocked round (ShieldSparks-like, white);
   gate the attacks on GhostForms once REQUEST 2 lands; city block clip.
6. The full director reel (16 chapters) windowed or `--chapter=` batches, and the full scenario suite on the
   final head. Delete masters scratch AVIs (`n6/ghost-powers/scratch/`) once the clips are final.
- 00:34 MILESTONE (DentView) the car bomb's blast was a pale disc beside the target's fireball: now a jagged
  ink-rimmed amber burst (#E9A23B, 9 points) with a cream core, swelling and burning down over 0.45 s (none
  under reduced motion; the ink ring stays). First try parse-failed (`append()` return discarded, warnings are
  errors) and drew nothing: caught by the 3 SCRIPT ERRORs in the run log and the empty after-row, fixed.
  Before|after `M/frames/dent-blast-ab-32ppm.png` (same ticks 133/137/142, 32 px/m), clip re-cut, 0 SCRIPT
  ERROR. frames.json 10.
- 00:38 GATES on ffffc6d7 (final code head): scenarios 47 ran / 0 failed (incl. scenario_ghost_attacks;
  `evidence/scenarios-it1-final.log`), unit 954/0 on 38bcc40c (DentView change after it is render-only),
  lint 13/13 on every commit. Masters scratch AVIs deleted; frames.json 10 entries, every file present.
Session state 00:39: head = this commit, tree clean, image.lock never taken, bench never run, no Godot
process of mine running. NEXT (iteration 2) is the 00:31 list above (item 1 done: unit 954/0; the Dent blast
colour from item 2 done at 00:34).

## Iteration 2 (00:39 - 01:39)
- 00:40 read JOURNAL, git log, the forms lane's JOURNAL (no new REQUEST to ghost-powers; their NEXT wires
  GhostForms into StagePilot), n5-cast tip. MERGE n6-ghost-forms 833babb8 (054fd5c0: morph v2, their merge of
  n5-cast) and n5-cast b38ab980 (db4043c8: plan-view peds, look goldens re-blessed by n5-cast); only JOURNAL.md /
  REPORT.md conflicted (kept ours); lint 13/13 on both.
- Rules applied (registry `motion-quality-gating`, `shader-budget-authoring` from iteration 1): judge in motion
  at 32 px/m with a 64 px/m slow close-up, every effect drawn on the actor layer with canvas draw calls only (no
  new shader, no per-frame allocation beyond the draw lists), reduced motion = no flicker / afterimages.

### Kerf (item 3)
- MILESTONE 56705eec KerfStage (features/souls): Q takes the soul when `StagePilot.kerf` is set (the reel
  sets it for `--ghost=kerf`; Tonnage keeps Q otherwise), walk x1.5, melee = blink: target = live hostile
  nearest the aim inside 35 deg / 9 m with no arena wall between, Rivet lands 0.9 m (+ radius) past it,
  weapon kerf_slice (99 human, 4 robot); no target = 4 m dash; 3 charges, 0.3 s apart, one back per 1 s.
  Kill row kerf_split (the plasma sword's split, slower halves) + new optional row field `edge: soul`
  (brutality's SignatureKill/KillSplitFx/KillCutEdge: the cauterised band white with a teal bloom).
  KerfView: teal path + 3 afterimage rings, the hanging white cut line in a teal glow (0.6 s), the charge pips.
- FRICTION the first film booted the city: the arena is `res://dev/arena/arena.tscn -- ...`, not `--arena`
  (the gunplay REPORT said so). Telemetry needs `--shot-tick` (written on that quit) and an absolute path.
- First run 4/5: recharge 1.5 s left the robot with one cut when the 6 s ran out -> 1.0 s: 5/5 (4 split,
  robot in 2 cuts), 8 blinks, first kill 0.5 s after Q (`evidence/ghosts-kerf-32.json`).
- Judged (frames looked at): the path, afterimages, cut line and the teal-edged halves read at 32 and 64 px/m;
  the rig draws Rivet one frame behind the overlay on the blink tick (feed order; next frame he is past the
  target): left as is. Clips `kerf-arena-32ppm.mp4` (8 s), `kerf-64ppm-halfspeed.mp4`; `frames/kerf-vs-target.png`,
  `frames/kerf-beat-32ppm.png`.
- scenario_ghost_attacks + Kerf: replay identical, same seed same state, planted human_damage 0 (dead 5 -> 1)
  caught. Unit test_kerf_attacks 3/3.

### Ohm (item 4)
- MILESTONE ef3a186a OhmStage: Q (with `StagePilot.ohm`), melee = forked bolt every 0.5 s from the fingertips
  (0.45 m ahead): 30 deg / 11 m, forks 2 within 3 m (MeleeShock.chain_path reused), PlayerShock.stun_on 1.2 s,
  0.5 to humans (electro X-ray kill: `ohm_bolt` added to electro_shock's also_weapons), 2 x machine_k 3 to robots,
  no body in the cone = the car nearest the aim burns 20. Mass = upgrade_tier 1 (6 bodies within 8 m), data only.
  OhmView: jagged teal bolt, white core, ink rim, white flash at each body, fingertip sparks while on.
- FINDING the robot stand-in (quest boss brain, Kind.BOSS) is only exposed while its tazer is spent; Ohm's stun
  freezes the brain, so 0 kills on the first run. OhmBeat.hold() (sim-side, dev beat only) keeps it exposed;
  logged as a FINDING in decisions. It is drawn as a cop and dies with a red splat (no robot rig in the arena).
- Measured: 5/5, robot to the first bolt, cops in 2 bolts, riot in 5, cruiser wrecked in 5 more; Rivet 100 hp
  (stunned cops do not fire). Clips `ohm-arena-32ppm.mp4` (9 s), `ohm-64ppm-halfspeed.mp4`, `frames/ohm-vs-target.png`.
- scenario + Ohm: replay identical, same seed, planted machine_k 0 (dead 5 -> 0) caught; _judge became a NEEDS
  table (gdlint max-returns). Unit test_ohm_attacks 2/2. Unit gate 960/0 on ef3a186a (`evidence/unit-it2.log`).
- DECISIONs in docs/decisions.md (Kerf, Ohm, the robot FINDING); role/TTK table holds all four ghosts.

### REQUEST 3 -> n6-ghost-forms (Kerf and Ohm attach points, 01:12)
Kerf and Ohm attacks are live on StagePilot (`pilot.kerf: KerfStage`, `pilot.ohm: OhmStage`, both null by
default; when one is set it takes Q in place of the Hauler and owns melee while its soul is on). When your
GhostForms drives StagePilot:
1. Set `pilot.kerf` / `pilot.ohm` (or call their `drive(...)` yourself) from the selected form; each keeps its
   own SoulPowers row (`kerf`, `ohm`) until GhostForms owns the one-power rule, same as REQUEST 2.
2. Anchors: Ohm's bolt leaves `OhmStage.HANDS_M` 0.45 m ahead (please map to your `electrodes` anchor and I will
   read it from ghost_forms.json); Kerf's blink has no emitter (the path starts at Rivet's centre); the hanging
   cut line sits on the target.
3. Kerf moves Rivet by setting `rivet.pos` on the blink tick (move_by 0 that tick): the form rig should snap,
   not tween, so the blink reads.
- 01:12 COMBAT CHECK director reel headless (`--quit-after 24000`) on the Kerf/Ohm head (after the brutality
  split-edge change): 16 chapters started, 16 down (claw_combo 2/2 ... katana, chainsaw, plasma_sword_deflect,
  riot_cop, mini_nuke 4/4), 0 SCRIPT ERROR (`evidence/director-reel-it2.log`). Combat holds.
- 01:14 CITY BLOCK (`--arena=city --bot=ghosts`): Kerf 4/5 of the beat (the chain also cut the block's own
  cops, 6 slices; `E/ghosts-kerf-city-32.json`), Ohm 5/5 + 4 car bolts (`E/ghosts-ohm-city-32.json`), 0 SCRIPT
  ERROR each. Clips `kerf-city-32ppm.mp4`, `ohm-city-32ppm.mp4`, still `frames/kerf-ohm-city-32ppm.png`. Judged:
  both read on the asphalt; Ohm's bolt is thin at 32 px/m in the city -> heavier strokes (10/6/2.5 px, was
  7/4/1.5), A/B pending the suite.
- 01:15 REEL `ghost-attacks-reel-32ppm.mp4` (40 s: the four arena beats, labelled). frames.json 15 entries, all
  files present; scratch emptied.
- 01:17 GATES on the Kerf/Ohm head: scenarios 47 ran / 0 failed (`E/scenarios-it2.log`), unit 960/0, lint 13/13.
- 01:18 MILESTONE Ohm's bolt strokes 10/6/2.5 px (was 7/4/1.5): A/B `M/frames/ohm-bolt-ab-city-32ppm.png` (city,
  tick 173, 32 px/m): holds on the asphalt. frames.json: dent-beat-32ppm swapped out for it (15 cap).
- 01:20 REDUCED: `--gore=reduced --reduced-motion` must go AFTER `--` (ArenaArgs; the first try before `--`
  was silently full gore: split 4). After `--`: 0 signature kills, the four fall whole (standard death, red
  pool), no afterimages (`E/ghosts-kerf-reduced-32.json`). FINDING: a cauterising beam leaving a red pool under
  reduced gore is odd; the death pipeline is shared (not changed).

NEXT (iteration 3, ghost-powers):
1. Merge n6-ghost-forms and n5-cast tips if they moved (keep ours on JOURNAL/REPORT). When GhostForms drives
   StagePilot (REQUEST 2/3), switch the reel beats to select the form instead of setting pilot.kerf/ohm, re-run
   scenario_ghost_attacks and re-film each ghost on its real body (the clips today show base Rivet).
2. Tonnage and Dent in the city block (`--arena=city --bot=ghosts --ghost=tonnage|dent`), clips + still.
3. Kerf polish: the afterimages as a teal silhouette of the body, not rings (once the Kerf rig exists); the cut
   line along the blink (the target sheet's long horizontal beam) as an option; a 64 px/m keyframe strip.
4. Ohm polish: the electro kill's cream arcs in teal for ohm_bolt (brutality row field, like `edge`); Ohm's
   mass tier demo under `--tune` (upgrade_tier 1) in a short clip (data hook proven by unit only today).
5. Tonnage polish (iteration-1 list): the flattened body at 32 px/m vs the standard pile; armour sparks off the
   plates; Dent's car-follow camera for the 64 px/m close-up.
6. Call for the owner stills: Tonnage crush vs pile side-by-side.
Session state 01:22: head = this commit, tree clean, no Godot process of mine running, masters scratch empty,
image.lock never taken, bench never run.
- 01:25 CITY Tonnage (`--arena=city --bot=ghosts --ghost=tonnage`, 960 ticks): 10/10 down, 2 slams, crush 2 /
  blowback 5, Rivet 100 hp, 0 SCRIPT ERROR (`E/ghosts-tonnage-city-32.json`, clip `M/tonnage-city-32ppm.mp4`):
  telegraph, slam, crack and the flattened cops read on the asphalt. BUT 0 cars crushed: the beat's cruiser never
  appears in the city block. Dent in the city: 0 seizes (no car beside Rivet; `E/ghosts-dent-city-32.json`).
  Lead: `VehicleService.spawn_parked` always returns a car, so the city ArenaStage probably has `vehicles == null`
  and the beats skip the spawn. NEXT item 2 becomes: give the city stage's beats a car (the city's own parked or
  traffic car via soul_hijack_traffic for Dent), then re-film Dent and Tonnage there.
Session state 01:26: head = this commit, tree clean, no Godot process of mine running, masters scratch empty.
- 01:28 (CORRECTED 01:26 clock) the city lead is NOT confirmed: `ArenaSession.open` uses the same
  `ArenaStations.shipped()` on the city site and attaches ArenaCars after `_add_city()`, so `stage.vehicles`
  should exist there. Why the beats' cars neither show nor get seized in `--arena=city` is open. Iteration 3:
  log `stage.vehicles`, `cars().size()` and the car positions at the beat's first tick in the city run, check
  whether the city view draws ArenaCars' cars and whether `_add_city` swaps the stage's walls/cells so the car
  sits inside a solid; then fix and re-film Dent and Tonnage there (the arena path must not move).
- 01:28 PROBE (a temporary log line in GhostReel._begin, reverted): `--arena=city --bot=ghosts --ghost=dent`
  headless: "powers pad: 2 cars parked", "vehicles true, 2 cars" at the beat's first tick (+ the beat's cruiser).
  So the cars ARE in the city sim. Open for iteration 3: (a) the city view does not draw ArenaCars' cars
  (CityView draws the city sim's traffic only?), (b) why Dent's G seize finds none there (log pick_on_line's
  distances and `powers.try_activate` result in the city run), (c) Tonnage's car_crush likewise.
Session state 01:29: head = this commit, tree clean, no Godot process of mine running, masters scratch empty.

## Iteration 3 (01:28 - 02:28)
- 01:30 read JOURNAL, git log, the forms lane's JOURNAL (REPLY to REQUEST 2 done there: GhostPilot on
  StagePilot; their NEXT is Dent polish then the Kerf body; no new REQUEST to ghost-powers).
- MERGE n6-ghost-forms 3d0a8f4d (7b053cc7). StagePilot conflicted (their GhostPilot vs our kerf/ohm slots):
  resolved by wiring KerfStage + OhmStage INTO GhostPilot (their REPLY 3 invited it): `share(powers)` on both
  (no own activate/tick; Kerf leaves the walk to the form row's top_mps), attacks only while settled in their
  form, owns_melee covers them; StagePilot.kerf/ohm are aliases of ghosts.kerf/ohm for the views. Kerf/Ohm reel
  beats now select the form (G at 40, 42[, 44]; LOOK_TICKS 40 swallows earlier presses: the first try at 30/32
  never picked and Q took Tonnage) and Q, attacks after the settled form. Unit test_kerf 3/3, test_ohm 2/2,
  test_ghost* 15/15, test_tonnage 2/2, test_dent 3/3, test_hauler* 18/18; scenario_ghost_attacks 1/0
  (`evidence/scenario-ghost-it3.log`). MERGE n5-cast cc744d85 (5ee2cfe8). Lint 13/13 on both.
