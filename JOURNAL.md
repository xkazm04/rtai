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

### REQUEST 1 -> weapon-art (02:38, low priority, after the weapons)
A SWAT look for the cop rig (the brief's third cop type; d5-cast has patrol and riot only):
two parts on a chroma-green part sheet in the d5 cop style (`features/characters/art/d5/cop/`,
parts.json cells), top-down like `head_helmet` / `torso`: (1) `head_swat`: a rounded tactical
helmet with a visor band, about 147 x 134 px like head_cap; (2) `torso_swat`: a plate-carrier
vest over the blue shirt (pouches as flat ink blocks, cop blue stays the main fill, no red, no
vermilion), 164 x 288 like torso. I wire the look (RigVariant + the arena line) when it lands.

## Iteration 4 (02:38-03:38), BUILD
- 02:38 read JOURNAL, git log; no new REQUESTs to human-reactions found in the brief scan.
- MILESTONE 02:50 698c9543: the city sim's `scare(x, y)` entry. CityCore::scare was private in
  projectiles.cpp: made public + bound (`CitySim.scare`), `CitySimBackend.scare` abstract,
  CitySimRef -> CitySimShots.scare (renamed from _scare), CitySimNative guards with has_method so
  other lanes' DLLs built before it skip the call (parity would show the drift). Built against a
  copy of int-day's native/godot-cpp (my submodule dir was empty; the copy is not committed):
  debug 2m17 + release, both DLLs in project/native/bin. Parity now drives a scare every 61 steps
  on both sides: bit-exact over 1200 steps, planted mutation caught at 629.
- MILESTONE 02:51 2109c74b: `CityScare` (features/combat/react): a WorldSystem ArenaSession adds
  between the stage and the city on `--arena=city`: each new round's muzzle and each landing
  (CombatArena.struck) becomes a sim scare (merged within 1.5 m, at most 4 a tick); the scare
  count goes into the replay hash. scenario_city_scare: 58 bangs in 20 s, 3 people near the fight
  fled (0 with the planted scare-off fault), replay identical. Quest 1's own rounds have no
  `origin` (gunplay sets it only for GunHand rounds): CityScare falls back to the shot's position.
- FRICTION: run_parity.mjs said "native CitySim not loaded" because GODOT_BIN was a shell var,
  not exported; `export GODOT_BIN=...` fixes it.
- Gates on 2109c74b: lint 13/13, unit 722/722, scenarios 32/32, parity bit-exact.
- Quest 1 on the city (quest1_session.gd) does NOT get CityScare yet: it would move the quest
  replay goldens; arena first, the quest is a one-line follow-up (+ re-bless) for the Director.
- 02:56 clips: `city_scare_32ppm.mp4` / `city_scare_64ppm.mp4` (`--arena=city --rigs --bot=gunplay
  --weapon=pistol --start=pit --clean --crowd=420`, 30 / 25 s, captioned). The pit is a plaza
  with few walkers at the block's 120 people, so the dev flag `--crowd=<n>` (arena_game.gd, the
  arena lane's dev file, 2 lines) fills the street for the clip. Read: the walkers by the kerb
  run with hands up at the first shots, the plaza stays empty round the fight.
- MILESTONE 03:00 51e53f7c: trip over bodies (brief item 4). ReactPose `trip` + CrowdReact
  `_trip_over` (fleeing ped within 0.6 m of a DEAD feed entry, once per (person, body)). Schema
  enums + table row. Unit 724/724 (2 new tests). Look goldens 11/11 worst 0.00, block 5/5
  (selftest alone, 67 s); the accent audit flag is the known gunplay blood-flicker debt.
- 03:05 board segment 8 "trip" (`trip_32ppm.mp4`, `trip_64ppm.mp4` + crop sheet). Honest read:
  the dip and arms-out read, the forward pitch is subtle; no body underfoot on the board.
- FRICTION: gdformat on Windows rewrites files with CRLF; a later python `replace("...\n")`
  then silently misses. Detect the newline before editing (git normalises on commit).
- MILESTONE 03:07 7a3f5516: quest 1 on the city gets CityScare too (quest1_session.gd, one
  line, the quest lane's file). Scenarios 32/32; unit 724/724 on a re-run (the first run had 1
  failure under load, not reproduced: a flake, test not identified).
- DECISION lines for scare + trip in docs/decisions.md.
- MILESTONE 03:10 539bc2ac: scenario_city_scare on a 420-person street (the pit plaza is thin
  at 120): 5 fled near the fight vs 0 deaf, want 4; the replay session gets the same crowd
  (first try diverged at tick 60: the spawner targets are set outside the input, so the fresh
  world must set them too).
- 03:11 the riot re-filmed at 64 px/m (city_bench --scenario=riot --zoom=2): too dense to read a
  single cower or trip; not filed. The sparse read is the city_scare clip.
- REQUEST 8 (showcase, hub overlap) ack: rivet-arsenal moved its claw cops to y 4.4 and its bot
  to y 2.85; react_line keeps y 1.5 x 1..13. Nothing to change on my side.
- MILESTONE 03:13 trip quality pass: lunge 70 -> 120, the body stretched along it (1.12) and
  narrowed (0.78), roll 0.45, head throw 90. Clips re-filmed (trip_32/64ppm.mp4).
- MILESTONE 03:18 wounded limp (brief item 2, last family): HumanReact.limp (hunch; once a
  stride on the gait phase: drop, tip, head bob; standing only the hunch), ReactLink._limps sets
  it from each hostile's hp lost x LIMP_GAIN 1.6. Board segment 14 + limp_32/64ppm.mp4. Unit
  725/725, scenarios 32/32, lint 13/13. Decision line written.
- Evidence this iteration (gtai-masters/n4/human-reactions + evidence/ here): city_scare_32ppm,
  city_scare_64ppm (+ sheet), trip_32/64ppm (+ sheet), limp_32/64ppm (+ sheet). frames.json 15.
- Gates at 03:18: lint 13/13, unit 725/725, scenarios 32/32, parity bit-exact (03:00, after the
  native change), selftest look 11/11 worst 0.00 + block 5/5 (03:01, after trip). Full
  `tools/evidence/run.mjs` not run this iteration. Bench not run (render-only + one sim entry).
- Note for the merge: project/native/bin DLLs are rebuilt here with `scare`; the Director must
  rebuild native on main (scons debug + release, then --import), else CitySimNative skips the
  scare and parity would show the drift. native/godot-cpp here is a local copy of int-day's (not
  committed, the submodule pointer is unchanged).

