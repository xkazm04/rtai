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
- 02:50 Ohm city on the body (4 kills + cruiser, `E/ghosts-ohm-city-body-32.json`, `M/ohm-city-32ppm.mp4`) and Dent in
  the city block at 64 px/m with `--cam=car` (5 down: 4 blowback + 1 gib, 1 seize, 1 wreck,
  `E/ghosts-dent-city-cam-64.json`, `M/dent-city-64ppm-cam-halfspeed.mp4`): the city lean keeps the car, the strike
  and the wreck in frame. Both 0 SCRIPT ERROR.
Session state 02:51: head = this commit, tree clean, no Godot process of mine running, masters scratch holds only
film.sh and reel.sh, image.lock never taken, bench never run (contended machine).
- 02:57 FINAL GATE evidence runner `--no-bench` on d7eb3843 (all four on their bodies): PASS lint 13/13, unit 976/0,
  scenarios 47, parity bit-exact (mutation caught at 629), selftest look goldens in tolerance (no re-bless)
  (`E/evidence-run-it4-final.log`). Director reel last run on a9c9d36f (16/16); since then only ghost views, the
  Ohm anchors and the merge of the forms lane (whose own director reel on 70a6297a was 16/16).
Session state 02:58: head = this commit, tree clean, no Godot process of mine running, masters scratch holds only
film.sh and reel.sh, frames.json 15 (all files present), image.lock never taken, bench never run.
- 02:59 Kerf arena + city re-filmed with the GhostRim (city 4 splits, `E/ghosts-kerf-city-rim-32.json`): the rimmed body
  and the mint-edged afterimages hold on the asphalt at 32 px/m. Reel re-cut: every segment from tonight's heads.
- 03:02 COMBAT CHECK director reel on 7ec45ab0 (the final head, Ohm body merged): 16/16 chapters down, 0 SCRIPT ERROR
  (`E/director-reel-it4-final.log`).
Session state 03:03: head = this commit, tree clean, no Godot process of mine running, masters scratch holds only
film.sh and reel.sh, frames.json 15 (all present).

## Iteration 5 (03:04-04:04, BUILD)
- 03:04 read JOURNAL, git log, the forms/cast JOURNALs: no new REQUEST to ghost-powers (forms lane merged ours at
  d3ca8581). MERGE n6-ghost-forms b2ea5f1f (394c58a4: n5-cast b16becfb D5 ped heads/bald head/cap size, the ghost
  body's Z_OVER_RIGS +60; JOURNAL/REPORT keep ours) + one `--import`.
- 03:09 MILESTONE 51ae297c the robot victim (NEXT 4, weakest item): ArenaRobotRigs puts the arena's BOSS brain on the
  robot thug's rig (ThugPlan: gunmetal frame, claws, one optic), poses it on CharacterRigs' tick count, shoves it on
  hits, plays DeathPipe.kill_robot on death; CombatBlood.robot_ids makes its death leak oil, not red. A/B
  `M/frames/ohm-robot-rig-ab-32ppm.png` (same seed, ~1/2/3 s): before a blue cop dying to Ohm's machine_k bolt in a red
  splat, after a gunmetal robot powering down in black oil. Kerf's robot kill re-filmed on the rig
  (`M/kerf-arena-32ppm.mp4`), Ohm's arena clip replaced (`M/ohm-arena-32ppm.mp4`). 0 SCRIPT ERROR. Unit 976/0
  (`scratch/unit-it5.log`). FRICTION combat_blood.gd is now 299 lines (hard stop 300): the next change there must
  split it first.
- 03:16 MILESTONE c30d488f Kerf under `--gore=reduced` (NEXT 5): the slice's kill kind is `cauterised` (a DRY_KILLS
  entry, robot ids excepted): no red pool when the signature split is off. A/B
  `M/frames/kerf-reduced-gore-ab-32ppm.png` (3/5/7/9 s): before red pools and stains, after the cops drop whole, the
  cut line hangs. scenario --filter=ghost 1/0 (`evidence/scenario-ghost-it5.log`). DECISIONs in decisions.md.
- Rules applied: `motion-quality-gating` (A/B pairs at the same tick and zoom from deterministic runs, judged in
  motion at 32 px/m); `depth-ordered-layered-art` (the robot rig on the rigs' own z, under the ghost body's +60).
- 03:20 COMBAT CHECK director reel on 5dde79e8 (robot rig + dry Kerf kill): 16/16 chapters down, 0 SCRIPT ERROR
  (`E/director-reel-it5.log`).
- 03:25 MILESTONE 06908631 Dent rides the seized car (NEXT 3, the optional bucking-bull vignette): sim side,
  `ghost_attacks.json dent.ride` 1 puts Rivet on the car's roof each tick it is seized (GhostPilot zeroes his walk;
  the car still steers by his facing) and hops him `ride_hop_m` 4 behind it at the blast (the blast hits hostiles
  only). DECISION: ride on by default (the concept vignette; the car stays in his frame); `ride 0` is the old
  stand-off seize; Call for the owner with `M/frames/dent-ride-ab-32ppm.png`. scenario_ghost_attacks needs
  `rides >= 30`; planted ride 0 caught (`E/scenario-ghost-it5-planted-ride0.log`).
- 03:29 FIX 89eda6e5 in the city block the hop stood Dent on a parked ambulance's hood: the hop now tries behind, left,
  right for a spot with no live car within 2.6 m. Re-filmed: he lands on the street beside it.
- 03:31 Clips: `M/dent-arena-32ppm.mp4`, `M/dent-city-32ppm.mp4`, `M/dent-64ppm-halfspeed.mp4` (64 px/m ride + hop,
  half speed). REEL `M/ghost-attacks-reel-it5-32ppm.mp4` (33 s; Dent's segment re-timed onto the ride, Ohm's onto the
  robot falling) replaces it4. Judged 6 stills. frames.json 15, all present.

### REQUEST 7 -> n6-ghost-forms (03:32)
Dent now rides the seized car (06908631; `DentStage.riding()` true while on the roof, Rivet's position = the car's).
DentBody feeds the car's speed as Rivet's velocity, so on the roof Dent runs his walk cycle at ~8 m/s with the full
lurch. Please, in DentBody (yours): while `pilot.dent.riding()` feed `vel_in` zero (or a crouch), and add a buck (a
short yaw/roll kick or a scale pop) on each car strike (`pilot.dent.strikes` rising) and a jump on the hop
(`blasts` rising). I will not edit DentBody.
- 03:38 GATES evidence runner `--no-bench` on db0b4541 (robot rig, dry Kerf kill, Dent ride + hop fix): PASS lint 13/13,
  unit 976/0, scenarios 47, parity bit-exact (mutation caught at 629), selftest look goldens 11/11 (worst 1.21) and
  block 5/5 in tolerance, no re-bless (`E/evidence-run-it5.log`). Bench not run (contended machine).
  TTK doc: Dent's ride and the robot victim lines.
