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

NEXT:
1. A visual range dev scene `project/dev/gunplay/` (or the arena station once it is on this
   branch): tracers at 32 and 48 px/m, the six weapons side by side, a 10-25 s `--fixed-fps 60`
   clip, then frames.json in gtai-masters/eve/gunplay/. The owner's ASK needs the clip.
2. `arena_stations/gunplay.json` (+ `gunplay.schema.json`): lanes at 5/10/20/35 m, targets,
   weapon ids that point into weapons.json.
3. Aim: reticle and aim line (range-readable), and pad magnetism (light cone, off for the mouse).
4. The enemy shot tell and muzzle flash in the view, plus a dodge clip (Rivet strafing through a
   volley).
5. A scenario test for projectile determinism through `run_scenarios` (replay identical, planted
   fault).
6. Burn panic and fire-patch visuals; the vehicles-lane hook for rocket car damage.
