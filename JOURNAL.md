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
