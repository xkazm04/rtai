# JOURNAL: lane enemy-ai (branch e-enemy), evening run 2026-11-03

## Iteration 1 (20:52-21:37), BUILD

Read: AGENTS.md, features/combat (GuardBrain, CombatArena, WaveDirector, Shot, CombatTuning),
bodies.json (body classes human/robot/boss), RngRegistry, the scenario harness, arena-1 ask (the
arena lane's pit is 36 x 26 m; mine is 40 x 28: align when the arena lands on this branch).
answers.json: empty at 20:52.

Registry applied: agent-behaviour-authoring. Followed: coordination is a scarce, leased claim
(attack tokens), not a commander; competence is a named dial per class (reaction_s, accuracy
curve by range, telegraph_s, turn_deg_s, accel). Deviation: the token registry lives in
EnemySquad over all pit agents, not on the defender (one defender today: same result; revisit
when enemies can target others). Not yet done: a decision trace per agent, knowledge decay,
perception latency beyond the alert reaction time.

- MILESTONE 591c460: enemies.json + schema (five archetypes, squad limits, weapons), arena
  station data/tables/arena_stations/enemy-ai.json.
- FRICTION: lint DAT-03 wants a schema per table basename, so arena_stations/<lane>.json needs
  data/schemas/<lane>.schema.json (added enemy-ai.schema.json). REQUEST 1 -> arena: one shared
  arena_station schema, plus a lint rule for the arena_stations/ subfolder, would avoid
  seven per-lane schemas.
- MILESTONE 6db5864: brains. EnemyRoster, EnemyAgent (states PATROL ALERT ENGAGE WINDUP FIRE
  RECOVER COVER FLANK PANIC DOWN DEAD; pose() = idle run aim windup shoot swing hit flee down
  getup die), EnemySenses (sight cone, hearing a nail, LOS vs cover boxes, cover spots, corner
  detour), EnemySquad (tokens), EnemyMotor (accel and turn-rate limits, separation, arrival),
  EnemyBrain, EnemyPit, PitDummy (a scripted Rivet: stand / dodge / fight), PitLayout.
  scenario_enemy_pit: green, planted faults (squad off, aim lock off) caught.
- MILESTONE ddae36f: the corner detour fix (a riot cop flipped between two box corners from
  11 s on, seen in the clip) + dev/enemy_ai/enemy_pit_view.tscn (32 px/m debug draw, one tick
  per frame) + evidence/enemy-ai/.
- Numbers (scenario, seed 7, 3 of one archetype vs PitDummy FIGHT nailing inside 10 m):
  patrol 14.4 s to clear / 0 dmg; riot 17.5 s / 24 dmg; SWAT 22.8 s / 0; thug 13.2 s / 0;
  gunner not cleared in 40 s (holds 11 m, the dummy fires inside 10 m). Squad: 6 cops, at most
  2 attacking (planted: 6). Hit rate standing 0.50, dodging tells 0.24, with the aim lock off
  0.34. SWAT flank spread 111 deg, hidden 78 % of their waiting time. 4 of 6 down: 2 cops
  panic, 0 robots.
- FINDING: PitDummy reacts perfectly (the moment a lock starts), so the aim-lock length barely
  moves its numbers (lock 6/12/18/24 ticks -> 0.18/0.24/0.18/0.24). The lock window can only
  be tuned against a human-like reaction delay (about 0.2-0.25 s after the tell starts).
- ASK enemy-ai-1 (enemy toughness), default A (as built).
- Gates: lint 13/13; scenarios 20/20 (full suite); unit: only test_save_slots fails (254
  assertions), and it fails in the shared user://test_save folder that every worktree's unit
  run writes (all lanes' Godot runs share one user:// for this project name). FRICTION, not
  this lane's code (no save code touched); re-run alone on a quiet machine.
- Evidence: gtai-masters/eve/enemy-ai/ (2 clips, 5 stills, frames.json).
- MILESTONE 3023c4a: hit stagger. enemies.json `stagger_s` (patrol 0.45, riot 0.3, SWAT 0.35,
  gunner 0.25, thug 0 = shrugs), a hit that does not kill cancels the windup and returns the
  token; `EnemyPit.stun(e, ticks)` is the hook for the electroshock (melee lane). pose() adds
  `stagger`. tests/unit/test_enemy_ai.gd 6/6 (table, accuracy curve, token cap, stagger, robot
  shrugs hit + tackle, riot shield front vs back). scenario_enemy_pit still green.
- FRICTION test_save_slots: also 16/16 failing when selected on its own
  (`-gconfig= -gdir=res://tests/unit -gselect=test_save_slots`), and its scratch dir
  %APPDATA%/RTAI Uprising/test_save is shared by every worktree (custom_user_dir_name); another
  lane wrote test_page_age_params.json there in the same minute (21:22), so "alone" was not
  alone. This lane touches no save code. REQUEST 2 -> Director/int: check test_save_slots on
  main on a quiet machine; if it is the shared dir, give tests a per-worktree scratch dir.

- REQUEST 3 -> gunplay: the enemy gun tell is the windup (telegraph_s per archetype, 0.5-0.9 s)
  with the aim locking aim_lock_s 0.2 before the shot; EnemyPit emits
  Events.attack_telegraphed(weapon id) at windup start and Events.player_hit(weapon id) on a
  hit. Each archetype carries hit_fx (blood | sparks) for your hit-feel module: please expose
  one call (position, direction, hit_fx, killed) that EnemyPit.hurt() can make, and say if your
  tell art (aim line or muzzle glint) wants the locked/tracking phase as a separate signal.
- Clip 3 (stagger build): gtai-masters/eve/enemy-ai/pit_mixed_squad_fight_stagger.mp4, 5 kills
  in 20 s, 24 shots, 0 hits on the perfect dummy.

NEXT:
1. Re-read answers.json (enemy-ai-1).
2. PitDummy reaction delay (react N ticks after the tell starts, not at the lock), then
   measure lock 0.12/0.2/0.3 s; maybe an ASK on the tell timing with clips.
3. Stagger is in (3023c4a); still to do: wire the tackle (EnemyPit.knock) to the bodies
   lane's knockdown result, and a clip showing a stagger cancelling a windup.
4. Waves: data rows in enemies.json (or waves table), spawner in the pit, clip of waves 1-3 +
   damage per wave -> ASK difficulty curve (brief item 6).
5. The cutout rig: map pose() to rig clips (d5-cast rig); readable at 32 px/m.
6. Spacing: idle cops bunch up near each other at the wait ring (six-cops clip); spread them on
   the ring by slot. The dummy needs wall sense (it ends against the pit wall).
7. Align the pit size with the arena lane (36 x 26 m) and move into the arena scene via the
   station file once the arena is on this branch; a city-block proving run.

## Iteration 2 (21:27-22:12), BUILD

answers.json at 21:27: only rivet-motion-1 (not mine); enemy-ai-1 still open (default A holds).
Registry applied: encounter-balance-simulation's habit (measure the curve against a scripted
player profile, publish the profile with the numbers); difficulty-design: the curve is one
data value so the owner's answer is a one-line switch.

- MILESTONE 924f532: waves. `data/tables/enemy_waves.json` + schema (curves gentle / standard /
  steep, gates east/north/south as [x, y], breather_s 3, spawn_gap_s 0.6), `PitWaves` (loader,
  interleaves the gates), `WaveRun` (BREATHER -> SPAWNING -> FIGHTING per wave, report per wave:
  start, seconds, damage, shots, hits, max_alive), `PitLayout.wave_fight`,
  `scenario_enemy_waves` (live curve clears, no overlap, breather holds, replay digest equal;
  planted fault: overlapping waves caught, max_alive 7 > 5).
- FIX (found by the wave runs, same commit): EnemySenses.detour (1) re-picked the corner the
  walker already stood on (zero velocity forever: a cop parked at a box corner for 200 s);
  (2) tested the line to a corner against the bare box, so a body on a box face aimed through
  its own push-out zone and stayed pinned (two SWAT stuck on the east face of the low wall).
  Now: corners within 0.3 m are skipped and reachability uses the box grown by the body
  radius - 0.05. scenario_enemy_pit still green; its evidence numbers moved (movement changed).
- PitDummy human profile: react_ticks (dodges N ticks after a tell starts), read_frac (share
  of tells noticed, a low-discrepancy pick per tell, no RNG), aim_err_deg (nail spread, a fixed
  golden-ratio sequence, no RNG: the dummy never touches the fight's streams).
- Numbers (scenario seed 31, human profile, fire inside 16 m; identical in the view clips):
  standard 7.9 / 18.2 / 20.5 s, dmg 0 / 0 / 0; steep 16.9 / 19.6 / 26.4 s, dmg 0 / 4 / 20;
  gentle 8.2 / 16.6 / 15.4 s, dmg 0. FINDING: enemies barely hurt even a 70 %-reader: the
  dummy one-shots cops at 16 m before they reach their 14-20 m firing range, where their
  accuracy is 25-35 %. Per-archetype danger is the next knob (not the wave count).
- Aim lock vs a reacting dodger (react 0.25 s, reads every tell, 3 shooters): lock 0.12 s ->
  hit rate 0.237, 0.20 -> 0.211, 0.30 -> 0.0. With a 0.5 s patrol tell, a 0.3 s lock starts
  before the player has reacted, so a reacting player always escapes; 0.2 keeps a sliver of
  tracking. Keep 0.2 (as built).
- ASK enemy-ai-2 (first difficulty curve), default B = steep, applied in data.
- Evidence: gtai-masters/eve/enemy-ai/pit_waves_standard_1-3.mp4 (58 s), pit_waves_steep_1-3.mp4
  (74 s), 3 stills, clip stats JSON; frames.json now 12 entries. Seen: in the steep clip a SWAT
  idles at the north edge at t 45 (probably waiting for a token out of sight; check next).
- MILESTONE e369543: the pit view runs a curve (--curve, --human=1, --every=2 for a 30 fps
  real-time clip).
- MILESTONE 604fec8: unit tests test_enemy_waves (curves load, gates interleave, a wave waits
  for the clear plus the breather). Caught: an Array[StringName].sort() is not alphabetical
  (sorts by interned pointer); curve_ids sorts by String now.
- MILESTONE 354ba63, two more behaviour bugs the waves surfaced:
  (1) MORALE counted every enemy the pit ever spawned, so from wave 2 on patrol cops (morale
  0.5) broke after the first death (wave 1's dead counted). EnemyAgent.squad (the wave index)
  + EnemyPit.fallen_frac(squad). Unit test added.
  (2) CORNER PING-PONG: a corner the target is still hidden from was costed as if the line went
  on through the box, so two corners took turns winning and a SWAT oscillated 0.3 m behind the
  north-west crate for 200 s. Blind corners now rank last (+100 m).
  The pit view's tag shows pose/brain-state (how the alert SWAT was spotted).
- Numbers after the fixes (seed 31, human profile): standard 14.5 / 18.3 / 25.7 s, dmg
  0 / 0 / 16; steep 15.9 / 21.9 / 24.7 s, dmg 0 / 0 / 0 (99 enemy shots); gentle 8.2 / 14.2 /
  11.5 s, dmg 0. Clips re-rendered (wave 3 cut ~2 s before its clear).
- ANSWER enemy-ai-1 (owner, 21:25 via answers.json): A as a placeholder; "not judgeable in
  this state - no weapon design, no final animation, no opponent hit reaction"; stop tuning on
  numbers, re-ask only with real-time clips in the final look (common.md, Owner direction
  21:25). Recorded in docs/decisions.md.
- WITHDRAWN ask enemy-ai-2 (difficulty curve): its clips are debug circles with no hit chain,
  so under the 21:25 rule 4 it is not a valid ask; deleted the file at 21:53. The curve is my
  call: steep stays the pit default (most pressure; the arena is a stress test).
- DIRECTION CHANGE (common.md 21:25): depth before breadth; enemies must be the cast rigs, not
  circles; the 00:00 sample is a patrol cop and a robot thug with full hit reactions and
  deaths, against Rivet's pistol and claw combo, in the arena, one 20-40 s clip per lane.
- Scouted for that: features/characters (CutRig.drive/hit(from_dir, strength); RigClips SHOOT,
  HIT, DEATH, knockdown fall/rise), dev/showcase/d5_arena_run.gd (Rivet vs two cops on the rig,
  on King's arena floor, the closest template), KingPlan (the robot boss on Rivet's skeleton,
  SIZE_K 1.3: a candidate base for the robot thug until a thug plan exists).
- Gates at 354ba63: lint 13/13; unit 543/543 at e369543 (+4 new enemy-wave tests green since);
  scenarios: full suite 21/21 green at 530fb96 (21:58).
- Housekeeping: gtai-masters/eve/enemy-ai/fr_steep/ (raw frames, ~44 MB) could not be deleted
  (it was the session's cwd); delete it next session.

NEXT:
1. Re-read answers.json. Delete gtai-masters/eve/enemy-ai/fr_steep/.
2. The 21:25 sample, enemy half: an EnemyRigView that drives CutRig cops (patrol cop first)
   from EnemyAgent each tick: facing + velocity -> drive(), pose() -> RigClips (shoot -> SHOOT
   recoil, windup -> a raised-gun aim hold, hit/stagger -> HIT with from_dir, die -> DEATH,
   down/getup -> the bodies lane's fall/rise). Start from d5_arena_run.gd's setup, at 32 px/m,
   D5 look, real-time clip.
3. The robot thug on a rig: KingPlan scaled down (or a thug plan), the claw windup as a pose,
   sparks on hit (hit_fx). Then the gun tell in the final look (coordinate with gunplay).
4. Full scenario suite + run_unit before the freeze; then the 20-40 s lane clip for 00:00.
- Scout detail for NEXT 2 (21:58): the rigs are data-fed through RigFeed rows (put(i, id,
  kind, pos_px, vel); face[], aim[], flags[] = DEAD | AIMING | GUN_OUT | FLEE | DOWN; clip[] +
  clip_arg[] per row = a RigClips.Clip to trigger). CharacterRigs.step_ticks / rig_for(id).
  So the enemy half is one adapter, `features/combat/ai/enemy_rig_feed.gd`: per tick, every
  EnemyAgent -> a feed row (pos * 32, vel, facing.angle(), aim, flags from state: WINDUP/FIRE ->
  AIMING|GUN_OUT, PANIC -> FLEE, DOWN -> DOWN, DEAD -> DEAD; clip: shoot -> SHOOT with the
  weapon's kick, hurt_tick == now -> HIT with the blow direction, died_tick == now -> DEATH).
  d5_arena_run.gd's _cast/_pose show the feed in use (RIVET + 2 COP rows, looks 5 and 6).
  BodyPlan.Kind is only RIVET, COP, PED: the robot thug needs a ROBOT kind (KingPlan-based,
  smaller) in features/characters; that file is the d5-cast/rivet-motion area: ask in a
  REQUEST or add a minimal kind with a JOURNAL note.
- MILESTONE (22:00): EnemyRigFeed (features/combat/ai/enemy_rig_feed.gd): pit enemies -> RigFeed
  rows, ready for CharacterRigs/RigInput. Flags: GUN_OUT for ranged (not in panic/down), AIMING
  in WINDUP/FIRE, FLEE, DOWN, DEAD; clips: DEATH on died_tick, HIT (arg = blow angle) on
  hurt_tick, SHOOT or PUNCH (swing) on the new shot_tick. Robots use the COP kind for now.
  tests/unit/test_enemy_rig_feed.gd 3/3; enemy units 13/13; enemy scenarios green; lint 13/13.
  Not yet rendered: NEXT 2 is now "a dev scene that hosts CharacterRigs and feeds it from
  EnemyRigFeed + Rivet's row, at 32 px/m in the D5 look, real-time clip".

## Iteration 3 (22:00-22:45), BUILD: the pit fight on the cast rigs
- 22:01 answers.json re-read: nothing new for enemy-ai (enemy-ai-1 = A placeholder, recorded).
  Deleted gtai-masters/eve/enemy-ai/fr_steep/.
- MILESTONE a8b5512: dev/enemy_ai/enemy_rig_fight.gd (+ _run.gd launcher, enemy_fight_fx.gd):
  the pit fight (PitLayout + PitDummy as Rivet) drawn by the CAST RIGS in the D5 look at 32 px/m
  (look_d4 + look_d5 overlay from D5ShowcaseRun, RigDetail on), never circles. Cops = CharacterRigs
  rows written by EnemyRigFeed.row() (new; write() loops it); robots = their own CutRig on
  KingPlan(1.05) with collar_part cleared (vermilion is Rivet's collar only), fed by a second
  RigFeed + RigInput.apply, so no shared features/characters file changed (no ROBOT body kind yet).
  Chain on screen: gun tell (vermilion aim line from the rig's muzzle, thin while tracking, thick
  once locked), melee windup arc, muzzle star 2 ticks, tracers (warm paper enemy rounds, steel
  nails), HIT clip shoved along the blow + the rig's own hit flash, CombatBlood: red splash on a
  hurt human, kill_human on a death (pool), robot_hit sparks/oil on robots and on Rivet; a 3-frame
  hold on a kill, an 8-tick camera shake when Rivet is hit. Camera eases on the fight's middle;
  CharacterRigs.focus = the camera centre (full rigs only within its 14 m radius, else the cop
  vanished: it is a baked-crowd row there).
- FRICTION: crates are crate_stack.png stretched to the box size; the barricade prop prints
  vermilion stripes (danger only), so the low wall is a crate too. Placeholder pit floor = flat
  D5 asphalt until the arena lane's scene is on this branch.
- First clip (rigfight_a, east column spawn, fire_m 12): both enemies dead in ~6 s, the cop fired
  2 rounds (0 hits), the thug never swung (6 nails before it closed). Numbers: kills 2, nails 13,
  nail hits 7, Rivet damage 0. Owner doctrine (enemies.json doc): humans die to one nail, so the
  patrol cop's hit reaction IS its death (DEATH shoved along the blow + blood); hp NOT changed.
  For the sample the run takes --spots (PitLayout.place: a staged, hot spawn) so the thug reaches
  Rivet and the cop gets its tell and shot off.
- Clip d (staged: cop at 9,-6, thug at 1,3, Rivet at -5,0, fire_m 10; pre-lunge code): the chain
  reads on the rigs: the cop's vermilion aim line from the muzzle, warm tracers, the thug's windup
  arc beside Rivet with white sparks and oil on every nail, the cop's death with blood and pool.
  But the thug died mid-windup again (swings 0, Rivet damage 0, 7 nails 7 hits, cop 4 shots 0
  hits). Clip runs b/c were wasted on a spots-order slip (spots follow the squad order: cop first).
- FINDING -> FIX 8a71359 (weakest item: melee threat): in scenario_enemy_pit the robot thug landed
  0 swings in its archetype run: at 2.4 m/s it never closes on a kiting shooter. The claw now
  LUNGES (weapon data lunge_m 3, lunge_mps 9, optional fields in the schema): the windup may start
  up to reach + lunge_m away; after it the thug dashes along the LOCKED aim (EnemyMotor.dash: no
  easing, cover still stops it) to 70 % of its reach, then swings. A sidestep after the lock is
  missed (unit test: 2.6 m sidestep -> 0 hits; a standing Rivet is caught). Registry rule applied
  (agent-behaviour-authoring / combat telegraphs): commit to the telegraphed line, never home in
  after the lock. scenario_enemy_pit thug run now: swings 1, hits 0 (the scripted Rivet dodges it).
  enemy units 16/16, enemy scenarios 2/2, lint 13/13.
- Clip e (lunge code, same staging): the thug's windup arc while the cop's aim line is up (two
  threats at once), the dash into Rivet, nails flash it (the rig's own hit tint) and spark it;
  it still dies a beat before the swing (swings 0: 7 nails, 7 hits, 6 hp; a race the scripted
  Rivet wins at 100 % close-range accuracy). Kept as rig_fight_lunge_race_32ppm.mp4. Clip f
  stages the thug 4.6 m out (inside reach + lunge at once) so the windup -> lunge -> swing reads.
- Clip f (thug staged 4.6 m out, i.e. inside reach + lunge at once): windup arc -> lunge -> swing
  (the arm thrown out) -> the scripted Rivet had stepped off the line: swings 1, hits 0; then the
  thug dies (7 nails, 7 hits). The cop: 2 shots, 0 hits. rig_fight_lunge_32ppm.mp4 (10 s, 30 fps
  real time) is the lane's lead clip; frames.json rewritten: 7 rig entries first, 5 debug-draw
  entries kept and marked superseded (12 total). Stats copied to evidence/enemy-ai/rig-fight-*.json.
- SEEN on the rigs (not fixed, not mine): a nail hit tints the whole robot rig vermilion-orange for
  a few frames (CutRig's hit tint, PartMaterials). Vermilion is reserved for danger; a hit flash
  on an enemy is arguably not danger. Note for d5-cast / gunplay (hit-feel owner).
- GATES at the lunge commit (8a71359 + docs): lint 13/13; unit 553/553 (run_unit.mjs); scenarios
  21/21 (full suite, 22:24); enemy units 16/16.
- 22:27 arena station `enemy_sample` (kind pit; the shared schema allows only id/kind/doc/script,
  so the staging lives in the doc): the 00:00 sample spawn and the run line.
- Clip g landed (22:33): rig_fight_two_pairs_32ppm.mp4, 15 s of action from a 24 s run (all four
  down by ~13 s): 4 kills, Rivet 17 nails 14 hits, cops 8 shots 0 hits, thugs 1 swing 0 hits.

NEXT:
1. Re-read answers.json (no enemy-ai asks open; ASK only with a real-time clip in the final look).
2. Clip g landed; to lengthen it to 20-40 s, add a third wave or a slower Rivet; re-run line (dev/enemy_ai/enemy_rig_fight_run.gd -- --seconds=24
   --squad=patrol_cop,robot_thug,patrol_cop,robot_thug --spots=9:-6,-1:2.5,16:5,15:-3 --fire_m=10)
   and encode at 30 fps; add it first in gtai-masters/eve/enemy-ai/frames.json.
3. The sample with Rivet's REAL weapons: the pit's Rivet is PitDummy (nails). When gunplay's pistol
   and rivet-motion's claw combo are on main, swap the dummy's rivet_fire for their API (or merge
   on the night run) so the cast-rig fight shows the finished pistol and claw against the enemies.
4. A robot thug plan + art (not King's skeleton): a ROBOT BodyPlan.Kind in features/characters is
   a d5-cast/rivet-motion file: REQUEST it, or land a minimal kind on the night run.
5. Suppression (the brief's "suppress" state): a nail passing within ~0.6 m of a human enemy
   flinches it / delays its windup; humans die to one nail, so a near-miss flinch is the only
   non-lethal reaction a patrol cop can show. Needs a distinct clip from HIT (a hit and a miss must
   read differently).
6. The city block clip (owner decision 1: tuned in the arena, holds in the city): the pit fight's
   brains on the generated city (dev/showcase/city_fight.gd is the closest host).
7. Robot hit tint note for d5-cast/gunplay (vermilion flash on enemy hits).

## Iteration 4 (22:34-23:18), BUILD: suppression, the long sample clip, the arena station format
- 22:34 answers.json re-read: nothing new for enemy-ai. Common brief re-read: test isolation
  (APPDATA=gtai-eve/appdata/enemy-ai) applied to every gate run from now on.
- MILESTONE 458fcde (brief work order 2, the "suppress" state; NEXT 5 of iteration 3):
  features/combat/ai/enemy_suppress.gd. A Rivet nail that has flown past a human enemy within
  0.6 m without hitting makes it flinch away from the nail (flinch_tick/flinch_dir on the agent,
  pose &"flinch"); during WINDUP/FIRE the flinch breaks the tell for 14 ticks (pit.stun: the aim
  line drops, the token goes back). Robots and a front-facing shield never flinch; 45-tick
  refractory. The rig fight shoves the rig sideways on a flinch (CutRig.hit, no tint, no blood),
  so a miss reads unlike a hit. Registry rules applied (agent-behaviour-authoring: reactions to
  the player's pressure must be visible and give the player a reward window; deterministic, no
  RNG). Unit tests test_enemy_suppress.gd 5/5 (near miss flinches away, a flinch breaks the
  tell, a hit is not a flinch, robots never, refractory).
- e01b895: scenario_enemy_pit judges suppression + planted fault plant_no_flinch:
  suppress {told, flinches 1, tells_broken 1, nail_hits 0, shots 0 in 25 ticks}; planted
  {tells_broken 0} -> caught. Decision line in docs/decisions.md.
- fc1844b (arena lane REQUEST 3, cross-session message): arena_stations/enemy-ai.json in the
  e-arena format (gtai.arena-station/1, "area": "pit", "name", no "script" because EnemyPit and
  PitLayout do not extend ArenaHook). DEVIATION: this branch's lint maps tables to
  <basename>.schema.json, so project/data/schemas/enemy-ai.schema.json stays as a verbatim
  copy of e-arena's arena_station.schema.json (an orphan after the merge; delete then). Arena
  lane told. Night-run item: an ArenaHook for the pit (setup builds EnemyPit; step drives it
  from stage.arena.rivet.pos).
- Gates: lint 13/13; unit 558/558 (run_unit.mjs, 22:45); enemy scenarios 2/2.
- Clip h (22:47, suppression code, pre-lead): rig_fight_three_pairs_flinch_32ppm.mp4, 24 s at
  30 fps real time, three cop + thug pairs staged at three depths (spots 9:-6,-1:2.5,16:5,15:-3,
  19:-10,19:9, fire_m 10): kills 6, nails 25 / hits 21, flinches 3, tells broken 1, cops 14
  shots 0 hits, thug 1 swing 0 hits, Rivet damage 0. Looked at the frames: the chain reads (blue
  cops, blood + pool on a death, robot sparks + oil field, aim lines, windup arc).
- FINDING -> FIX 09b59b1 (weakest item now: the threat at range): cops hit a strafing Rivet 0
  times out of 14 (scenario archetype run: 0 of 22). The aim locked 0.2 s before the shot on where
  he stood, and the pistol round flies 18 m/s, so any steady strafe made him immune. Guns now
  LEAD while they track (enemies.json squad.aim_lead 0.8 of his travel over the lock plus the
  round's flight); after the lock the aim is still frozen, so a change of course dodges. Registry
  rule (combat telegraphs / agent-behaviour-authoring: the dodge must be a read-and-react act, not
  a passive state). Unit tests test_enemy_aim_lead.gd 2/2 (lead hits a steady strafe more than
  0.2 better than no lead; a reversal at the lock halves the hits or better). Pit scenario:
  dodge 0.0, stand 0.5, lock off 0.053 (still caught). FRICTION: python on Windows wrote CRLF
  into the JSON (json-canonical failed); re-emitted via tools/lib/canonical_json.mjs.
- GATES at 09b59b1 (+ the flinch-frame stats commit): lint 13/13; unit 558/558 at e01b895 (+2
  aim-lead tests green in the enemy unit run, 23/23); scenarios 21/21 (full suite, 22:52).
- Clip with the lead only (22:55, fr_lead first pass): cops still 17 shots 0 hits. Root cause was
  the scripted Rivet, not the enemies: PitDummy dodged EVERY shot the tick it was fired (a FIRE
  state bypassed the read share and the reaction delay), a zero-reaction read no player has.
- FIX (pit_dummy.gd): the human-like dummy dodges a shot only if it noticed that enemy's tell
  (the same read_frac hash, remembered per enemy); the perfect reader (react_ticks -1, used by the
  pit scenario's dodge/stand/lock judges) is unchanged, so those judges did not move. The waves
  scenario (human profile) now draws damage on every curve (gentle 6 / 12 / 4 per wave).
  Enemy scenarios 2/2, enemy units 23/23, lint 13/13.

NEXT (night run):
1. Re-read answers.json. Encode clip i (fr_lead, the lead + dummy fix) if this session did not.
   ASK candidate with real-time clips in the final look: aim_lead 0.8 (a steady strafe is hit;
   only a juke after the lock dodges) vs 0 (strafing is safe): clip h (rig_fight_three_pairs_
   flinch, lead 0, but with the old dummy) vs clip i. Re-render clip h with lead 0 and the fixed
   dummy first, so the two differ only in the lead (`squad.aim_lead` in enemies.json).
2. An ArenaHook for the pit (features/combat/ai/enemy_pit_hook.gd extends ArenaHook once the
   arena scene is on main: setup builds EnemyPit + WaveRun, step drives it from
   stage.arena.rivet.pos, write_state = pit digest); then add "script" back to
   arena_stations/enemy-ai.json and delete project/data/schemas/enemy-ai.schema.json (orphan).
3. Swap PitDummy's nails for gunplay's pistol and rivet-motion's claw combo once merged; the
   sample clip with Rivet's real weapons and his real hit reaction.
4. A robot thug plan + art (not King's skeleton), a ROBOT BodyPlan.Kind (REQUEST d5-cast).
5. A flinch duck clip on the rig (RigClips is d5-cast/rivet-motion): today a flinch is only a
   sideways shove; a short crouch would read better at 32 px/m.
6. The city block clip (owner decision 1), dev/showcase/city_fight.gd as the host.
7. Robot hit tint is vermilion-orange (CutRig hit tint): note for d5-cast/gunplay.
- Clip i landed (23:03): rig_fight_three_pairs_lead_32ppm.mp4 (25 s, 30 fps real time, same
  staging as clip h, lead + dummy fix): cops 13 shots 2 hits, thug 2 swings 1 hit (first claw hit
  on Rivet tonight), Rivet damage 32, kills 6, nails 25 / 21 hits, flinch 1 (frame 291, saved as
  rig_fight_cop_flinch_f291.png: a claw hit sparks Rivet while a nail passes the cop). It is now
  the lane's lead clip in gtai-masters/eve/enemy-ai/frames.json (14 entries); stats copied to
  evidence/enemy-ai/. Raw frame folders deleted. No ask raised: Rivet is still the scripted dummy
  firing nails, which does not meet the 21:25 bar (final look with the finished pistol).
- Arena lane FYI (cross-session, 23:0x): e-arena 05c1b48 draws its fighters on the cast rigs
  (`-- --bot=pit --rigs`, dev/arena/arena_rigs.gd); ArenaRigs._put is the one place where the
  enemy rig rows (EnemyRigFeed.row, the robot plan) should replace its generic COP + HIT after the
  merge. Added to the night run: NEXT 2 (with the ArenaHook).
- GATES at the end of iteration 4: lint 13/13; unit 560/560 (run_unit.mjs, 23:04); scenarios
  21/21 (full suite, 22:52) + enemy scenarios 2/2 after the dummy fix.

## Iteration 5 (23:05-23:30), BUILD: the fair aim-lead A/B clip
- 23:05 answers.json re-read: nothing new for enemy-ai (enemy-ai-1 = A, placeholder; re-ask only
  with a real-time clip in the final look). No ask this iteration (Rivet is still the nail dummy).
- 34eea0c: enemy_rig_fight_run.gd takes --aim_lead=<f> (sets pit.roster.aim_lead after build), so
  the A/B differs only in the lead without touching enemies.json. FRICTION: `(x as Object)` on a
  Variant is an unsafe-cast warning = parse error; check-only caught it before the windowed run.
- Clip j landed (23:10): rig_fight_three_pairs_nolead_32ppm.mp4, the A/B partner of clip i (same
  staging, seed 31, fixed dummy; only aim_lead 0): cops 14 shots 1 hit, thug 1 swing 0 hits,
  Rivet damage 6 (clip i, lead 0.8: 13/2, swings 2/1, damage 32). Looked at f165 and f400: the
  chain reads. frames.json: j is now entry 2 and clip i's `before`; dropped the staged_prelunge
  clip (superseded by the lunge clips) to stay at 15.
- MILESTONE 3cd1378 + 5a635fa: dev/enemy_ai/aim_lead_ab.gd, a headless A/B (3 s for 2x20 fights).
  FINDING (the clip pair is n=1, so measured): the seed only moves the shot spread, so the 20
  seeds are one staging with spread varied; read it as such. Cop hit rate by the dummy's tell-read
  share (lead 0 -> 0.8): read 0 = 43.7 % -> 43.7 % (a Rivet who never reads stands and fights, so
  the lead has nothing to lead; 70 dmg / 25 s); read 0.7 = 8.2 % -> 10.8 % (damage 6.9 -> 28.4,
  most of the gap is the thug's claw: the lead does not touch melee, it moves Rivet into the
  claw, a second-order effect); read 1 = 0.4 % -> 1.7 %. So the TELL decides the hit (the
  design contract: a watched tell is a dodged shot), and the lead only punishes moving without
  reading. evidence/enemy-ai/aim_lead_ab{,_read0,_read1}.json.
- Design read for the owner (no ask: the 21:25 bar needs the final look): at read 0.7 a cop
  lands ~1 shot in 10. That is low pressure at range for a human who reads most tells; the dial is
  accuracy by range or max_shooters, not the lead. Not tuned tonight (owner: stop tuning on
  numbers until the final look).

NEXT (night run; supersedes the iteration 4 list's items 1, the rest stand):
1. Re-read answers.json. The lead A/B is ready as evidence (clips i/j + aim_lead_ab*.json), but
   ASK only once Rivet fights with gunplay's pistol and rivet-motion's claw (21:25 bar).
2. Pressure at range: a human reading 70 % of tells is hit ~1 in 10. Before any tuning, sweep
   accuracy-by-range and squad.max_shooters with aim_lead_ab.gd (add --acc / --shooters knobs)
   and pick the curve against the wave targets in pit_waves; then one clip per candidate.
3. aim_lead_ab: make the seed move the dummy too (its read hash is seed-free today), so 20 seeds
   are 20 fights, not one staging with spread varied.
4. Items 2-7 of the iteration 4 NEXT (ArenaHook, real weapons, robot plan, flinch duck, city
   block clip, robot hit tint note).
- GATES at the end of iteration 5 (d4f26ea): lint 13/13; unit 560/560 (run_unit.mjs, 23:14);
  scenarios 21/21 (full suite, 23:15, exit 0). No sim change this iteration (dev + evidence only),
  so replay and parity goldens are untouched. Godot processes from this session all exited.

## Iteration 6 (23:16-23:30), BUILD: the seeds become fights (NEXT item 3)
- 23:16 answers.json re-read: nothing new for enemy-ai (enemy-ai-1 = A placeholder stands).
- a6851c8: PitDummy.read_salt (default 0 = the historic read pattern, so scenario_enemy_waves and
  every clip are unchanged); aim_lead_ab.gd sets read_salt = seed (--salt=0 restores the old run).
  Now 20 seeds are 20 fights: which tells the dummy reads differs per seed, not only the spread.
- MILESTONE 3d74df6, CORRECTION of the iteration 5 finding (n=20 real fights now). Cop hit rate,
  damage per fight, lead 0 -> 0.8: read 0 = 43.7 % -> 43.7 %, 69.8 -> 69.8 (unchanged, as
  before); read 0.7 = 10.7 % -> 11.4 %, 13.6 -> 15.9 (iteration 5 said 6.9 -> 28.4: that gap was
  one staging's luck, the claw pull-in effect is mostly not real); read 1 = 0.4 % -> 1.7 %, 0.3 ->
  2.7. So the lead is a small dial (+2 damage per 25 s fight for a 70 % reader); the tell decides
  the hit, and the pressure-at-range question is accuracy and max_shooters, not the lead.
  evidence/enemy-ai/aim_lead_ab_salted{,_read0,_read1}.json. Clips i/j stay as the look of the
  chain, but their damage numbers are n=1 and must not be quoted as the effect of the lead.
- FRICTION: --check-only -s on a script that uses the Log autoload reports "Identifier not found:
  Log" (no autoloads in check-only); the real headless run is the check for those files.
- GATES (23:19): lint 13/13; unit 560/560; scenarios 21/21 (exit 0). Sim untouched (dev knob
  with default 0), replay and parity goldens untouched.

NEXT (night run; supersedes iteration 5 items 1 and 3, the rest stand):
1. Re-read answers.json. ASK on the lead only once Rivet fights with gunplay's pistol and
   rivet-motion's claw (21:25 bar), and quote the salted numbers, not clip i/j damage.
2. Pressure at range: add --acc (scale the accuracy-by-range curve) and --shooters
   (squad.max_shooters) knobs to aim_lead_ab.gd, sweep them salted at read 0.7, pick the curve
   against pit_waves' targets, then one clip per candidate.
3. Iteration 4 NEXT items 2-7 (ArenaHook, real weapons, robot plan, flinch duck, city block
   clip, robot hit tint note).
- 23:22 NEXT item 2 started: aim_lead_ab.gd --shooters=<n> (overrides squad.max_shooters; default
  2 from enemies.json). Salted, read 0.7, 3 cops + 3 thugs, damage per 25 s fight (lead 0 / 0.8):
  shooters 1 = 10.9 / 17.0 (shots 246/234, hit 9.4 % / 12.8 %); 2 = 13.6 / 15.9; 3 = 14.4 / 19.0
  (shots 312/409). Shooters move volume, not much damage: the tell read still caps the hit rate
  near 10 %. So pressure at range for a 70 % reader needs the accuracy curve or a shorter
  tell-to-lock window (aim_lock_ticks), not more shooters. --acc knob is still open (item 2).
  evidence/enemy-ai/aim_lead_ab_salted_shooters{1,3}.json. Lint 13/13 after the change.
- 23:24 f9366b9: the pre-commit hook caught a 100+ char usage line and _initialize at 43 lines on
  the first try; split the usage line, moved the file write to _write(). Lint 13/13. Re-running
  --shooters=1 rewrote its evidence byte-identical (the sweep is deterministic). Unit/scenarios
  not re-run after this commit: dev-only file, no sim or test code touched since the 23:19 green
  run. The two Godot processes still alive (PIDs 33868, 39464) are not this session's; all my
  runs were under `timeout` and exited. NEXT stands as written above (item 2: the --acc knob next).

## Iteration 7 (BUILD, session start 23:24, freeze 23:30)
- 23:25 Read JOURNAL tail and answers.json: only enemy-ai-1 answered (21:45, keep A as a
  placeholder; re-ask only with the full D5 chain clip). Nothing new to apply. Six minutes to
  freeze, so no code change this session: starting the --acc knob and leaving it half-done and
  un-gated would be worse than landing nothing. Tree clean at b611a13 before this entry; last
  green gates are iteration 6's 23:19 run (lint 13/13, unit 560/560, scenarios 21/21).
NEXT (night run, unchanged from iteration 6 close): item 2 first: the --acc knob on
  aim_lead_ab.gd (scale the accuracy-by-range curve) and an aim_lock_ticks sweep, salted at read
  0.7, since --shooters showed volume, not damage; then the iteration 4 items 2-7.
