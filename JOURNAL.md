# JOURNAL: lane gunplay (e-gunplay), evening 2026-11-03

## Iteration 1 (20:51-21:36, BUILD)

Read: AGENTS, the brief, the existing combat feature (quest-1 `CombatArena`/`Shot`/`combat.json`,
1-hp humans), CameraRig (it already has shake and hit-stop by id with reduced motion), bodies.json,
the lint DAT-03 rule (every table needs a schema by basename). answers.json was empty at 20:51.
Registry: no time to read the subjects this iteration (FRICTION). Next iteration: read
`realtime-combat-semantics` before the enemy-fire tell.

- MILESTONE 1069211: `data/tables/weapons.json` (+ schema) holds the owner's set: pistol,
  machine_pistol, flamethrower, rocket_launcher, electro_gun and molotov (core), gloria (canon),
  and the unique rows (plasma_rifle, hand_cannon, ray_gun, homing_shard, mini_nuke) present with
  `enabled: false`. There is also an `enemy_fire` block (speed 0.45x, damage 0.25x, tell 0.35 s,
  muzzle flash 0.08 s) and target classes (human 100, armored 250, robot 600 metal).
  `features/combat/weapons/` has WeaponSpec, WeaponTable, Trigger (semi on the press edge, auto
  while held, bloom that recovers, magazine, reload), Projectile, RangeTarget (burn = panic, stun,
  knockback), Sweep (exact swept circle and rect), ProjectileSim (cover, enemy scaling, fire
  patches, digest) and Impact (splash falloff, electro chain through metal at 0.7x per hop, burn,
  stun). 11 unit tests, including determinism per seed and a planted fault (a different seed
  moves the digest).
- MILESTONE 3543a99: the shared hit feel (`features/combat/hit_feel/`, README has the API for
  rivet-motion, powers and enemy-ai). 4 unit tests.
- MILESTONE 2c558d1: the TTK bench (`dev/gunplay/ttk_bench.gd`) writes `evidence/gunplay/ttk.{json,md}`,
  copied to gtai-masters/eve/gunplay/. It found the rocket defect (a missed rocket burst at 45 m,
  so it never killed a 5 m strafer); fixed.
- FRICTION: a parse error (discarded `store_string()` return) in a runtime-loaded runner made
  `-s` hang for 5 minutes with no output. The launcher now quits(2) when the runner cannot
  instantiate. Always run new dev scripts once unpiped with a 25 s timeout.
- ASK gunplay-1 (lethality model, TTK table as evidence), default A. Built so the answer is a
  number change in weapons.json targets and damage.

Key numbers (pure sim, not perf; the shooter aims at the target without leading):
pistol vs a still human: 0.08/0.17/0.33/0.85 s at 5/10/20/35 m. A strafing human (3.2 m/s)
drops the pistol's hit rate to 0.17 at 10 m. Enemy fire at Rivet strafing at 4.5 m/s: pistol hit
rate 0.06-0.20, so the dodge works, maybe too well (re-check against the tell).

REQUESTs:
- REQUEST 1 -> rivet-motion: arms point along the aim. The aim vector is the mouse world point
  minus Rivet's position (pad: the right stick plus a magnetism cone, coming next). I will
  expose `aim_dir` from the weapon user. Also use `HitFeel.land(target_id, &"melee", ...)` for
  the claw combo and `&"shock"` for the electroshock.
- REQUEST 2 -> enemy-ai: listen to `HitFeel.reaction(target_id, kind, dir, ticks)`; read
  `RangeTarget.panicking()` (burning) to break cover; the shot tell is `enemy_fire.tell_s` in
  weapons.json (0.35 s). Fire through `ProjectileSim.fire(trigger, muzzle, aim, TEAM_ENEMY, id)`
  so enemy rounds get the slower speed.
- REQUEST 3 -> arena: the 35 m lane is off screen at 32 px/m (your arena-2). The rocket, the
  pistol and the electro gun reach it. My station file lands next iteration.

