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