### REQUEST 2 -> weapon-art (03:20, low priority, after the weapons and REQUEST 1)
The robot thug's own look (brief item 5; today it rides King's restyled parts in enemy-ai's dev
scene): one chroma-green part sheet in Rivet's part names, sizes and pivots (the layout-template
technique King used, art/king/), a squat street-gang robot: grey-gunmetal plates, dented, a
single round optic, no collar (vermilion is Rivet's collar only), no red. I wire it as ThugPlan
(RivetPlan FORM_OPEN, art_dir "thug") and add sparks/oil per hit on it.

### Calls for the owner (adds to the iteration 3 list)
- Crowd density round a fight: the city block holds 120 people; the pit plaza then has almost
  nobody to scare. The clips use `--crowd=420`. Option A: keep 120 (quiet streets, the fight is
  the event); B: raise the block's CITY_PEDS for the arena (more panic on screen, bench cost).
  Clip: city_scare_32ppm.mp4 (420).

NEXT (iteration 5, in order):
1. Robot thug light pass without new art: ThugPlan (own plan name, RivetPlan FORM_OPEN, King art
   until REQUEST 2 lands, size 1.05), sparks/oil per hit via ReactLink for robot kinds; bring
   enemy-ai's robot into the arena pit if the roster has it there.
2. SWAT look when weapon-art REQUEST 1 lands (RigVariant crowd index + CrowdAtlas clamp), then
   the react_line gets a fifth dummy (SWAT) for "each cop type from four sides".
3. A limp in the live arena: film gunplay's armored humans (--weapon=pistol vs armored, they
   live through a hit) on --rigs at 32 px/m to show the limp in the real fight.
