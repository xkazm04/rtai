# JOURNAL: lane human-reactions (branch n-human-reactions), night run 2026-11-04

## Iteration 1 (01:05-02:05), BUILD

Read: brief, enemy-ai REPORT, hit_feel README, RigClips/CutRig/RigPose/RigSprings/RigGait,
ArenaRigs, CombatArena.struck, HitLink. Registry rules applied (realtime-combat-semantics,
motion-quality-gating): every reaction is direction-true (the body moves along the round's
travel, the head snaps with it), a fast attack (0.15 of the family) and a slower ease back, the
families are distinguishable in silhouette at 32 px/m (knockdown and deaths change the outline,
flinch/stagger/stun change the pose), the corpse holds a pose that names its death. Deviation:
no authored key poses or sprite art yet; every family is procedural on the cutout rig.

- MILESTONE 01:17 f1ada818: reaction + death layer (`features/combat/react/`), table
  `human_reactions.json` + schema, CutRig `react` slot, unit test (8 tests), dev board
  `dev/human_react/react_board.gd`. Lint 13/13, unit 703/703 at that commit.
- FRICTION 01:16: first board render showed the feet left behind when a body slid (feet are
  world-planted, only the body node moved). Fixed: travel moves the rig node (`HumanReact.slide`),
  the feet follow. Blood also piled up across segments; the board now starts each segment clean.
- Evidence: `evidence/react_families_32ppm.mp4`, `evidence/react_families_64ppm.mp4` (27 s each,
  real time, 12 captioned segments: patrol, riot, patrol, riot, ped, ped hit from front, behind,
  north, south). Contact sheet checked (`evidence/sheet_check.png`).
- MILESTONE 01:22: ReactLink (CombatArena.struck -> wound family / standard death on the rig via
  DeathPipe), wired into ArenaRigs (`--rigs`), which drops its old HIT clip when the link is on.
  test_react_link 3/3.

### Replies to REQUESTs
- gunplay REQUEST 1 (kill_landed payload): AGREED as proposed. ReactLink listens to `struck`
  (which already carries lethal + weapon + dir) today; when kill_landed lands I switch deaths to it
  and map `kind` (shot/blown/burned) over the weapon's hit class (burned -> death_burn, blown ->
  death_blast). Please keep `dir` = the round's travel (that is what the reaction falls along).
- brutality REQUEST 2: DONE as a hook. `DeathPipe.add_signature(func(rig, hit_class, dir, weapon)
  -> bool)`; return `SignatureKills.consumed.has(rig.actor_id)` (rig.actor_id == Fighter.id) and the
  standard death never starts. ReactLink.pipe is the arena's DeathPipe.
- showcase REQUEST 2: the flinch/stagger toward the hit and deaths by kind are live on the pit
  cops under `--rigs` from this commit (ReactLink in ArenaRigs). Shock from the jab maps to
  stun/death_shock when its weapon row's hit_class is `shock`.
- MILESTONE 01:28 f6813fe4/f9eff12b: `scenario_human_react` (every wound family clears within 1
  tick of its table length; knockdown lies 1.57 s flat; stagger + round kill carry along the round
  from 4 sides, min dot 1.0; burn kill chars; two runs same digest). Planted faults all caught:
  inverted direction (dot -1.0), no burn row (char 0.0), signature takes the death.
- FRICTION 01:25: in the live arena the corpses vanished when Rivet turned: CharacterRigs keeps
  full rigs only within 14 m of a focus 7 m ahead of Rivet. Fixed in ArenaRigs (focus = centre of
  the box around Rivet, his aim point and hostiles within 20 m) and ReactLink (a corpse whose rig
  comes back re-plays its death at the last frame, `HumanReact.settle`).
- MILESTONE 01:32 4a2d9e3c: arena station `react_line` (4 never-dying dummies in the hub).
- MILESTONE 01:37 39582854: `--rigs` on the city block (`--arena=city`): ArenaRigs attaches to the
  CityView actor layer (before: no rigs at all there). Clip `city_pit_rigs_32ppm.mp4` = game-city.
- Gates 01:42 on 39582854: lint 13/13, unit 706/706, scenarios 29/29. Parity/replay untouched
  (render-only layer, no sim change).
