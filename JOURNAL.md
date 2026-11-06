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
  27/44, bay hop 11/11, parcels 103 hits (12 + 52 + 39). Crates made the fight longer (dodge mean 161 s, was
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
- 21:06 FILM `M/servo_drone_wave_scan_drop_dodge_48ppm_it3.mp4` (the brief's full-wave clip on
  the real rigs, replacing the graybox one): `--ppm=48 --seed=2`, 4.5-11.5 s. **Looked at** the
  keys (`M/servo_drone_wave_keys_48ppm_it3.png`): the beam sweeps and locks on Rivet, three dashed
  rings on the marked spot, the bot steps off after the lock, one bomb blasts inside its ring, two
  CS crates land beside him. The wave reads at 48 px/m.
- 21:09 FIX b588d8b1 the defeat blob (first-pass weakness above): lighter empty bays, one thinner
  plume, deeper slump. Re-filmed (`--phase=3 --seed=2`, crates solid now: down at tick 1723) and
  **looked at** `M/servo_defeat_beat_keys_32ppm_it3.png`: the spilled drones fan out as separate
  wrecks round a slumped grey body; reads as "down" at 32 px/m.
- 21:09 GATES (tree b5d8fc43 + render-only b588d8b1): lint 13/13; unit 1146/1, the one failure
  `test_noir_shadows` (the known flake), 2/2 re-run alone (`unit-it3b-noir-rerun.log`); scenarios
  52 ran / 1 failed: `scenario_rig_stress` 50 people rig p50 1.105 ms > 1.0 ms, CONTENDED (my GPU
  film and the gate ran together); re-run alone below.
- 21:12 director reel on b5d8fc43 (`--bot=reel --reel=director --loadout=pistol`, headless):
  19 chapters, every one fully down, 0 SCRIPT ERROR (`evidence/servo/director-reel-it3.log`).
  Combat did not regress (the boss hooks are live only under --boss).

Calls for the owner (for REPORT; 1-3 from iteration 2 stand):
4. CS crates solid (default: block bodies and shots both ways, 12 s) vs paint only:
   `servo.json parcels.crates_solid`. See `RTAI.exe -- --boss=servo` (dev arena) or the clip
   `M/servo_drone_wave_scan_drop_dodge_48ppm_it3.mp4`. Solid made the dodging bot's fight
   longer (mean 161 s vs 122 s) because the bot never walks round for a line of sight.

NEXT (iteration 4, in order):
1. Merge n7-king when REQUEST 5 lands (or keep mine) and when BossHook emits `boss_engaged`
   (music + stinger); check the stinger plays on Servo's engage and the loop stops at the defeat.
2. Shots chip crates (crate_hp): needs the stage to tell whose box stopped a shot (a generic
   `BossMoves.shot_blocked(box)`?) or Servo-side via ArenaWalls index; then the dodging bot's
   time should drop back toward 120-160 s. A line-of-sight bot (REQUEST 5 ask) for fair numbers.
3. A bot with human aim error so waves land at a human rate; per-attack hit rates over seeds 1-5.
4. Proof clips still missing: per attack at 48 px/m (dash, carpet, bay hop, kamikaze), phase 1 and
   phase 2 at 32 px/m real time (`--phase=N`), the target sheet beside the in-game boss with the
   it3 rig (hstack), the ghosts on the drones (Ohm's chain through a swarm, Kerf's blink line,
   Dent seizing a drone).
5. Body to target: rack wings 3 rows, bigger pads; the defeat's visor flicker; the horn and the
   bay doors rolling up at rush hour.
6. Windows export `build/export/windows/RTAI.exe` (by 08:30, the int-day recipe).
- 21:12 MERGE n7-king 0965780d as e73d8032 (BossMusic: every boss's stinger + loop from
  BossView.attach, so Servo has his music with no Servo code; --boss-cam; leap_m, unused by
  Servo; KingBeats). JOURNAL ours. Unit on the merged tree 1156/0 (`unit-it3c.log`). Servo seed 1
  dodging on the merged tree: down at 134.2 s, Rivet took 80, 0 SCRIPT ERROR: identical to before
  the merge (`bots-it3/merged-dodge-s1.*`). NEXT 1's music half is done.
- 21:19 GATES on the merged tree (8c14a186): scenarios 52 ran / 0 failed, run alone
  (`scenarios-it3b.log`): the earlier `scenario_rig_stress` 1.105 ms was contention, as logged.
  Director reel (b5d8fc43, before the merge; the merge touched no combat code): 19/19 chapters
  down, 0 SCRIPT ERROR; exit 124 is the gate script's 600 s limit after the last chapter (the reel
  idles there). Lint 13/13, unit 1156/0.
- 21:24 FILMS on the merged tree with n7-king's `--boss-cam` (both in frame), 32 px/m real time,
  0 SCRIPT ERROR each: `M/servo_p1_depot_bosscam_32ppm_it3.mp4` (seed 3, 40 s) and
  `M/servo_p2_rush_hour_bosscam_32ppm_it3.mp4` (`--phase=2`, seed 2, 45 s) + keys. **Looked at**
  the keys: phase 1 = beam lock, ring waves on the mark, dash lanes, crates; phase 2 = carpets of
  rings in lanes, crates building up, the belt running. Seen again: the framework's dash lane is
  drawn past the floor's edge (REQUEST 4's note, still open for king). With the phase-3 film,
  every phase now has a 32 px/m real-time clip; `M/frames.json` 15 entries, superseded files
  deleted, scratch emptied.

NEXT (iteration 4) stands as written above, minus the phase 1 / phase 2 clips and the music
(done). Session ends 21:25 with everything committed.

## Iteration 4 (21:25-22:25), BUILD