4. Trip in game: count CrowdReact.trips in an --arena=city --crowd=420 run (temporary log) and
   film one; the board has no body underfoot.
5. Run the full `node tools/evidence/run.mjs --no-bench` once (it was not run this iteration).
- 03:23 FINDING for NEXT 3: gunplay's armored humans exist only in dev/gunplay/pistol_fight
  (`--armored`, Fighter hp = table armored / human = 2.5 rounds), which draws quest 1's
  CollectCallView sprites, not the cast rigs with ReactLink. So the limp in the live arena needs
  an arena-side `--armored` (GunplayHook or ArenaGame: scale the pit hostiles' hp like
  pistol_fight line 70) and then `--rigs`. Not started at 03:23 (15 min left).

## Iteration 5 (03:22-04:22), BUILD
- 03:22 read JOURNAL, git log, other lanes' JOURNALs. REQUESTs to me: showcase REQUEST 10 (the
  react_line on the merged build sits at x -0.5..11.5, y 1.5). weapon-art has not taken
  REQUEST 1 (SWAT) or 2 (thug parts) yet. Registry rules applied as before
  (motion-quality-gating: judged in motion at 32 + 64 px/m, look at every frame).
- MILESTONE 9503319e: showcase REQUEST 10 taken: react_line x -0.5, 3.5, 7.5, 11.5 (y 1.5).
  scenario_react_line + scenario_arena_stations green on it. REQUEST 10 answer -> showcase,
  rivet-arsenal: my branch now carries your spot.
- MILESTONE d72a6694: arena `--armored` (dev, arena_game.gd 6 lines, the arena lane's dev file):
  the pit's humans get armored hp (weapons.json armored / human = 2.5 pistol hits), Rivet's hp
  x2.5 too (first take without it: Rivet died at 12 s and lay still). Set before tick 0, so the
  run is deterministic. Clips arena_armored_limp_32ppm.mp4 / _64ppm.mp4 (`--rigs --bot=gunplay
  --weapon=pistol --start=pit --clean --armored`). Honest read: a real pit fight, the first cop
  takes hits up close and walks on hunched before the third kills it; the limp is a small motion
  at 32 px/m, clearer at 64. The camera wanders the hub for the first ~7 s (teleport at tick 0,
  trimmed). After the first kill GunplayBot stands and trades shots with the far cop.
- MILESTONE d4556023: ThugPlan (features/characters): the robot thug's own proportions on
  Rivet's rig (legs 0.82, stance 1.25, arms 1.15, arm weight 1.3, head +8 forward, gait 0.85, no
  collar/hose), King's parts until REQUEST 2 lands (ART_DIR is the one line). enemy-ai's
  EnemyRigFight draws robots on it (was KingPlan at 1.05). Unit 727/727. Clip
  thug_plan_32ppm.mp4 (two thugs + a patrol cop vs the pit dummy: sparks on hit, oil on floor).
  The robots stay out of the arena's CombatArena (no robot Fighter kind there; owner: robots
  later).