- 03:40 MERGE n6-ghost-forms 4eb92883 (1469cabd: voice apparitions, `--teal-forms`, n5-cast r_forearm, and DentBody's
  answer to REQUEST 7: braced on the roof, buck per strike, jump on the hop; JOURNAL/REPORT keep ours) + `--import`.
  scenario --filter=ghost 1/0.
- 03:43 COMBAT CHECK director reel on the merged head 1469cabd: 16/16 chapters down, 0 SCRIPT ERROR
  (`E/director-reel-it5-merged.log`).
- 03:44 Dent's ride re-filmed at 64 px/m on the merged head: braced on the roof, the buck into the strike, the jump
  clear of the blast (`M/frames/dent-ride-buck-keys-64ppm.png`, `M/dent-64ppm-halfspeed.mp4`). Judged: reads as the
  concept's ride. frames.json 15, all present. REQUEST 7 closed.

NEXT (iteration 6, ghost-powers):
1. Merge n6-ghost-forms / n5-cast if they moved (one `--import` before filming).
2. (done 03:45) the reel's Dent segment re-cut from the city clip on the merged head.
3. Ohm: a cane-step recoil or arm kick per bolt (REQUEST to ghost-forms for an OhmRig hook: `bolts` rising, like
   Dent's strikes), then re-film Ohm at 64.
4. combat_blood.gd is at 299 lines: any further change there splits it first (e.g. the robot/dry-kill routing into
   a small helper).
5. Weakest left after this session: Kerf at 64 px/m on the merged head (last filmed in iteration 4), then the
   quality pass on whichever ghost reads weakest in the 33 s reel at 32 px/m (watch it first). (Tonnage 64 and the
   city robot are done, below.)
Session state 03:44: head = 94c9f8d8, no Godot process of mine running, no lock held,
masters scratch holds only film.sh and reel.sh.
- 03:45 NEXT 2 done: Dent in the city block re-filmed on the merged head 1469cabd (`M/dent-city-32ppm.mp4`, ride with
  the brace, hop clear of the ambulance, 0 SCRIPT ERROR); reel `M/ghost-attacks-reel-it5-32ppm.mp4` re-cut (33 s),
  Dent segment judged on 4 stills.
Session state 03:46: head = this commit, tree clean, no Godot process of mine running, no lock held (image.lock and
bench.lock never taken), masters scratch holds only film.sh and reel.sh, frames.json 15 (all present).

### REQUEST 8 -> n6-ghost-forms (03:47)
Thanks for REQUEST 7 (cf9faa0c, merged and filmed: `M/frames/dent-ride-buck-keys-64ppm.png`). The same for Ohm,
please, in OhmRig/GhostFormView (yours): a kick on each bolt. `pilot.ohm.bolts` rises by one per bolt and
`pilot.ohm.bolt_tick` is the sim tick it left (OhmStage, ghost-powers; both stay). Suggested read: the guard arm
(electrodes) snaps forward ~0.06 m and back over ~0.15 s, the cane plants, the shell rocks back a few degrees;
halved under reduced motion. The bolt's prongs follow `electrode_l/r` from ghost_forms.json, so if the arm kick
moves the drawn fingers, tell me and I will offset the prongs by the same kick (or expose the kick offset).
- 03:48 the robot victim in the city block: the Ohm city beat spawns it too (the city is an ArenaStage), so it
  draws on the thug rig there as well; re-filmed on the merged head (`M/ohm-city-32ppm.mp4`, 0 SCRIPT ERROR): the
  gunmetal robot powers down in oil to the first bolt (tick ~120), then the cops and the cruiser. Judged 4 stills.
Session state 03:48: head = then head, tree clean, no Godot process of mine running, no lock held, masters
scratch holds only film.sh and reel.sh, frames.json 15 (all present).
- 03:49 Tonnage re-filmed at 64 px/m on the merged head (`M/tonnage-slam-64ppm-halfspeed.mp4`, 0 SCRIPT ERROR): the
  press on the cruiser (crushed, wrecked), the street crack, the flattened cops, the second slam's telegraph ring.
  Judged 6 stills; no regression from the merges.
- Not mine: PID 22028 (n5-cast's city capture) was running at 03:48; left alone.
Session state 03:50: head = this commit, tree clean, no Godot process of mine running, no lock held, masters
scratch holds only film.sh and reel.sh, frames.json 15 (all present).

## Iteration 6 (03:51-04:51, BUILD)
- 03:51 read JOURNAL, git log, the forms/cast JOURNALs: no new REQUEST to ghost-powers; REQUEST 8 (Ohm's arm kick)
  not answered yet. MERGE n6-ghost-forms 483aaeca: it fast-forwarded to the forms lane's 601bc1c2 (which had
  merged ours) and so replaced our JOURNAL/REPORT with theirs; FRICTION, restored ours in 13d6c778. MERGE n5-cast
  70ceb3bf (docs only; JOURNAL/REPORT keep ours) in 6d70e4ea. New on the head: n5-cast's visor slot at 32 px/m.
- 03:58 MILESTONE 686f1a8a NEXT 4: CombatBlood's kill routing (robot ids, dry kinds) split into BloodVictims
  (combat_blood.gd 299 -> 297 lines); test_blood_victims, unit 991/0, scenario --filter=ghost 1/0.
- 03:59 NEXT 5 Kerf re-filmed at 64 px/m on the merged head (`M/kerf-64ppm-halfspeed.mp4`): three blinks, four split
  cops (teal-white cauterised halves), robot down; 5 ghost kills at ticks 95/115/135/195 (`E/ghosts-kerf-64-it6.json`).
  FRICTION: the arena log's `react: ... 0 deaths` line prints at open, not at the end; the kill count is in the
  telemetry (`hook_8.ghost_dead`), and `--telemetry=` needs an absolute path.
- 04:00 Watched the it5 reel at 32 px/m (12 stills): Ohm reads weakest (small body, long range). Checked Ohm under
  `--gore=reduced`: its kills bled full red pools (the X-ray signature is off there; the standard death bleeds).
- 04:03 MILESTONE Ohm's bolt reports kill kind `electrocuted` (a BloodVictims.DRY_KILLS entry): under reduced gore
  the cops drop whole and dry. A/B `M/frames/ohm-reduced-gore-ab-32ppm.png` (ticks 130/200/300/410), clip
  `M/ohm-arena-gore-reduced-32ppm.mp4`. DECISION in decisions.md. Unit 991/0, scenario ghost 1/0, lint 13/13.
- 04:06 scenario_ghost_attacks guards the dry kills: every human kill Rivet makes in the Kerf and Ohm beats must report a
  BloodVictims.DRY_KILLS kind (wet 0, dry >= 4; robots excepted, they leak oil). FINDING on the way: the Kerf beat's
  robot dies to `shot` (Rivet's claw after the form ends; Kerf's slice does robot_damage, "heavy damage" by design),
  so robots are excluded. Planted `OhmStage.KILL_KIND = &"shot"` caught ("ohm: a kill bled",
  `E/scenario-ghost-it6-planted-ohm-shot.log`), reverted; clean 1/0 (`E/scenario-ghost-it6.log`).
- 04:12 GATES evidence runner `--no-bench` on d93fb106: lint 13/13, unit 991/0, scenarios 47, parity bit-exact
  (mutation caught at 629), look goldens 11/11 (worst 1.22) and block 5/5 in tolerance, no re-bless. Flagged FAIL only
  because I edited REPORT/ghost-attacks.md during the run ("tree changed during run"; FRICTION, mine:
  `E/evidence-run-it6-dirty.log`). Re-run on a still tree after the merge below.
- 04:14 REPORT iteration-6 rows; TTK doc: gore per ghost (crush/blast bleed; Kerf/Ohm dry kinds).
- (iteration 6 ended here without a NEXT line; carried below.)

## Iteration 7 (04:23-05:23, BUILD)
- 04:23 read JOURNAL, git log, the forms/cast JOURNALs: no new REQUEST to ghost-powers. The forms lane's plan this
  iteration: the forms, morph fx and HUD on the SHIPPED quest 1 (StoryForms, theirs; uncommitted in their tree).
- 04:24 MERGE n6-ghost-forms 882f4860 (carries n5-cast 0abfd6c3: the visor slot Rivet-only) with `--no-ff
  --no-commit`, JOURNAL/REPORT restored to ours before the commit (no fast-forward slip this time): 3d6a095b.
- 04:30 GATES evidence runner `--no-bench` on 3d6a095b, tree still the whole run: PASS lint 13/13, unit 996/0,
  scenarios 47, parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38),
  no re-bless (`E/evidence-run-it7.log`). Bench not run (contended machine).
- 04:34 MILESTONE 3b05cf31 the open "does not work" row closed: the Kerf beat's robot died to `shot` because the
  stand-in (the quest boss brain) is `exposed` only while its tazer is spent and CombatArena.damage skips an
  unexposed body, so both Kerf cuts were DROPPED and the claw finished it after the form. KerfBeat.hold() now holds it
  exposed, as OhmBeat did. Gate: scenario_ghost_attacks needs `robot_ghost >= 1` (the robot falls to the ghost's own
  kind: Kerf cauterised, Ohm electrocuted); planted no-hold caught ("kerf beat fell short (robot_ghost < 1)",
  `E/scenario-ghost-it7-planted-no-hold.log`), clean 1/0 (`E/scenario-ghost-it7.log`, `E/ghost-attacks.json`).
  A/B same seed and ticks (374/404/434/464): `M/frames/kerf-robot-cut-ab-32ppm.png`. Judged: before, the robot keeps
  firing its tazer line into Rivet after the cut and dies to a white claw flash at 464; after, it powers down in oil
  at the cut (404) and the line is gone. `M/kerf-arena-32ppm.mp4` re-filmed on the fix (0 SCRIPT ERROR).
  FRICTION (mine): restoring a planted edit with `git checkout -- file` also wiped the uncommitted fix in that file;
  re-applied. Plant from a scratch copy and copy it back.
- 04:45 MILESTONE 708d5672 the ghosts' attacks draw in quest 1. FINDING: quest 1 ran every ghost attack in the sim
  (StagePilot -> GhostPilot) but only the arena's TonnageHook drew them, so in the shipped quest 1 Kerf's blink was a
  bare teleport and Ohm's bolt invisible. GhostAttackViews (features/souls, mine) is now the one attacher; the arena
  hook and Quest1Game._casts (both casts) call it; TonnageView.marks false in quest 1 (CastView draws the crack
  there already). DECISION in decisions.md. Proof through real bound input (new dev quest_ghost_rec, extends my
  quest_hauler_rec: G taps, Q, right stick, melee): Kerf 6 blinks 5 slices 5 kills, Ohm 6 bolts 10 struck 5 kills,
  0 SCRIPT ERROR. A/B `M/frames/quest1-kerf-views-ab-32ppm.png` (same frames 80/100/120/260; before = the attach line
  removed), clips `M/quest1-kerf-32ppm.mp4`, `M/quest1-ohm-32ppm.mp4` (5 s each), `M/frames/quest1-ohm-bolt-keys-32ppm-x2.png`,
  `M/frames/quest1-tonnage-telegraph-keys-32ppm.png` (the die-plate telegraph, then one crack). Unit 996/0
  (`E/unit-it7.log`). gd-size caught _begin at 42 lines: the call went to a new `_casts()` at the file's end
  (keeps clear of the forms lane's `_dev_rigs` hunk).
- 04:47 COMBAT CHECK director reel headless on 708d5672: 16/16 chapters down, the same counts as iteration 6,
  0 SCRIPT ERROR (`E/director-reel-it7.log`). Tonnage re-filmed in the arena on the refactored hook
  (`M/tonnage-arena-32ppm.mp4`, 16 s, 0 SCRIPT ERROR): crack, crushed cruisers, flattened cops, all as before.
- 04:50 reel re-cut `M/ghost-attacks-reel-it7-32ppm.mp4` (41 s: + Kerf's robot cut, + Kerf and Ohm in quest 1);
  it6 reel deleted, frames.json updated (15).

### NOTICE -> n6-ghost-forms (04:51)
For your StoryForms on the shipped quest 1: my attack views now attach there too, in `Quest1Game._casts()` (a new
function at the end of quest1_game.gd that calls your `_dev_rigs()` then `GhostAttackViews.attach_quest(...)`;
`_begin` calls `_casts()` instead of `_dev_rigs()`, the only line I changed in `_begin`). They draw in the same
printed actors' layer as your body (Tonnage's telegraph at actors-2, Dent/Kerf at +1, Ohm at +2). Two notes from
the film: (1) in the Tonnage quest film the voice apparition (StoryVoice) stands over Rivet while he is in the form
and hides the telegraph; your StoryForms "silent in a form" should fix it. (2) Ohm's prongs come from your
electrode anchors whatever body draws, so on the sprite cast they start beside the Rivet sprite's hand.
- 04:53 Ohm's mass arc re-filmed on the current head (`M/ohm-mass-tier1-32ppm.mp4`; the it4 clip showed a red spot,
  the current one drops the cops dry, then the cruiser burns); reel re-cut (42.7 s).
- 04:55 FINDING Dent is a no-op in quest 1: DentStage.drive returns unless the stage is an ArenaStage with a
  VehicleService; quest 1 has none (city-sim traffic). REPORT "does not work" row. Not started this session: too
  large for the time left (a quest-side VehicleService over the city's parked cars).
- 04:57 quest 1 at 64 px/m half speed, Kerf and Ohm (`M/quest1-kerf-64ppm-halfspeed.mp4`,
  `M/quest1-ohm-64ppm-halfspeed.mp4`, keys `M/frames/quest1-kerf-ohm-keys-64ppm.png`), 0 SCRIPT ERROR, 5/5 kills each.
  Judged: Kerf's teal-white cut lines and afterimages read over the sprite cast; Ohm's bolt leaves the sprite's hand
  and forks to the zap star on each cop.
- 04:56 MERGE n6-ghost-forms f76274fc (StoryForms: the form bodies, morph and HUD on the shipped quest 1; Ohm's teal
  seams): quest1_game.gd merged clean (our `_casts()` calls their `_dev_rigs()`, which now attaches StoryForms).
  FRICTION: both lanes name evidence logs alike (`evidence/director-reel-it7.log`, `evidence-run-it7.log`): add/add
  conflicts; kept ours, theirs saved as `*-forms.log`. MERGE n5-cast d7bf12ce (core tan sticker, print_part shader).
  JOURNAL/REPORT keep ours at both. `--import` once.
- 05:02 GATES evidence runner `--no-bench` on the merged head d44c84cb, still tree: PASS lint 13/13, unit 1006/0,
  scenarios 47, parity bit-exact (mutation caught at 629), selftest look goldens 11/11 and block 5/5 in tolerance,
  no re-bless (`E/evidence-run-it7-merged.log`).
- 05:04 quest 1 on the merged head, Kerf and Ohm through real input: the forms lane's bodies and my attack views
  draw together (Kerf body + blink/cut lines; Ohm body + forked bolts), 5/5 kills each, 0 SCRIPT ERROR.
  `M/frames/quest1-forms-and-attacks-merged-32ppm.png`, clips `M/quest1-kerf-32ppm.mp4`, `M/quest1-ohm-32ppm.mp4`
  re-filmed; reel re-cut (42.7 s). frames.json 15 (all present).

NEXT (iteration 8, ghost-powers):
1. Merge n6-ghost-forms / n5-cast if they moved (`--no-ff --no-commit`, restore JOURNAL/REPORT, `--import`).
   Evidence log names: suffix ours with `-powers` from now on to stop add/add conflicts with the forms lane.
2. Dent in quest 1 (REPORT "does not work"): DentStage needs a VehicleService on the stage; quest 1 has none. Design
   first: a quest-side car source over the city's parked cars, or keep Dent out of quest 1's selection (one data
   value) until its act quest. Either changes quest 1's sim or selection: replay goldens, decisions line.
3. Combat check again after any merge (`--bot=reel --reel=director` headless, `--quit-after 24000`).
4. (done 05:08, below) quest 1 Tonnage on the merged head. NEW quality item: Tonnage's die-plate telegraph
   (TonnageView, z actors-2) sits mostly UNDER the forms lane's 3x press body at 32 px/m (it lands 0.9 m ahead,
   inside the body's footprint), so the wind-up warning barely reads, in the arena too. Fix to try: draw the
   telegraph's teal edge and dropping square on a second node above the actors (the crack stays under), or push
   the plate's draw out past the body's front; A/B at 32 and 64 px/m in quest 1 and the arena.
Session state 05:05: no Godot process of mine running, no lock held (image.lock and bench.lock never taken),
masters scratch holds only film.sh, reel.sh and two logs, frames.json 15 (all present).
- 05:08 COMBAT CHECK director reel on the merged head 9b5ae95f: 16/16 chapters down, the same counts as iteration 6,
  0 SCRIPT ERROR (`E/director-reel-it7-merged-powers.log`, `-powers` suffix per NEXT 1).
- 05:08 quest 1 Tonnage on the merged head (dev quest_hauler_rec): the forms lane's press body stands in for Rivet,
  the voice apparition is gone in the form (their StoryForms), one slam: 1 stomp hit, 3 ram hits, 4 kills, one crack
  and ring (CastView), 0 SCRIPT ERROR. `M/frames/quest1-tonnage-telegraph-keys-32ppm.png` re-shot (frames 226-292).
  Judged: the telegraph is mostly hidden under the body (NEXT 4).
Session state 05:09: head = this commit, tree clean, no Godot process of mine running, no lock held, masters scratch
holds only film.sh, reel.sh and two logs, frames.json 15 (all present).
- 05:13 TRIED (reverted, not committed) NEXT 4: TonnageView's telegraph on a child node lifted to actors+2. The quest 1
  film (frames 226-292) came out identical to the unlifted one. So either the forms' press body draws above actors+2,
  or quest_hauler_rec's slam (melee at its tick 40 lands during the morph; the one stomp is at tick 230) never shows a
  wind-up through TonnageView. Next session: read `hauler.form.windup_k()` per frame in the rec (log it) and the
  GhostFormView body's z, then lift (or move the plate ahead of the body) with a measured A/B.
Session state 05:14: head = this commit, tree clean, no Godot process of mine running, no lock held, masters scratch
holds only film.sh, reel.sh and two logs, frames.json 15 (all present).

## Iteration 8 (05:13-06:13, BUILD)
- 05:13 read JOURNAL, git log, the forms/cast JOURNALs: no new REQUEST to ghost-powers.
- 05:15 MERGE n6-ghost-forms ac0f15e5 (folding-card HUD, StoryForms; carries n5-cast 550b000d CORE_TAN 1.0) as
  64e9365d, `--no-ff --no-commit`; JOURNAL/REPORT and our it7 logs restored to ours; `--import` 0 SCRIPT ERROR.
- 05:25 MEASURED NEXT 4's cause: the forms' GhostFormView draws at rigs.z + 60 (ghost_form_view.gd:78), so the lift to
  actors+2 stayed under it; and the 1.8 m plate lies wholly inside the press body's footprint (top-down).
- 05:35 MILESTONE Tonnage's telegraph reads again: TonnageView draws the stomp's reach (dashed teal ring at
  stomp_radius_m, an ink wash filling from the plate outward over the wind-up) on its ground layer; dev
  `--no-tele-ring` = before. Quest 1 A/B same ticks (236-286, real input, 4 kills both, 0 SCRIPT ERROR):
  `M/frames/quest1-tonnage-reach-ab-32ppm.png` (before: no visible wind-up; after: the ring from tick 246, the wash
  filling to 266, then the crack). Arena re-filmed `M/tonnage-arena-32ppm.mp4` (0 SCRIPT ERROR), keys
  `M/frames/tonnage-reach-arena-keys-32ppm.png`: ring + wash, then the slam crushes the cruiser. DECISION in
  decisions.md. Registry rule applied (motion-quality-gating): a telegraph must read at game zoom on the shipped path,
  judged on stills at 32 px/m. Lint 13/13, unit 1007/0 (`E/unit-it8-powers.log`).
- 05:24 COMBAT CHECK director reel headless on ed6567b9: 16/16 chapters, the same per-chapter counts as iteration 7,
  0 SCRIPT ERROR (`E/director-reel-it8-powers.log`).
- 05:26 Tonnage's reach in quest 1 at 64 px/m (quest_hauler_rec --ppm=64, 4 kills, 0 SCRIPT ERROR):
  `M/frames/quest1-tonnage-reach-keys-64ppm.png`, `M/quest1-tonnage-reach-64ppm-halfspeed.mp4` (frames 200-320).
  Judged: ring, wash and crack read over the press body; the quest's dialogue box covers the lower street at 64.
- 05:29 reel re-cut `M/ghost-attacks-reel-it8-32ppm.mp4` (47 s, + the arena's Tonnage reach/slam segment first);
  it7 reel deleted; frames.json 15 (all present).
- 05:22 DESIGN Dent in quest 1 (NEXT 2): quest 1 has no vehicle bodies at all (no VehicleService in Quest1Session's
  world, no parked VehicleBody, the sprite CastView draws no cars), so a real car source is: a quest-side
  VehicleService seeded with parked cars at layout spots (or the baked chunks' parked cars, which StageCells already
  treats as solid), plus car drawing in the quest cast; it changes quest 1's sim (replay goldens, decisions line).
  Too large for this session; feedback first (below).
- 05:33 MILESTONE Dent's missed reach: a seize that finds no car (quest 1 always; the arena when nothing is on the
  aim line) lashes the teal tether out along the aim to its reach and frays it (DentStage miss_tick/miss_to/misses,
  view-only fields; DentView._miss). Dev `--no-dent-miss` = before. quest_ghost_rec now takes `--ghost=dent` (its
  press is fire, the seize) and reports `dent misses`. Quest 1 real input: 12 misses, 0 kills (correct: no car),
  0 SCRIPT ERROR both runs. A/B same frames 90-102: `M/frames/quest1-dent-miss-ab-32ppm.png` (before: nothing;
  after: the lash toward the guards, then dashes), clip `M/quest1-dent-miss-32ppm.mp4` (4.5 s). test_dent_miss 2/2.
  Gates: lint 13/13, unit 1009/0 (`E/unit-it8b-powers.log`), scenario ghost 1/0 (`E/scenario-ghost-it8-powers.log`).
  DECISION in decisions.md (feedback, not the fix: the REPORT row stays).
- 05:41 GATES evidence runner `--no-bench` on cefbcf8b, still tree: PASS lint 13/13, unit 1009/0, scenarios 47,
  parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38), no re-bless
  (`E/evidence-run-it8-powers.log`). REPORT iteration-8 rows (reach telegraph, Dent miss, reel it8, gates).
  frames.json 15 (all present; + quest1-dent-miss-ab, - kerf-body-keys, still in REPORT).
- 05:45 COMBAT CHECK (Dent, arena) after the miss change: `--bot=ghosts --ghost=dent` 480 ticks windowed, 0 SCRIPT
  ERROR: seize, ride, overload blast, the group down, no stray lash (the seize found its car). `M/dent-arena-32ppm.mp4`
  re-filmed. (Telemetry's "top speed 234.5 m/s" is the ride's roof placement counted as Rivet's walk: pre-existing,
  panel only.)

### NOTICE -> n6-ghost-forms (05:46)
Dent in quest 1 still has no car to seize (quest 1 has no VehicleService and the sprite cast draws no cars). Since
cefbcf8b the fire press in Dent shows a missed reach (a teal tether that frays), so the form is not mute. If the
Director prefers Dent unselectable in quest 1 until its act quest, that is your selection data (ghost_forms.json);
I have not touched it.

NEXT (iteration 9, ghost-powers):
1. Merge n6-ghost-forms / n5-cast if they moved (`--no-ff --no-commit`, restore JOURNAL/REPORT and our `*-powers`
   logs, `--import`). Then the director reel combat check (headless, `--quit-after 24000`).
2. Dent in quest 1, the real fix (design in the 05:22 line): a quest-side VehicleService on Quest1Session's world
   with 2-3 parked cars at StageLayout spots near the dock (data, not code), DentStage taking `stage.vehicles` from
   a small interface both stages expose (not `as ArenaStage`), and car drawing in the quest cast (CastView reads the
   service's cars). Changes quest 1's sim: replay goldens + a dated decisions line; prove with quest_ghost_rec
   `--ghost=dent` (seizes >= 1, blasts >= 1, kills) and an A/B against the miss.
3. Freeze 08:30: final evidence runner on the head, REPORT final (Calls: add the Tonnage reach ring vs plate-only A/B
   if the Director wants it judged), session-state line.
Session state 05:47: head = this commit, tree clean, no Godot process of mine running, no lock held (image.lock and
bench.lock never taken), masters scratch holds only film.sh, reel.sh and two logs, frames.json 15 (all present).
- 05:50 Dent's miss at 64 px/m in quest 1 (quest_ghost_rec --ghost=dent --ppm=64, 12 misses, 0 SCRIPT ERROR):
  `M/frames/quest1-dent-miss-keys-64ppm.png`, `M/quest1-dent-miss-64ppm-halfspeed.mp4`. Judged: the lash leaves the
  crash-test body's hands, crosses the guards and breaks into dashes; the end sparks are small at 64.
Session state 05:51: head = this commit, tree clean, no Godot process of mine running, no lock held, masters scratch
holds only film.sh, reel.sh and two logs, frames.json 15 (all present).
- 05:48 Not started NEXT 2 this session (scouted above): the refactor touches the shared stage and needs a quest
  blocker; a half-done sim change at the session cut is worse than none. CORRECTION: the 05:50/05:51 stamps above ran
  ahead of the real clock (it was 05:46); the work order is right.
Session state 05:49: head = this commit, tree clean, no Godot process of mine running (the 6 Godot processes in the
task list are other lanes'), no lock held, masters scratch holds only film.sh, reel.sh and two logs, frames.json 15.

## Iteration 9 (05:47-06:47, BUILD)
- 05:48 read JOURNAL, git log; n6-ghost-forms at 6e0532a2 and n5-cast at 030eb775 not merged yet.
- 05:50 MERGE n6-ghost-forms 6e0532a2 (per-form health bar_m, view only; carries n5-cast 551ed9c6 dark ped heads) as
  4b9c0b52 and n5-cast 030eb775 (docs) as e1283d9c, `--no-ff --no-commit`, JOURNAL/REPORT/our it7 logs kept ours;
  `--import` 0 SCRIPT ERROR. FRICTION: my first combat-check launch put `--quit-after` and the scene after `--`
  (ignored args, idle arena): killed my PID, relaunched as `--headless --quit-after 24000 --path project
  res://dev/arena/arena.tscn -- --bot=reel --reel=director`.
- 05:58 COMBAT CHECK director reel on the merged head + the quest-car change: 16/16 chapters, the same per-chapter
  lines as it8 (diff empty), 0 SCRIPT ERROR (`E/director-reel-it9-powers.log`).
- 06:00 MILESTONE Dent in quest 1 (NEXT 2), 291ad11c: `vehicles`/`cars()` moved from ArenaStage to CollectCallStage;
  quest 1 on the city parks three ghost cars (collect_call_city.json `ghost_cars`, fit clear of buildings, props,
  kerbs and baked parked cars by dev/ghost-powers/ghost_cars_fit.gd) on ArenaCars.attach_at; DentStage reads the
  stage's cars and pushes the car out of the arena's walls, else the city's StageCells; Tonnage's car crush and
  Ohm's car bolt read stage.vehicles too; StageView draws the cars (ArenaFloorView's car print moved up to it).
  Gates: lint 13/13, unit 1012/0 (+test_dent_quest_cars 2/2), scenarios 47/0 (no golden moved, no re-bless).
  DECISION in decisions.md (cost: a pre-change city checkpoint re-simulates to another hash and is refused).
  Registry rule applied (motion-quality-gating): judged on the shipped quest 1 path at 32 and 64 px/m.
- 06:08 quest 1 real input (quest_ghost_rec --ghost=dent, now also a melee press at tick 200 = the overload command):
  seizes 1, strikes 4, kills 4, blasts 1, then 5 misses (no car left in reach), 0 SCRIPT ERROR; identical counts at
  64 px/m. A/B/C same frames 90-102 `M/frames/quest1-dent-car-abc-32ppm.png` (before: nothing; it8: frayed miss;
  now: the teal-plated car with Dent on its roof), keys `M/frames/quest1-dent-car-keys-32ppm.png` and
  `-64ppm.png`, clips `M/quest1-dent-car-32ppm.mp4` (5 s), `M/quest1-dent-car-64ppm-halfspeed.mp4`. Judged: the
  parked white car reads as a target, the hijack plate turns it teal, the blood trail and blast read; the car
  mounts the pavement (cells are walkable there; kerbs are not solid), acceptable. frames.json 15 (all present).
- 06:12 arena re-check after the stage move (headless, 600 ticks, telemetry `E/arena-<ghost>-it9-powers.json`):
  Tonnage cars_crushed 2, ram_hits 6, 10 dead; Dent seizes 1, strikes 5, blasts 1, 5 dead; Ohm bolts 15, cars_hit
  5, 5 dead; 0 SCRIPT ERROR each.
- 06:16 GATES evidence runner `--no-bench` on bc72f553, still tree: PASS lint 13/13, unit 1012/0, scenarios 47,
  parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.21), no re-bless
  (`E/evidence-run-it9-powers.log`). Reel re-cut `M/ghost-attacks-reel-it9-32ppm.mp4` (51.2 s, + the quest 1 Dent
  car segment after the city Dent); it8 reel deleted; frames.json 15 (all present). REPORT iteration-9 rows (Dent
  in quest 1, gates), the "does not work" row rewritten (fixed cars, not the city's; ghost cars are not solid),
  Call added (quest cars vs Dent locked in quest 1).
- 06:25 MILESTONE quest 1's ghost cars are solid for Rivet and the guards (ArenaCars.push_out, an oriented box per
  parked/wrecked car; the seized car is not solid so the ride holds; the arena unchanged). Unit 1013/0
  (`E/unit-it9b-powers.log`, + test_a_parked_ghost_car_is_solid_and_the_seized_one_is_not), scenarios 47/0
  (`E/scenarios-it9b-powers.log`), quest 1 Dent rec identical counts, 0 SCRIPT ERROR; after the blast Dent lands
  clear of the wreck's box (looked at frames 204/230/290, not kept). DECISION in decisions.md.
- 06:30 GATES evidence runner `--no-bench` on 514e6899, still tree: PASS lint 13/13, unit 1013/0, scenarios 47,
  parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.21), no re-bless
  (`E/evidence-run-it9b-powers.log`). REPORT rows: solid ghost cars, final gates; "does not work" amended.
  Other lanes' JOURNALs: no new REQUEST to ghost-powers.

