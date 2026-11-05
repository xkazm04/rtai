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
- 01:42 CITY CAR ROOT CAUSE (the iteration-2 open item): on the city block the city's RivetBody holds Rivet
  (CollectCallStage.step sets `rivet.pos = follow.target` when the body is on), so GhostReel._begin's placement
  was undone on tick 1 and Rivet stood 34 m from the beat's cars (probe: rivet (524,524), cruiser (493,523.5)).
  FIX d88eac6c: _begin also sets `stage.follow.focus/target` (dev reel only; the arena has no follow). City:
  Dent 1 seize, Tonnage 10/10 + 2 cars crushed, Kerf 5/5 (was 4/5), Ohm 5/5.
- 01:47 Dent city film: the seized car drove onto the sidewalk and blew up past B, off-screen, on the overload
  timer. 87678661: DentStage._wall also pushes the car out of the city's cells (buildings, props, parked cars =
  an impact), and the beat presses melee (blow on command) once the car is within 1.6 m of B's centre. City 5/5
  (`E/ghosts-dent-city-32.json`), scenario_ghost_attacks 1/0 (arena beat unchanged in outcome). Judged at 32
  px/m: the teal tether, the hijack plate, the strike through A and the amber blast in B all read on the
  asphalt. M: `dent-city-32ppm.mp4` (10 s), `frames/dent-city-keys-32ppm.png`.
- 01:52 Tonnage city re-filmed (47148cc3): 10/10, 2 slams, 2 cars crushed, Rivet 100 hp, 0 SCRIPT ERROR; the
  forms lane's TonnageRig stands in. M: `tonnage-city-32ppm.mp4` (15 s), `frames/tonnage-city-crush-keys-32ppm.png`.
  frames.json 15 (dropped tonnage-beat / kerf-beat stills for the two city strips).
- Rules applied this session (registry `motion-quality-gating`: judge in motion at 32 px/m, 64 px/m close-ups,
  a before/after at the same tick and zoom for every change; `shader-budget-authoring`: canvas draw calls on the
  existing actor/kill layers, no new shader).
- 01:56 MILESTONE 0e794d2c Ohm's human kill = row `ohm_shock` (the electro X-ray shock + `edge: soul`):
  KillShockFx draws the arcs teal and the zap star teal-white (the cream bones still pop); the electro gun keeps
  cream (`ohm_bolt` left electro_shock's also_weapons). A/B `M/frames/ohm-kill-teal-ab-64ppm.png` (64 px/m, ticks
  152/156/168; before = the two files checked out from HEAD~1 for one run, restored after). Unit test_ohm 3/3.
- 01:59 MILESTONE 7fd55cb6 `--tier=1` on the Ohm beat: the mass arc in game, 5/5, the knot down at tick 119 vs
  149 (`E/ghosts-ohm-mass-32.json`, `M/frames/ohm-mass-tier1-32ppm.png`, `M/ohm-mass-tier1-32ppm.mp4`). Judged:
  one bolt walking the whole group reads as "many at once" at 32 px/m; a radial fan from the first body would
  read more like a mass spell (polish).
- 02:01 decisions.md: Kerf/Ohm inside GhostPilot, ohm_shock, the city placement FIX; ghost_attacks.json docs
  follow GhostPilot; role table iteration-3 lines (docs/ghosts/ghost-attacks.md).
- 02:03 COMBAT CHECK director reel headless (`--quit-after 24000`) on the iteration-3 head: 16/16 chapters down
  (claw_combo 2/2 .. electro_gun 1/1 .. mini_nuke 4/4), 0 SCRIPT ERROR (`E/director-reel-it3.log`).
- 02:05 TRIED + REVERTED Kerf afterimages as a top-down body (teal shoulder oval + head) in place of the rings:
  filmed at 64 px/m twice (faint, then bolder); both read as small teal "eyes" on the path, weaker than the
  rings. Not committed. The real fix is a ghost copy of the Kerf form rig once ghost-forms builds it.
- 02:08 GATES on the iteration-3 head (4db4eed5 code = 7fd55cb6): unit 968/0 (`E/unit-it3.log`), scenarios 47 ran
  / 0 failed, 0 SCRIPT ERROR (`E/scenarios-it3.log`), lint 13/13 every commit.
- 02:10 MILESTONE 9b0ad775 Ohm's mass arc fans out from the first body (OhmStage.bolt_from: each path point's
  source; the base bolt still chains, so tier 0 is unchanged): before|after `M/frames/ohm-mass-chain-vs-fan-32ppm.png`
  (ticks 91/93). Judged at 32 px/m: the burst from the robot to each cop reads as a mass spell, the chain read as
  one long bolt. Unit test_ohm 4/4 (new: the fan reaches bodies past the fork radius); scenario_ghost_attacks 1/0
  on this head (`E/scenario-ghost-it3-final.log`).

