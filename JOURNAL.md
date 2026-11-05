# JOURNAL: lane servo (branch `n7-servo`), night 2026-11-05/06

Masters: `C:\Users\kazda\kiro\gtai-masters\n7\servo\` (`M/`). Evidence: `evidence/` (`E/`).

## Iteration 1 (18:53-19:53), BUILD

- 18:53 read: BOSSES.md, `img/boss_servo.jpg` (looked at it: walker on two long legs, two
  hover-pad arms with hazard stripes, a glass cargo belly showing crates on a conveyor, a visor
  head with a vermilion slit, and two big drone-rack wings across the back; the top view is a
  wide bar of rack cells with the slim body in the middle and the two round pads hanging at the
  sides, the most important panel), enemy-ai REPORT (aim lock 0.2 s, windup arcs, stagger rules),
  ghost-powers REPORT (Dent seize/ride, Kerf blink-and-slice, Ohm forked bolt within 3 m, Tonnage
  slam), STANDARDS via AGENTS.md, `core/rng/rng_registry.gd`, `core/clock/sim_clock.gd`,
  `core/events/events.gd` (`boss_engaged` exists), `DataTable`.
- 18:58 n7-king's JOURNAL does not exist yet; its branch is still at main 763f8fba. I post the
  interface REQUESTs first (below) so we agree it in iteration 1.
- Registry rules applied (`combat-pacing-and-dramatic-arc`, `encounter-balance-simulation`):
  duration is a two-sided envelope stated per encounter class (I set the boss class at 60-150 s,
  each phase 20-60 s; a Rivet death inside 5 s of an attack's tell = punishing); breathers are
  authored (the dock/reload window after each wave) and dead zones are measured on the raw event
  stream; report rates as counts ("hit 3 of 10 dodging"); a single dominant damage source is
  named; numbers are judged only against a stated reference hit (Rivet 100 hp, regen 10/s after 3 s).

### REQUEST to n7-king (the shared boss framework interface), 18:58
Proposed; if you built it differently, your shape wins and I adapt; write the answer in your JOURNAL.
1. **Boss ids:** `king`, `servo` (StringName, = the character id in `Events.boss_engaged`).
2. **Table:** `project/data/tables/bosses.json` (`gtai.bosses/1`), rows by id. Boss row: `hp`,
   `poise` (heavy hits a windup can absorb before it staggers; 0 = never), `stagger_s`,
   `arena` (arena id), `music` / `stinger` (audio ids), `name_key` (Loc), `phases` (array).
   Phase: `id`, `from_hp_frac` (enters when hp <= this; phase 1 = 1.0), `attacks` (ids),
   `pick` (`cycle` | `weighted`), `gap_s` (rest between attacks), `transition_s` (invulnerable
   beat on entry).
   Attack record (under the boss row, `attacks.{id}`): `windup_s`, `active_s`, `recovery_s`,
   `punish_s` (part of recovery where the boss takes `punish_k` x damage), `punish_k`,
   `cooldown_s`, `weight`, `damage`, `aim_lock_s` (aim tracks during windup, locks this long
   before active, the enemy-ai rule scaled up), `range_m`, `telegraph` (a kind id the framework's
   telegraph helper draws: `line`, `lane`, `ring`, `arc`, `none`), `adds` (optional:
   `{ "kind": <boss-folder add id>, "count": n }`). Anything else boss-only goes in
   `extra: {}` which the framework passes through untouched.
3. **Phase / attack events** (Events signals, so HUD, music and the bot listen without coupling):
   `boss_phase_changed(boss, phase: int)`, `boss_attack_stage(boss, attack, stage)` with stage
   in `windup|active|recovery|done`, `boss_health_changed(boss, hp, max_hp)`,
   `boss_defeated(boss)`. Keep `boss_engaged` and `attack_telegraphed`.
4. **Adds:** the framework never knows what an add is. The boss's own body script in
   `features/bosses/<id>/` implements a small hook set the framework calls on the tick:
   `on_attack_stage(attack: StringName, stage: StringName)`, `on_phase(phase: int)`,
   `adds_alive() -> int`, `step(tick)`. Servo's drones live in `features/bosses/servo/`
   (`ServoSwarm`, RNG stream `&"servo_swarm"`); King's gang in his folder.
5. **Arena record:** `project/data/tables/boss_arenas.json` (or a block in bosses.json), rows by
   id: `size_m` (Vector2), `rivet_spawn`, `boss_spawn`, `walls` (rects), `props` (a list of
   `{kind, pos, size, rot}` where kind is free text resolved by the boss folder's arena script),
   `camera_ppm`. Servo's arena id: `depot`.
6. **Damage into the boss:** one entry `BossBrain.take_hit(amount, kind, from: Vector2)` that
   applies poise/punish and emits health; ghosts and weapons call it like `EnemyPit.stun()` is
   called today. A `stun(seconds)` scaled by a boss row `stun_k` (I propose 0.33).

Until the framework lands, Servo's swarm and attacks run standalone in `features/bosses/servo/`
with their own data table `servo.json` (`gtai.servo/1`); the attack rows there use the field
names above, so they move into `bosses.json` with a copy.

- 19:00 MILESTONE 110e8708: the drone swarm standalone (`features/bosses/servo/`: ServoTuning,
  ServoRack, ServoDrone, ServoParcels, ServoSwarm; `data/tables/servo.json` + schema). Unit
  `test_servo_swarm` 6/6. FRICTION: GUT silently skips a test file that fails to parse (a
  discarded return value is a warning-as-error): the full-suite "1110 passed" did not include my
  file. Always run the new file alone with `-gselect=<name>` and look for its test names.
- 19:04 MERGE n7-king 243f216b (framework core: bosses.json, BossFight, BossZone, BossMoves,
  BossSpec) into n7-servo as cc4446ba. Conflict only in JOURNAL.md (each lane keeps its own: ours).
  King's interface (their JOURNAL REQUEST 1) differs from my proposal; **theirs wins**, I adapted:
  phases `hp_below`, attack `shape`, per-boss `script` extending `BossMoves`, `arenas.<id>`.
- 19:11 MILESTONE 49bff207: Servo's row in bosses.json (written by
  `evidence/servo/write_servo_row.mjs`, which only sets `bosses.servo` and `arenas.depot`) and
  `ServoMoves`. Unit `test_servo_moves` 4/4.
  - Measured a dead zone and fixed it: the rotor dash (14 m) ended on top of Rivet, inside every
    attack's `min_m`, and the default walk only closes in, so Servo stood idle for 25 s of a 30 s
    run (2 attacks). ServoMoves.idle_step holds a band (9 +- 2 m, backs off): now 7 attacks / 30 s.
  - First rough phase-1 numbers (30 s, seed 7, the unit test's crude bot, NOT the bot): standing
    took 178 (would die: Rivet has 100), a 6 m sidestep at each lock took 60. To be measured by the
    real bot.
- DECISION servo-mark: every drone attack drops on the MARK = where Rivet stood when the tell
  locked (the scanner beam does no damage itself). Moving after the lock dodges, as the enemy-ai
  rule. Rejected: re-aiming drones in flight (homing drops are undodgeable at 32 px/m).
- DECISION servo-wave-shape: a wave is one drone on the mark plus a ring spread_m (1.9 m) out;
  the union of the rings + blast (1.6 m) is about 4 m round the mark, so a dodge is a real step
  (~0.6 s of Rivet's walk), not a shuffle. One data value (`phases[].spread_m`) to tighten.

### REQUEST 2 to n7-king (19:12): three small generic hooks Servo needs
1. **A per-tick hook every state:** in `BossFight.step()`, before the state match (not when
   DEFEATED), `var extra: float = moves.tick(self, target, target_r)` and add `extra` to the
   returned damage. Default `BossMoves.tick()` returns 0. Why: Servo's parcels and kamikaze drones
   land after the attack's active window (King's coin hail landing late would use it too).
   `ServoMoves.tick(f, target, target_r) -> float` already exists with that signature.
2. **Seeding the boss's own sub-systems:** `BossMoves.bind(f: BossFight, rng: RngRegistry)`,
   called once by whoever builds the fight (the hook), so a boss script can take its own named
   stream (Servo: `ServoSwarm.STREAM` = `servo_swarm`). Until then I call
   `ServoMoves.setup_swarm(reg.stream(ServoSwarm.STREAM))` myself.
3. **Your `write_bosses.mjs` keeps other rows:** read the existing table and set only
   `bosses.king` / `arenas.king_boulevard`, or regenerating drops Servo's row. Mine
   (`evidence/servo/write_servo_row.mjs`) already does that for `servo` / `depot`.
- 19:18 MILESTONE c60ac868: dev graybox of the fight (`dev/servo/servo_fight_run.gd`, windowed
  d3d12; stand-in shapes, NOT the rig). Looked at the 48 px/m keys
  (`M/frames/servo-graybox-wave-keys-48ppm.png`): the thin tracking beam, the lock ring, the three
  dashed drop rings (they overlap into one pill-shaped zone), drone rotor crosses over ink shadows,
  rack cells going dark at the wing tips as drones launch: all read. Weak: the rings show from
  launch, ~3 s before the drop at 9 m/s cruise; raised cruise to 12 m/s (data).
  - MEASURED (graybox, seed 7, 30 s phase 1, a perfect-reader stand-in that steps 5 m off the
    mark at the lock; not the real bot, Rivet's real reaction is later): standing 178 damage (4
    blast hits of 9 drones, 3 dashes of 3); dodging 0 (0 of 9 drones, 0 of 3 dashes). Too easy for
    a perfect reader by design; the real bot must react with Rivet's reaction delay.
  - Clips: `M/servo-graybox-p1-dodge-32ppm.mp4`, `M/servo-graybox-p1-stand-32ppm.mp4`,
    `M/servo-graybox-wave-48ppm.mp4`; `M/frames.json` (4 entries).
- 19:20 gates: lint 13/13 every commit; unit 1130 passed / 0 failed (`E/unit-it1.log`, includes
  test_servo_swarm 6, test_servo_moves 4, king's test_boss_fight 10).
- 19:21 image job `servo_core_a` started under `gtai-n5/image.lock` (runner copied to
  `gtai-n7/scratch/servo/tools/gen.mjs`; round `M/gen/r1/`): an edit of the n5-cast 3x2 layout
  template (`gen/r1/refs/sheet.png`, the d4 core sheet) with the Servo target: TL kept as the
  scale reference, TM visor head, TR hover pad, BL walker pelvis, BM cargo-belly torso, BR one
  drone-rack wing (2x3 bays with docked drones). Neutral visor (the game tints it vermilion only
  during a tell).
- Calls for the owner (collect for REPORT):
  1. **When the drop rings appear.** Default built: from the drone's launch (~2-3 s of warning).
     Option: only over the hover (hover 0.7 + fall 0.35 = 1.05 s), the mark ring alone before.
     To build as one flag next iteration (`servo.json drone.ring_from_launch`); see
     `M/servo-graybox-wave-48ppm.mp4`.
  2. Should a CS crate landing on Rivet hurt (today only bombs do; crates block and cover)?
- 19:22 Codex `servo_core_a` came back in 72 s (lock released): visor head + hoses, octagonal hover
  pad with landing circle, walker pelvis, cargo-glass torso with parcels, a 2x3 drone-rack wing;
  the template's reference cell kept. Saturated orange on visor, hoses, stripes (fixed in the cut).
  19:24 `servo_limbs_b` (sheet 2, same template): drone, plain cardboard crate, thigh, lower leg
  with foot, arm with pad fork. Sheet sha256 core 3d3351d5...; both in `M/gen/r1/out/`.
- 19:30 MILESTONE 0c6b9832: **ServoRig**, the cutout body (`features/bosses/servo/servo_rig.gd`,
  parts in `features/bosses/servo/art/` at 96 px/m from `tools/art/servo_parts.py`). Procedural
  motion: gait + bob from distance walked, lean back through every tell (anticipation) and lunge
  in the active window (follow-through), head turns to the aim with a vermilion visor slit only in
  a tell (thick once locked), pads spin up for the dash, steam in the punish window, rack bays go
  dark while their drone is out, phase 3 hides a wing, a hit flashes (never touches the state).
  Dev view draws it (`--graybox` keeps the stand-in as the before). FIX: the legs first hid under
  the rack; the target's top view shows them stepping out in front: moved the feet forward.
  Looked at `M/frames/servo-rig-vs-target-64ppm.png`: same family; gaps listed in NEXT.
  Provenance x10 in `steam/ai-provenance/2026-11.jsonl`.
- FRICTION: my gate logs overwrote tracked `evidence/unit-it1.log` etc. from an earlier lane;
  restored them and keep this lane's logs in `evidence/servo/` (rule for every later run).
- Gates on 0c6b9832's tree: lint 13/13; unit 1130/0 and scenarios 52 ran / 0 failed (run on
  c60ac868, the rig is dev-view only plus data rack spacing); director reel (`--bot=reel
  --reel=director --loadout=pistol`, headless) 19/19 chapters fully down, 0 SCRIPT ERROR:
  `evidence/servo/*-it1.log`. Combat untouched (no shared code changed).

NEXT (iteration 2, in order):
1. Merge n7-king again (`git -C ../n7-king log`), read its JOURNAL for answers to REQUEST 2
   (per-tick `BossMoves.tick`, rng bind, write_bosses keeping rows). If `tick` landed, delete the
   manual `moves.tick()` calls in the dev view / tests and let BossFight sum it.
2. Body to target: rack wings 3 rows deep (regenerate the wing cell as 2x3 -> 3x3 or stack two),
   the body set BETWEEN the wings (not in front), pads bigger and lower; rack data cells to match
   (18 cells?) or keep 12 and draw 3 rows; the drone sprite on its own little rig (rotor blur
   discs spinning, parcel slung below, tilt toward velocity). Check silhouette at 32 px/m against
   Rivet's REAL rig and cops (put CutRig Rivet in the view instead of the disc).
3. Kamikaze dive (phase 3) in ServoSwarm: dive line tell (thin tracking 0.6 s, lock 0.3 s), 2.2 m
   blast; then the carpet lanes' painted stripes (1.4 s) in the view.
4. Calls to build as flags: rings from launch vs at hover (`servo.json drone.ring_from_launch`);
   crate landing damage.
5. Then the arena (depot: bays, conveyor, CS crates) through king's arena loading + `--boss=servo`,
   the HUD bar, music; then the bot (`--bot=boss --boss=servo`) with Rivet's reaction delay.
- 19:37 MERGE n7-king e92b3d8b into n7-servo as 6f7572cf: REQUEST 2 answered by king (BossMoves.tick
  every state, BossMoves.bind, plus BossAdds/BossHook). Conflicts: JOURNAL (ours), bosses.json (took
  king's, re-applied Servo's row with `evidence/servo/write_servo_row.mjs`, schema-valid).
  ServoMoves.bind takes `servo_swarm`; the manual tick() calls removed from tests and the dev view.
  Same numbers after (standing 178 / sidestep 60 in 30 s). Unit 1134/0
  (`evidence/servo/unit-it1-merge2.log`), lint 13/13.
- 19:43 `--bot=boss --boss=servo` through king's BossHook in the dev arena (headless, 30 s):
  "servo engaged in depot, phase 1", 0 SCRIPT ERROR (`evidence/servo/boss-servo-bot-it1.log`).
  NOT YET: the arena draws neither ServoRig nor the drones/rings (only the dev view does). That is
  NEXT item 0: a Servo view attacher in `features/bosses/servo/` that BossHook's view calls for a
  boss with a rig (ask king for the generic hook if there is none: REQUEST 3).

NEXT (revised, iteration 2): 0. draw ServoRig + the swarm/rings/crates in the arena path
(`--boss=servo`), filmed at 32 px/m with the real Rivet; then items 1-5 above (item 1, the
REQUEST 2 merge, is done).

### REQUEST 3 to n7-king (19:44)
1. `project/tests/unit/test_boss_adds.gd.uid` is not committed on n7-king (Godot generates it on
   import; AGENTS rule 8). I left mine untracked so we do not both add it; please commit yours.
2. A generic view hook for a boss's own body: BossHook's view draws the default boss shape; Servo
   needs `features/bosses/servo/servo_rig.gd` (a Node2D: `fight`, `rack`, `pose(tick)`) plus his
   swarm overlay. Proposal: an optional `view` script path in the boss row (like `script`), a Node2D
   the hook adds to the arena and calls `pose(tick)` on each sim tick. Servo-only drawing stays in
   his folder.

## Iteration 2 (19:45-20:45), BUILD
(FRICTION 20:31: these entries were lost once, when I ran `git checkout --ours JOURNAL.md` after a
merge that had refused to start because JOURNAL had uncommitted edits; re-written from the session.
Rule from now on: commit JOURNAL before any merge.)
- 19:47 MERGE n7-king 48c80e83 into n7-servo as 7fe50de9 (king committed test_boss_adds.gd.uid:
  REQUEST 3.1 answered; fight clamped to the floor; claw cops off the boss floor). JOURNAL: ours.
  REQUEST 3.2 needs nothing from king: `BossView.make` already loads
  `features/bosses/<id>/<id>_body_view.gd` (my miss).
- 19:52 MILESTONE 119e98db: **Servo in the live arena path** (`--boss=servo`, the dev arena with
  `--rigs`). `ServoBodyView` lays three layers on the actors' layer: ground (drop rings, blasts,
  CS crates, Servo's own tells), ServoRig, air (drones over shadows). The swarm drawing moved from
  dev/ to `features/bosses/servo/servo_draw.gd` (dev is excluded from exports). Looked at two
  32 px/m stills with the real Rivet rig and the HUD bar ("SERVO", 1/3): Servo reads as the biggest
  thing on the floor; the dashed rings read; drones too small (22 px): drawn 1.4x.
  `servo.json drone.ring_from_launch` (owner call 1) is now one data value (default true).
- 20:05 drones as arena bodies: `ServoDroneBodies` (one brain-owned Fighter per live drone on its
  shadow; a body knocked to 0 hp calls `ServoSwarm.kill`, the carried parcel falls where it is).
  Every weapon, the claw and the four ghosts hit drones through the arena's own code.
- 20:02 FRICTION: the dev arena ignored `--seed` (always MASTER_SEED): `arena_game.gd` now reads it.
- 20:03 MEASURED, a unit error FOUND: Servo's hp 4200 was in weapons.json's scale; the arena's
  rounds do 1 damage (combat.json: humans 1 hp, King 120; Rivet 100 hp, repairs 10/s after 3 s).
  Set hp 220; drone hp 1 (100 first: the bot shot 0 drones in 240 s).
- Registry rules applied (`combat-pacing-and-dramatic-arc`, `encounter-balance-simulation`): a
  distribution over seeds, never one run; unmeasured is not zero (late hits were credited to the
  running attack, so Servo counts his own: `boss_fight.moves`); a boss wants a long build and a
  late climax (~2-3 min; Act 2 longer than King's 92 s).
- 567ef26b generic hooks (REQUEST 4 below); 69c16b07 drones as bodies + kamikaze dive (ServoDive,
  unit `test_servo_dive` 3/3) + Servo's hazards for the bot + telemetry + hp 220 + bay-hop lock
  0.75 s. DECISIONS servo-drone-hp / servo-kamikaze / servo-bay-hop-lock: `docs/decisions.md`.
- 20:10 MEASURED (tree 69c16b07, `--bot=boss --boss=servo --rigs`, dev arena pit, 240 s cap):

  | bot | seed | Servo down at | Rivet took | deaths | drones up / shot | parcel hits | dives / hits |
  |---|---|---|---|---|---|---|---|
  | dodge | 1 | 136.9 s | 60 | 0 | 65 / 57 | 0 | 6 / 0 |
  | dodge | 2 | 109.8 s | 110 | 0 | 45 / 33 | 0 | 4 / 0 |
  | dodge | 3 | 140.6 s | 180 | 0 | 51 / 35 | 0 | 4 / 0 |
  | stand | 1 | alive 25 % | 970 | 1 | 91 / 86 | 17 | 24 / 2 |
  | stand | 2 | alive 30 % | 1574 | 7 | 145 / 118 | 48 | 4 / 1 |
  | stand | 3 | alive 78 % | 1372 | 6 | 78 / 76 | 31 | 0 / 0 |

  Dodging bot: rotor dash 8 of 26 landed (31 %), hot dash 3 of 9, bay hop 1 of 6. Standing: dash
  42 of 45, hot dash 13 of 14, bay hop 5 of 5. The fight separates a reader from a stander (0 vs
  1-7 deaths). Weak: the bot's perfect aim downs 70-88 % of drones, so waves rarely land; a human
  will not aim like that. NOT measured yet: a bot with human aim error; the depot arena itself.
- 20:13 MILESTONE 6eceae5f: the CS depot dressing (first pass, render only): four roller-door bays
  on the north edge, the conveyor on the south edge (belt and CS cartons move from phase 2).
- 20:16 FILM `M/servo_fight_bot_dodge_32ppm_it2.mp4` (113 s, 32 px/m, seed 2, tree 69c16b07) +
  contact sheet + stills; `M/frames.json` 15 entries. **Looked at it**: all three phases and the
  defeat play in the live arena; a carpet leaves a readable lane of CS crates; Servo vents from both
  pads in the punish window; phase 3 has one wing; the bot steps out of the hot dash. FOUND: drop
  rings too thin at 32 px/m -> FIXED 49ec99f2 (widths x px/32), looked at
  `M/servo_ring_weight_conveyor_32ppm_it2.png`. NOT fixed: king's dash-lane tell runs past the wall
  where the body is clamped; the defeat is only a grey body; crates do not block Rivet; drones small.
- 20:30 GATES on 49ec99f2: lint 13/13; unit exit 0 (`evidence/servo/unit-it2.log`); scenarios 52
  ran / 0 failed (`scenarios-it2.log`); director reel `--bot=reel --reel=director --loadout=pistol`
  headless: 19 chapters, every one fully down, 0 SCRIPT ERROR (`director-reel-it2.log`; the reel
  idles after the last chapter and my gate script's 10-min limit stopped it there).
- 20:33 MERGE n7-king 745ce3cf as c37ea648 (KingRigs, idle_step detour, boulevard, body classes).
  Conflict: boss_moves.gd (kept both), JOURNAL (ours). ServoMoves.write_state now calls super.
  test_boss_* 18/18, test_servo_* 14/14, lint 13/13.

### REQUEST 4 to n7-king (20:10): three generic BossMoves hooks I added on my branch (567ef26b)
Please take them verbatim at your next merge of n7-servo, or tell me your shape:
1. `bodies() -> Array[Fighter]` (default `[]`): extra hittable bodies the script owns;
   `BossHook._sync_bodies()` (right after `fight.step`) keeps exactly these in `_arena.hostiles`.
2. `threat_away(at, r) -> Vector2` (default zero): the way out of the script's own late hazards
   (only what a player can see by now); `BossBot.sample` checks it after the adds' dodge, and
   `BossBot._target` shoots a `bodies()` body inside ADD_M before the boss.
3. `telemetry() -> Dictionary` (default `{}`), under `boss_fight.moves` in BossHook.telemetry.
Also seen in the film: BossTellView draws a CHARGE lane its full range_m past the floor's edge,
where `_keep_in` stops the body; clip the lane to `bounds`?

Calls for the owner (for REPORT): 1. drop rings from launch (default) vs only at hover
(`servo.json drone.ring_from_launch`); 2. should a CS crate landing on Rivet hurt (today no);
3. drones at 1 hp (one round, default) vs tougher drones so waves land more often.

NEXT (iteration 3, in order):
1. Defeat beat: the rack spills its drones, pads spin down, Servo kneels/collapses with steam and
   the stinger (`boss_stinger_01.wav`); phase transitions with a beat (horn + belt start; wing
   blow-off sparks). Boss music `boss_loop_01.ogg` under --boss (check whether king wired it).
2. Crates block Rivet and shots (ServoParcels.blocked into the arena's movement/shot blocking,
   through a generic hook if needed); the conveyor carries crates and Rivet in phase 2 (sim).
3. A bot with human aim error (spread) so waves land at a human rate; per-attack hit rates again
   over seeds 1-5; Kerf / Ohm / Dent / Tonnage on the drones checked in a clip.
4. Proof clips: per attack 48 px/m (scan wave, dash, carpet, bay hop, kamikaze), per phase 32 px/m
   real time (`--phase=N`), the full drone wave at 48 px/m, target sheet beside in-game (hstack).
5. Body to target (iteration-1 NEXT 2): rack wings 3 rows, body between the wings, bigger pads.
6. Bay hop to the nearest loading bay (the depot's bays), not the mark.
- 20:37 MEASURED on the merged tree (c37ea648 + logs), seeds 1-3, 240 s cap: dodging bot downs
  Servo at 136.9 / 109.9 / 119.3 s, Rivet took 60 / 110 / 120, 0 deaths (seed 3 moved: 140.6 ->
  119.3 s, king's idle detour). Standing bot: seed 1 downs him at 158.6 s with 3 deaths; seed 2
  leaves 16 % with 2 deaths; seed 3 stays in phase 1 at 78 % with 6 deaths (rotor dash 23 of 25
  landed: the standing bot holds its band right in the dash lane; a stander should lose, but look
  at why seed 3 never gets the phase-1 punish damage in: iteration 3).

## Iteration 3 (20:38-21:38), BUILD
- 20:40 MERGE n7-king d86e36fe as 6c347500 (king took REQUEST 4 verbatim; GangPlan, KingAccents,
  throne-car trim; no framework file moved beyond REQUEST 4). JOURNAL: ours (committed first).
  Lint 13/13 on the merge. Music: `boss_engaged` -> AudioHooks already plays boss_stinger +
  boss_loop, but BossHook does not emit it yet; king's iteration-3 item 3 owns it (framework), so
  I leave it to them.
- 20:50 MILESTONE 454099d4 **the defeat beat**. Sim: the fight stops ticking the moves once the
  boss is DEFEATED, so live drones froze in the air and stayed hittable bodies (a defect, found
  reading `BossFight.step`). ServoMoves now connects `defeated` in bind and grounds the swarm at
  once (`ServoSwarm.ground`: flying drones crash, a carried crate lands, bombs are duds, falling
  bombs are duds; the bodies leave the hostiles on the next sync). Render (`ServoFall`): flash +
  spark burst, pads spin down and sag, slump with a settling bounce, grey over 1.5 s, head droops,
  docked drones spill, crashed drones fall onto their shadows with a dust ring, the rack smokes.
  Unit `test_servo_fall` 2/2; unit 1144/0 (`evidence/servo/unit-it3.log`).
- 20:47 FOUND in the first defeat film: **the rig hid the wrong wing in phase 3.** ServoRack uses
  side = (-fwd.y, fwd.x), the rig fwd.orthogonal() = (fwd.y, -fwd.x): break_wing's cells
  (across < 0) are the rig's side +1, but the rig dropped side -1, so phase 3 showed the sim's
  broken wing and the dark "drone out" bays fell on the missing side. Fixed in 454099d4; the
  re-film shows the bays and spills on the wing that is drawn. Looked at
  `M/servo_defeat_beat_keys_32ppm_it3.png` (38.4-47 s of `servo_p3_overtime_defeat_32ppm_it3.mp4`,
  `--phase=3 --seed=2`, Servo down at tick 2299 both before and after the render fix: the render
  does not touch the sim). Weak: the bay marks + smoke + wrecks clump into one dark blob left of
  him; the slump is subtle at 32 px/m.
- FRICTION 20:55: `run_unit.mjs` without `GODOT_BIN` reports "1138 passed" from a stale result
  file while every step exits -1. Always export GODOT_BIN; read the step exits, not the summary.
- 20:58 the transition beats (`ServoShift`, render only): rush hour = rise 8 % on revving pads +
  the rack reloads in a ripple; overtime = the failing wing shakes and sparks through the 2 s,
  blows off in six debris pieces + a ring on the phase's first tick, the socket smokes after.
  docs/bosses/servo.md section 4 "As built" paragraph.
- 21:00 FILM `M/servo_fight_bot_dodge_32ppm_it3.mp4` (tree 2507cc33, seed 2, 32 px/m): Servo down
  at tick 6591 (109.8 s), the same tick as iteration 2 (the beats are render only). Phase 2 at
  ~34 s, phase 3 at ~85 s (read off the HUD's phase counter, tiled once a second). **Looked at**
  `M/servo_transitions_keys_32ppm_it3.png`: the reload ripple runs across the bays into rush
  hour; into overtime the sparks sit on the wing that then blows off (ring + debris), the other
  wing stays: matches the sim's broken cells now.
- 21:01 MILESTONE b5d8fc43 **crates are solid** (generic `BossMoves.solids()`, REQUEST 5 below;
  `servo.json parcels.crates_solid`, default true). Unit `test_servo_crates` 3/3.
- 21:01 MEASURED (tree b5d8fc43, `--bot=boss --boss=servo --rigs`, 240 s cap,
  `evidence/servo/bots-it3/`):

  | bot | seed | Servo down at | Rivet took | deaths | drones up / shot | parcel hits | dives / hits |
  |---|---|---|---|---|---|---|---|
  | dodge | 1 | 134.2 s | 80 | 0 | 62 / 46 | 0 | 6 / 0 |
  | dodge | 2 | 205.3 s | 240 | 0 | 115 / 77 | 5 | 4 / 0 |
  | dodge | 3 | 142.8 s | 280 | 0 | 51 / 33 | 0 | 4 / 0 |
  | stand | 1 | 163.9 s | 522 | 0 | 62 / 57 | 12 | 6 / 1 |
  | stand | 2 | alive | 1524 | 8 | 139 / 112 | 52 | 0 / 0 |
  | stand | 3 | alive | 1376 | 5 | 110 / 91 | 39 | 2 / 1 |

  Dodging, per attack landed/tried over seeds 1-3: rotor dash 9/27 (33 %), hot dash 4/8, bay hop
  5/10, carpet 0/13 direct (its parcels count under `servo`: 5 hits on seed 2). Standing: dash
  27/44, bay hop 11/11, parcels 104 hits. Crates made the fight longer (dodge mean 161 s, was
  122 s) and stand-s1 now wins (crates shield a stander from the rotor dash's line? not checked).
  The bot never seeks a line of sight round a crate; a player would. NOT measured: human aim.
- FRICTION 21:02: `--telemetry=<relative path>` resolves against `project/`, not the cwd: the
  sweep's JSONs landed in `project/evidence/`; moved, and the stray folder deleted. Use absolute
  paths.

### REQUEST 5 to n7-king (21:05): one more generic BossMoves hook, on my branch in b5d8fc43
`solids() -> Array[Rect2]` (default `[]`): solid boxes the boss script owns this tick; BossHook
`_sync_solids(stage.walls)` (right after `_sync_bodies`) keeps exactly these in the stage's
ArenaWalls (erase last tick's, append this tick's), so they push Rivet / adds / boss out and stop
shots both ways like the arena's cover. Servo returns his landed crates. Please take it verbatim
(boss_moves.gd +7, boss_hook.gd +11), or tell me your shape. Also an ask: BossBot could strafe
when `stage.walls.blocks(me, boss)` (no line of sight); a player would, and my crates make the
straight-line bot slow (seed 2: 205 s). And: BossHook does not emit `boss_engaged` yet, so the
boss loop/stinger in AudioHooks never start under `--boss` (your item 3; Servo needs nothing
special).