- Evidence: `gtai-masters/n4/human-reactions/` (frames.json, 7 entries): city block 32 px/m,
  arena pit 32 px/m, reaction board 64 and 32 px/m, three contact sheets.
- Rejected clip: city block at 64 px/m (camera on Rivet, the deaths happen off-frame).

NEXT (iteration 2, in order):
1. Crowd reactions (brief item 4): pedestrians under fire in the city (duck, cover head, flee away
   from the shooter, trip over bodies). The city sim owns ped motion (native); start render-side:
   a `cower` family on CityCharacters' full rigs from the FLEE flag + nearest shot, then ask what
   the sim already exposes (panic state) before touching native.
2. "Shoot each cop type from four directions" in the arena itself: a bot for the `react_line`
   station (or `--start=hub` + a scripted walk around a dummy), clip at 32 + 64 px/m.
3. Riot shield + SWAT in the arena: Fighter has no shield/archetype; the arena pit spawns
   GuardBrain contractors only. Feed EnemyRigFeed looks (riot = look 6) through ArenaRigs when the
   enemy-ai pit is hooked into the arena (enemy-ai NEXT 2), so `shield` plays in the live game.
4. Switch deaths to gunplay's `CombatArena.kill_landed` once it merges (kind shot/blown/burned ->
   death family); hook brutality's SignatureKills through `ReactLink.pipe.add_signature`.
5. Quality: the drawn carry ignores cover (a body can slide onto a crate); board blood drag streak
   is a hard rectangle when `slide_px` is large (clamp it); electro death reads close to the round
   death at 32 px/m (stiffer plank: arms locked to the sides); the robot thug skeleton (item 5).
6. A 64 px/m close-up in the arena/city needs a camera on the victim (`--start` or a dev cam).
- 01:44 board re-rendered with the pool lead clamped to 10 px (`POOL_LEAD_MAX_PX`). FINDING: the
  hard vertical red bars under victims hit from north/south remain, so they are CombatBlood's
  spray along a vertical `dir` (d5-combat blood), not the pool lead. REQUEST 1 -> gunplay (owns the
  CityBlood/CombatBlood fixes tonight): `CombatBlood.kill_human(pos, Vector2.UP/DOWN)` draws a
  rectangular streak; see `gtai-masters/n4/human-reactions/react_families_64ppm_sheet.png` rows
  8-10, columns 3-4.
- 01:46 tried an electro "plank" death (tuck to pull the feet together, squash undone): it read as
  a curled huddle at 64 px/m, worse than the X; reverted. The plank needs the legs straight and
  together, which RigGait's sprawl spread cannot do: a `c_plank` envelope in RigGait._clip_feet
  (feet at (-210, +-60) instead of +-230) is the d5-cast-side change to ask for or make.
- Scratch cleaned (board frames deleted; clips stay in evidence/ and in gtai-masters). Encoder for
  the captioned board clips: `evidence/enc_clip.py <frames dir> <out.mp4> <title>`.

## Iteration 2 (reconstructed from git, the session left no journal lines)
- 68e13449 merged n-gunplay (b3b3c92f): kill_landed payload + FightAreas states.
- 8669b5d9: gunplay REQUEST 2 answered: stun convulses / burn flails / knockdown lies for as long
  as the FighterFx state lasts (`ReactLink.hold`, HOLD spans), then runs out; kill_landed kind
  picks the death (burned -> death_burn, blown -> death_blast). rivet-arsenal REQUEST 1 DONE: the
  hit flash is cream, not vermilion (print_part.gdshader).

## Iteration 3 (01:53-02:53), BUILD
- FRICTION 02:00: the line's dummies are GUARD fighters whose GuardBrain turns them to Rivet, so
  every round landed from the front in the victim's own space: "four sides" would be the same
  flinch four times. Fix, render-only: ArenaRigs feeds the line's dummies a fixed east facing.
  Also: the 2.5 m line put Rivet on top of the dummy on W/E (the rigs are wider than the 0.45 m
  collision radius); respaced to 4 m (x 1, 5, 9, 13; y 1.5), W/E shots from 2 m, N/S from 2.8 m.