NEXT (iteration 4, ghost-powers):
1. Merge n6-ghost-forms and n5-cast tips if they moved (keep ours on JOURNAL/REPORT/evidence name clashes). NOTE
   for ghost-forms (in REQUEST form below): GhostPilot now carries kerf/ohm (7b053cc7); their edits to
   ghost_pilot.gd will conflict lightly.
2. When the Kerf and Ohm rigs land (forms lane): re-film both on their bodies (arena 32, city 32, 64 slow), map
   OhmStage.HANDS_M to the `electrodes` anchor from ghost_forms.json, and replace Kerf's afterimage rings with a
   faded copy of the Kerf rig (the shape try at 02:05 failed).
3. Re-cut the four-ghost reel (`M/ghost-attacks-reel-32ppm.mp4`) from the iteration-3 clips (Tonnage/Dent on
   their bodies, Dent and Tonnage city beats, Ohm's teal kill, the mass fan).
4. Call for the owner still: Tonnage crush vs the standard pile (`--gore=reduced` at the same tick) side by side.
5. Dent: a car-follow camera for the 64 px/m close-up (the strikes leave the frame); Dent riding the car (optional).
6. The evidence runner (`node tools/evidence/run.mjs`) has not been run by this lane tonight.
Session state 02:13: head = this commit, tree clean, no Godot process of mine running, masters scratch empty,
image.lock never taken, bench never run.

### REQUEST 4 -> n6-ghost-forms (02:13)
GhostPilot (your file) now holds `kerf: KerfStage` and `ohm: OhmStage` (merge 7b053cc7 on n6-ghost-powers): both
`share(powers)`, driven only while `settled_in(&"kerf"|&"ohm")`, owns_melee covers them, write_state appends theirs.
Please merge n6-ghost-powers before editing ghost_pilot.gd again. Kerf moves Rivet by `rivet.pos` on the blink tick
(snap the rig); Ohm's bolt leaves 0.45 m ahead (`OhmStage.HANDS_M`) until I read your `electrodes` anchor.
- 02:17 CALL still `M/frames/call-tonnage-crush-vs-pile-32ppm.png`: the Tonnage beat shot at tick 200, full gore
  (the crush: flattened ink discs) | `--gore=reduced` (the standard pile with its red pool), 32 px/m, 0 SCRIPT ERROR
  both; REPORT Calls updated (NEXT item 4 done). frames.json 15 (kerf-ohm-city still out; the city clips stay).
Session state 02:18: head = this commit, tree clean, no Godot process of mine running, masters scratch empty.
- 02:21 REEL re-cut (NEXT 3, partly): `M/ghost-attacks-reel-it3-32ppm.mp4` (37 s, labelled): Tonnage + Dent city
  (iteration 3, their bodies), Kerf + Ohm arena (iteration 2 clips: base Rivet, Ohm's kill still cream there),
  Ohm's mass fan. frames.json points at it. Still to do: re-film Kerf/Ohm arena on the iteration-3 head.
Session state 02:22: head = this commit, tree clean, no Godot process of mine running, masters scratch empty.

## Iteration 4 (02:15 - 03:15)
- 02:16 read JOURNAL, git log, the forms lane's JOURNAL (KerfRig landed d3aaa8a2, limbs 0.22 m 9f69e87c; their NEXT:
  Kerf to done then Ohm; no new REQUEST to ghost-powers). MERGE n6-ghost-forms 6ef0bc5d (db6685cf; JOURNAL, REPORT
  and our `evidence/ghosts-tonnage-city-32.json` keep ours) and n5-cast 093f4b73 (b06f0cad). Lint 13/13 both.
- FRICTION the first film after the merge: 609-style parse errors (KerfRig/FormsTourBot unknown): the class cache
  needs one `--import` after a merge that adds class_names. Killed my two stuck runs by PID.
- 02:30 MILESTONE f566e06e Kerf's afterimages are faded copies of the Kerf body (KerfView pools 9 KerfRigs, limbs
  swept, modulate (0.55, 1.75, 1.6) lifts the dark steel to teal, alpha 0.2..0.6 older->newer x the path fade,
  show_behind_parent so the path and the cut sit on top). A/B `M/frames/kerf-echo-rings-vs-rig-64ppm.png` (ticks
  80/100, 64 px/m; before = HEAD's kerf_view.gd checked out for one run, restored). Judged: the rings read as
  "targets" on the path; the body copies read as Kerf itself smeared along the blink, at 64 and at 32 px/m
  (`M/frames/kerf-echo-keys-32ppm.png`). Arena beat on the Kerf body: 4 splits (`E/ghosts-kerf-it4-32.json`),
  0 SCRIPT ERROR; `M/kerf-arena-32ppm.mp4` re-filmed (11 s).
- 02:24 Kerf re-filmed on the body: `M/kerf-64ppm-halfspeed.mp4` (64 px/m, half speed), `M/kerf-city-32ppm.mp4`
  (city block, 4 splits, `E/ghosts-kerf-city-it4-32.json`), stills `M/frames/kerf-body-keys-64ppm-city-32ppm.png`
  and `M/frames/kerf-vs-target.png` (target | two 64 px/m frames): the target's vignette (teal ghost copies along a
  line behind the soldier) is now what the game draws.
