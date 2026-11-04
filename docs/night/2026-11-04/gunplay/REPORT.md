# REPORT: lane gunplay (`n-gunplay`), night 2026-11-04

DRAFT, written at iteration 11 (06:50). The report phase checks the head, the gates and the clips again.

Scope: weapons and projectiles, the weapon table, the shared hit-feel module, aiming, enemy fire and
its tells, `CombatArena`'s weapon behaviour, the range station. `MASTERS` below means
`C:\Users\kazda\kiro\gtai-masters\n4\gunplay\`. `WT` means this worktree. Branch cut from `9ebc5918`.
JOURNAL: `WT/JOURNAL.md` (every claim below has its dated line there).

## Summary

- **The evening's largest gap is closed.** In the real fight (`CombatArena`, which the arena pit,
  the city proving block and the quest share), the flamethrower burns (panic plus damage over time,
  fire patches), the rocket splashes and knocks down, the electro gun chains and stuns, and the
  molotov flies its arc and leaves a fire patch. One model (`FightAreas` + `FighterFx` +
  `FightReach`). `scenario_gunplay_fight` proves that the same seed gives the same hash and that a
  planted fault is caught, for each of the six guns.
- **Every gun in the table fires in the real fight with its own look**, in the order the brief
  gave. Core six: pistol, machine pistol, rocket launcher, flamethrower, electro gun (tap stun bolt
  plus a held 0.6 s charged one-shot), molotov. Unique five: hand cannon, plasma rifle, ray gun,
  homing shard gun, mini-nuke. All eleven are enabled. A kill on a human carries the weapon id, the
  hit direction and the point to `brutality`'s signature kills (`kill_landed`).
- **They read apart with the sound off.** Each gun has its own muzzle flash shape, tracer or
  projectile, casings (or none), impact by surface, reload and screen feel, and a `shot_cue` sound
  hook. Proof: the six-gun reels in the pit at 48 px/m and in the city at 32 px/m, plus 64 px/m
  close-ups.
- **Enemy fire reads.** Before firing, a cop stops and shows a dashed vermilion aim line, which
  locks solid. Then a muzzle star, and a slowed round (0.45x) down the locked line (gunplay-3 = A).
  Where it hits Rivet's plating it throws cream sparks, and the cast tint flashes.
- **The riot blood cost:** the flying drops now redraw on their own canvas item. The bench JSON
  carries `bloodUsPerFrame` / `bloodPoolDraws` / `bloodDropDraws`. The combat blood measures
  0.04-0.13 ms a frame, which is 0.8-1.0 % of the riot p99, on every contended run tonight. **The
  riot p99 is not the blood any more.** The idle number of record stays the Director's: every one
  of my bench runs was CONTENDED.

## What works (each with its proof)

| Claim | Evidence |
|---|---|
| Burn, splash with knockdown, electro chain and stun, molotov arc with a fire patch, all in `CombatArena` | `WT/project/features/combat/weapons/{fight_areas,fighter_fx,fight_reach}.gd`; `test_fight_areas.gd`; `scenario_gunplay_fight` (`WT/evidence/n1/gunplay-fight.json`) |
| How they look: rocket body, exhaust and a wobbling smoke trail; blast starburst and ink shock ring; flame puffs that grow and fade; electro zigzag and chain arcs; molotov arc over its shadow; fire patches over a scorch; burning and stunned humans | `FightAreasArt`, `FightChargeArt`; `MASTERS/side_by_side_table_six_fightcam_48ppm.mp4` |
| Bullet guns (GunFx): per-gun muzzle flash, tracer weight, brass casings that pile up, smoke, magazine drop and reload ring; impacts by surface (dust and scuff on the ground, cream sparks on metal and on Rivet's plating, an ink burst on a body) | `gun_fx*.gd`, `data gun_fx.json`; `test_gun_fx.gd`; `MASTERS/side_by_side_pistol_mpistol_fightcam_64ppm.mp4` |
| Pistol and machine pistol finished in the arena range, the pit and the city block | `MASTERS/side_by_side_range_64ppm.mp4`, `camfight_pistol/`, `camfight_machine_pistol/`, `city9_pistol/`, `city10_machine_pistol/` |
| The unique five in the real fight, each with its own projectile (hand cannon's fat flare and shock ring; plasma's pulsing comet bolts; the ray's straight beam with ripple rings; homing shards that fan out and curve in; the mini-nuke's lobbed shell, flash, mushroom and burning ring) | `MASTERS/side_by_side_unique_five.mp4`, `fightcam_unique_kills_64ppm.png`, `city_*_block_32ppm/` |
| The electro charged shot (brutality REQUEST 12) | `MASTERS/arena_electro_charge_64ppm/`; `test_charge_shot.gd` |
| Thrown weapons land at the cursor (aim distance in TickInput bits 25-28; pad: stick deflection) | `test_aim_reach.gd`; `MASTERS/arena_molotov_reach_48ppm/` |
| A charged bolt lands as a blast in the hit feel (stop, knockdown, shake) | `HitLink.CHARGED_CLASS`, `CombatArena.struck_charged` |
| Readable enemy fire: tell, lock, muzzle star, slowed round, sparks on Rivet | `guard_tell.gd`, `test_guard_tell.gd`; `MASTERS/arena_cop_fire_48ppm/` |
| Riot blood: drop redraw split, A/B of settled 6 vs 30 (kept at 6: within noise), bench metrics | `WT/evidence/n3/riot-blood-ab.md`; bench runs `WT/evidence/n{1,3,6,8,9}/bench.log` |
| Time to kill per weapon, range and target (24 seeds a cell); the shard's reach, and the electro tap vs charge | `WT/evidence/n6/ttk-shard.md`, `WT/evidence/n8/ttk-electro.md`, raw `ttk.json` |
| Fire patches print an ink char (a splash burn: soot wedges, floor hatch, a broken edge), and the burnt ground stays 15 s after the fire; a rocket blast scorches the ground it hit (view only) | `fight_scorch.gd`, `fight_scorch_art.gd`; `test_fight_scorch*.gd`; `MASTERS/molotov_scorch_ab_city_32ppm.mp4` (+ `.png`), `MASTERS/camfight11_molotov/`, `MASTERS/rocket_scorch_ab_city_32ppm.png`, `MASTERS/camfight11_rocket/` |
| The range station: `data/tables/arena_stations/gunplay.json` (`--weapon=<id> --bot=gunplay`, `--cam=fight`) | `WT/project/data/tables/arena_stations/gunplay.json` |
| Other lanes' REQUESTs answered: brutality 1/12, human-reactions 1/2/3 (vertical blood bars, spray floor, `GunFx.shield_test`), showcase 5 (the rocket body and smoke trail; showcase 3, Rivet's hit flash, landed from human-reactions), rivet-arsenal 12 (the aim distance) | JOURNAL "Answers to REQUESTs" lines |
| Dev capture camera `--cam=fight` (pit only; view only, the sim is identical) | `fight_cam.gd`; `MASTERS/fightcam_hand_cannon_64ppm_ab.mp4` |

## Calls for the owner

Each one is a single value. The default stands until you answer.

- **gunplay-7:** the electro charged shot. A: holding the trigger fires automatically at full charge (default). B: fire on release. Clip: `MASTERS/arena_electro_charge_64ppm/arena_electro_charge_64ppm.mp4`. Values: `charge_s` 0.6, `charge_damage` 150.
- **gunplay-8:** the mini-nuke's fire. A: it burns as a ring round the rim (default; ground zero reads burnt out). B: a full 6 m disc. Clips: `MASTERS/arena_nuke_ring11_32ppm/` (the ring as printed char, 3d85efbe; first cut `arena_nuke_ring_32ppm/`) vs `MASTERS/city_nuke_block_32ppm/`. Value: `RING_PATCH_M`.
- **gunplay-9:** thrown weapons. A: they land at the mouse cursor (default; 1.2 m steps, up to 18 m). B: the fixed 14 m lob. Clip: `MASTERS/arena_molotov_reach_48ppm/`. Value: `input_actions.json aim.aim_reach_step_m` (0 gives the fixed lob).
- **gunplay-10:** electro taps on humans. A: the plain taps stay lethal on humans (default; two taps drop a still human in 0.62 s). B: taps stun only, so the charged one-shot is the only electro kill. Evidence: `WT/evidence/n8/ttk-electro.md` and the charge clip. Value: the electro row's damage on humans.
- **gunplay-11:** pad throws. A: a full stick push gives the old 14 m lob (default). B: a full push gives 18 m. Value: `LiveInput.stick_reach_m`.
- **gunplay-12:** the play camera. A: it frames the fight (half way to the foe Rivet faces, at most 4.5 m off him, a fresh kill held 1 s). B: the placeholder arena-2 A (leans toward the mouse). Clips: `MASTERS/fightcam_hand_cannon_64ppm_ab.mp4` (left: camera on Rivet; right: fight framing) and `MASTERS/side_by_side_table_six_fightcam_48ppm.mp4`. In the city the camera point also steers the sim's spawner (`CitySystem.focus`), so a fight camera there first needs the view point and the sim focus split (a city-lane change).
- **gunplay-13:** the kill spray's smallest turn off the blow. A: 6 deg (default). B: a wider floor. Evidence: `WT/evidence/n9/blood_spray_floor_ab.png`. Value: `blood_fx.json game.spray_tilt_min_deg`.

## Not done / gaps

- No idle riot bench of record. The contended riot p99 ran 7.09 to 13.09 ms, and the blood was 1 % of it.
- The fight camera is a dev flag in the pit only. The city camera stays on Rivet (see gunplay-12).
- Quest 1 has no `GunHand` yet, so the quest fight keeps its evening pistol path. `LiveInput.px_per_m` is not wired there.
- The arena's default weapon is still Gloria. A table gun is armed only with `--weapon=<id>`, so that the arena scenarios do not move.

## Gates of record

As of iteration 11 (3d85efbe); the report phase re-runs them on the final head.

- lint 13/13 (the pre-commit hook on every commit).
- unit 745/745 at 3d85efbe (`WT/evidence/n10/unit-b.log`).
- scenarios 29/29 at 3d85efbe (`WT/evidence/n10/scenarios-c.log`).
- parity bit-exact, the planted mutation caught at step 629 (`node tools/evidence/run.mjs` on 47476501, `WT/evidence/n10/evidence.log`). No native or city-sim file has changed since.
- selftest: look goldens 11/11 and block 5/5 within mean 4, and the world lock holds. The accent audit flags vermilion 8 px on vehicles at 48 px/m and 28 px on a cop at 64 px/m. These are blood edges: the audit compares a full capture with a layer-hidden capture taken a frame later (d5-city's fix; see JOURNAL showcase REQUEST 7). The audit is not one of this lane's four gates.
- bench: every run tonight was CONTENDED (riot p99 7.09 to 13.09 ms; the blood was 0.8 to 1.0 % of it). There is no idle number of record.