### NOTICE -> n6-ghost-forms (06:31)
Quest 1 now has cars (291ad11c, 514e6899): three parked ghost cars on the city street (`collect_call_city.json
ghost_cars`), `vehicles`/`cars()` on CollectCallStage, drawn by StageView. Dent seizes, rides and blows them in quest
1 (the NOTICE of 05:46 is answered: Dent can stay selectable there). If your StoryForms Dent body has a ride pose
for the arena, it now applies in quest 1 too (DentStage.riding()).

NEXT (iteration 10, ghost-powers):
1. Merge n6-ghost-forms / n5-cast if they moved (`--no-ff --no-commit`, keep JOURNAL/REPORT and our `*-powers`
   logs, `--import`); director reel combat check as `--headless --quit-after 24000 --path project
   res://dev/arena/arena.tscn -- --bot=reel --reel=director` (flags before `--`!).
2. A determinism scenario for Dent in quest 1 (same seed twice -> same seize/strike/blast counts and state hash;
   planted fault: `ghost_cars` [] must fail it), beside scenario_ghost_attacks.
3. Tonnage and Ohm on quest 1's cars, filmed: quest_hauler_rec's slam beside a ghost car (crush) and the Ohm rec's
   car bolt (the code reads stage.vehicles since 291ad11c; not yet seen in quest 1).