- 02:27 MILESTONE 3d369dcf Ohm's bolt leaves from the forms lane's `electrode_l/electrode_r` anchors (GhostPilot reads
  ghost_forms.json into OhmStage.set_electrodes; OhmStage.tips): two jagged prongs, one per fingertip, meet in the
  first body; the fingertip sparks sit on the anchors. A/B `M/frames/ohm-electrode-prongs-ab-64ppm.png` (ticks
  92/122). Judged: the twin strands braid into the first body and read as an electrode discharge rather than a
  ray gun line; at 32 px/m they merge into one heavier bolt (fine). Still base Rivet's body (no Ohm rig yet).
  Unit test_ohm 5/5 (new: anchors from the row, the bolt starts between them), scenario_ghost_attacks 1/0
  (`E/scenario-ghost-it4.log`). FRICTION gdformat broke the first commit (a long line): the hook caught it.
- FRICTION a stuck Godot from my first (pre-import) shot loop kept running (the loop moved on to tick 100 after I
  killed the tick-80 pair): two of my Godot processes overlapped from 02:21 to ~02:35. Found by command line and
  killed by PID 64008. Lesson: wrap every shot in `timeout 60`, and list my processes after any kill.
- 02:34 GATES evidence runner (`node tools/evidence/run.mjs --no-bench`, first run by this lane tonight) on 3d369dcf:
  PASS lint 13/13, unit 973/0, scenarios 47, parity (1200 steps bit-exact, mutation caught at 629), selftest
  (look goldens 11/11 within mean 4, worst 1.20; block 5/5) -> `E/evidence-run-it4.log`. Bench skipped (contended
  machine; not taken). FRICTION its first try exited 2: my log file inside the tree made it dirty; logs go to
  masters scratch while it runs.
- 02:37 Ohm arena re-filmed on the iteration-4 head: 4 shock kills (teal X-ray), the cruiser wrecked, Rivet took 6
  (`E/ghosts-ohm-it4-32.json`, `M/ohm-arena-32ppm.mp4`). REEL `M/ghost-attacks-reel-it4-32ppm.mp4` (31 s, labelled,
  32 px/m: Tonnage + Dent city, Kerf arena + city on the body, Ohm arena, Ohm mass) replaces the it3 reel; judged
  frame by frame (6 stills): each ghost readable with the sound off. frames.json 15.
- 02:39 COMBAT CHECK director reel headless (`--quit-after 24000`) on a9c9d36f: 16/16 chapters down (claw_combo 2/2 ..
  plasma_sword_deflect 1/1 .. mini_nuke 4/4), 0 SCRIPT ERROR (`E/director-reel-it4.log`).
- 02:40 MILESTONE b575c591 dev `--cam=car` (NEXT 5 of iteration 3): DentView.follow_cam (set by TonnageHook when the
  flag is on) eases the view's camera to the midpoint of Rivet and the seized car and holds on the blast for 1 s;
  view only (arena: CollectCallView.focus; city: city_lean_m). A/B `M/frames/dent-cam-car-ab-64ppm.png` (ticks
  132/168/204/252): before, the car and the blast leave the frame; after, the strike into the cops, the amber
  blast and the wreck sit in frame. `M/dent-64ppm-halfspeed.mp4` re-cut from the car-camera run.
- 02:42 Ohm re-filmed on the head: city block 4 shock kills + the cruiser wrecked (`E/ghosts-ohm-city-it4-32.json`,
  `M/ohm-city-32ppm.mp4`), 64 px/m half speed (`M/ohm-64ppm-halfspeed.mp4`), target composite
  `M/frames/ohm-vs-target.png` (target | 64 arena | 32 city). Judged: the twin prongs follow the target's two copper
  fingers; the body is still base Rivet. frames.json 15.
- Rules applied this session: `motion-quality-gating` (every change judged in motion at 32 px/m with 64 px/m
  close-ups, a before/after at the same tick and zoom: Kerf echoes, Ohm prongs, Dent camera);
  `depth-ordered-layered-art` (the afterimages draw behind the path and cut line via show_behind_parent, on the
  actor layer above the floor); `shader-budget-authoring` (no new shader: modulate on pooled sprites, canvas draws).