- MILESTONE 30deecc: range and dodge station draft `evidence/gunplay/station-draft/gunplay.json`.
  It validates against arena's `gtai.arena-station/1` (from a2467d8) and has 85 tuning keys
  (`weapons.<id>.<field>`, `weapons.enemy_fire.*`). It cannot live in `data/tables/arena_stations/`
  on this branch yet: arena's lint maps that folder onto `arena_station.schema.json`, and neither
  is here. Move it there unchanged once arena is merged.
- MILESTONE 7ed9305: pad aim assist (`AimAssist`, weapons.json `aim_assist`: 8 deg cone, 25 m,
  bends 35 % of the way, pad_only). The mouse aims raw.
- MILESTONE 4305f19: the dev range scene `dev/gunplay/range_view.gd` with the core six side by
  side. Clip: gtai-masters/eve/gunplay/range-core6-32ppm.mp4 (5 s, --fixed-fps 60, d3d12),
  frames.json written (3 entries). I looked at frames 150 and 200: the first capture cut off the
  labels (the project's stretch shifts the canvas about 70 px) and drew them white on paper; both
  fixed before the kept capture.
- Gates at 7ed9305: lint 13/13; unit 551/552 at 2c558d1 (test_noir_shadows, the known flake,
  passes alone); scenarios 19/19 (evidence/gunplay/*-iter1.log). Replay and parity are untouched:
  no native or quest code changed.
- answers.json at 21:24: only rivet-motion-1. No answer to gunplay-1 yet.

NEXT:
1. Re-read answers.json (gunplay-1). Apply the answer as numbers in weapons.json and re-run the
   TTK bench.
2. Clip at 48 px/m (make PPM a `--ppm=` arg in range_view.gd), a longer 15-20 s clip with a lane
   per weapon at 5/10/20/35 m, and the real Rivet once the arena lane's stage is on this branch.
3. Aim: the reticle and an aim line in the view that make range readable (the line ends at the
   weapon's range_m; the reticle opens with cone_rad()). Wire AimAssist into the player's pad
   aim.
4. The enemy shot tell and muzzle flash in the view, plus a dodge clip (Rivet strafing through a
   volley).
5. A scenario test for projectile determinism through `run_scenarios` (replay identical, planted
   fault).
6. Burn panic and fire-patch visuals; the vehicles-lane hook for rocket car damage.
- MILESTONE (iteration 1 close): range_view takes `--ppm=`; the 48 px/m clip is at gtai-masters/eve/gunplay/range-core6-48ppm.mp4 (frames.json now has 4 entries). The lane marks overlap at 48 because lane spacing is capped at 120 px to fit 800 px.

## Iteration 2 (21:27-22:05, BUILD)

answers.json at 21:27: nothing for gunplay. At 21:47: gunplay-1 = A and gunplay-2 = A, both as
"default as a placeholder". Registry read this time: `realtime-combat-semantics` golden path
(the perceive-to-unavoidable interval, the 0.25 s reaction floor, the 0.4-1.5 s wind-up band,
"an area effect must be telegraphed or homing"). Applied: the enemy tell plus flight time is
the window, and it is measured against a 4.5 m/s sidestep (DodgeDrill), not assumed. DEVIATION
(docs/decisions.md): the 0.35 s tell is under the 0.4 s floor; tell plus flight is 0.79 s at 12 m
and 0.54 s at 5 m.

- MILESTONE fa31963: readable enemy fire. `EnemyGunner` runs REST, then a 0.35 s TELL (tracks
  for the first half, then holds its aim still), then a 3-round VOLLEY at the locked point, then
  a 1 s rest. New `weapons.json enemy_fire` keys: lock_frac, volley_shots, rest_s.
  `DodgeDrill` measures it. `scenario_gunplay_fire` checks the core six replay identically per
  seed, and a planted fault (the target 5 cm off) moves the digest. Dodge at 12 m with the
  pistol: still 0.93 hit rate, timer juke 0.13, sidestep on the tell 0.00 (also 250 ms late),
  planted no-lock gunner 0.67. Unit test_enemy_gunner covers the tell length and the aim lock.
- MILESTONE 8e73411: the dodge clip scene `dev/gunplay/dodge_view.gd` (`range_clip.gd -- --view=dodge`).
  Clips at gtai-masters/eve/gunplay/dodge-volley-{32,48}ppm.mp4 and the A/B dodge-speed-{0.45,0.65}.
  I looked at 7 frames. The first take drifted Rivet off the bottom and the muzzle flash was
  too pale; both fixed before the kept take. frames.json has 10 entries. ASK gunplay-2 asked
  (enemy round speed); the Director answered A as a placeholder (debug circles).
- MILESTONE 23c39db: `AimReadout` (the aim line ends at range_m, the reticle radius is the live
  cone at the aim distance, a flag for out of reach) + unit test. The dodge view draws with it.
  Station draft: +3 enemy-tell keys.
- MILESTONE e1775ff: d5-combat REQUEST 3 done in the hit-feel module. `HitFeel.beat_mode` makes a
  lethal hit use `beat_kill_hitstop` (boss_hit, 8 ticks) instead of kill (6). camera.json is
  unchanged. Unit test added.
- Gates at 23c39db: lint 13/13, unit 557/557, scenarios 20/20 (19 + scenario_gunplay_fire);
  logs in evidence/gunplay/*-iter2.log. hit_feel unit 5/5 at e1775ff. Replay and parity are
  untouched (no native or quest code changed).
- Tuning numbers (my call, per the 21:25 direction): enemy speed_scale 0.45, tell 0.35 s,
  lock_frac 0.5, volley 3, rest 1 s. The lethality model stays A (pistol one hit on a human).

### OWNER DIRECTION 21:25 (binding; read in common.md)
Depth before breadth: one finished pistol with the full hit chain in the D5 look, on real
rigs (a patrol cop and a robot thug), in the arena, as one 20-40 s clip at 32 px/m. No debug
circles as the basis of a question. Everything I have on this branch is the model under that
chain, and the dev views are debug circles. So the next iterations go to the chain, not more
numbers.

Where the chain lives: the arena (e-arena, `dev/arena/arena.tscn`) is `CollectCallStage` +
`CollectCallView` (the real Rivet, `CombatArena`, `CastView` art from collect_call_art.json,
d5-combat's blood and kill beat, `MuzzlePop`). The pistol must land there, not in my views.

- REQUEST 4 -> arena: give `ArenaStage` a hook so a lane can swap Rivet's weapon model. I will
  add an optional `CombatArena.gun` (null in quest 1, so quest goldens stay put).
- REQUEST 5 -> enemy-ai: the guard's shot in `GuardBrain` should go through `EnemyGunner`
  (tell, lock, volley), so the cop rig can play the raised-gun pose while `telling()` is true.
- REQUEST 6 -> rivet-motion: arms point along the aim, plus a recoil kick of about 3 ticks on
  each `Trigger.pull()` true. A pistol prop hangs off the claw socket; I supply the art.

NEXT (iteration 3, depth-first on the pistol):
1. `features/combat/weapons/gun_hand.gd`: an adapter that owns a `Trigger` (pistol WeaponSpec)
   and turns a pull into `Shot.fire` with the spec's speed, damage, range and spread (ctx RNG
   stream `gunplay`). Make `CombatArena.gun` optional; when set, `rivet_fire` goes through it.
   Prove quest 1 unchanged (scenario_quest1_* hashes).
2. On the same path, `HitFeel.land` in `CombatArena.damage` (hook via Events or a callback),
   with the victim flash drawn in CastView and knockback on Fighter (pos nudge per tick).
3. The pistol art: one Codex image_gen for an original compact pistol in the D5 inked-grime
   look (a top-down 3/4 silhouette readable at 7 px), plus a provenance line. Draw it in
   Rivet's claw in CastView. Add the shell casing spark at the muzzle.
4. Clip: arena (merge e-arena locally into a scratch branch only for capture, never commit
   the merge) or the quest-1 view. Rivet fires the pistol at a patrol cop: tell, his volley,
   Rivet's sidestep, Rivet's shot, hit flash and hit-stop, the cop's flinch and death, blood.
   20-40 s at 32 px/m, --fixed-fps 60.
5. Only then the second weapon.
- MILESTONE 1223920: NEXT 1 started. `GunHand` (features/combat/weapons/gun_hand.gd) bridges
  the weapon table into `CombatArena`. Shared quest file touched minimally: `CombatArena.gun`
  (null by default; when set, `rivet_fire` goes through it, and `step()` settles the trigger).
  Unit test_gun_hand covers semi on the press edge and one pistol round dropping a guard.
  Quest scenarios 4/4 and autosave 2/2 (the bound-input hash) unchanged.
- MILESTONE (next commit): `CombatArena.struck(victim, dir, lethal, weapon)` is emitted after
  each landed round. A test proves the lethal pistol round reaches `HitFeel.land` and returns
  the kill hit-stop (6 ticks) once. Quest scenarios 4/4 again.
- NEXT for iteration 3 (updated): NEXT 1 is done on the combat side. What is left: the arena
  wiring (needs REQUEST 4: `ArenaStage` sets `arena.combat.gun = GunHand.make(...)` and connects
  `struck` to `HitFeel.land` with the view's CameraRig), the victim flash and knockback in
  CastView/Fighter, then the pistol art (NEXT 3) and the full-chain clip (NEXT 4).
- FINDING 21:56: Rivet's D5 rig already holds a pistol. `rivet_plan.gd` sets
  `hand_pistol = "claw_pistol"`, `rig_arm.gd` swaps the gun arm to that cell when armed, and
  the art is `features/characters/art/d5/rivet/{claw_pistol,pistol}.png` (d5-cast). The cop has
  `forearm_pistol`. So NEXT 3 is not "make art from zero". Use these cells. The pistol inside
  claw_pistol is a plain black bar, so a designed top-down prop is a candidate to replace it.
  A Codex image_gen job for that prop ran at 21:55 in gtai-spike/gunplay-pistol/ (style ref:
  the d5-cast Rivet frame). It is not integrated. If it is kept, add a provenance line and
  REQUEST rivet-motion/d5-cast to repaint the claw_pistol cell, A/B in the full-chain clip.
- REQUEST 4 -> arena (exact): in `ArenaStage.setup(ctx)` (e-arena features/arena/arena_stage.gd,
  after `arena.rivet.weapon = WEAPON`), add
  `arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", ctx.rng.stream(&"gunplay"))`.
  Keep `rivet.weapon` set, because the view's armed state and the rig's claw_pistol swap read
  it. Then connect `arena.struck` to `HitFeel.land(v.id, spec.hit_class, dir, lethal, tick)`
  with the view's CameraRig, and hold `SimClock.hold(ticks)` on the returned hit-stop. That
  moves the arena's own replay (a new RNG stream and new shot timing), so re-bless it. Quest 1
  is unaffected because `gun` stays null there.
- FINDING 21:58 (evidence: gtai-masters/eve/gunplay/art/pistol_scale_preview.png): the Codex
  pistol prop is a clean, original, inked top-down service pistol (art/pistol_topdown_candidate.png,
  keyed). At true scale (0.22 m) it is 7 px at 32 px/m and melts into the asphalt. DESIGN RULE
  for every weapon prop: draw it about 2x true length with a thick cream rim and one bright
  accent at the muzzle, the way d5-cast already draws the cop pistol and the claw_pistol cell.
  The candidate is not in the repo, so there is no provenance line yet. Add one
  (steam/ai-provenance/2026-11.jsonl, model "codex image_gen", prompt in
  gtai-spike/gunplay-pistol/codex.log) only if a cell made from it lands.

NEXT (iteration 3, final order):
1. Arena wiring. REQUEST 4 (exact hook above), or capture on a local scratch merge of e-arena
   into a throwaway branch (never committed). Settle the pistol's GunHand and struck -> HitFeel.
2. The victim's side in the view: the hit flash (HitFeel.flash) on the CastView figure, and
   knockback on Fighter (WeaponSpec.knockback_mps x HitFeel.knock_scale, decaying). The cop's
   flinch and death come from enemy-ai (REQUEST 5), blood from d5-combat (already in that view).
3. The muzzle flash and casing spark on Rivet's claw_pistol (MuzzlePop exists in features/fx).
   The tracer is drawn from `CombatArena.shots` in the view, with the 2.5 m tail and the D5 ink.
4. The 20-40 s full-chain clip at 32 px/m (--fixed-fps 60) in the arena. Then re-ask
   gunplay-2 with it if the tell still matters.
5. Only then the second weapon.

## Iteration 3 (21:57-22:42), BUILD
- Answers re-read 21:57: nothing new for gunplay (gunplay-1 and gunplay-2 stay placeholders A until a
  D5 full-chain clip; this iteration builds toward that clip).
- MILESTONE 52b92a6: `HitLink` (features/combat/hit_feel/hit_link.gd) wires `CombatArena.struck`
  into `HitFeel.land`: the hit-stop owed to the caller (`hold`), the victim flash and a decaying
  knockback (weapon knockback_mps x knock_scale, x0.82 per tick). CastView draws the flash as an
  inked impact star (`CastView.hit_link`, null in quest 1). FxView draws a table gun's round as a
  2.5 m ink-cased cream tracer. `GunHand.tap` lets a bot's held button re-tap a semi gun.
  Shared files touched minimally: cast_view.gd (+1 var, `_impact`), fx_view.gd (`_tracer`).
  Unit test_hit_link 2/2 (kill hit-stop 6 owed, flash fades, body slides 0.02-0.5 m, tapped
  cadence). Scenarios 20/20 (quest goldens unchanged).
- MILESTONE 5d0996e + 4972c90: `dev/gunplay/pistol_fight.tscn`, the pistol on quest 1's REAL dock
  fight in the D5 print (CollectCallView, real cast art, d5-combat blood), CameraRig on foot at
  32 px/m, HUD hidden. Clip: gtai-masters/eve/gunplay/pistol_fight/pistol_fight_32ppm.mp4 (20 s,
  --fixed-fps 60). Telemetry: 24 shots, 24 hits on contractors (100 %, they are 1 hp and close),
  24 kills, 17 kill hit-stops held (6 ticks; the rig's cooldown drops the rest), Rivet hit once.
  Muzzle flash: a 2-tick cream star off the claw. Stills at the first shots and hits.
- FRICTION: `node tools/tests/run_unit.mjs` reports test_save_slots failing (12 cases). The
  same file fails the same way in `int-day` (merged main, none of my changes), so it is the
  shared machine (other lanes' runs share the user:// save dir), not this branch. Every other
  test passes, including mine. Re-run alone on a quiet machine before calling it red.
- What the clip still does NOT show (honest): contractors are 1 hp, so no non-lethal hit and no
  flinch; there is no cop raised-gun tell (REQUEST 5 -> enemy-ai); Rivet's art is the static
  capture, so the claw does not visibly point the pistol (REQUEST 6 -> rivet-motion).
- MILESTONE 9e3715a + e2a88b9: `pistol_fight -- --armored` (contractors take weapons.json's
  `armored` hp, 2.5 pistol rounds): 42 shots, 42 hits, 14 kills, 11 kill hit-stops; the impact
  star now shows on a LIVING figure. FINDING: quest 1's enemy rounds were 4 px vermilion dashes
  (0.25 m), invisible at 32 px/m. With a table gun wired, FxView now draws them as 1.2 m vermilion
  strokes in an ink casing (Rivet's: 2.5 m cream), and Rivet struck gets the star with a vermilion
  rim. The dev camera eases (FOCUS_EASE 0.06), because a kill used to cut the frame (seen on a
  contact sheet). Clips: gtai-masters/eve/gunplay/pistol_fight{,_armored}/; frames.json updated
  (top 6 are this iteration).
- Rules applied: realtime-combat-semantics (readability of the incoming threat over the
  outgoing one: the enemy round is the more saturated colour), the morning's palette verdicts
  (vermilion = danger only: enemy rounds and Rivet struck; red = blood only; nothing teal).

NEXT (iteration 4, depth on the pistol chain, then ASK):
1. Arena wiring (REQUEST 4 still open on e-arena): in `ArenaStage.setup`, set `arena.gun` and
   `HitLink.make(arena, HitFeel.shipped(view_rig), WeaponTable.shipped())`, set
   `view.cast_view.hit_link`, and hold the play on `link.hold`. If the arena lane has not done
   it, capture on a local scratch merge (never committed).
2. The cop's raised-gun tell (REQUEST 5 -> enemy-ai): route GuardBrain's shot through
   EnemyGunner so the tell line and the lock show in this same D5 view. Then quest-1 contractors
   become the dodge test: count rounds dodged by a strafe in pistol_fight --armored.
3. The flinch: HitFeel.reaction is emitted on non-lethal hits; nothing draws it. Until enemy-ai
   lands an animation, a 6-tick lean back along the hit direction in CastView (data: the
   class's stagger_ticks) would show it.
4. Then re-ASK gunplay-2 with pistol_fight_armored_32ppm.mp4 (D5, real cast, hit reaction) plus
   the 5/10/20/35 m TTK row for the pistol. Only after that: the machine pistol on the same chain.
- Gates at e2a88b9: lint 13/13; scenarios 20/20 (at 4972c90, view-only changes since); unit:
  all mine pass, test_save_slots fails here AND on int-day (shared machine, see FRICTION).
- MILESTONE (22:30): NEXT 3 done in code. `HitLink.lean(f)` listens to `HitFeel.reaction` and
  CastView draws a living contractor offset 0.3 m along the hit, easing back over the
  reaction's ticks (view only; the sim position is untouched). test_hit_link 3/3, scenarios
  20/20 (evidence/scenarios-it3b.log). NOT visually confirmed: at 32 px/m the `light` class
  lean is about 10 px for 6 ticks and did not read on a contact sheet. Next iteration: judge it
  at 48 px/m, and raise `light.stagger_ticks` or LEAN_M if it is still lost (a hit_feel.json value).

## Iteration 4 (22:32-23:17), BUILD
- Answers re-read 22:32: nothing new for gunplay (gunplay-1/2 placeholders A; the Director wants the
  enemy tell in the D5 full chain before a re-ask). This iteration builds exactly that.
- MILESTONE b0abbf4: `GuardTell` (features/combat/weapons/guard_tell.gd). With a table gun wired
  (`CombatArena.guard_tell`, null keeps GuardBrain and quest 1's goldens), a contractor stops, shows
  a tell (weapons.json tell_s 0.35 s: dashed vermilion aim line tracking Rivet, then solid line in an
  ink casing + a cream muzzle glint for the lock_frac 0.5 lock), then fires the rifle burst down the
  locked line at speed_scale (30 -> 13.5 m/s). FxView draws it. Fighter gained `tell_left` (not in
  write_state, so no golden moves). test_guard_tell 3/3: told before any round, slowed rounds,
  control (standing still is hit), a 5 m/s strafe takes none, planted fault (tracking through the
  lock) caught. Clip: gtai-masters/eve/gunplay/pistol_fight_tell/ (20 s, 32 px/m, fixed 60).
- FRICTION/FINDING (the first dodge run changed nothing: 25/61 vs 25/60): quest 1's bot holds a
  firing post at (100, 2) and walks back every tick, so a positional nudge never sticks (it also
  is not the city follow: that writes back what the stage gave it). Fix: `CollectCallPlay.after_act`
  (dev/bots, shared dev file, +3 lines), a callable run after bot.act() and before the step; the
  pistol_fight `--dodge` uses it to rewrite stage.intent.move_by on each lock (4.5 m/s across the
  locked line for lock + 24 ticks, the side alternates per dodge, a running strafe never flips).
- FINDING (design): the 8-degree rifle cone at 12 m is +-1.7 m, so the drawn line lied about a cone.
  New data value `enemy_fire.lock_spread_scale` (schema updated), default 0.3. Armored dock fight,
  enemy rounds landed on Rivet: cone 1.0 standing 25/60, strafing 9/48; tight 0.3 standing 60/60,
  strafing 17/48 (the rest is crossfire from a second gunner on another line; seen at frame ~860).
  ASK gunplay-3 filed (default A = tight 0.3), with both dodge clips and the locked-tell still.
  Recorded in docs/decisions.md.
- Rules applied: realtime-combat-semantics (the telegraph must show the real threat zone; incoming
  danger in the saturated colour), morning palette verdicts (vermilion = danger: the aim line and
  enemy rounds; cream = Rivet's rounds and the glint; red only blood).
- Gates at 8dac77f: lint 13/13; scenarios 20/20 (evidence/scenarios-it4.log, at b0abbf4: data-only
  and dev changes since); unit full run 564/564 at b0abbf4 incl. test_save_slots this time;
  test_guard_tell + test_hit_link re-run at 8dac77f 3/3 each.
- MILESTONE 20438a7: `pistol_fight --ppm=48`. Clip gtai-masters/eve/gunplay/pistol_fight_48/ (same
  dodge run, 17/48). The drawn flinch (LEAN_M 0.3 m, light class 6 ticks) reads at 48 px/m as a
  ~14 px shove, mostly under the impact star for its first 3 ticks (lean-sheet.png: 16 consecutive
  frames, 2x crop). Left as is: the owner's 21:25 direction is no number tuning before the full
  look, and the star already carries the hit. A real flinch needs enemy-ai's animation (REQUEST 5).
- REQUEST 7 -> enemy-ai (sharpens REQUEST 5): the tell is now in the sim on quest 1's fight.
  While `GuardTell.telling(fighter)` (Fighter.tell_left > 0) play the raised-rifle pose; while
  `arena.guard_tell.locked(fighter)` hold it still (the dodge window). Draw nothing else: FxView
  already draws the aim line and the muzzle glint. The same two calls work for any CombatArena
  with `guard_tell` set (arena lane: set it next to `arena.gun`, REQUEST 4).
- FRAMES: frames.json top 5 are this iteration (dodge tight 32, 48 px/m, the dodge pass still,
  the locked tell still, dodge with the full cone).

- MILESTONE 5068f67 (NEXT 2 started, measured): `GuardTell.one_slot` (off by default, an A/B
  switch): one attack slot, so only one contractor tells or bursts at a time. Armored dock fight,
  tight burst, enemy rounds landed: no slot standing 60/60 / strafing 17/48; one slot standing
  41/41 / strafing 9/36 (fewer rounds: the pace drops by a quarter). test_guard_tell 4/4 (never two
  busy at once, both still get turns). Unit full run at 8bb66ea: 567 passed, 0 failed
  (evidence/unit-it4.log). FRICTION: the earlier full GUT run "passed 564" while test_guard_tell
  had a parse error: GUT's CLI skipped the broken script silently; run_unit.mjs counts it. Always
  read the per-file count for a new test.
- Clip (one slot + dodge): gtai-masters/eve/gunplay/pistol_fight_one_slot/ if the background
  capture finished before the stop (see run.log there).

NEXT (iteration 5):
1. Apply gunplay-3 when answered (one value: weapons.json enemy_fire.lock_spread_scale; B = 1.0).
2. Crossfire: one_slot is built and measured (9/36 vs 17/48). Decide its default with a side-by-
   side clip (pistol_fight_one_slot vs pistol_fight_dodge_s0.3) as one ASK, or give the slot
   count to enemy-ai's encounter director (attack slots belong to enemy-ai; GuardTell only
   honours them). Also: let the scripted dodger pick the side away from other live lines.
3. Rivet's own side of the dodge: the dodge is a scripted strafe through the bot's intent; a real
   player strafes with the move stick while aiming (twin-stick). Capture a TickInput-driven dodge
   (stage.pilot with a scripted TickInput) so the clip shows the real mover's acceleration.
4. Then the machine pistol on the same D5 chain (GunHand with &"machine_pistol"), same clip.
- Gates at 7347bad (end of iteration 4): lint 13/13; scenarios 20/20 (evidence/scenarios-it4b.log);
  unit 567/567 at 8bb66ea + test_guard_tell 4/4 at 5068f67 (later commits are docs and a dev-scene
  arg split, re-run: same 9/36). One-slot clip landed: gtai-masters/eve/gunplay/pistol_fight_one_slot/.
  Godot processes of mine: none left running.

## Iteration 5 (23:04-23:30, BUILD)
- answers.json re-read at 23:04: no answer to gunplay-3 yet (default A, spread 0.3, stays).
- MILESTONE 6caa763: `pistol_fight --weapon=<id>` (any weapons.json row on the D5 hit chain;
  unknown id exits 2). Machine pistol, armored dock fight, alternating dodge: Rivet 104 rounds,
  70 hits (67 %: bloom 1.4 deg/shot up to 14 deg at dock range; the tapped pistol is 42/42),
  14 kills; enemy rounds landed 10/31. The stream reads as separate tracers (f0060: three in
  flight). Clip: gtai-masters/eve/gunplay/pistol_fight_machine_pistol/ (32 px/m).
- MILESTONE 3b1a5da: `--dodge-away` (the strafe side away from the other live gunners). Armored
  dock fight, enemy rounds landed: pistol 17/48 (alternating) -> 8/42; machine pistol 10/31 -> 8/33.
  Headless and the rendered capture give identical counts (deterministic). DECISION (docs/decisions.md):
  GuardTell.one_slot stays off; the crossfire was the dodge walking into a second line, and a smart
  strafe beats one_slot (9/36) without slowing the fight by a quarter.
- FRICTION/FINDING (evidence labels): `--ppm=48` never worked. PrintStage takes its zoom from the
  CameraRig (camera.json on_foot = 32), and the rig only eases in step(), which this scene never
  calls; `_view.px_per_m` never reached the screen. Proof: evidence/pistol_fight_48 f0240 and
  pistol_fight_dodge_s0.3 f0240 are byte-identical (md5 ef2d39...). So every pistol_fight clip so far
  is a true 32 px/m (labels right) and iteration 4's "48 px/m flinch" judgement was made on the
  32 px/m image. Fixed (1a916bb): --ppm snaps the rig to the camera.json mode with that ppm; verified
  by the floor tile (4 m: 128 -> 192 px). frames.json: the fake 48 entry withdrawn, a real 48 px/m
  machine pistol clip added (pistol_fight_mp_48/). The 48 px/m flinch needs re-judging on it.
- FRICTION: I committed a parse error (5ac6d4a, `float(Variant)` under warnings-as-errors); lint does
  not parse scripts and `--check-only -s` cannot resolve autoloads for this scene. Caught by the
  capture's run.log, fixed in the next commit. Always grep run.log for SCRIPT ERROR before trusting
  a capture. Also fixed: a bad arg / weapon now exits 2 without script errors (_process guarded,
  the weapon check before the quest starts).
- Rules applied: realtime-combat-semantics (the threat zone is honest; the player can read it and
  move off the line), evidence rules (look at every frame: the identical-frame check is what caught
  the ppm lie).
- Re-judged the flinch on a real 48 px/m frame (pistol_fight_mp_48 f0056): the impact star (~2.3 m,
  ~110 px) still covers the 0.3 m lean (~14 px). Same conclusion as iteration 4, now on the right
  image: the star carries the hit; a readable flinch needs enemy-ai's animation (REQUEST 5/7).
- FRICTION (gate, contended): full unit run at 1a916bb: 555/568, all 13 failures in
  test_save_slots (ERR 16 on the slot files, flip() out of bounds). Two other lanes' GUT runs were
  live at the same moment (PIDs 9260, 50232, not mine), and SaveKit.SCRATCH is `user://test_save`,
  which is the same folder for every worktree of this project on the machine. Not a gunplay change
  (my commits touch only dev/gunplay/pistol_fight.gd). REQUEST 8 -> autosave owner: SaveKit.SCRATCH
  per process (append OS.get_process_id()) so parallel lanes stop colliding. Log:
  build/test-results/unit-tests.log, summary evidence/unit-it5.log.