- MILESTONE 02:03 d0b230b6: `--bot=react_line` (ReactLineBot): Rivet walks round each dummy and
  shoots it once from W, N, E, S (16 shots, 16 hits, deterministic); the line wears looks
  (patrol cop, riot cop, ped coat, ped hoodie; peds unarmed); `ReactLink.shielded(rig)`: the riot
  look blocks a front round in the live arena (before: `shielded` was always false). Unit 717/717,
  lint 13/13.
- DECISION human-reactions: the riot shield is render-only tonight (the sim's hp still drops on a
  shield block; Fighter has no shield). Rejected: a shield in CombatArena (gunplay's sim, moves
  the replay goldens). Alternative = one flag when enemy-ai's riot archetype reaches the arena.
- Evidence: `react_line_4sides_32ppm.mp4`, `react_line_4sides_64ppm.mp4` (35 s, captioned per
  shot), `react_line_4sides_64ppm_sheet.png` (rows = looks, cols = W N E S) in gtai-masters.
- Gap: no SWAT look exists in d5-cast (RigVariant.crowd has patrol and riot only); adding index 8
  breaks CrowdAtlas (LOOKS = CROWD_COUNT). SWAT stays out of the line until the cast has it.
- 02:04 board-side REQUEST check: no new REQUESTs to human-reactions (showcase REQUEST 6 was
  withdrawn by showcase itself; gunplay 1/2, brutality 2, rivet-arsenal 1 all answered).
- MILESTONE 02:08 8e93389a: crowd startle. `cower` family (crouch drawn smaller, both hands over
  the head, head tucked, a 0.3 m hop away from the bang, 0.7 s) + `CrowdReact` on CityCharacters
  (boot/city_characters.gd, a 2-line shared-file change: `crowd.observe(rigs, steps)` after the
  feed fill): a pedestrian whose FLEE flag switches on cowers DELAY_TICKS 3 later along its new
  flight, then the sim's flight runs on (RigClips already raises the hands while fleeing). Already
  fleeing when first seen = no startle; cops never cower. Unit 720/720.
- MILESTONE 02:10 bf5300e7: reaction board segment "pedestrians startled by a shot"; clip
  `crowd_cower_64ppm.mp4` + sheet. It reads (a small knot, arms over the head) but is subtle at
  32 px/m: quality item for later (scale 0.8 -> 0.72, hop 0.3 -> 0.45 m).
- FINDING 02:12: the arena's own gunfire on the city block (`--arena=city`) never reaches the
  city sim: the sim scares pedestrians only when ITS rounds kill one (sim_shots._scare), on a car
  strike, or in a riot (M_RIOT, already FLEE). So the crowd round the arena fight does not flee
  or cower. Needs a `scare(x, y, r)` entry: CitySimState + CityCore (native) + the binding + the
  backend abstract + parity (NAT-06). Not started tonight at 02:12 (35 min left; other lanes'
  DLL copies would lack the method). Iteration 4 item 1.
- MILESTONE 02:13 b3f7ded6: the city's own kills play the standard deaths. CrowdReact turns each
  DEAD onset on a full rig into DeathPipe.kill along the sim's slide (the snapshot heading at
  death = the round's travel; slide speed > 4 m/s = a car = blast death, thrown). DeathPipe, so
  brutality's signature hook works in the city too (CityCharacters.crowd.pipe.add_signature).
  Carry 0.3 (the sim slides the body itself). Unit 722/722.
- Evidence 02:16: `riot_deaths_32ppm.mp4` (city_bench --scenario=riot, 25 s): 15 standard deaths
  on full rigs, measured with a temporary log (reverted). Honest read: the riot is so dense that
  a single death does not read in a still; a sparser street fight will show them better.
- Gates on bf5300e7: lint 13/13, unit 720/720, scenarios 30/30. On b3f7ded6: lint, unit 722/722.