- DECISION thug proportions: a squat brawler with long arms (reads apart from Rivet's hunched
  base and King's squared boss at a glance) over a scaled King (rejected: same silhouette).
- MILESTONE 323ce44c: trip in game, measured (NEXT 4): a 40 s `--arena=city --rigs --bot=gunplay
  --weapon=pistol --start=pit --crowd=420` run logged 11 cowers, 0 trips, 0 deaths. Cause found:
  the fight's dead are drawn on ArenaRigs' own rig set, so CrowdReact (the city feed) never saw
  them as bodies. Fix: CrowdReact.extra_bodies, filled by ArenaRigs with the arena's dead. Re-run:
  still 0 trips. People flee AWAY from the fight, so they rarely pass within 0.6 m of a corpse; only
  the 16 full rigs can trip. Honest state: trip is proven on the board and in unit tests, not yet
  seen in a live fight. The arena exit now logs `crowd: cowers, trips, deaths` and `react: wounds,
  deaths, ducks`.
- 03:46 full `node tools/evidence/run.mjs --no-bench --allow-dirty` (only the untracked
  evidence/ clips dirty): lint PASS 13/13, unit PASS 728/728, parity PASS (bit-exact, mutation at
  629), scenarios 31/32: scenario_city_chase failed under load, green alone (the known 2 ms nav
  flake). Selftest FAIL on the accent audit only: "NEW off-doctrine 32 px/m vermilion on vehicles
  4 px / on cop 4 px" while the debt rows blood_flicker_* were "no longer seen": the known gunplay
  blood flicker moving between rows; look goldens 11/11 worst 0.00, block 5/5 worst 0.39. Nothing
  this iteration touches the D4 frames it audits.
- MILESTONE fb70cc84: limp pass 2 (my read of the arena clip: too small at 32 px/m): drop 26 ->
  60 part px, tip 0.16 -> 0.34, head bob 48. Board re-filmed (limp2_64ppm.mp4 + sheet), both
  armored arena clips re-filmed after it (the same fight frame for frame: deterministic).
- MILESTONE 3717f2d2 + fb32a2c1: near misses (brief item 2, "a hit while in cover" made live):
  NearMiss plays the cover duck on a human a round of Rivet's passes within 1.1 m (once per round
  per human, judged after the round passed, up to 8 m past: a 60 m/s round moves 2-4 m a frame).
  Unit 731/731 (3 new tests). Live counts: pistol pit 40 s = 0 wounds, 11 deaths, 0 ducks (the
  bot rarely misses); machine pistol + armored 30 s = 16 wounds, 4 deaths, 0 ducks (the target
  is still in its wound flinch when a burst's miss passes, and a busy body does not duck);
  city machine pistol 40 s = 4 wounds, 4 deaths, 1 duck. No clip filed: not enough misses to see.
- Evidence this iteration (gtai-masters/n4/human-reactions, frames.json 15 entries, each file
  checked): arena_armored_limp_32ppm / _64ppm (live fight, limp pass 2), limp2_64ppm (+ sheet),
  thug_plan_32ppm (+ sheet). Scratch AVIs deleted.
- Gates at fb32a2c1: lint 13/13, unit 731/731; scenarios react/arena_pit/human/arena_stations
  green after the near-miss change (full suite at 03:46: 31/32 + the city_chase flake green
  alone). Bench not run (render-only work and dev flags; no sim change).

### Calls for the owner (adds to the list)
- Limp strength: pass 2 is visible at 64 px/m and small at 32 px/m (arena_armored_limp_32ppm vs
  _64ppm). Option A: keep it (a wound is mostly told by the flinch and the blood); B: also slow
  the wounded human's sim walk (moves replays, a gameplay change: wounded enemies are easier).
- Near-miss ducks are render-only and rare against the bot (it seldom misses). With a player who
  misses they fire often; judge in a hand-played arena run.

- MILESTONE 04:04 bd216b25: `--bot=react_line --wide=0.8` (dev): Rivet aims 0.8 m beside each
  dummy; 30 s = 26 ducks, 3 wounds (pistol spread). Clip near_miss_line_64ppm.mp4 + sheet: the
  round passes north of the patrol cop, its head tucks and the body turns away. frames.json 15
  (react_families_32ppm dropped from the list, the file stays).

- MILESTONE 04:06 d7676995: duck pass 2 (the 32 px/m run read too small): cover travel 0.2 m,
  tuck 0.78. near_miss_line_32ppm.mp4 + the 64 px/m clip re-filmed (26 ducks, 3 wounds each).
  Unit 731/731, react scenarios green. frames.json 15 (crowd_cower_64ppm dropped from the list).

NEXT (iteration 6, in order):
1. Run the full evidence (`node tools/evidence/run.mjs --no-bench --allow-dirty`) on d7676995.
2. SWAT look when weapon-art REQUEST 1 lands (still open at 03:58); then a fifth react_line
   dummy. ThugPlan.ART_DIR swap when REQUEST 2 lands.
3. Trip live: put fleeing paths across bodies (the riot: city_bench --scenario=riot has bodies
   amid the crowd); count CrowdReact.trips there and film one.
4. Full evidence run again after the next change; bench once (the lock) since the riot gets
   CrowdReact work.
- 04:08 session close. Branch tip has everything; gtai-masters/n4/human-reactions/frames.json
  15 entries, each file checked to exist.
- 04:11 full evidence on 8fd248f4 (`--no-bench --allow-dirty`, only untracked evidence/ clips):
  lint 13/13, unit 731/731, scenarios 32/32, parity bit-exact (mutation caught at 629) all PASS.
  Selftest FAIL only on the same accent-audit line as at 03:46 (4 px vermilion on vehicles / cop
  at 32 px/m while the blood_flicker_* debt rows read "no longer seen": the known gunplay blood
  flicker moving rows); look goldens 11/11, block 5/5. NEXT 1 is done; NEXT 2-5 stand.

## Iteration 6 (04:13-05:13), BUILD
- 04:13 read JOURNAL, git log, the other lanes' JOURNALs. weapon-art answered both REQUESTs:
  REQUEST 1 DONE d9102db7 (head_swat / torso_swat, D4 + D5 cop sets), REQUEST 2 DONE dae102b7
  (art/thug + art/d5/thug in Rivet's part names). No new REQUESTs to me. Registry rules as before
  (motion-quality-gating: judged in motion at 32 and 64 px/m, every sheet looked at).
- MERGE: cherry-picked weapon-art d9102db7 -> c4f562a3 and dae102b7 -> 81f98dd3 (clean; parts,
  parts.json rows, their swat_lineup dev scene, provenance rows).
- MILESTONE a27c786b: the SWAT look. RigVariant.SWAT = 8 (full rigs only), atlas_look() prints it
  as patrol in the 8-row baked atlas (CrowdAtlas.cell_for clamps). ArenaRigs dresses the pit's
  guards patrol/riot/SWAT by actor id (squad_index_for, no RNG); enemy-ai's rig fight draws its
  `swat` archetype in it; the reaction line's fourth dummy is SWAT (was the hoodie pedestrian).
  Unit 735/735 (test_rig_variant_swat: 3 tests), lint 13/13, react/arena/human scenarios green.
- MILESTONE c819d6be: ThugPlan.ART_DIR king -> thug (own parts), unit test checks they exist.
- DECISION SWAT on the line: swap the hoodie pedestrian for SWAT rather than a fifth dummy (no
  layout move next to rivet-arsenal's claw cops and showcase's REQUEST 10 spot; scenario_react_line
  keeps 16 shots). Alternative: a fifth spawn at x 15.5.
- Evidence: react_line_cops4_32ppm / _64ppm.mp4 (36 s each, 16 shots, 16 wounds, 7 ducks: the
  neighbours duck at rounds passing them) + react_line_swat_{32,64}ppm_sheet.png. Read: at 64
  px/m the SWAT is the dark helmet with a visor bar and a dark vest, the flinch reads; at 32 px/m it
  is the dark-headed cop beside the white cap (patrol) and white helmet + shield (riot).
  thug_parts_32ppm.mp4 (+ sheet): two thugs + a SWAT in enemy-ai's dev fight; the thug prints as a
  dark body with one pale optic; its arms still print steel at 32 px/m (shader limb LOD).
- MILESTONE 738c3d67: trip in a live crowd (NEXT 3). city_bench logs CrowdReact at exit: a 30 s
  `--scenario=riot` = 0 cowers, 4 trips, 15 deaths (headless the same: 4 trips at process frames
  182, 189, 276, 584, deterministic); 16 s at zoom 2 = 4 trips, 12 deaths. 0 cowers is right:
  rioters carry FLEE from their spawn, so there is no rising edge. Honest: in a 300-person riot a
  single trip is not picked out by eye (scanned frames 150-290 at 32 and 64 px/m). Clips
  riot_crowd_32ppm.mp4 (30 s) / riot_crowd_64ppm.mp4 (16 s): the crowd, the blue shield line, the
  standard deaths with red pools.
- pit_squads_32ppm.mp4 (+ sheet): the live pit (`--rigs --bot=gunplay --weapon=pistol --start=pit
  --clean`, 11 deaths) on the mixed squads; at 32 px/m the looks differ mainly by the head.
- frames.json: 15 entries, the four new ones first; dropped thug_plan_32ppm and react_line_4sides
  (superseded, files stay). Scratch AVIs deleted.
- 04:40 full evidence (`--no-bench --allow-dirty`) on 738c3d67 (it straddled the startle edit, so
  unit + react scenarios were re-run on 1da7fd7d below): lint 13/13, unit 735/735, scenarios
  32/32, parity bit-exact (mutation caught at 629) PASS. Selftest FAIL on the same accent-audit
  line as iteration 5 (4 px vermilion on vehicles / cop at 32 px/m, blood_flicker_* debt rows "no
  longer seen": gunplay's blood flicker moving rows); look goldens 11/11 (worst 0.34), block 5/5.
  One unit run during the evidence run showed 1 failure; alone it was 737/737 (contention flake).
- MILESTONE 1da7fd7d: a death startles the crowd (brief item 4, "they read in a riot"): living
  pedestrians within STARTLE_M 2.5 m of a death cower away from the body; a trip skipped on a busy
  (mid-cower) body fires once it is free (the first version dropped trips 4 -> 1). Riot 30 s:
  20 startles, 4 trips, 15 deaths (was 0 cowers). Unit 738/738 (3 new tests), react / city_scare /
  human scenarios green. riot_crowd_64ppm.mp4 re-filmed on it (16 s: 20 startles, 3 trips, 12
  deaths). Honest read: the startles are small motions inside a dense riot; the clip reads as
  a crowd, a police line, the dead and pools.
- DECISION startle radius 2.5 m (about two body widths past arm's reach): the neighbours of a kill,
  not the street (the street's flight is the sim's scare). Alternative: STARTLE_M = 0 turns it off.
- 04:46 bench (lock taken): the first try failed at export ("export path doesn't exist": a fresh
  worktree has no build/export/windows-bench; created it), re-run in the background.

NEXT (iteration 7, in order):
1. Read the bench result (build/evidence/bench.json) from the 04:46 run; if the riot p99 moved
   past the idle record (6.0 ms, CONTENDED), profile CrowdReact._startle (O(feed) per death).
2. Make a single startle and a single trip readable: a 64 px/m close-up on a thinner city street
   (`--arena=city --crowd=420` pit fight: deaths near walkers) rather than the 300-person riot.
3. scenario for the startle (planted fault: STARTLE_M 0 -> no cowers at deaths in the riot feed).
4. The arena city exit log (arena_game.gd) could also print startles (one line, the arena lane's
   dev file).
- 04:55 bench (exported release, windowed, 3 x 4 x 60 s, lock held, CONTENDED: six lanes on one
  GPU): p99 19.947 ms, 1 % low 35 fps (MISSES), drive p99 3.975 ms, drive48 3.706 ms; rigs p99
  1.309 ms per frame in the riot. Idle record is 6.0 ms / 124 fps, so this number is contention
  until shown otherwise. Headless A/B of my riot change (30 s riot, back to back): STARTLE_M 2.5 ->
  p99 9.281 ms, 0.0 -> 8.854 ms, 2.5 again -> 8.829 ms: within run-to-run noise, the startle is
  not the cost. (Startle off = 6 trips, on = 4: the startled are mid-cower when they pass a body
  and trip later or not at all.) NEXT 1 is answered; the riot needs an idle-machine bench.
- 04:58 gates on the tip (0204a090): lint 13/13, unit 738/738 (04:44), scenarios 32/32 (full suite, 04:58), parity bit-exact (04:40 evidence run; no sim change since). Branch tip has everything; gtai-masters/n4/human-reactions/frames.json 15 entries, each file checked to exist. Session close.

## Iteration 7 (04:59-05:59), BUILD
- 04:59 read JOURNAL, git log, the other lanes' JOURNALs: no open REQUESTs to human-reactions
  (showcase REQUEST 20, the test_rig_variant_swat .uid, was already closed in their round 6).
  Registry rules as before (motion-quality-gating: judged in motion, every sheet looked at).
- MILESTONE c034af76 (NEXT 3): scenario_crowd_react. A scripted street (5 x 3 walkers, two deaths,
  a fleeing runner) stepped on the 60 Hz tick through CrowdReact: exactly the 15 living walkers
  within STARTLE_M startle (0 further out), each away from the body (min dot 1.0), the cower clears
  in 41 ticks (table 42), the runner trips once, two runs give the same pose digest. Planted
  faults caught: startle radius 0 (0 startles) and trip radius 0 (0 trips). CrowdReact.startle_m
  / trip_m are now live vars defaulting to the consts. FRICTION: the cower timer first read 82
  ticks because the same walker is startled again by the second death; the timer now covers only
  the first death's window.
- MILESTONE 3ad17652 (NEXT 4 + a gap): the fight's dead (arena rigs, CrowdReact.extra_bodies on
  `--arena=city`) now startle the street too, once per new body (before, they only tripped
  walkers). The arena exit log prints the startles. Unit 739/739, crowd_react / city_scare /
  arena_city scenarios green. Measured in the live pit (`--arena=city --rigs --bot=gunplay
  --weapon=pistol --start=pit --clean`, 30 s headless): --crowd=420 -> 11 cowers, 0 at a death;
  --crowd=900 -> 15 cowers, 1 at a death. CityScare empties the plaza before the cops die, so in
  the pit a startle is rare. That is right for the sim; it is why the readable close-up is a board.
- MILESTONE a76284b2 (NEXT 2): StreetBoard (`react_board_run.gd --board=street`): a patrol
  cop's round kills one walker of a 4 x 3 knot; the 9 within 2.5 m cower away from the body, then
  scatter, and a fleeing runner trips over the body; four takes from four sides (9 startles, 1
  trip each). Pass 1 read as a perfect ring with the west walker running past the cop. Pass 2:
  each walker on its own beat and pace (by index, no RNG), away from the body and the gun, and a
  walker on the line of fire breaks sideways. Clips street_startle_32ppm / _64ppm.mp4 (16 s) +
  street_startle_64ppm_sheet.png. Read at 64 px/m: the tracer, the fall with red along the round,
  the knot hunched with hands over their heads, the break, the runner pitching over the body. At
  32 px/m the duck reads as the knot going dark (arms over heads), the trip is small.
  frames.json 15 (street_startle_64ppm second; arena_pit_rigs_32ppm dropped, the file stays).
- DECISION fight deaths startle: a body drawn on the arena's own rigs startles like a city death
  (one rule for every death the street sees). Alternative: skip extra bodies in _startle_extra
  (one line).
- 05:16 full scenario suite on 3ad17652 + the street board (dev only): 33/33.
- MILESTONE 9762ed55 (quality pass on the weakest death): the electro death falls stiff.
  Before, every death ended in the same X sprawl (legs spread, one arm flung up): sheet
  death_electro_x_before_64ppm_sheet.png. New CutRig.c_plank channel (RigClips zeroes it each
  tick, DeathPose._shock sets it with the fall): feet 55 px apart (was 230) and 130 px further
  back, feet unsplayed, arms along the sides, no torso or body twist. Pass 1 (feet together at
  the sprawl's 210 px, arms back at 25 px) read as a compact blob from above, because the legs and
  arms overlapped the torso; pass 2 pushed the feet out and the arms 70 px off the sides; pass 3
  removed the sprawl's torso twist (one arm still flared). Read at 64 px/m: a body lying at
  attention, clearly unlike the X. With c_plank 0 every changed formula reduces to the old
  value, so no other pose and no look golden moves. Touches d5-cast's rig files (cut_rig,
  rig_clips, rig_gait, rig_arm, rig_pose: one channel, a few lines). Unit 740/740 (planted: a
  round death keeps c_plank 0), human_react scenario green, lint 13/13. Clips
  death_electro_stiff_{32,64}ppm_halfspeed.mp4 (the board, half speed: the fall takes 0.14 s in
  real time) + the after sheet. Live check: the arena bot's electro gun kills 1 cop in 45 s
  (`--rigs --bot=gunplay --weapon=electro_gun --start=pit`), too slow for a live clip.
- DECISION electro corpse: the stiff plank (legs together, arms at the sides) rather than the
  shared X. Alternative: c_plank = 0 in DeathPose._shock (one line) brings back the X.
- 05:24 evidence on c31a9064 (`--no-bench --allow-dirty`, only untracked evidence/ clips): lint
  13/13, unit 740/740, scenarios 33/33, parity bit-exact (mutation caught at 629) PASS. Selftest
  FAIL only on the same accent-audit line as iterations 5-6 (4 px vermilion on vehicles / cop at
  32 px/m, blood_flicker_* debt rows "no longer seen": gunplay's blood flicker); look goldens
  11/11 worst 0.34 (unchanged: the c_plank channel moves no other pose), block 5/5.
- MERGE: cherry-picked gunplay 356a3a2d -> f4ef483f (my REQUEST 1 answer: a kill spray turns up
  to 14 deg and fans 52 deg; clean). Read on the board: a north/south hit's spray is wider but
  still reads as a column under the body at 64 px/m (deaths_r7_64ppm_sheet.png rows 1-3).
- MILESTONE a649b7c0: the melee death lies curled round the blow (DeathPose.MELEE_CURL c_tuck
  0.55, MELEE_LIE c_sprawl 0.7; was 0.2 / 1.0, the round's X). Unit 741/741 (one run under load
  showed 1 failure, two re-runs 741/741), human_react / crowd_react scenarios green.
- Evidence: react_families_r7_64ppm / _32ppm.mp4 (32 s, real time, every family + the five
  deaths) + deaths_r7_64ppm_sheet.png: five deaths, five corpses (round X/crumple, melee curl,
  blast spread-eagle, burn charred, electro stiff). frames.json 15 (the board first;
  riot_deaths_32ppm and limp2_64ppm dropped from the list, the files stay). Scratch frames deleted.
- DECISION melee corpse curled (c_tuck 0.55, c_sprawl 0.7): "folding over" ends folded. Alternative:
  MELEE_CURL 0.2 / MELEE_LIE 1.0 brings back the X.

### Calls for the owner (adds to the list)
- Corpse variety: the electro corpse lies stiff and the melee corpse curled (deaths_r7_64ppm_sheet).
  Option A: keep five distinct corpses. Option B: one shared sprawl (two constants).
- Crowd startle radius 2.5 m (street_startle_64ppm.mp4): A keep; B wider (4 m) makes a kill read
  across a pavement but startles people who could not have seen it.

NEXT (iteration 8, in order):
1. Read /tmp/ev7b.log or re-run the evidence on the tip (a649b7c0 + journal): the cherry-picked
   blood fan touches combat_blood + blood_fx.json, so check the look goldens.
2. The north/south blood column (deaths_r7 sheet): tell gunplay (REQUEST 2 -> gunplay) or try
   it in CombatBlood.kill_human with their OK; it is their file.
3. The electro death live: a pit run where the electro gun kills faster (the charged shot from
   gunplay 0c0465fd, `--weapon=electro_gun` holding fire) and a 64 px/m clip of the stiff corpse.
4. Blast corpse: thrown spread-eagle is close to the round's X; give it a twisted landing
   (one leg bent, rot past the slide).