- 21:27 MERGE n7-king 7bbeeba6 as 2d472754 (Ohm's daze on bosses, decree buff_adds, ermine
  collar, boss-cam range, the stalled car holds). Conflict: boss_hook.gd (kept my `_solids`
  beside king's `_stun_seen`), JOURNAL (ours). REQUEST 5 (solids) is still not on n7-king: my
  copy stays. Unit on the merged tree 1159/0 (`evidence/servo/unit-it4a.log`).
- 21:28 ServoMoves telemetry now lists every windup as "tick:attack" (`moves.windups`, telemetry
  only, no state, no golden), so the per-attack films are cut on real ticks.
- 21:29 FILMS 48 px/m, boss cam, seed 2, phases 1-3 (2400 ticks each, 0 SCRIPT ERROR;
  `evidence/servo/films-it4/`). Cut per attack into `M/servo_attack_<id>_48ppm_it4.mp4` + keys.
  **Looked at** every key sheet:
  - rotor dash (p1 t620): thin tracking line, vermilion lane locks, bot steps out, Servo crosses
    to the lane's tip and skids. (I first read the lane as flipping after the dash; it is the boss
    cam moving: he stands at the lane's tip, and the lane stays frozen at the lock.)
  - package carpet (p2 t1181): a lane of rings through the mark, the bot steps out, bombs/crates.
  - bay hop (p2 t671): the landing ring locks on Rivet; crates from the last carpet box him in and
    it lands on him (a hit, not a dodge).
  - hot dash (p3 t956): lane, clean dodge, dash to the bay wall on one wing.
  - kamikaze (p3 t314): beam lock, two dive drones launch; the bot downs both before a strike
    locks, so no dive ring is in this clip. FOUND, not fixed: the perfect-aim bot hides the dive.
- 21:35 MILESTONE 135528a5 dev `--bot=boss --ghost=<dent|kerf|ohm>` (`dev/servo/servo_ghost_bot.gd`):
  BossBot picks the ghost (G presses), takes it (Q), then aims the ghost attack at the thickest
  knot (>= 2) of the boss's extra bodies within 10 m, holding the gun while a knot is in reach;
  once the form runs out (about 6 s in the fight) it is the plain boss bot. FRICTION: a new
  class_name needs `--import` before a windowed run (the first ghost films were script errors and
  were thrown away).
- 21:43 FILMS the ghosts on the drones (48 px/m, p2, seed 2). **Looked at** dense keys:
  - Ohm: the bolt chains through a knot of four drones (a strike burst on each), a second chain on
    the next knot, then bolts into Servo. 12 of 15 drones down in 25 s. `M/servo_ghost_ohm_chain_drones_48ppm_it4.mp4`.
  - Kerf: blinks through Servo and cuts him; the knots the bot chose sat beside the hub, so a line
    of drones being cut is NOT shown. `M/servo_ghost_kerf_blink_drones_48ppm_it4.mp4`.
  - Dent seizing a drone: NOT built (drones are arena Fighters, not vehicles); servo.md promised
    it. Open.
- 21:45 TARGET comparison in the live arena (`M/frames/servo_target_vs_arena_48_32ppm_it4.png`,
  p2 tick 359, turned 180 degrees like the sheet; 48 and 32 px/m). **Looked at**: same family
  (two drone-bay wings, hub, striped octagon pads, cream-and-rust print). Gap: the sheet's wings are
  3 rows deep and dominate the silhouette; ours are 2 rows (the wing is one cut texture of 2x3 bays,
  and `rack.cells` 12 sets the launch capacity, so 3 rows is a sim + art change that moves the bot
  numbers: next).
- 21:48 `M/frames.json` 15 entries (the it4 attack and ghost clips, the arena comparison first);
  removed the 64 px/m dev-scene rig film and the it2 phase-3 still.
- 21:50 GATES on the merged tree (135528a5, before the rack): scenarios 52 ran / 0 failed
  (`evidence/servo/scenarios-it4.log`); director reel `--bot=reel --reel=director
  --loadout=pistol`: 19/19 chapters fully down, 0 SCRIPT ERROR (`director-reel-it4.log`; exit 124
  = the 600 s limit after the last chapter, as before). Combat did not regress with king's daze.
- 21:51 MILESTONE b3e12695 **the rack is 3 rows deep** like the target's wings (`servo.json
  rack.rows` 3, `cells` 18; ServoRack.rows()/cols(); ServoRig._extra_rows repeats the wing art's
  back row one row further back: the art is 2 rows = 141 px at 96 px/m = 2 x 0.73 m = row_dy_m,
  so the bays sit on the sim's cells). Phase 3 breaks 9 cells (half of every row). **Looked at**
  `M/frames/servo_target_vs_arena_rack3_ab_48ppm_it4.png` (sheet | 2 rows | 3 rows): the rack now
  carries the sheet's mass over the hub; a faint seam where the back row repeats. test_servo 20/20.
  DECISION in docs/decisions.md; rows 2 / cells 12 = the it3 rack.
- 21:52 MEASURED (b3e12695, seeds 1-3, 240 s cap, `evidence/servo/bots-it4/`):

  | bot | seed | result | Rivet took | deaths | rotor dash landed/tried |
  |---|---|---|---|---|---|
  | dodge | 1 | down 176.7 s | 238 | 0 | 4/10 (hot 2/5) |
  | dodge | 2 | down 119.8 s | 150 | 0 | 4/8 (hot 1/3) |
  | dodge | 3 | down 143.2 s | 230 | 0 | 7/10 (hot 0/3) |
  | stand | 1 | alive 28 % | 1084 | 3 | 8/14 |
  | stand | 2 | alive 43 % | 1234 | 6 | 9/17 |
  | stand | 3 | alive 72 % | 1282 | 5 | 20/25 |

  Every stander now loses (seed 1 used to win: the envelope wants that). But the dodging bot's
  rotor dash landed 15/28 (54 %; it3 33 %; target <= 25 %). Paint-only crates (same tree,
  `paint-dodge-s*`): dash 9/25 (36 %), down at 148 / 123 / 111 s, Rivet took 120 / 90 / 200. So
  the solid crates pin the bot's sidestep (it never rolls over or walks round a crate). Not fair
  yet for a crate-blind dodger; a player rolls. Open: the dash lock vs crates (NEXT 1).
- 21:55 FOUND + FIXED 1e266efb: `crates_solid = false` (owner call 4's alternative) was a SCRIPT
  ERROR every tick: `ServoMoves.solids()` returned an untyped `[]` from a ternary into BossHook's
  `Array[Rect2]`. Typed now; test_servo_crates checks the array type (fails on the old code,
  passes on the fix). The first paint-only sweep ran with the error and was re-run clean (same
  numbers, 0 SCRIPT ERROR).
- 21:57 `M/frames.json` entry 1 = the rack before/after beside the sheet; unreferenced 64 px/m
  dev renders and the scratch films deleted.

Calls for the owner (for REPORT; 1-4 stand):
5. Rack depth: 3 rows / 18 cells (default, the sheet's mass) vs 2 rows / 12 (it3):
   `servo.json rack.rows` + `cells`. See `M/frames/servo_target_vs_arena_rack3_ab_48ppm_it4.png`
   or `RTAI.exe -- --boss=servo --phase=2`.
4 (update): paint-only crates now work; with the 3-row rack they halve the dodging bot's dash hits
   (36 % vs 54 %).

NEXT (iteration 5, in order):
1. Fairness of the rotor dash with solid crates: the bot (and a player) gets boxed in. Options:
   the dash smashes crates in its lane (servo.md already says so: build it: ServoParcels clears
   crates the dash body crosses), and/or BossBot rolls when its sidestep is blocked
   (`stage.walls.push_out`). Re-measure dodging dash <= 25-35 %.
2. Kamikaze dive on film: a seed/phase where a dive locks before the bot shoots it (or film with
   `--ghost=ohm` holding fire), 48 px/m.
3. Kerf's blink cutting a line of drones on film (aim the blink along a carpet line); Dent seizing
   a drone is NOT built (drones are Fighters, not vehicles): build or drop it from servo.md.
4. Human-aim bot (aim error) so waves land at a human rate; per-attack rates over seeds 1-5.
5. The rack seam (a 3-row wing part sheet under the image lock), bigger pads; horn + bay doors
   rolling up at rush hour; the defeat's visor flicker.
6. Windows export `build/export/windows/RTAI.exe` (by 08:30) and REPORT.md.
- 22:04 MILESTONE 15346f87 **the rotor dash smashes the crates in its lane** (servo.md promised
  it): `ServoParcels.smash`, 2 ticks ahead of the body so a crate never stops him;
  `servo.json parcels.dash_smash` (default true, false = a crate stops him like a wall).
  MEASURED (seeds 1-3, `evidence/servo/bots-it4s/`, 0 SCRIPT ERROR): dodging dash 12/26 (46 %; 54 %
  without), hot dash 1/12, bay hop 1/10, 0 deaths, Rivet took 78 / 280 / 180, down at
  163 / 171 / 169 s (over the 150 s envelope). Standers die 3-6 times (s1 downs him at 202 s after
  3 deaths). The flag build reproduces the sweep exactly (seed 1: tick 9773, 78 dmg, 21 smashed).
  Still above the dodging target: not called fair. DECISION in docs/decisions.md.
- 22:07 **Looked at** `evidence/servo/shots/dash_smash_keys_48ppm_it4.png` (p2 seed 2, the dash
  at tick 1679, 6 fps): a CS crate sits in the locked lane, Servo crosses, the crate is gone;
  Rivet stepped out of the lane. FOUND: the crate vanishes with no debris (render-only fix next).
- 22:08 GATES on 15346f87: lint 13/13; unit 1161/0 (`unit-it4c.log`). Scenarios (52/0) and the
  director reel (19/19) last ran on 135528a5; everything since is Servo-only (live only under
  --boss).

Call 6 for the owner (for REPORT): the dash smashes crates (default) vs crates stop him:
`servo.json parcels.dash_smash`; `RTAI.exe -- --boss=servo --phase=2`.

NEXT (iteration 5, in order; replaces the list above):
1. Smash read: a crate the dash smashes bursts into CS cardboard debris + dust (render only, in
   ServoBodyView from a smashed list); film it at 48 px/m.
2. Dash fairness: BossBot rolls when its sidestep is blocked by a wall/crate (a generic ask to
   n7-king, or Servo-side through threat_away); re-measure the dodging dash toward <= 25-35 % and
   the fight toward <= 150 s (phase hp or the carpet cadence if still long).
3. Kamikaze dive on film (a lock before the bot shoots the drone), 48 px/m.
4. Kerf's blink through a line of drones on film; Dent seizing a drone is NOT built: build or drop
   it from servo.md.
5. Human-aim bot and per-attack rates over seeds 1-5.
6. The rack seam (a 3-row wing part sheet under the image lock), bigger pads, horn + bay doors.
7. Windows export `build/export/windows/RTAI.exe` by 08:30 and REPORT.md (calls 1-6).
- 22:12 MILESTONE a431aa8d NEXT 1 done: a smashed crate bursts into six cardboard shards over a
  dust puff for 0.5 s (ServoParcels.debris, render only, not in write_state). **Looked at**
  `evidence/servo/shots/dash_smash_debris_keys_48ppm_it4.png` (p2 seed 2, ticks ~1725-1755): the
  CS crate in the lane becomes a pale puff with shards beside the pad; it reads, small at 48 px/m.
  test_servo 21/21, 0 SCRIPT ERROR in the film.

NEXT (iteration 5): items 2-7 of the 22:08 list (item 1 is done). Start with 2 (BossBot rolls
when its sidestep is blocked; re-measure the dodging dash and the fight length), and re-run
scenarios + the director reel on the head first.
- 22:14 GATES: scenarios 52 ran / 0 failed, 0 SCRIPT ERROR (`evidence/servo/scenarios-it4b.log`), started on 15346f87 (the dash smash; the render-only debris landed while it ran). Lint 13/13 and unit 1161/0 on 15346f87. Session ends with everything committed.

## Iteration 5 (22:15-23:15), BUILD

Read: JOURNAL NEXT, git log, n7-king's JOURNAL (FYI 22:07: REQUEST 5 done, --bot-human, --ghost,
stuns/dazes). Registry rules applied: encounter-balance-simulation (three bots as ceiling / human /
floor, the cap is game time not frames, n seeds before a claim), realtime-combat-semantics (a
dodge is judged on the i-frame window meeting the hit, not the tell).
- 22:18 MERGE n7-king 5eb4e47e (3d939696): --bot-human (BossBotRead), --ghost (BossBotGhost),
  BossBot walks round cover, stuns/dazes telemetry, King's wreck cover. boss_hook.gd got a second
  `_solids` declaration from the merge (both sides added it): kept one. JOURNAL ours. Unit 1167/0.
- 22:20 FRICTION: king's `boss_numbers.mjs` caps runs with `--quit-after` frames and no
  `--fixed-fps`: on a contended machine 15000 frames were 6400 ticks, so every Servo fight was cut
  at 107 s. My copy (`evidence/servo/boss_numbers.mjs`) adds `--fixed-fps 60` (one frame = one
  tick, 14400 = 240 s). King's numbers end on the defeat, so theirs were not cut, but they are
  CONTENDED in wall time only.
- 22:28 MILESTONE 66a94020 the boss bot reads a charge on its body. Why the dodging bot ate the
  rotor dash: it rolled at the tell's end, about 22 ticks before a 14 m / 22 m/s dash body
  reached it, so the i-frames (2-14) were spent; and its sidestep walked into crates. Now it rolls
  when the body is 7 ticks away along the lane, and takes the open side when a box is within
  1.8 m. MEASURED (`evidence/servo/numbers-it5/`, seeds 1-3, 0 SCRIPT ERROR):

  | bot | downed | time to kill | Rivet took (mean) | deaths | rotor dash | hot dash | parcels hit |
  |---|---|---|---|---|---|---|---|
  | dodge | 3/3 | 112-122 s (118) | 6.7 | 0 | 0/19 | 0/7 | 0 |
  | human | 3/3 | 115-133 s (126) | 174 | 0 | 13/23 | 3/11 | 0-1 |
  | stand | 1/3 | 202 s | 1329 | 14 | 44/51 | 3/3 | 29-47 |

  The fight is now inside the 60-150 s envelope for both reading bots; every stander loses. The
  dodging bot is the ceiling (King's dodge took 4.8). The human bot's dash rate (57 %) includes
  the 30 % of tells it never reads by design; a judgement call for the windup (0.9 s), not called
  fair yet. Sweep note: the seed-2/3 jobs ran on the tree with the parked van (below); a van
  nobody seizes changes nothing (seed 1, 40 s: same hp 0.807, same damage, checked).
- 22:30 MILESTONE e55ef095 the depot's **delivery van** (servo.md promised Dent a vehicle):
  generic `bosses.json arenas.<id>.parked` (kind, at, head, art), parked by BossHook on its first
  step (FOUND: at setup the stage's car service is not attached yet, the first try parked
  nothing). The van backs into bay 3 (vehicle_handling `van`, traffic atlas cell 4).
- 22:33 FOUND: `--ghost` was read twice after the merge (king's BossBotGhost inside BossBot and my
  ServoGhostBot wrapper): both would press the ghost picks. Mine is now `--servo-ghost=<id>`.
- 22:34 MILESTONE 692e6ba5 dev `--servo-ghost=dent` (ServoDentBot): seize the nearest parked car,
  steer it into Servo, blow it within 3 m. Seed 1: seized at tick 121, strikes 3 at 176-181
  (Servo and two drones), blows at 337 (full heat, off the top of the yard: the car overshoots
  Servo because Dent steers to a point 14 m along the aim; the bot cannot set the cursor reach).
- 22:35 **Looked at** the film (48 px/m, boss cam): the teal tether to the van at bay 3, the van
  swings down into Servo's rack, Servo rocks. FOUND + FIXED 42d04f84: the two drones the van
  killed took the *human* `dent_car_hit` signature kill: a red spray fan and drag smears off
  Servo's rack (red is blood only). `KillEvent.human` was `kind != BOSS`, and drones are GUARD
  bodies. Now `Fighter.machine` (drones set it) makes the kill a robot's. Re-filmed: no red, same
  ticks. `M/servo_ghost_dent_van_48ppm_it5.mp4`, `M/frames/servo_dent_van_drone_kill_ab_48ppm_it5.png`
  (before | after). Unit 1167/0 (`unit-it5b.log`).

### FYI to king (22:38): framework changes on n7-servo (the Director merges both)
- `BossBot`: a CHARGE is rolled on the body (`CHARGE_ROLL_TICKS` 7 before contact) and the
  sidestep switches side when a solid box is within 1.8 m (`_roll_now`, end of `_dodge`). King's
  ram is a charge: your dodging numbers will move on the merged tree.
- `bosses.json arenas.<id>.parked` + `BossSpec.Parked` + `BossHook._park` (first step): park cars
  for Dent in King's boulevard if you want Dent's cars (your NEXT 2).
- `Fighter.machine` + `KillEvent.human` (combat): a non-boss robot gets no human kill.
- `boss_numbers.mjs`: add `--fixed-fps 60` before `--quit-after`, or a contended run is cut short.
- 22:40 GATES on ae0fefe2 (the bot's charge read, the van, Fighter.machine): scenarios 52 ran /
  0 failed, 0 SCRIPT ERROR (`evidence/servo/scenarios-it5.log`); director reel `--bot=reel
  --reel=director --loadout=pistol --rigs`: 19/19 chapters fully down, 0 SCRIPT ERROR
  (`director-reel-it5.log`, exit 124 = the 600 s cap after the last chapter). Combat did not
  regress with `KillEvent.human` changed.
- 22:42 MILESTONE 63b158f4 the Dent bot puts the cursor on Servo
  (`pack_aim` reach), so the van parks on him and blows there: seed 1 strikes 4, blast at tick
  193 on Servo (was 337 off the yard). **Looked at** (48 px/m keys): dash lane, tether, the van
  into the rack, the amber fireball on Servo, the charred wreck beside him; no red.
  `M/servo_ghost_dent_van_48ppm_it5.mp4` re-cut.
- 22:44 FOUND: the phase-3 kamikaze never lands: `dives` counts launches and every bot shoots the
  two dive drones before a lock. Also FOUND + FIXED: my runner's `arg()` split on every '=', so
  `--extra=--phase=3` became `--phase` (phase 1 ran); now it slices after the first '='.
- 22:47 MILESTONE e564346b kamikaze drones are armoured (`servo.json kamikaze.hp` 3; 1 = before).
  MEASURED `--phase=3`, 60 s, seeds 1-3 (`numbers-it5-p3-hp1/`, `numbers-it5-p3-hp3/`):

  | dive hp | dodge dives landed | human | stand | human phase-3 kill |
  |---|---|---|---|---|
  | 1 | not run | 0/20 | 1/22 | 31-34 s |
  | 3 | 4/30 | 1/20 | 12/22 | 33-37 s |

  Full fights at hp 3 (`numbers-it5b/`, seeds 1-3, 0 SCRIPT ERROR): dodge down 113-122 s (118),
  took 36, dives 2/14; human down 116-131 s (126), took 186, dives 2/14; stand 1/3 downed, 14
  deaths, dives 3/8. The attack now bites a stander and stays dodgeable. DECISION: hp 3 is the
  default; `kamikaze.hp` 1 is the alternative (call 7). Unit 1168/0 (`unit-it5c.log`, +1 test:
  a dive drone's body has the dive hp).
- 22:52 **Looked at** the kamikaze at 48 px/m (p3, seed 1, the standing bot): the dive line
  tracks and locks (thick line + dashed ring on Rivet), the drone dives... and the blast was an
  ink disc for one frame (blasts live one step). FIXED d8e8213e: `ServoParcels.booms` keeps each
  blast 0.45 s, drawn as Dent's car-bomb fireball (amber, cream core, ink rim and shock ring) over
  an ink scorch; render only. Parcel bombs get it too. **Looked at** again: lock, dive, fireball
  read at 48 px/m. `M/servo_attack_kamikaze_dive_lands_48ppm_it5.mp4` (replaces the it4 clip where
  the bot shot the drones), `M/frames/servo_kamikaze_dive_boom_keys_48ppm_it5.png`. frames.json 15
  (the it4 kamikaze clip, the Kerf clip that did not show a cut, the it3 transition and defeat
  stills dropped; the phase-3 defeat clip stays).

Calls for the owner (for REPORT; 1-6 stand):
7. Kamikaze armour: dive drones take 3 rounds (default; the attack lands on a stander 55 %, on the
   human bot 5 %) vs 1 (shot before every dive: the attack never lands): `servo.json kamikaze.hp`.
   See `M/servo_attack_kamikaze_dive_lands_48ppm_it5.mp4` or `RTAI.exe -- --boss=servo --phase=3`.
8. Dent's van: parked from the start (default) vs none (`bosses.json arenas.depot.parked: []`).
   See `M/servo_ghost_dent_van_48ppm_it5.mp4`.

NEXT (iteration 6, in order):
1. Re-run scenarios + the director reel on the head (everything since ae0fefe2 is Servo-only,
   live only under --boss, but check).
2. The human bot's rotor dash rate (13/23, 57 %): judge the 0.9 s windup against the
   human's 18-32 tick lateness; try windup 1.0 s or a wider lane tell; 5 seeds x 3 bots.
3. One full bot fight at 32 px/m on the current tree (the it3 one predates the rack, the smash,
   the van, the armour and the fireball), 60-120 s, with the boss cam; the target comparison
   re-shot at 32 px/m.
4. Kerf's blink cutting a line of drones on film (aim the blink along a carpet line).
5. The rack seam (a 3-row wing part sheet under the image lock), bigger pads, the horn and the
   bay doors rolling up at rush hour, the defeat's visor flicker.
6. Windows export `build/export/windows/RTAI.exe` by 08:30 and REPORT.md (calls 1-8).
- 23:00 decisions.md: kamikaze armour line added.
- 23:02 GATES on the head (63b158f4): scenarios 52 ran / 0 failed, 0 SCRIPT ERROR
  (`evidence/servo/scenarios-it5b.log`). The director reel last ran on ae0fefe2 (19/19); everything
  since is Servo-only or boss telemetry.
- 23:02 FOUND + FIXED 8c6dabd2 (framework, telemetry only): a late hit of the boss script
  (Servo's parcels and dives, King's coins) inside an attack's active window was counted as that
  attack landing (the stander's hot dash read 5 of 3). `BossFight.late_hit`; BossHook credits a
  hit that is only late damage to the boss id. Same damage on phase 3 stand seeds 1-3; seed 3 hot
  dash 3/3 (was 4/3). The it5 rotor dash rates above may hold a few parcel hits (human
  parcel_hits 0-1 per fight, so small); re-run in iteration 6. FYI king: this is in
  boss_fight.gd / boss_hook.gd.
- 23:03 FILM `M/servo_fight_bot_human_32ppm_it5.mp4` (`--bot-human --seed=3 --boss-cam`, 32 px/m,
  116 s, 0 SCRIPT ERROR; down at tick 6930, took 112, 0 deaths, identical to the numbers run).
  **Looked at** the contact sheet (one frame per 6 s): beam lock, waves, crates, the van at bay 3
  reads at 32 px/m, the phase-3 rack, the slump. FOUND: the boss cam often frames the cream
  off-floor ground beside the pit (up to half the frame): clamp the cam to the arena area (next).
  Replaces the it3 dodge full-fight clip in frames.json (15).

NEXT (iteration 6) as above, with: 0. re-run the it5b sweep on the attribution fix (5 seeds x 3
bots) for the REPORT's per-attack table; 3 is done except the target comparison at 32 px/m; add
3b. clamp the boss cam to the arena area bounds (`--boss-cam`, a framework view: ask king or do
it Servo-side).
- 23:08 MEASURED on the head (8c6dabd2, attribution fixed), seeds 1-5 x 3 bots, --fixed-fps 60,
  240 s cap, 0 SCRIPT ERROR (`evidence/servo/numbers-it5c/boss-numbers.json`; CONTENDED wall
  time only, the cap is game time):

  | bot | downed | time to kill | took (mean) | deaths | rotor dash | hot dash | bay hop | dives | parcels |
  |---|---|---|---|---|---|---|---|---|---|
  | dodge | 5/5 | 113-156 s (127) | 70 | 0 | 1/32 | 3/17 | 2/9 | 8/32 | 2 |
  | human | 5/5 | 116-147 s (134) | 160 | 0 | 16/37 (43 %) | 6/18 | 2/11 | 3/28 | 2 |
  | stand | 1/5 | 204 s | 1388 | 25 | 86/95 | 3/3 | 14/14 | 3/8 | 179 |

  The envelope holds for the human bot (60-150 s, 0 deaths, every stander loses); one dodge seed
  runs 156 s. The rotor dash on the human (43 %) is the open fairness question (NEXT 2).
  Session ends with everything committed. NEXT for iteration 6 stands as written above.

## Iteration 6 (23:09 - 00:09)
- 23:12 Read: JOURNAL, git log, king's JOURNAL (FYI 22:56: `ghost_k`, BossBot cover 5ef33a80).
- 23:14 MERGE n7-king 9695947c (ghost_k f468f112, BossBot cover 5ef33a80, KingCarTrim, gang steel,
  coin fan 10). Conflicts: JOURNAL (ours); boss_hook.gd (both: my `_park` on the first step + king's
  `route(fight, _last_hp, _ghost_k(stage))`); boss_bot.gd: both lanes flipped the sidestep away from
  a box. Kept king's generic `_unblock`/`sidestep`/`walled` (BLOCK_M 1.5) and dropped my
  SIDE_LOOK_M 1.8 block in `_dodge`; folded my charge-on-the-body roll (CHARGE_ROLL_TICKS 7) into
  king's `_rolls` (windup: not for a charge; active: the charge's body gap, else walled).
  The dodging/human numbers move with this: re-measured below.
- Boss cam clamp (my NEXT 3b) is king's NEXT 3 (BossCam, framework): left to king, not duplicated.
- 23:22 MILESTONE a1828ea2 merge committed; unit **1171/0** (`evidence/servo/unit-it6.log`), lint 13/13.
- 23:25 MEASURED on the merged tree (king's cover sidestep in the bot), seeds 1-5 x 3 bots,
  --fixed-fps 60, 240 s cap, 0 SCRIPT ERROR (`evidence/servo/numbers-it6a/`; wall time CONTENDED):

  | bot | downed | time to kill | took | deaths | rotor dash | hot dash | bay hop | carpet | scan drop | kamikaze |
  |---|---|---|---|---|---|---|---|---|---|---|
  | dodge | 5/5 | 114-140 s (127) | 62 | 0 | 2/35 | 1/17 | 5/8 | 0/13 | 0/55 | 0/12 |
  | human | 5/5 | 121-138 s (129) | 128 | 0 | 15/38 (39 %) | 5/15 | 0/8 | 0/12 | 0/57 | 0/15 |
  | stand | 1/5 | 204 s | 1388 | 25 | 86/95 | 3/3 | 14/14 | 0/23 | 0/113 | 0/4 |

  (carpet / scan drop / kamikaze are 0 as *attacks*: their damage is the parcels and dives, the
  boss script's late hits, credited to the boss id since 8c6dabd2; see `moves` per run.)
- 23:33 MEASURED NEXT 2, the rotor dash's fairness (encounter-balance-simulation: separate the
  player model from the attack). The human bot ignores 30 % of tells by design (READ_P 0.7), and
  an ignored dash lands. Local experiment (not committed): READ_P 1.0, every tell read but 18-32
  ticks late, human bot, seeds 1-5:

  | rotor_dash aim_lock_s | READ_P | rotor dash landed | hot dash | took |
  |---|---|---|---|---|
  | 0.35 (built) | 0.7 | 15/38 (39 %) | 5/15 | 128 |
  | 0.5 | 0.7 | 12/37 (32 %) | 9/16 | 173 |
  | 0.35 (built) | 1.0 | **2/40 (5 %)** | 2/16 | 63 |
  | 0.5 | 1.0 | 3/39 (8 %) | 3/15 | 91 |

  A late but reading player dodges the 0.9 s windup 95 % of the time; the 39 % is the unread
  tells (30 % x the share of dashes aimed while Rivet stands in the lane). The lock at 0.5 s does
  not help the reader (8 %, within noise). DECISION: the dash windup 0.9 s / lock 0.35 s stays;
  no tuning. Evidence `numbers-it6-lock05/`, `numbers-it6-read1-lock035/`, `numbers-it6-read1-lock05/`.
  Rule applied (encounter-balance-simulation): judge an attack against a reading model, the
  standing floor and the dodging ceiling separately, never one blended rate.
- 23:30 GATES on a1828ea2 (the merge): scenarios 52 ran / 1 failed: `scenario_city_chase` 2 ms nav
  budget (max 3113 us) while my numbers sweeps ran beside it (CONTENDED; the known flake). Re-run
  alone: **1 ran, 0 failed** (`evidence/servo/scenarios-it6.log`, `scenarios-it6-citychase-rerun.log`).
- 23:40 FOUND: servo.md promises "Kerf's blink cuts a line of drones", but Kerf cuts only its one
  target (`ghost_attacks.json kerf.path_cut_m` 0 is the owner's crowd-wide call, ghost-powers lane).
  MILESTONE 544c2cec **`bosses.json kerf_line_m`** (generic, optional, default 0): every Kerf blink
  since the last step also cuts each live body of the boss script (`BossMoves.bodies()`) within
  that width of the line (`BossKerfLine`, called from BossHook.step; telemetry `kerf_line_cuts`;
  reads the sim's blink trail, so it replays). Servo 0.6 m. path_cut_m untouched (humans and cops
  are not affected). DECISION: a boss-row value, not path_cut_m (that one changes Kerf in every
  fight). Alternative: `kerf_line_m` 0. Unit `test_boss_kerf_line` 2/2; unit **1173/0**
  (`unit-it6b.log`). p2, `--servo-ghost=kerf`, seeds 2-3: 3 extra drones cut per run, 0 SCRIPT ERROR.
- 23:44 Tried aiming the Kerf bot along the densest line of drones (instead of the thickest knot):
  same blinks and the same 3 cuts on seeds 2-3: no gain, reverted (not committed).
- 23:47 FILM `M/servo_ghost_kerf_line_cut_48ppm_it6.mp4` (p2, seed 2, 48 px/m, boss cam, 8 s,
  0 SCRIPT ERROR). **Looked at** 10 fps keys (`M/frames/servo_kerf_line_cut_keys_48ppm_it6.png`):
  the teal blink line crosses the rack's edge, three drones on it drop as ink rings, Servo is
  sliced. FOUND, open: a cut drone shows the generic ink-ring fall, not Kerf's teal-white cut edge
  (the drones have their own fall, not the split-kill view). frames.json 15 (the kamikaze keys
  still and the Dent A/B still dropped: their clips stay).

### FYI to king (23:52): framework changes on n7-servo since your 9695947c (merged here as a1828ea2)
- boss_bot.gd merge: your `_unblock`/`sidestep`/`walled` kept as is; my older SIDE_LOOK_M block is
  gone; `_rolls` now also rolls a CHARGE on its body (`CHARGE_ROLL_TICKS` 7, active window), not on
  its tell (a charge is never rolled in the windup). King's ram is a charge: your dodging numbers
  on the merged tree will differ from yours.
- `bosses.json <boss>.kerf_line_m` + `BossSpec.kerf_line_m` + `BossKerfLine` (BossHook.step, one
  line; telemetry `kerf_line_cuts`): optional, default 0; King has no script bodies, so unchanged.
- The boss cam over the off-floor ground: I left it to you (your NEXT 3), not duplicated.
- 23:56 GATES on the head 9aa2b8e9 (the merge + the Kerf line): scenarios **52 ran / 0 failed**,
  0 SCRIPT ERROR (`evidence/servo/scenarios-it6b.log`); director reel (headless, --fixed-fps 60,
  `--bot=reel --reel=director --loadout=pistol --rigs`): **19/19 chapters fully down**, 0 SCRIPT
  ERROR (`director-reel-it6.log`). Combat did not regress. Session ends with everything committed.

Calls for the owner (for REPORT; 1-8 stand):
9. Kerf on Servo's drones: the blink line cuts the drones within 0.6 m of it (default,
   `bosses.json servo.kerf_line_m` 0.6) vs only the one target (0). See
   `M/servo_ghost_kerf_line_cut_48ppm_it6.mp4` or `RTAI.exe -- --boss=servo --phase=2` and take Kerf.

NEXT (iteration 7, in order):
1. Merge n7-king again if it moved (its boss cam clamp); re-run unit + the numbers sweep.
2. A cut drone's fall in Kerf's look: the teal-white cut edge and two halves (ServoFall, render
   only) when the kill weapon is kerf_slice; re-film at 48 px/m.
3. The rack seam (a 3-row wing part sheet under the image lock), bigger pads, the horn and the
   bay doors rolling up at rush hour, the defeat's visor flicker.
4. Per-phase 32 px/m clips on the current tree (the it3 ones predate the rack, smash, van, armour,
   fireball); the target comparison re-shot at 32 px/m (after king's boss cam clamp lands: merge).
5. Windows export `build/export/windows/RTAI.exe` by 08:30 and REPORT.md (calls 1-9; the rotor
   dash READ_P table and the it6a per-attack table are the numbers).

## Iteration 7 (2026-11-06 00:00-00:59, BUILD)
Read: JOURNAL (it6 NEXT), git log, n7-king's JOURNAL it6 (boss cam clamp, whole bar, parked
sedans, Dent bot car_goal). Rules applied: motion-quality-gating (judge the cut at 48 px/m in the
live arena path, frame by frame), encounter-balance-simulation (a merge must not move the numbers:
same seed, same ticks).
- 00:00 MILESTONE d9d13e63 merge n7-king 3f95d031: no code conflicts (JOURNAL ours). The parked
  sedans are in the boulevard (x 124), far off the pit; BossBotGhost.car_goal is `--ghost=dent`
  only (my `--servo-ghost=dent` is untouched).
- FRICTION: the first unit run had no GODOT_BIN in the shell: "1171 passed" was a stale count with
  exit -1 everywhere. Re-run with GODOT_BIN: **unit 1180/0** (`evidence/servo/unit-it7.log`).
  Always export GODOT_BIN with APPDATA.
- 00:03 MEASURED the merge does not move the fight: seed 1, human + dodge (`numbers-it7-merge/`):
  Servo down at tick 7733 / 8308, took 120 / 104, the same landings as it6a. 0 SCRIPT ERROR.
- 00:20 MILESTONE 6dae00ee NEXT 2: **a drone Kerf cuts falls in two halves** (`ServoCut`, render
  only): CombatArena.kill_landed with weapon kerf_slice on a drone body -> an 8-frame white-hot
  slice in a teal bloom across the drone (2.4 x its width), then the drone sprite's two halves
  (texture region halves along the blink) part 0.6 m, turn 0.35 rad and shrink as they drop, the
  cauterised soul edge cooling, lying dark and fading by 90 frames. The machine smoke follows.
  Framework: `BossView.arena` (generic, set by `BossView.attach(view, hook, arena)` from
  BossHook.attach_view) so a boss view can listen to kills; it never steps the arena.
- FOUND on the way: the halves were drawn but at PART_M 0.32 / a thin edge they vanished into the
  rack's detail (the cuts happen as drones launch off the rack). Debug log: 5 cuts in 240 ticks,
  dir = the blink's. Fixed by the part 0.6 m, edge 0.1 x the art height, and the slice flash.
- FILM `M/servo_ghost_kerf_cut_halves_48ppm_it7.mp4` (p2, seed 2, 8 s, 0 SCRIPT ERROR). **Looked
  at** `M/frames/servo_kerf_cut_halves_keys_48ppm_it7.png` (10 fps): the slice flashes white-teal
  along the blink through the three drones, the halves part with teal edges, then the smoke. At
  48 px/m over the rack it reads as Kerf's slashes; the half-drone silhouettes are small (a drone
  is ~1 m). The it6 clip and keys deleted (superseded).
- 00:18-00:23 (written up at it8 start: the it7 session ended before its journal) three more
  commits, each looked at in a 32 px/m boss-cam clip on the it7 tree:
  - 5206ae56 **boss cam clears the boss bar** (framework view fix, BossCam floor clamp lets the
    screen rise HUD_PX above the floor): Servo at the loading bays stood under the bar at every
    bay hop; now below it.
  - e6a57d49 **rush hour rolls the bay doors up** (ROLL_S 1.6 s, eased; render only).
  - 5013c1c1 **the defeat's visor flicker** (cream, never vermilion; dark by 80 ticks).
  - FILMS `M/servo_p1_depot_bosscam_32ppm_it7.mp4`, `servo_p2_rush_hour_bosscam_32ppm_it7.mp4`,
    `servo_p3_overtime_defeat_32ppm_it7.mp4` (human bot, seed 2, `phase32.sh`); **looked at**
    `scratch/servo/it7/p2_sheet.png` (15 keys): the doors open, the lanes and drop rings read,
    the bar clear of Servo. frames.json not yet updated for these (done in it8).

## Iteration 8 (2026-11-06 00:24-01:24, BUILD)
Read: JOURNAL, git log, n7-king's JOURNAL it7 (target comparison at 32, plain thug FYI, Dent
numbers; f448dbce car_goal on the floor, ad428713 gang helmets). No REQUEST to servo open.
- 00:30 MERGE n7-king ad428713 (f448dbce car_goal takes BossHook.bounds; gang helmets; king
  evidence). JOURNAL conflict, ours; boss_bot.gd auto-merged.
- 00:31 MILESTONE 97492d77 merge committed (lint 13/13); unit **1181/0** (`unit-it8.log`).
  Committed the it7 evidence left untracked (cf8fa7ea).
- 00:30 MILESTONE 4b2d7ce3 **the rack seam is gone**: each 3-row wing is one frame. No image
  job: `tools/art/servo_rack3.py` composes `rack3.png` from the installed 2-row wing (the centre
  repeats a whole bay row with its cross bar; the striped side panels stretch to the new height).
  ServoRig._wing_art draws it bottom-aligned with the 2-row wing for rows 3 (other row counts keep
  `_extra_rows`). Looked at p2 seed 2 at 48 px/m: `M/frames/servo_target_vs_arena_rack3_seam_48ppm_it8.png`
  (target | it4 2-row | it4 3-row with the seam | it8). DECISION in docs/decisions.md.
- 00:36 MILESTONE f442c3c8 **the rush-hour horn** (`ServoHorn`, Servo's folder, render side):
  phase_changed to index 1 cues `audio_cues.json servo_horn` (horn_01 at pitch 0.62, not
  positional). Unit test_servo_horn; **unit 1182/0** (`unit-it8b.log`). FRICTION: the first unit
  run passed 1182 but load_all failed: `ServoHorn.attach(...)` discarded its return (warning =
  error), which would have broken Servo's whole view in the game. `run_unit.mjs` prints it only as
  "load_all exit 1"; run `-s res://tests/load_all.gd` to see the line. Not heard (headless).
- 00:40 MILESTONE 41075551 **the central spine** (`ServoSpine`, render only): the target's top
  view is wing | spine | wing; ours had the wings meeting in the middle. A cream column with shaded
  rivet bands (0.56 m, over the wings' inner striped panels only, so `cell_pos` and the numbers do
  not move) from the rack's back edge to under the torso, capped past the back edge by the head
  part's panel box with its copper hose loops. Two looks: a flat strap with tiny hoses inside the
  rack outline (rejected), then the shaded bands and the cap pushed out 0.08 m past the edge.
  `M/frames/servo_spine_ab_48ppm_it8.png`. DECISION in docs/decisions.md.
- "Bigger pads": measured against the sheet (pad ~0.48 of a wing's width there; ours 1.3 m of
  2.6 m = 0.5): already matched. Dropped from NEXT.
- frames.json 15: the it8 target still and spine A/B in, the it7 phase clips replace the it3 ones
  (it3 clips, the it3 keys still and the it4 target stills deleted: superseded, the it4 A/B is
  inside the it8 still).
- 00:47 GATES on 41075551 (rack3, horn, spine): scenarios **52 ran / 0 failed**, 0 SCRIPT ERROR
  (`evidence/servo/scenarios-it8.log`, beside a film: CONTENDED, the nav flake did not trip).
- 00:47 FILM the full fight at 32 px/m on 41075551 (human bot, seed 2, boss cam): Servo down at
  tick 8264 (137.7 s), took 0 (6 rotor dashes + 1 hot dash landed on the bot... `landed` counts
  attacks; damage_taken 0.0 in the arena block: to check), 57 drones launched, 31 shot, 14 crates
  smashed. **Looked at** 15 keys (1 per 10 s): FOUND Servo half off the bottom of the screen at
  ticks 3000 and 6000 (pushed onto the conveyor at the floor's bottom edge; the floor clamp holds
  the screen on the floor and cuts him).
- 00:51 MILESTONE 85401d4c **BossCam.keep_in** (framework, generic, view only): after the floor
  clamp the view shifts the least so the boss +- 3 m stays on screen below the bar. Unit +1
  (**1183/0**, `unit-it8c.log`). DECISION in docs/decisions.md. Re-filming the full fight.

### FYI to king (00:52): framework change on n7-servo since your ad428713 (merged as 97492d77)
- `BossCam.keep_in(focus, half_m, p, margin_m, top_m)` + `BOSS_MARGIN_M` 3.0: `_process` now
  clamps to the floor, then keeps the boss's centre +- 3 m on screen below the bar. King on the
  plaza's edges is held on screen too; `BOSS_MARGIN_M` 0 = your clamp alone. Unit test_boss_cam
  `test_keep_in_holds_the_boss_on_screen`.
- 00:56 FILM re-shot with keep_in: the fight is tick-identical (down at 8264, dealt 210 to Rivet:
  `boss_fight.dealt` is the damage on Rivet; the arena block's damage_taken 0.0 is the pit's, not
  the boss's). Looked at: ticks 5400 and 6000 now show Servo whole at the bottom edge; tick 3000
  still hid him. A debug log (not committed) at 2910-3090: boss (1.1, 30.4) on the floor (bounds
  y 6..32), focus y 20.9, half 12.5: keep_in held him exactly 3 m inside the bottom edge, but at
  x 1.1 m that is **under the ghost card** (GhostFormHud, bottom-left, 158 px + margin); only his
  pads peeked out below it. CORRECTION: he was never off the floor or off the screen.
- 01:02 keep_in takes HUD bands (`band_m`: top = the bar's HUD_PX, bottom = FOOT_PX =
  GhostFormHud.MARGIN + 162 px, the whole width), so the boss stays between the bar and the card.
  Unit test extended (a bottom-band case). Third full-fight film running.
- 01:05 FILM `M/servo_fight_bot_human_32ppm_it8.mp4` (third take, ff643886): tick-identical
  fight (down 8264 = 137.7 s, 210 on Rivet, 0 deaths). **Looked at** the 15 keys
  (`M/frames/servo_fight_keys_32ppm_it8.png`): at 2400 and 3000 Servo stands whole above the
  conveyor, clear of the ghost card; the price is an off-floor ground band at the bottom then.
  The it5 full-fight clip deleted. 137 s is over the brief's 60-120 s: that is the measured fight.
- 01:07 STILL `M/frames/servo_target_vs_game_32ppm_it8.png`: sheet | 1x | 2x at 32 px/m (tick
  1800, the dash lane locked on Rivet, turned to face down). **Looked at**: the wide 3-bay rack
  bar split by the spine with its hose cap, the hub, the pads on arms, the legs. Gaps: the sheet's
  spine is a heavy rounded body (ours a narrow column); its pads hang lower and further out.
- 01:08 FILM `M/servo_drone_wave_scan_drop_dodge_48ppm_it8.mp4` (the brief's wave clip, on the
  current tree; dodging bot, seed 2, 4.5-11.5 s). **Looked at** the keys: beam tracks, locks,
  rings on Rivet's spot, he steps off, a bomb blasts in its ring (the amber fireball). FOUND: at 48
  px/m the rings fall beside the bottom-left ghost card (the cam keeps only the boss clear).
  it3 clip + keys deleted. frames.json 15 (the spine A/B dropped: the 32 px/m still shows it).

NEXT (iteration 9, in order):
1. Merge n7-king if it moved; tell king about `BossCam.keep_in` + `FOOT_PX` (FYI above; the
   signature is now `keep_in(focus, half_m, p, margin_m, band_m: Vector2)`).
2. The spine heavier. Measured on the sheet (01:10): its spine is ~1.5 m wide with the wings set
   apart by it; ours is 0.56 m over the wings' inner panels. The pads already match (sheet 2.65 m
   out, 1.23 m forward; ours 2.6 / 1.2: dropped). A true match needs a centre gap in
   `ServoRack.cell_pos` (+ the wing art offset 1.305 m): the drones' launch points move, so it is
   a sim change: build it as a `servo.json rack.spine_m` value (0 = today), re-measure seeds 1-5,
   and make it a call (spine 0.56 render-only vs a 1.5 m gap).
3. Re-film the per-attack 48 px/m clips on the current tree (all are it4/it5: before the 3-row
   frame, the spine, the fireball): rotor dash, carpet, bay hop, hot dash.
4. Windows export `build/export/windows/RTAI.exe` (`windows-showcase` preset, docs/decisions.md
   2026-11-04 showcase export) by 08:30; check `RTAI.exe -- --boss=servo` boots into the depot.
5. REPORT.md final (the draft is committed): the exe lines, the final gates, calls 1-9 + a call
   for keep_in (boss over floor) if king disagrees.
- 01:20 GATES: director reel on the it8 head (`--bot=reel --reel=director --loadout=pistol --rigs`,
  headless, --fixed-fps 60): **19/19 chapters fully down**, 0 SCRIPT ERROR
  (`evidence/servo/director-reel-it8.log`; exit 124 = the 700 s cap after the last chapter, as
  it6). Combat did not regress. Unit 1183/0, scenarios 52/0, lint 13/13 this iteration.
  Session ends with everything committed; NEXT for iteration 9 is the list above.

## Iteration 9 (01:22-02:22, BUILD)
Read: JOURNAL (it8 NEXT), git log, n7-king's JOURNAL tail (it10: gang heads; no REQUEST to servo;
king reads my keep_in FYI and leaves the merging to the Director). Rules applied:
encounter-balance-simulation (a sim-moving art change is re-measured on seeds 1-5 x bots before it
ships; the alternative stays one data value), depth-ordered-layered-art (the spine sits between
the wings, under the torso).
- 01:24 MERGE n7-king 63bbdeb8 as 108324a4 (press plates, shoulder megaphone, gang bulk + steel
  dome heads, king evidence). Conflicts: JOURNAL.md and REPORT.md (add/add: each lane's own),
  both ours. Unit on the merged tree **1185/0** (`evidence/servo/unit-it9.log`; king's +2).
  FRICTION: a `&&` chain sent to the background with `&` ran the commit's pre-commit lint in a
  shell that returned at once; the commit did land (108324a4), and my retry then failed on the
  missing MERGE_HEAD. Do not background commits.
- 01:30 BUILT NEXT 2, `servo.json rack.spine_m` (schema 0..2): the rack wings sit spine_m further
  apart across the back (`ServoRack.cell_pos` adds +-spine_m/2 to each cell's across, so drones
  launch from the moved cells; `ServoRig._wings` moves the wing art; `ServoSpine` widens by the
  gap and its hose cap grows by 0.6 of it). Unit `test_spine_gap_sets_the_wings_apart_not_the_bays`.
- 01:33 LOOKED at the A/B, p2 seed 2 tick 200, 48 px/m (`it9/ab.png`, zoom `zab.png`) beside
  the sheet's top view: at 0 the wings meet behind a thin column; at **0.94** (spine 1.5 m, the
  sheet's measure) the top view is the sheet's three blocks, wing | heavy cream spine with the
  hose cap | wing. The drones launch from the wider wings (their tick-200 spread differs).
  Measuring seeds 1-5 x dodge/human before it becomes the default.
- 01:28 MEASURED the gap (`evidence/servo/numbers-it9-spine94/`, seeds 1-5, --fixed-fps 60,
  14400 cap, 0 SCRIPT ERROR, CONTENDED wall time), against it6a (the it8 tree's fight: human s2
  137.7 s / 210 in both):

  | bot | downed | time to kill | took | deaths | rotor dash | hot dash | bay hop |
  |---|---|---|---|---|---|---|---|
  | dodge it6a | 5/5 | 114-140 s (127) | 62 | 0 | 2/35 | 1/17 | 5/8 |
  | dodge gap 0.94 | 5/5 | 110-159 s (124) | 16 | 0 | 2/36 | 0/14 | 0/9 |
  | human it6a | 5/5 | 121-138 s (129) | 128 | 0 | 15/38 | 5/15 | 0/8 |
  | human gap 0.94 | 5/5 | 116-169 s (134) | 168 | 0 | 17/38 | 5/15 | 2/10 |
  | stand it6a | 1/5 | 204 s | 1388 | 25 | 86/95 | 3/3 | 14/14 |
  | stand gap 0.94 | 0/5 | - | 1398 | 28 | 81/90 | 6/6 | 17/17 |

  The moved launch points re-roll every wave (the cascade), so seeds move both ways (dodge took
  less, human more); the attack hit rates hold. Called: no direction, inside the spread, not
  "balanced" (n = 5). DECISION: ship 0.94 (the target's measure), `rack.spine_m` 0 = the owner's
  alternative (call 10 in REPORT).
- 01:30 MILESTONE ad9b80c0 the spine gap committed (unit **1186/0**, lint 13/13 in the hook;
  FRICTION: gdformat on Windows writes CRLF: strip it before staging).
- 01:31 FILMS the per-attack 48 px/m clips re-shot on ad9b80c0 (dodging bot, seed 2, boss cam,
  phases 1-3 x 2400 ticks, 0 SCRIPT ERROR). **Looked at** every key sheet:
  - rotor dash (p1 t620): tracking line, the lane locks, the bot steps out, Servo crosses
    smashing the crates in his lane, steam in the punish window; the wide spine reads.
  - package carpet (p2 t863): beam tracks, locks, the ring lane runs past the van through the
    mark, the bot steps out, a bomb's amber blast in its ring.
  - bay hop (p2 t671): the ring locks on Rivet among crates, he lands by bay 4, the bot clear.
    FOUND: the ring sits on the screen's top edge under the boss bar (the cam frames the boss,
    not the mark); the cam then jumps with the hop.
  - hot dash (p3 t956): one wing gone, lane locks, the bot steps out, the slam at the yard edge.
  - kamikaze: my cut (p3 t788) shows the lock ring but not the dive landing clearly: not kept;
    the it5 clip stays.
  The it4 clips and keys deleted; frames.json updated (4 clips, the spine A/B still replaces the
  it8 rack3-seam still).
- 01:34 TRIED a generic BossCam keep for Rivet +- 2 m (for the bay-hop ring under the bar):
  no change on film (Rivet +- 2 m already fit; the ring is 3 m, and with Rivet 6 m above the boss
  the 12 m between the HUD bands cannot hold both margins; the boss wins). Reverted: it is the
  dev clip cam only; in play the camera centres Rivet, so his rings are always on screen. Noted
  under "open" in REPORT.
- 01:37 FILM `M/servo_fight_bot_human_32ppm_it9.mp4` on ad9b80c0 (human bot, seed 2, 32 px/m,
  boss cam): down at tick **7036 (117 s, inside the brief's 60-120 s)**, 188 on Rivet, 0 deaths,
  0 SCRIPT ERROR, tick-identical to the headless numbers run. **Looked at** the 12 keys
  (`M/frames/servo_fight_keys_32ppm_it9.png`): the three phases, the dash lanes, the last hot dash
  and blast. STILL `M/frames/servo_target_vs_game_32ppm_it9.png` (sheet | 1x | 2x, tick 1800):
  **looked at**: wing | wide spine | wing now matches the sheet's blocks; gaps: the sheet's spine
  is grey panelled steel with orange hoses (ours a cream column), its docked drones read cream
  with rotors (ours dark cells). it8 fight clip, keys and target still deleted (superseded).
- REPORT numbers moved to the shipped tree (it9-spine94); stale paths fixed.
- 01:41 MILESTONE fae5b894 **the spine plated** (render only, `ServoSpine._plates`, only when
  spine_m > 0.2 so the 0 alternative keeps the it8 column): plate seams, a raised lighter centre
  plate with an ink rim, a copper hose down each side. **Looked at** 48 and 32 px/m (p2 seed 2):
  the centre plate reads as the sheet's raised box; the hoses print copper-brown (not vermilion),
  faint at 32. FRICTION: `PackedVector2Array.append/resize` return values = warnings = errors;
  the first film had 246 SCRIPT ERRORs (Servo's whole view gone). Always run
  `-s res://tests/load_all.gd` after a render edit, before filming. Still
  `M/frames/servo_spine_gap_ab_48ppm_it9.png` now 0 | 0.94 | 0.94 plated; target still re-shot on
  fae5b894. (The full-fight and attack clips are on ad9b80c0: the same fight, before the plating.)
- 01:42 GATES scenarios **52 ran / 0 failed**, 0 SCRIPT ERROR (`evidence/servo/scenarios-it9.log`,
  CONTENDED, beside films). Unit on fae5b894 **1186/0** (`unit-it9c.log`). Lint 13/13 (hook).
- 01:44 EXE de-risked: `--export-release "windows-showcase"` in 14 s, exit 0; headless smoke
  `RTAI.exe --headless --fixed-fps 60 --quit-after 7400 -- --rigs --boss=servo --bot=boss
  --bot-human --seed=2`: **down at 7036, 188 on Rivet, 0 SCRIPT ERROR** = the editor
  (`evidence/servo/exe-smoke-it9.json`). REPORT exe lines written. Re-export at the freeze.
- 01:50 MILESTONE 8e34d545 **docked drones read in the rack** (render only, `ServoRig.DOCKED_M`
  0.34): a cream body with an ink rim in each FULL cell, the sheet's cream drones in dark bays;
  the gaps are the drones out. First try, the flying drone's whole sprite per bay at 0.95: 18
  rotor crosses, a dot field at 32 px/m (noise; rejected). **Looked at** p2 seed 2 at 32 and 48
  px/m (I first took the gaps for a misalignment with the bays; checked the arithmetic: the cell
  pitch 0.87 x 0.73 m matches the art's 2.6 m / 3 bays and 2.125 m / 3 rows, and the bodies sit in
  the bays; the gaps are the 5 drones in flight), and the defeat (p3 seed 2 human, down at 1930,
  `phase32_9.sh`): standing at 1900 the bodies sit in the remaining wing; from the flash at 1932
  the spill owns the bays (the bodies are hidden once down), no body left behind. REPORT call 11,
  decisions line. Still `M/frames/servo_rack_spine_docked_ab_it9.png` (top: spine 0 | 0.94 |
  plated at 48; bottom: plated | docked at 32) replaces the spine A/B; the unreferenced it3
  defeat clip deleted.
- 01:55 Unit on 8e34d545 **1186/0** (`unit-it9d.log`). FILM `M/servo_drone_wave_scan_drop_dodge_48ppm_it9.mp4`
  (the brief's wave clip on 8e34d545, dodging bot, seed 2, 4.5-11.5 s). **Looked at** the keys
  (`M/frames/servo_drone_wave_keys_48ppm_it9.png`): beam tracks, locks, rings on Rivet's spot, he
  steps off, a bomb blasts in its ring; the rack empties as the wave launches and refills (the
  docked bodies make it read on the body). it8 wave clip + keys deleted.
- 01:58 EXE re-exported on 8e34d545 (exit 0), smoke again: down 7036, 188 on Rivet, 0 SCRIPT
  ERROR (`evidence/servo/exe-smoke-it9.json`; render-only changes since, as expected).

NEXT (iteration 10, in order):
1. Merge n7-king if it moved (last merged 63bbdeb8 as 108324a4; JOURNAL/REPORT add/add: ours).
2. If the it9 phase re-films (p1/p2/p3 at 32 px/m on 8e34d545, `scratch/servo/phase32_9.sh`)
   are not in frames.json yet: look at their keys, replace the it7 phase clips, delete the it7 ones.
3. Kamikaze 48 px/m clip on the current body (the it5 one stays until then): cut on a
   `kamikaze` windup in a p3 film where a dive lands (the it9 p3 t788 cut showed only the lock).
4. Look: the target still's remaining gaps: the sheet's spine is grey panelled steel (ours cream
   with a raised plate); its pads hang lower and further out at the corners. Both render only.
5. Numbers: the stand bot 0/5 downed at the 240 s cap with the gap (it6a 1/5); the human 116-169 s.
   If the owner wants a tighter fight length, the carpet cadence or phase hp (encounter-balance:
   measure 5 seeds x 3 bots per change).
6. At the freeze (08:30): re-export `windows-showcase`, smoke `RTAI.exe --headless --fixed-fps 60
   --quit-after 7400 -- --rigs --boss=servo --bot=boss --bot-human --seed=2` (expect down 7036, 188),
   final gates (lint, unit, scenarios, evidence/run.mjs, director reel), REPORT final (drop DRAFT).
- 02:08 GATES director reel on c8ff4375 (`--bot=reel --reel=director --loadout=pistol --rigs`,
  headless, --fixed-fps 60): **19/19 chapters fully down, 0 SCRIPT ERROR**
  (`evidence/servo/director-reel-it9.log`). The wrapper was stopped by the tool's 600 s
  background limit after the last chapter (it idles to the 700 s cap, as in it6/it8); my Godot
  process had exited (checked by command line; the other reel processes are another lane's).
- 02:09 FILMS the phase clips at 32 px/m on 8e34d545 (human bot, seed 2, boss cam, `phase32_9.sh`;
  p1/p2 2400 ticks, p3 2300, 0 SCRIPT ERROR): `M/servo_p{1,2,3}_*_32ppm_it9.mp4`, replacing the it7
  ones (deleted). **Looked at** the 12-key sheets (`M/frames/servo_p{1,2,3}_keys_32ppm_it9.png`):
  p2: beam, rings, the running conveyor, Servo hopping to the bays and back to the yard's
  bottom-right corner; p3: one wing, hot-dash lanes, down at 1930 with the spill. FOUND: at the
  defeat he stands in the yard's top-left corner, half off the screen's left edge (the boss cam's
  keep_in holds him only between the HUD bands vertically; the x margin loses to the floor clamp
  there?). To check in it10 (view only, framework BossCam).
- NEXT 2 above is done (the phase re-films are in frames.json). Add to NEXT: 2b. the boss cam at
  the yard's left edge (p3 defeat, tick ~1930-2300): measure, then keep_in's x if it is the cause.
- 02:12 MEASURED the p3 defeat at the left edge: tried `BossCam.BOSS_MARGIN_M` 3.5 (was 3.0):
  no visible change. Servo's centre already stands ~3.1-3.5 m inside the screen's left edge
  (keep_in works); it is his body that is wider than the margin there: turned sideways, the rack
  with the spine gap reaches 3.07 m out from the centre, plus the defeat slump and the spill
  (1.8 m). Holding the whole body needs a margin of ~4.5 m, which pushes the view off the floor
  more often elsewhere: not measured tonight, reverted to 3.0. NEXT 2b is now: try 4.5 on the full
  fight's 12 keys and the p3 defeat, and keep it only if the floor framing holds.

## Iteration 10 (02:13-03:13, BUILD)
Read: JOURNAL (it9 NEXT), git log, n7-king's JOURNAL tail (it12: procession clip; no REQUEST to servo).
Rules applied: motion-quality-gating (look at every cut), encounter-balance-simulation (no sim change
without 5 seeds x bots).
- 02:16 MERGE n7-king 73543d25 as 91f94504 (coin spray, decree arc, slam plates; BossCam port is the
  same file as ours, no change). JOURNAL/REPORT add/add: ours. Lint 13/13 on the merge.
- 02:17 NEXT 3 done: FILM the kamikaze on the current body (`scratch/servo/film48_10.sh 3 2 1000` on
  91f94504, dodge bot, seed 2, 48 px/m, boss cam; 0 SCRIPT ERROR; windup at tick 314, 4 dives, 0 hits).
  **Looked at** keys every 1/6 s over 5-10.8 s: the scanner lock, launch puffs on the rack, thin dive
  lines track, the lock (thick line + dashed blast ring), Rivet steps out, the blast bursts in the
  empty ring at ~9.5 s, the next hot-dash lane already telegraphed. Cut
  `M/servo_attack_kamikaze_dive_lands_48ppm_it10.mp4` (5.0-10.8 s) + keys
  `M/frames/servo_kamikaze_keys_48ppm_it10.png`; the it5 clip and the it4 keys deleted; frames.json 15;
  REPORT call 7 points at the new clip.
- 02:40 MILESTONE NEXT 4 (part): **the spine is the sheet's tan steel** (`ServoSpine.STEEL_TONE`:
  a mid steel fill 116,94,70 under three stacked lighter boxes 203,165,122, sampled from the
  target's top view). Before, the cream column and its near-white plate were the brightest thing
  on the body and merged with the torso. 150,121,89 tried first: the boxes did not separate from
  the fill under the print. **Looked at** 48 px/m before | after | the sheet, 32 px/m before |
  after at 2x (p2 seed 2 tick 420): wing | darker spine | wing, torso set off, stacked boxes as
  in the sheet. `M/frames/servo_spine_steel_ab_it10.png` (frames.json 15: the it9 rack still is
  now its `before`). Render only. Unit 1185/1 (the known flake `test_noir_shadows`, then 1186/0
  alone, twice); scenarios exit 0, 0 SCRIPT ERROR (`evidence/servo/*-it10.log`); decisions.
  The pads lower/further out (the other half of NEXT 4) left: it moves the arms' reach (a fight
  read), not tonight's last half hour.
- 02:35 FILM the full fight on the steel spine (`full32_10.sh`, 8d8c3cae tree, human bot, seed 2,
  32 px/m, boss cam): down at **7036, 188 on Rivet, 0 deaths, 0 SCRIPT ERROR**: tick-identical to
  it9 (render-only since). `M/servo_fight_bot_human_32ppm_it10.mp4` (121 s). **Looked at** the 12
  keys (`M/frames/servo_fight_keys_32ppm_it10.png`): the beam, bay hops, the belt, the dash lanes,
  carpet rings, hot dash lanes, the spill at the defeat. STILL `M/frames/servo_target_vs_game_32ppm_it10.png`
  (sheet | 1x | 2x, tick 1800): **looked at**: the steel spine's stacked boxes read beside the
  sheet's; remaining gaps: the sheet's hazard-striped rack bases, the spine's horseshoe frame, and
  the pads hanging in front of the wings (ours beside them). it9 fight clip, keys, still deleted;
  frames.json 15; REPORT paths.
- 02:39 MILESTONE NEXT 4 (rest): **the pads hang in front of the wings** (`ServoRig.PAD_OUT_M`
  2.35, `PAD_AHEAD_M` 2.0; were 2.6 / 1.2), measured on the sheet's top view (pads ~1.5 m ahead
  of the rack's front edge, at ~3/4 of the half-width). Render only: no hit test reads the pads
  (hit body 1.6 m; pads drawn at 3.1 m from the centre, were 2.86: outside it as before).
  **Looked at** 48 px/m before | after | sheet and 32 px/m before | after (p2 seed 2 tick 420,
  `M/frames/servo_pads_ahead_ab_it10.png`): the front now reads pad | leg | leg | pad ahead of the
  rack, the sheet's four limbs; before, the pads touched the wings' front corners. The target still
  re-shot at tick 1800 with it (`M/frames/servo_target_vs_game_32ppm_it10.png`, 0 SCRIPT ERROR).
  Unit 1186/0 (`evidence/servo/unit-it10b.log`). Decisions; REPORT call 13.
- 02:44 MILESTONE (target gap from the it10 still): **the rack wings carry the sheet's hazard
  base**: `ServoWingBand`, a copper and ink striped ledge along each wing's front edge, drawn in
  the wing's art space (turns, flips, shakes, hidden with the blown wing). Copper, not vermilion
  (palette verdict). Step 1 (15 px, half copper) **looked at** 48 px/m 2x: thin, ink-heavy; step 2
  (22 px, 60 % copper 196,112,60): reads as the sheet's ledge at 48, a clean striped edge at 32
  (2x), no noise. `M/frames/servo_wing_band_ab_it10.png`. New class: `--import` first, then 0
  SCRIPT ERROR in both renders. Unit 1186/0 (`evidence/servo/unit-it10c.log`). Decisions; REPORT
  call 14.
- 02:46 GATES director reel on a93af6cf (`scratch/servo/reel10.sh`: `--bot=reel --reel=director
  --loadout=pistol --rigs`, headless, --fixed-fps 60): **19/19 chapters fully down, 0 SCRIPT
  ERROR** (`evidence/servo/director-reel-it10.log`). Combat holds after the merge and the body work.
- 02:49 EXE re-exported on f430d3a2 (`--export-release "windows-showcase"`, exit 0), smoke `RTAI.exe
  --headless --fixed-fps 60 --quit-after 7400 -- --rigs --boss=servo --bot=boss --bot-human
  --seed=2`: **down 7036, 188 on Rivet, 0 SCRIPT ERROR** = the editor
  (`evidence/servo/exe-smoke-it10.json`). REPORT exe line and DRAFT header updated.
- 02:50 FILM the full fight once more on a93af6cf (the it10 body: steel spine, pads ahead, wing
  ledges): down **7036, 188**, 0 SCRIPT ERROR, identical. `M/servo_fight_bot_human_32ppm_it10.mp4`
  and its 12 keys replaced; the target still re-shot from it at tick 1800
  (`M/frames/servo_target_vs_game_32ppm_it10.png`), **looked at**: three blocks, steel spine,
  striped rack bases, pad | leg | leg | pad in front. Left vs the sheet: the spine's horseshoe frame
  and hose loops; the stripes read browner (copper, by the palette verdict). frames.json 15
  (the pads and band A/Bs are named in the still's note). Scratch renders deleted.

NEXT (iteration 11, in order):
1. Merge n7-king if it moved (last merged 73543d25 as 91f94504; JOURNAL/REPORT add/add: ours).
2. Re-film the per-phase 32 px/m clips on the it10 body (`scratch/servo/phase32_9.sh` with
   O=it11; p1/p2 2400, p3 2300) and the 48 px/m attack clips whose body shows (rotor dash, bay
   hop): they show the it9 cream spine and pads beside the wings. Look at keys, replace, delete old.
3. The spine's horseshoe frame (the sheet's U rail round the lower spine) and the hose loops over
   the top: render only, `ServoSpine`; A/B at 48/32 beside the sheet.
4. NEXT 2b of it9 (the clip cam at the yard's left edge) stays open in REPORT: framework file.
5. At the freeze (08:30): re-export `windows-showcase`, smoke (expect down 7036, 188), final gates
   (lint, unit, scenarios, evidence/run.mjs, director reel), REPORT final (drop DRAFT, Next steps).
- 02:56 NEXT 2 (of the it11 list) done early: the phase clips re-filmed at 32 px/m on the it10
  body (`scratch/servo/phase32_10.sh`, human bot, seed 2, boss cam; p1/p2 2400 ticks, p3 2300,
  0 SCRIPT ERROR, p3 down at 1930 as in it9). **Looked at** the 12-key sheets
  (`M/frames/servo_p{1,2,3}_keys_32ppm_it10.png`): p1 dash lanes, beam, drop rings, hops to the
  bays; p2 bomb blast, carpet rings, spilled CS crates, the belt, the hop into the bottom-right
  yard; p3 one wing, hot-dash lanes, kamikaze rings, the defeat spill in the top-left corner (half
  off the left edge: the known clip-cam item). `M/servo_p{1,2,3}_*_32ppm_it10.mp4` replace the it9
  clips (deleted with their keys); frames.json 15; REPORT paths. The it11 NEXT 2 now covers only
  the 48 px/m rotor-dash and bay-hop clips (the body shows; it9 spine and pads).
- 02:58 FILMS the 48 px/m rotor dash and bay hop on the it10 body (`film48_10.sh 1 2 900`,
  `hop48_10.sh 2 2 900`, dodging bot, seed 2, 0 SCRIPT ERROR; windups at 59 and 671 as before).
  **Looked at** both 4 fps key sheets: the dash's thin tracking lane, the vermilion lock, the
  sidestep, the dash and the vent (the wing ledges read at 48); the hop's ring locking among the
  crates by bay 4 and the landing (this seed lands it, as in it9). `M/servo_attack_rotor_dash_48ppm_it10.mp4`,
  `M/servo_attack_bay_hop_48ppm_it10.mp4` + keys replace the it9 ones (deleted); frames.json 15;
  REPORT paths. The it11 NEXT 2 is done.
- 03:01 FILMS the package carpet (p2, windup 47), the hot dash (p3, windup 35) and the full drone
  wave (seed 2, 4.5-11.5 s) re-filmed at 48 px/m on the it10 body (dodging bot, 0 SCRIPT ERROR).
  **Looked at** each key sheet: carpet (scanner, ring lane, step out, launch, blasts and CS
  crates); hot dash (one wing with its ledge, lock, step out, dash, the long vent); wave (lock,
  rings, step off, bays empty, a bomb in its ring). The it9 clips and keys deleted; frames.json 15;
  REPORT paths. Every per-attack, per-phase and full-fight clip is now on the it10 body; only the
  ghost clips (Kerf it7, Dent it5, Ohm it4) show older bodies.

NEXT (iteration 11, replaces the 02:50 list):
1. Merge n7-king if it moved (last merged 73543d25 as 91f94504; JOURNAL/REPORT add/add: ours).
2. Re-film Ohm's chain on the it10 body (`--phase=2 --ghost=ohm --seed=2`, 2.3-8.3 s), look, replace;
   and look at the it10 Kerf clip frame by frame for the falling halves (the it7 clip, kept, shows them).
3. The spine's horseshoe frame and hose loops (render only, `ServoSpine`): only if they show past
   the torso from above; A/B at 48/32 beside the sheet.
4. The clip cam at the yard's left edge stays open in REPORT (framework file, shared with king).
5. At the freeze (08:30): re-export `windows-showcase`, smoke (expect down 7036, 188), final gates
   (lint, unit, scenarios, evidence/run.mjs, director reel), REPORT final (drop DRAFT, Next steps).
- 03:03 FILM Dent's van re-filmed on the it10 body (`--servo-ghost=dent --seed=1`, 48 px/m, 0 SCRIPT
  ERROR). **Looked at** the keys: dash lane, teal tether to the van, the van onto the rack, the
  amber fireball, the charred wreck. `M/servo_ghost_dent_van_48ppm_it10.mp4` + keys replace the it5
  clip (deleted); REPORT call 8 path; NEXT 2 narrowed to Kerf and Ohm. Session ends here with
  everything committed (scratch avis deleted).
- 03:05 FILM Kerf re-filmed on the it10 body (`--phase=2 --servo-ghost=kerf --seed=2`, 48 px/m, 0
  SCRIPT ERROR): `M/servo_ghost_kerf_cut_halves_48ppm_it10.mp4`. **Looked at** keys every 2/3 s:
  the blinks slice teal across the swarm and the rack; the falling halves are not singled out at
  that spacing, so the it7 clip stays on disk as the halves' evidence (frames.json `before`).
  REPORT call 9 path. NEXT 2 updated. Session ends with everything committed.

## Iteration 12 (03:04-04:04, BUILD)
Read: JOURNAL NEXT (it11), git log -15, n7-king's JOURNAL it13 (REQUEST servo: `ArenaPlan.Area.stenciled`,
nothing to change on my side). Rules kept: motion-quality-gating (judge at 48/32 px/m in the live
arena path, key sheets looked at), depth-ordered-layered-art (spine parts over the wings' inner
edges, under the torso).
- 03:06 MERGE n7-king 3e3c0d61 as f28e1ad1 (11 commits: the king's cape, horn, gang D5 lift,
  `ArenaPlan.Area.stenciled`). JOURNAL/REPORT add/add: ours; no code conflicts. Lint 13/13 (hook),
  unit **1189/0** (`evidence/servo/unit-it12a.log`).
- 03:12 FILM Ohm's chain re-filmed on the it10 body (`scratch/servo/ghost48_12.sh ohm 2 2 540`:
  `--phase=2 --servo-ghost=ohm --seed=2`, 48 px/m, boss cam, 0 SCRIPT ERROR). **Looked at** the
  1.5 fps keys: the beam locks, the rings, the teal bolt jumps drone to drone (three keys), then
  the rack. `M/servo_ghost_ohm_chain_drones_48ppm_it12.mp4` + keys replace the it4 clip (deleted);
  frames.json 15. Every ghost clip is now on the it10 body (Kerf's it7 halves clip kept as before).
- 03:16 MILESTONE (NEXT 3) a7e35f83 **the spine's horseshoe rail and big hose loops**
  (`ServoSpine.HORSESHOE`, render only): a light steel U (ink 0.2 m, plate fill 0.11 m) at 0.84
  of the column's inner half from 0.38 of its length, its round bottom under the torso; two
  copper loops (r 0.42 m) off the back cap past the rack's back edge. Step 1 (rail 0.86 in box
  tone, loops 0.3 m) **looked at** 48 px/m 2x: no visible change (the loops under the cap, the
  rail the column edge's tone); step 2 (rail at the edge): lost in the edge band; step 3 (0.84,
  plate tone, loops 0.42 m at 0.66 out): the rail frames the column down to the torso, the loops
  show beside the cap. Subtle at 32 px/m, no noise. `M/frames/servo_spine_horseshoe_ab_it12.png`
  (the sheet | 32 before | after; 48 before | after). Unit 1189/0 (`unit-it12b.log`). Decisions;
  REPORT call 15; moveset doc body paragraph.
- 03:21 MILESTONE (NEXT 4) 2667c047 **the clip cam holds a side-on boss at the floor's side
  edge**: `BossCam.BOSS_MARGIN_X_M` 5.5 sideways (3.0 vertically as before), keep_in called per
  axis (API and test unchanged). Measured on the p3 clip (`phase32_12.sh 3 2 2300`, 0 SCRIPT
  ERROR): at 4.5 the rack was whole but a pad and the smoke touched the edge; at 5.5 the whole
  body, spill and smoke stay on screen, a strip of sidewalk at the left; keys 1-9 frame the same.
  `M/frames/servo_bosscam_xmargin_ab_it12.png` (it10 3.0 | it12 5.5, keys 10-11);
  `M/servo_p3_overtime_defeat_32ppm_it12.mp4` + keys replace the it10 clip. Unit 1189/0
  (`unit-it12c.log`). Decisions; REPORT open item marked fixed.
- REQUEST king (FYI, framework view, no action): `BossCam.BOSS_MARGIN_X_M` 5.5 on n7-servo
  (2667c047). `--boss-cam` only; your clips frame the same unless King stands within 5.5 m of a
  side edge of the screen, where the view now keeps more of him in. 3.0 restores it11.
- 03:25 MEASURED (REPORT open item: the bay-hop ring under the boss bar in the 48 px/m clip):
  tried `BossCam.RIVET_MARGIN_M` 3.0 (keep_in round Rivet before the boss's). Re-filmed
  `hop48_12.sh 2 2 900`, keys 10.5-15 s **looked at**: keys 1-5 identical to it10 (the ring still
  cut at the top). Cause: at 48 px/m the screen holds ~11.9 m between the bar and the ghost card,
  Rivet stood 7.7 m above Servo, so 3 + 7.7 + 3 m cannot fit and the boss wins. Reverted (no
  code change); the measurement is in REPORT's open item. In play the camera centres on Rivet.
- 03:31 FILM the full fight re-filmed on 2667c047 (`full32_12.sh`: the horseshoe spine and the
  5.5 m side margin): down **7036, 188**, 0 SCRIPT ERROR, tick-identical to it10.
  **Looked at** the 12 keys beside it10's: key 4 (Servo at the yard's left edge) now whole, the
  rest framed the same. `M/servo_fight_bot_human_32ppm_it12.mp4` + keys replace it10's; the target
  still re-shot at tick 1800 (`M/frames/servo_target_vs_game_32ppm_it12.png`), **looked at**: the
  copper loops beside the cap and the rail along the column read at 2x. frames.json 15 (all files
  exist); REPORT paths. Scratch avis deleted.
- 03:41 GATES director reel on 4a4e810c (after the n7-king merge and the it12 changes;
  `scratch/servo/reel12.sh`, headless, --fixed-fps 60): **19/19 chapters fully down, 0 SCRIPT
  ERROR** (`evidence/servo/director-reel-it12.log`). Combat holds.
- 03:44 GATES scenarios on eb111830: **52 ran, 0 failed**, 0 SCRIPT ERROR, exit 0
  (`evidence/servo/scenarios-it12.log`). Lint 13/13 (every commit's hook), unit 1189/0.

- 03:54 FILMS (NEXT 3 of it13, done early) the p1/p2 32 px/m clips and the tick-1800 target
  still re-shot on 1373be3f (`phase32_12.sh 1|2 2 2400`, `still32_12.sh`; 0 SCRIPT ERROR each).
  **Looked at** both 12-key sheets (p1: dash lanes, beam, rings, bay hops, whole in the top-left
  corner; p2: carpet rings, a bomb, CS crates, the belt, the bottom-right yard) and the still (the
  0.55 m loops arc out over the wing at 2x). `M/servo_p{1,2}_*_32ppm_it12.mp4` + keys replace
  it10's (deleted); every phase clip and the target still are it12; frames.json 15 (all exist).
  The full fight clip shows the 0.42 m loops (same tick-exact fight).

- 03:56 FILM the full fight re-filmed on d7617e57 (the 0.55 m loops): down **7036, 188**, 0 SCRIPT
  ERROR, identical. **Looked at** the 12 keys: same framing as the 03:31 cut (key 4 whole at the
  left edge). `M/servo_fight_bot_human_32ppm_it12.mp4` + keys replaced; NEXT 2 below is done.
  Session ends with everything committed (scratch avis deleted).

NEXT (iteration 13, in order):
1. Merge n7-king if it moved (last merged 3e3c0d61 as f28e1ad1; JOURNAL/REPORT add/add: ours).
   Its JOURNAL has my FYI REQUEST on `BossCam.BOSS_MARGIN_X_M` 5.5.
2. (done at 03:56) the full fight is on the final it12 body.
3. Weakest item by the target still: the rail's round bottom is hidden under the torso, and the
   sheet's pads carry bright hazard stripes round their rims (ours are copper-ringed discs):
   compare `M/frames/servo_target_vs_game_32ppm_it12.png` and pick one, render only, A/B at 48/32.
4. The bay-hop ring under the boss bar in the 48 px/m clip stays open (measured: no room).
5. At the freeze (08:30): re-export `windows-showcase`, smoke (expect down 7036, 188), final gates
   (lint, unit, scenarios, evidence/run.mjs, director reel), REPORT final (drop DRAFT, Next steps).

## Iteration 14 (03:56-04:56, BUILD)
Read: JOURNAL NEXT (it12/13), git log -15, n7-king's JOURNAL (it14: cape slam, gang chain; no
REQUEST for servo). Rules kept: motion-quality-gating (A/B in the live arena path at 32/48 px/m,
same tick), sprite-and-atlas-production (derived art from the installed cut by a reproducible,
idempotent tool; palette gate held), depth-ordered-layered-art (no layer change).
- 03:58 MERGE n7-king 9a207b0b as 04164ce1 (12 commits: King's cape on the slam, the gang's gold
  chain). JOURNAL/REPORT add/add: ours; decisions auto-merged. Lint 13/13 (hook), unit **1190/0**
  (`evidence/servo/unit-it14a.log`).
- 04:02 MILESTONE (NEXT 3) 204d2ba1 **the pads' hazard rim** (render only). Looked at the pad cut
  at 4x beside the sheet: the rim already holds diagonal stripes, but copper (182,121,80) on a mid
  brown (102,82,67): one brown band at 32 px/m. `tools/art/servo_pad_rim.py` re-inks the rim band
  (2-15 px from the edge, distance seeded past the image border too: the octagon touches it; the
  first pass missed that and inked only the corners, **looked at** and fixed): mid-brown stripes
  to ink, copper lifted 10 % under the 0.24 gate; idempotent (second pass: no pixel changed).
  `ServoRig.PAD_ART` &"pad_hazard" (&"pad" = it13). FRICTION: gdformat exploded the PARTS list
  to one name per line when the new name pushed it past 100 chars; loaded PAD_ART on its own line.
  A/B `spine14.sh before|after 1 300 32|48` (0 SCRIPT ERROR each), **looked at**: at 32 px/m the
  pads ring ink and copper like the wing ledges and the sheet; at 48 px/m the stripes are crisp.
  `M/frames/servo_pad_hazard_ab_it14.png`; frames.json 15 (it10 steel A/B dropped, kept on disk
  for REPORT call 12). DECISION in docs/decisions.md; REPORT call 16.
- 04:16 FILM the full fight re-filmed on 939453f5 (the hazard pads; `full32_14.sh`): down **7036,
  188**, 0 SCRIPT ERROR, telemetry identical to it12. **Looked at** the 12 keys: framed as it12.
  Target still re-shot at tick 1800 (`M/frames/servo_target_vs_game_32ppm_it14.png`), **looked
  at**: at 1x the pads ring ink and copper like the sheet's. it12 fight clip, keys and still
  deleted (frames.json `before` names them); REPORT paths moved to it14.
- 04:13 GATES director reel on 939453f5 (after the n7-king merge and the pads; headless,
  `reel14.sh`): **19/19 chapters fully down, 0 SCRIPT ERROR**; the 780 s timeout fell after the
  last chapter (CONTENDED: two film jobs ran beside it) (`evidence/servo/director-reel-it14.log`).
- 04:19 MILESTONE 5f9ed433 **the legs stand parallel** (render only). By the target still the
  legs splayed out toward the pads (foot 0.9 m past the hip, knee bowed 0.5 m), crossing the pad
  arms: a spidery silhouette, where the sheet's top view has pad | leg | leg | pad. Strut widths
  measured first: ~0.56 m, the sheet's, so no art change. `ServoRig.LEG_SPLAY_M` 0.25,
  `KNEE_OUT_M` 0.2. A/B `spine14.sh legs32|legs48 1 300` (0 SCRIPT ERROR), **looked at** 32/48 px/m
  and the walk's keys (1.2 fps, the dash and the walk): parallel legs stride between the pads, the
  pad arms read on their own. `M/frames/servo_legs_stance_ab_it14.png`; frames.json: it replaces
  the pad A/B entry (that file stays, REPORT call 16). Unit 1190/0 (`unit-it14c.log`). Decisions;
  REPORT call 17; moveset doc body paragraph.
- 04:27 FILM the full fight re-filmed on 5f9ed433 (the parallel legs): down **7036, 188**, 0
  SCRIPT ERROR, identical. **Looked at** the 12 keys (framed as before) and the tick-1800 target
  still: pad | leg | leg | pad now reads at 1x and 2x like the sheet's top view. Clip, keys and
  still replaced in place (same it14 names).