4. Freeze 08:30: final evidence runner on the head, REPORT final (mark DRAFT -> final), session-state line.
Session state 06:31: head = this commit, tree clean after it, no Godot process of mine running, no lock held
(image.lock and bench.lock never taken), masters scratch holds only film.sh, reel.sh, report_it9.py and logs,
frames.json 15 (all present).
- 06:34 NEXT 3 probe: quest_hauler_rec with a local `cars_crushed` log (reverted: _run went past 40 lines). On 514e6899 (solid ghost cars): stomps 1, stomp_hits
  1, ram_hits 3, kills 4 (same as it8), cars_crushed 0, 0 SCRIPT ERROR. Looked at frame 236: the start-side ghost car
  stands about 3 m north of the press head, outside car_crush_m, so the slam misses it. Next session: a rec variant
  that steers the ram at the ghost car (or a second spot in its path), then the crush A/B in quest 1.
Session state 06:35: head = this commit, tree clean, no Godot process of mine running, no lock held, masters scratch
holds only film.sh, reel.sh and logs, frames.json 15 (all present).

## Iteration 10 (06:36-07:36, BUILD)
- 06:37 read JOURNAL, git log. MERGE n6-ghost-forms e865146d (Ohm's 2.6 m soul glow, story-form lift, n5-cast cop
  art) as 97f49bf0 and n5-cast 7005b5c8 (plain riot crown) as 23bc7c07, `--no-ff --no-commit`, JOURNAL/REPORT and
  our it7 logs kept ours; `--import` 0 SCRIPT ERROR. No new REQUEST to ghost-powers in the other lanes' JOURNALs.
