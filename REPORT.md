# REPORT: day lane d5-combat (branch `d-combat`), 2026-11-03 10:06 to 17:30

Mission: combat in the default D5 game looks and feels brutal. Noir's red blood becomes the default blood under
D4/D5, and the comic kill beat becomes an owner A/B.

`<masters>` = `C:\Users\kazda\kiro\gtai-masters\day-d5\d5-combat\` (frames.json with 15 entries, ladder.png, clips,
raw/). A copy of frames.json, the ladder and the strips is in `evidence/d5-combat/`. The running log is `JOURNAL.md`.
Every performance number here is **CONTENDED** (7 lanes, one GPU).

## Summary
- 51 commits on `d-combat` (116 files, +2749/-52). The code froze at **5a6e21b**. Only journal, evidence and report
  commits came after it.
- **Gates at the freeze** (evidence/run.mjs --no-bench, 16:40; unit re-run on a clean tree):
  - lint 13/13;
  - unit 352/0;
  - scenarios 8/8;
  - parity exact (1200 steps, the planted mutation caught);
  - selftest PASS (look goldens 11/11 worst 0.74, block goldens 5/5 worst 0.97).
  - Flake: scenario_city_chase once went over the 2 ms nav budget at 15.2 ms. A headless re-run was green (491 us).
    It is nav code, not FX.
- **Bench: not a valid judge today.** Five runs, all CONTENDED. The riot (400 actors, blood on) p99 was
  4.86 / 7.68 / 15.18 / 9.87 / 10.31 / 12.71 ms with no hot-path change between most runs, and the riot hitches are
  `present` waits. The last judge (iter5, 16:57) MISSES p99CpuMs, low1Fps and over50.unexplained. Re-bench on an
  idle machine.
- Camera breaks rejected: 0 (every frame straight down).
- No Codex images were generated: everything is code, data and in-engine frames.

## What works (claim -> evidence)
1. **Noir's blood is the default blood in the real game** (`--blood=noir|ink|both`, default noir; `ink` = the old
   D4 splat, kept as the fallback).
   - `CombatBlood` plus the `boot/city_blood.gd` glue drive the city riot from the sim cues (shot, projectile_end,
     death). On seed 91: 16 deaths, 16 bled, 15 sprays aimed along the killing round.
   - Quest 1's CombatArena bleeds through `Events` (CollectCallView): 48-49 guards soaked, 0 missed.
   - What prints: directional spurts, teardrop splats with satellites, pools that spread with a wet-edge scallop,
     drip trails, wall splats (they pile at the wall base and never cross a roof edge), and corpse stains.
   - Blood draws on its own `blood` band, because look_d4 would turn any red into the vermilion plate.
   - Colours: blood #A30509 and pool body #540005. These equal d5-city's palette `blood` / `blood_dark`.
     CombatBlood reads the tokens when they exist, so the merge changes nothing. Noir's pool body keeps #750008.
   - Frames: `<masters>frames/final-t900-{32,48,64,128}ppm-pair.png` (ink before, noir after),
     `fight-final-t900-128ppm.png`, `wall-splat-f1-t900-32ppm-crop.png`, `quest1-stains-04-crop.png`.
   - Clips: `<masters>clip-it4-final-{48,64}ppm.mp4` (15 s, real time).
2. **Pools spread from under the body** (58a8388).
   - The city's dead slide 0.54 m along the blow, so the pool used to sit beside the body.
   - `blood_fx.json game.pool_lead_m` fixes it on the city cue path. Frames: `frames/pool-lead-t{480,600}-*-pair.png`.
3. **Riot cost.**
   - Noir's draw path cost 61.5 ms per redraw at 400 decals. It is now MultiMesh splats, cached pool fans and
     bucketed drops.
   - City riot average 0.22-0.42 ms/frame (debug, CONTENDED). The stains step costs 34-48 us.
4. **Robots do not bleed.**
   - Rivet and the robots throw white sparks and black oil. The oil now has a cream rim plus an OilLeak trail, so it
     reads on asphalt: `frames/fight-oil-after-noir-t420-64ppm.png`.
   - A corpse's soak fades under any walker standing on it (Rivet or rioters): `frames/walker-fade-t480-64ppm-pair.png`.
5. **Kill beat A/B: `--kill-beat=off|panel|flash|both`, default off.**
   - It shares the FlashBudget (at most 3/s) and stays calm under `--reduced-motion`.
   - Evidence: `frames/beat-modes-contact.png`, `beat-{flash,panel,both}-48ppm-realtime.mp4`, `beat-{flash,both}-64ppm-realtime.mp4`.
     There is no real-time panel clip at 64 px/m; panel at 64 is in the contact sheet only.
6. **Muzzle pop** (MuzzlePop): it lights the scene for one tick on the shot nearest the focus.
   - A 3-band paper pool, 5 m across, at most once per 20 ticks, spending from the FlashBudget. It is off under
     reduced motion.
   - Strength A/B: `frames/pop-strength-ab-64ppm.png` (0.32 is the default).

## Owner picks waiting (the 18:00 sync)
1. `--blood` default (noir proposed) versus the ink fallback.
2. `--kill-beat` mode (off, panel, flash or both).
3. Muzzle pop 0.32 or off.
4. Pool body #540005 (the doctrine, current) versus #750008: `frames/pool-dark-t900-64ppm-pair.png`.
5. Pool size 22 / 16 / 12 px: `frames/pool-size-ab-t900-64ppm.png`.
   - My read: 16.
   - The pick is one key: `blood_fx.json game.pool_radius_px`. Noir keeps 22.
6. Orphan pools: the sim despawns the dead at 8 s and the pools persist and fade. Is that wanted?

## Not done / gaps
- **Hit-stop and held knockback were not tuned.** camera.json and the sim are not my files.
  - REQUEST 3 asks for the kill hit-stop to go from 6 to 8 ticks under a beat mode.
  - Quest 1 has no hit-stop at all until it gets a player entry.
- **Blood on a non-lethal human hit has no trigger today.** Humans have 1 hp, and the tazer chain only hops metal.
  The hook is ready: `Fighter.hurt_tick` -> `splash(..., "player_hit")`.
- **Car-hit deaths slide further than 0.54 m,** so their pool sits short of the body. The fix needs a death-speed
  field on `FxTriggers.cued` (core/render, shared).
- **The `--beat-frames` stills were taken without `--fixed-fps`,** so their beat timing is compressed. The
  `*-realtime.mp4` clips are timing-true.

## Shared-file changes (minimal, in JOURNAL)
- `boot/launch_args.gd`: `--blood`, `--kill-beat`.
- `data/tables/render_layers.json`: band `blood`, canvas `beat`, band `kill_beat`.
- The render_layers schema: z minimum -4000.
- `core/render/fx_triggers.gd`: signal `cued`.
- `core/render/README.md`.
- `docs/decisions.md`: the junction golden re-bless (aa1661d) and the fx pool body.