- Not done this session: the robot victim (no robot body exists: `enemy_rig_feed.gd` draws robots on the cop rig
  until a robot body kind lands), Kerf's reduced-gore red pool, the bench (contended machine).

### REQUEST 5 -> n6-ghost-forms (02:45)
1. KerfView (ghost-powers) now instances your KerfRig as the blink afterimages (`KerfRig.new()`, add_child, then
   `speed_mps = KerfRig.FAST_MPS; advance(1.0)`; position/rotation/scale/modulate set per frame). Please keep
   `FAST_MPS`, `PX_PER_M`, `speed_mps` and `advance(dt)` (or tell me in a REPLY when they change).
2. Ohm: OhmStage reads `electrode_l/electrode_r` from your ghost_forms.json row (GhostPilot._init) and the bolt's two
   prongs leave from exactly those points. When you draw the Ohm rig, put the copper fingertips on those anchors
   (or move the anchors to the drawn tips: the bolt follows the data).

NEXT (iteration 5, ghost-powers):
1. Merge n6-ghost-forms / n5-cast if they moved (one `--import` after the merge before filming).
2. Ohm on its body is filmed everywhere (arena, city, 64 slow, mass; 02:50-02:55). Next on Ohm: a cane-step recoil
   or arm kick on each bolt (needs a hook in the forms lane's OhmRig: REQUEST it), and Ohm's machine multiplier on
   a real robot (item 4).
3. Dent riding the car (the optional bucking-bull vignette) now that the car camera keeps it in frame.
4. Weakest left: the robot victim (no robot fighter in the arena; the brain stands in drawn as a cop). Look for a
   robot body on main/day branches; otherwise a ghost-powers dev robot (sim stand-in with a distinct look) so the
   machine multipliers (Ohm machine_k, Kerf robot_damage) read on screen.
5. Kerf under `--gore=reduced`: the red pool under a cauterised cut (a reduced-gore Kerf death without blood).
- 02:44 MERGE n6-ghost-forms 19ae646c (31c06cc9: the Ohm body OhmRig, GhostRim cream rims on Kerf/Ohm; JOURNAL/REPORT
  keep ours) + one `--import`. Kerf's echoes inherit the rim: a pale mint outline under the teal wash (judged at 64:
  reads as the target's ghost outline; kept).
- 02:46 MILESTONE 898bbf1a Ohm on its body: the full-weight prongs from (0.38, -+0.1) buried the guard arm (and the
  right anchor sat on the cane side). Moved `electrode_l/r` in ghost_forms.json to the drawn copper fingers (0.52,
  -0.17 / -0.07; OhmRig.GUARD_HAND is (0.5, -0.12)), prongs thin (x0.5) for 0.9 m then one full bolt. A/B
  `M/frames/ohm-prongs-on-body-ab-64ppm.png`. DECISION in decisions.md (the forms lane's file: data only; REQUEST 6).
  Unit test_ohm* 8/8, test_ghost* 15/15, scenario_ghost_attacks 1/0 (`E/scenario-ghost-it4b.log`).
- 02:50 Ohm re-filmed on the body: arena 4 kills + cruiser (`E/ghosts-ohm-body-32.json`), 64 px/m half speed, the
  mass arc tier 1 (knot down at tick 119, `E/ghosts-ohm-mass-body-32.json`), target composite
  `M/frames/ohm-vs-target.png`. Reel `M/ghost-attacks-reel-it4-32ppm.mp4` re-cut: all four ghosts on their bodies.

### REQUEST 6 -> n6-ghost-forms (02:52)
I moved Ohm's `electrode_l/electrode_r` in your `ghost_forms.json` to the copper fingers your OhmRig draws on the
guard hand: (0.52, -0.17) and (0.52, -0.07) (898bbf1a; data only, nothing else in the file). If you move
OhmRig.GUARD_HAND, move the anchors with it (or tell me in a REPLY); the bolt follows the data.
- 02:55 Ohm city on the body (4 kills + cruiser, `E/ghosts-ohm-city-body-32.json`, `M/ohm-city-32ppm.mp4`) and Dent in
  the city block at 64 px/m with `--cam=car` (5 down: 4 blowback + 1 gib, 1 seize, 1 wreck,
  `E/ghosts-dent-city-cam-64.json`, `M/dent-city-64ppm-cam-halfspeed.mp4`): the city lean keeps the car, the strike
  and the wreck in frame. Both 0 SCRIPT ERROR.
Session state 02:56: head = this commit, tree clean, no Godot process of mine running, masters scratch holds only
film.sh and reel.sh, image.lock never taken, bench never run (contended machine).