- 06:45 COMBAT CHECK director reel on 23bc7c07 (`E/director-reel-it10-powers.log`): 16/16 chapters, chapter lines
  identical to it9 (diff empty), 0 SCRIPT ERROR.
- 06:55 MILESTONE NEXT 2, a9b4a90f: `scenario_quest1_dent` (quest 1 on the city, a scripted pad: G, Q, the stick
  on the nearest guard, fire every 20 ticks, melee at 200). Clean: seizes 1, strikes 4, kills 4, blasts 1, misses
  5, rides 131 (= the filmed rec's counts); the same seed twice gives the same counts and state hash
  (5718fac2...); the planted fault (the street's ghost cars cleared before tick 0) gives 0 seizes, 12 misses, a
  different hash: caught (`E/quest1-dent.json`). No replay verify in it: the group is spawned outside the input
  stream (as in the rec), so a replay log alone cannot rebuild it; the hash check is the determinism proof.
- 06:50 MILESTONE NEXT 3a Tonnage on quest 1's car, filmed: `dev/ghost-powers/quest_crush_rec` (bound input only:
  Start, five guards round the start-side ghost car, Q, the left stick walks the press to the car until its centre
  is 3.4 m off, melee). First take: STOP_M 2.2 never reached (the solid car holds the press about 2.5 m off since
  514e6899), the slam only came at the fallback press; set STOP_M 3.4 (the head lands 0.9 m ahead, car_crush_m 3.4,
  so a car centre within 4.3 m is in reach). Now: slam tick 121, cars_crushed 1, stomp_hits 3, kills 4, car WRECK,
  0 SCRIPT ERROR, identical at 64 px/m. The second press at 220 falls in the stomp cooldown (stomps 1). Judged at 32
  and 64: the reach ring and the press shadow grow over the white sedan, the drop turns it into the black flattened
  wreck with the street crack, the guards thrown and flattened. `M/frames/quest1-tonnage-crush-keys-32ppm.png`,
  `-64ppm.png`, `M/quest1-tonnage-crush-32ppm.mp4`, `M/quest1-tonnage-crush-64ppm-halfspeed.mp4`; frames.json 15
  (dropped tonnage-reach-arena-keys and quest1-kerf-views-ab, older; files kept). Registry rule applied
  (motion-quality-gating): the shipped path, judged in motion at 32 and 64.
- 07:03 MILESTONE NEXT 3b Ohm on quest 1's car, defdd14b. First take (quest_ghost_rec --ghost=ohm, 300 ticks):
  bolts 6, cars_hit 0: a cop still stood within reach at the end, so the stick never left the guards. The rec now
  runs Ohm 450 ticks and, once no guard is within his 11 m, aims at the nearest live street car: cars_hit 3. Judged:
  three bolts only cracked the windscreen (20 flat of 100 = 60, D1): "strong against machines" did not read on a
  car. FIX: the car bolt takes machine_k like a robot (car_damage 12 x 3 = 36: D1, D2, the wreck on the third bolt,
  1 s). test_a_car_is_a_machine_three_bolts_wreck_it (test_ohm_attacks 6/6), scenarios 48/0 (arena Ohm cars_hit 3,
  5 dead, `E/ghost-attacks-it10-powers.json`), TTK row and DECISION. A/B same frames 390/430/449
  `M/frames/quest1-ohm-car-ab-32ppm.png` (before: cracked glass; after: smashed shell, then the black burned-out
  wreck), keys `M/frames/quest1-ohm-car-keys-64ppm.png`, clips `M/quest1-ohm-car-32ppm.mp4` (7.5 s),
  `M/quest1-ohm-car-64ppm-halfspeed.mp4`. frames.json 15 (dropped quest1-forms-and-attacks-merged and
  quest1-tonnage-reach-keys-64ppm, both superseded; files kept). Registry rule (motion-quality-gating): judged on
  the shipped quest path in motion, 32 and 64.
- 07:05 GATES: evidence runner `--no-bench` on the head started (`E/evidence-run-it10-powers.log`).
- 07:10 GATES on b251cc0a: unit 1017/0 but marked FAIL "tree changed during run" (I edited REPORT.md while it ran:
  FRICTION, my error). Committed REPORT (a30a5ce3) and re-ran on a still tree: PASS lint 13/13, unit 1017/0,
  parity bit-exact (mutation caught at 629), selftest goldens 11/11 + block 5/5 in tolerance (no re-bless); scenarios
  47/48: `scenario_rig_stress` failed in the full run, passed alone (rig median 0.40/0.42 ms of 1 ms) and passed in
  the 48/48 run on defdd14b; a wall-clock budget under contention, no rig code touched (`E/evidence-run-it10-powers.log`,
  `E/rig-stress-alone-it10-powers.log`). Reel re-cut `M/ghost-attacks-reel-it10-32ppm.mp4` (57.7 s, + the quest 1
  Tonnage crush and Ohm car segments), it9 reel deleted, frames.json 15 (all present).
- 07:20 COMBAT CHECK director reel on a30a5ce3: 16/16, chapter lines identical to 06:45, 0 SCRIPT ERROR
  (`E/director-reel-it10b-powers.log`). Other lanes' JOURNALs: no new REQUEST to ghost-powers.

NEXT (iteration 11, ghost-powers):
1. Merge n6-ghost-forms / n5-cast if they moved (`--no-ff --no-commit`, keep JOURNAL/REPORT and our `*-powers`
   logs, `--import`); director reel combat check (flags before `--`). Never edit the tree while the evidence runner
   runs (write its log to /tmp, copy in afterwards).
2. Kerf in quest 1 against the robot or a car? Kerf has no car interaction (by design: assassin). Weakest item now:
   the robot victim is a dev stand-in brain (REPORT "does not work"); or a quest-1 determinism scenario for Ohm's car
   bolt (planted machine_k 0 must leave the car intact), beside scenario_quest1_dent (same Press input, melee instead
   of fire, the car fallback aim).
3. Freeze 08:30: final evidence runner on the head (still tree), REPORT final (DRAFT -> final, Next steps section),
   session-state line.
Session state 07:22: head = this commit, tree clean after it, no Godot process of mine running, no lock held
(image.lock and bench.lock never taken), masters scratch holds only film.sh, reel.sh and two it7 logs, frames.json 15.
- 07:22 MILESTONE NEXT 2 (ohm part, pulled forward): `scenario_quest1_ohm` (quest 1 on the city, a scripted pad: three
  G taps, Q, melee every 20 ticks, the stick on the nearest guard, else, none within 11 m, the nearest live car).
  Clean: bolts 9, struck 10, cars_hit 3, wrecks 1, kills 5 (= the filmed rec); the same seed twice gives the same
  counts and hash (f6ee6923...); the planted machine_k 0 leaves the car standing (wrecks 0, another hash): caught
  (`E/quest1-ohm.json`). The fault cannot leak into later scenarios: GhostAttacks parses its own table per session.
  Full scenario count is now 49 (not yet run as a suite: next session's first gate).
Session state 07:24: head = this commit, tree clean, no Godot process of mine running, no lock held, masters scratch
holds only film.sh, reel.sh and two it7 logs, frames.json 15. NEXT as above, item 2 now: the robot stand-in, or a
Kerf quest-1 scenario on the same pattern (planted human_damage 0).
- 07:27 scenario suite on ed965182: 49 ran, 0 failed (`E/scenarios-it10b-powers.log`; rig_stress passed this time). REPORT row added.

## Iteration 11 (07:27-08:27, BUILD)
- 07:28 read JOURNAL, git log, REPORT. MERGE n6-ghost-forms ebc5ed9d (Dent's keyline shader, apparition; carries
  n5-cast 473a405e) as the first merge commit and n5-cast 02e4295c (quest 1 sprite Rivet sticker tier) as bbc861d0,
  `--no-ff --no-commit`; JOURNAL/REPORT and our it7 logs kept ours. `--import` 0 SCRIPT ERROR. No new REQUEST to
  ghost-powers in the other lanes' JOURNALs.
- 07:31 COMBAT CHECK director reel on bbc861d0 (`E/director-reel-it11-powers.log`): 16/16, chapter lines identical
  to it10b, 0 SCRIPT ERROR.
- 07:33 MILESTONE 81d6bdfe: the last two quest-1 determinism scenarios, on the ohm/dent pattern.
  `scenario_quest1_kerf` (two G taps, Q, melee every 20, stick on the nearest guard): blinks 6, slices 5, kills 5;
  same seed twice = same counts and hash (dcdda41a...); planted human_damage 0: kills 0 (slices 6): caught.
  `scenario_quest1_tonnage` (Q, the stick walks the press to the start-side car until 3.4 m, melee every 20 in
  reach; a stateless pad): stomps 1, stomp_hits 3, cars_crushed 1, car WRECK, kills 4 (= the filmed quest_crush_rec);
  same seed twice = same (5a9f46da...); planted car_crush_m 0: car stands (wrecks 0): caught. All four ghosts now
  have a quest-1 scenario with a planted fault (`E/quest1-{tonnage,dent,kerf,ohm}.json`). Suite count 51.
- 07:36 docs: ghost-attacks.md quest-1 table (the four scenario_quest1 outcomes and faults).
- 07:41 GATES on 2486357c (still tree, log to /tmp, copied in after): evidence runner PASS: lint 13/13, unit
  1019/0, scenarios 51/51 (rig_stress passed this time), parity bit-exact + mutation caught at 629, look goldens
  11/11 (worst 1.33), block 5/5, no re-bless (`E/evidence-run-it11-powers.log`). Bench not run (contended).
- 07:46 MILESTONE a3beb449 (owner call "Kerf: target only vs every body on the path", was without a still):
  `ghost_attacks.json kerf.path_cut_m` (schema 0..3; 0 = built). KerfStage._cut_path slices every other live
  hostile within path_cut_m + radius of the blink segment; 0 returns before any work, so no golden moves. Dev
  `--kerf-line` (the riot cop 8.5 m out behind two cops on the line, aim at the farthest in reach) and
  `--kerf-path=<m>` in KerfBeat. Unit `test_path_cut_spares_the_body_on_the_line_unless_set` (1020/0). Filmed
  arena 32 px/m, 420 ticks each: built kill_ticks [75,195,255,315] (one per blink), 0.6 [75,75,75,195] (the pick
  and both cops on its line in one pass), 0 SCRIPT ERROR. Judged: built shows one teal-white star at the far end,
  0.6 three stars along the line, and by frame 82 both near cops split. `M/frames/call-kerf-target-vs-path-32ppm.png`
  (frames 70/76/82/100, top built / bottom 0.6), `M/call-kerf-target-vs-path-32ppm.mp4` (7 s). frames.json 15
  (added at the head, dropped dent-vs-target, file kept). DECISION target-only stays (assassin role; the path cut
  turns the blink into an area attack and takes Tonnage's group role). Registry rule (motion-quality-gating):
  the A/B judged in motion at game zoom on the real rigs.
- 07:48 scenario_ghost_attacks alone on a3beb449: 1/0 (the arena beats unchanged at path_cut_m 0).
- 07:50 REPORT final: header, "In short", iteration 11 rows, the Kerf call with its still, Next steps.
- 07:50 COMBAT CHECK director reel on a3beb449: 16/16, identical, 0 SCRIPT ERROR (`E/director-reel-it11b-powers.log`).
- 07:56 GATES on 2ca168ff (still tree): evidence runner PASS: lint 13/13, unit 1020/0, scenarios 51/51, parity
  bit-exact + mutation caught at 629, look goldens in tolerance (`E/evidence-run-it11b-powers.log`).
- 07:58 MERGE n6-ghost-forms cd56e482 (5be03adb: quest 1's story-forms path draws n5-cast's 32 px/m sticker Rivet,
  their answer to n5-cast's 07:40 REQUEST, which was addressed to us too: met there, nothing for ghost-powers to
  edit; it carries n5-cast c7549272) as 467830fc, `--no-ff --no-commit`, JOURNAL/REPORT and our it7 logs kept ours.
  n5-cast's tip is now an ancestor. `--import` 0 SCRIPT ERROR.
- 08:08 FINAL GATES on 467830fc (the merged head, still tree): evidence runner PASS: lint 13/13, unit 1020/0,
  scenarios 51/51, parity bit-exact + mutation caught at 629, look goldens in tolerance, no re-bless
  (`E/evidence-run-it11c-powers.log`); director reel 16/16, identical to it10b, 0 SCRIPT ERROR
  (`E/director-reel-it11c-powers.log`). Bench not run (contended machine, no bench.lock taken).

NEXT (ghost-powers, after the morning merge):
1. A real robot fighter in CombatArena: bridge one enemy-ai EnemyAgent (robot_thug) onto a Fighter (`ROBOT`
   kind) and retire the Kerf/Ohm beats' exposed boss stand-in (replay re-bless with a decision line).
2. Quest 1 street: promote the nearest baked parked cars to VehicleBody so Dent/Tonnage/Ohm meet the city's own
   cars; the crowd avoiding ghost cars is native (parity re-bless).
3. Tier-1 rows for Tonnage, Dent, Kerf when the act quests land (only Ohm's mass arc reads upgrade_tier now).
4. The owner's calls in REPORT (Ohm colour, Kerf path_cut_m, Dent ride, Tonnage crush, Dent quest cars): each one
   data value.
Session state 08:09: head = this commit, tree clean after it, no Godot process of mine running, no lock held
(image.lock and bench.lock never taken), masters scratch holds only film.sh, reel.sh and two it7 logs, frames.json
15 (all present).