NEXT (iteration 4, in order):
1. City sim `scare(x, y, radius)`: CitySimState/CitySimRef (GDScript reference, the body of
   sim_shots._scare with a radius), CityCore::scare in native/sim_core (spawn.cpp next to
   strike), binding (city_sim.cpp/.h bind_method), CitySimBackend abstract + CitySimNative;
   `scons platform=windows arch=x86_64 target=template_debug` + template_release, then
   `--import` (my native/godot-cpp is an empty submodule: build against int-day's
   native/godot-cpp, which has the prebuilt libs; CityCore::scare(x, y) ALREADY exists in
   projectiles.cpp, private: make it public + bind it, that is all the native work); parity gate (`node tools/tests/run_parity.mjs`). Then the arena on the city block
   calls it on every shot Rivet fires and every landing (ArenaSession/ArenaStage when
   `city != null`; it IS a sim write, so it goes through the input-driven tick and the replay
   golden may move: a dated decisions line + re-bless). Clip: `--arena=city --rigs --bot=gunplay`
   with pedestrians cowering and fleeing from the fight, 32 + 64 px/m.
2. Cower quality: scale 0.8 -> 0.72, hop 0.3 -> 0.45 m, a short look-back toward the bang
   (head_rot) before the run; re-film the board segment at 32 px/m.
3. Trip over bodies (brief item 4): the sim knows corpses (M_DEAD slots); a fleeing ped whose path
   crosses a corpse within 0.5 m -> render-side stumble (stagger family, small); or sim-side
   later.
4. A sparse street-fight clip of the city deaths (the riot is too dense to read single deaths):
   city_bench with fewer rioters, or `--arena=city` once item 1 lands.
5. Robot thug (brief item 5): own skeleton, sparks/oil per hit, light.
6. SWAT look: none in d5-cast (RigVariant.crowd 0..7; CrowdAtlas sizes by CROWD_COUNT). Write a
   REQUEST to whoever owns the cast tonight, or add index 8 arena-only with an atlas clamp.
- FRICTION 02:20: the evidence gate's selftest showed look goldens 8/11 (d4@64, auto@56, auto@64
  off on the far share). Bisected by disabling the CrowdReact hook: 11/11 worst 0.02, so mine.
  Side-by-side of d4@64 (scaled to the golden size): only the junction riot's corpses differ (the
  standard death poses along the round instead of the generic X sprawl). Deliberate: RE-BLESS
  592b5ae0 + decisions line. After: look 11/11 (worst 0.00), block 5/5.
- Gate 02:30 on 592b5ae0 (`node tools/evidence/run.mjs --no-bench --allow-dirty`): lint 13/13,
  unit 722/722, scenarios 30/30, parity bit-exact (planted mutation caught at 629), selftest FAIL
  only on the accent audit: NEW 32 px/m vermilion on vehicles 4 px + on cop 4 px. NOT mine: same
  with my hook off; showcase traced it to gunplay's blood flicker round (their REQUEST 7 ->
  gunplay, debt rows to move). Bench not run (render-only lane work this iteration).
- Lesson: never edit a tracked file while the evidence run is going (it flags "tree changed
  during run" and fails the unit kind even at 722/722).
- MILESTONE 655cf163: cower quality: a glance back at the bang (first 0.3 of the family), crouch
  0.72, head tucked further, hop 0.45 m. Board re-filmed (crowd_cower_32/64ppm.mp4, the sheet is
  now the two pedestrians only). Look goldens unmoved (11/11 worst 0.00), unit 722/722.
- MILESTONE bad59551: `scenario_react_line` (the reaction line on the real ArenaSession: 16 shots,
  16 hits, 4 per dummy, each round travels from the side it was shot from, min dot >= 0.95,
  replay identical on a fresh world; planted fault: every spot on the west, the direction check
  fails as it must). Scenarios 31/31.
- Scratch cleaned: AVIs and board frames under build/hr deleted; clips live in gtai-masters
  (frames.json 13 entries, every file checked to exist).

### Calls for the owner (draft for the REPORT)
- Riot shield is render-only tonight: a riot cop shot from the front recoils behind the shield,
  but the sim still takes the hp. Option B: the shield also stops the round (CombatArena change,
  re-bless replay goldens). Clip: react_line_4sides_64ppm.mp4 (riot cop, "from the east").
- City corpses now lie in the standard death poses (along the round) instead of the old X
  sprawl: look goldens re-blessed. Compare tests/golden/look/d4-64ppm.png before/after 592b5ae0.

NEXT (iteration 4): unchanged list above (sim scare entry first; CityCore::scare exists, private).
Also: a sparse city street fight to show single deaths; SWAT look; trip over bodies; robot thug.
