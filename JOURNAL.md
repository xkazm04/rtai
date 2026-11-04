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
