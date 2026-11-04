# human-reactions: night report (2026-11-04, 01:10-08:30)

Branch `n-human-reactions` (118 commits over main `9ebc5918`). The last code commit is `fdff7990`. Every commit
after it changes only JOURNAL. Evidence: `C:\Users\kazda\kiro\gtai-masters\n4\human-reactions\`
(`frames.json`, 15 entries, all files present) plus `evidence/` in the lane cwd (untracked clips).
Paths below are relative to the masters folder unless they start with `evidence/` or `project/`.

## After 09:00 (extension, updated in place)
- **Robot thug power-down death** (`fbfa406b`, `3cf3ce29`): its own death, no longer the human fall. The knees give into a
  crouch, it pitches flat on the spot (0.2 m, no slide), the head drops last, the plates darken; sparks and oil, no
  blood. `death_robot` is outside `death_map` and the signature hooks, so no human can ever play it. Dev pit only (the
  live `CombatArena` has no robot fighter). Clips: `robot_powerdown_48ppm.mp4` (follow camera), `robot_powerdown_64ppm.mp4`
  + `_64ppm_sheet.png`, `robot_powerdown_32ppm.mp4`; death frame 138 at every zoom. Honest read: at 48 px/m the thug is
  weapon-art's ink mass, so the fall reads by silhouette (crouch, then a flat X); the plates go dark and the pale
  optic goes out at every zoom (dim 0.7; 0.45 was filmed first and left the optic lit at 32 px/m).
  The oil spray from six hits is busy.
- **Knockdown: no shot from the floor** (`e41fb9c6`, gunplay `83429487` cherry-picked, `FighterFx.RISE_TICKS` 29):
  re-filmed `pit_knockdown_rise29_48ppm.mp4` (follows Rivet) and `_64ppm.mp4` + `_64ppm_sheet.png`. The guard is blown
  flat, lies, rises, and his next aim tell starts only once he stands. Call 4 is now answered B on this branch.
- The pit's dev camera keeps a fresh corpse in frame for 3 s (the 04:00 aftermath rule); `--zoom=` films 48/64 px/m.
- 48 px/m re-films for the 04:00 rule: `pit_burn_death_48ppm.mp4` (+ sheet; the victims die near the frame edge
  because Rivet stands still, and the old flame stars still hide the burning body) and `riot_crowd_48ppm.mp4` (the city
  riot: 20 cowers, 3 trips, 12 deaths, the same counts as before).
- Gates on the code tip `e41fb9c6`: lint 13/13, unit 754/754, scenarios 33/33 (city_chase nav flake under load, green
  alone), parity bit-exact (mutation caught at step 629). Look goldens not re-run (no render path changed: the robot
  pose is dev-pit only and the RISE hold is sim-side in the arena fight).

## Gates of record (on `fdff7990`)
`node tools/evidence/run.mjs --no-bench --allow-dirty` (the only dirt was the untracked clips in `evidence/`):
- lint 13/13
- unit 750/750
- scenarios 33/33
- parity bit-exact (the planted mutation was caught at step 629)
- look goldens 11/11 (worst 1.87) and block 5/5 (worst 1.77)

The selftest FAILs only on the known accent-audit rows. These are the 48 px/m vermilion and blood on vehicles, which belong to d5-city and gunplay's blood flicker and have been there since iteration 5. This lane changed no replay or parity golden. The 7 look goldens were re-blessed once, deliberately, for the riot shield slab (`0f6d3c9b`, bisected, with a line in decisions.md).

## What works

### 1. Reaction and death layer on the real cutout rigs
This is `project/features/combat/react/`, driven by the table `project/data/tables/human_reactions.json` and its schema.

- **`ReactLink`** listens to `CombatArena.struck`. It picks a wound family or a standard death from the hit direction and the weapon's hit class. It is wired into the live arena's `ArenaRigs` (`--rigs`) and the city block (`--arena=city --rigs`).
- **Wound families**: flinch, stagger, knockdown with slide, lie and get-up, riot-shield block, melee spin/fold, electro stun, burning, near-miss duck (a hit while in cover), cower, trip, and the wounded limp.
  - Evidence: `react_families_r7_64ppm.mp4` (32 s, real time, every family and death on the cast rigs; the 32 px/m version is `evidence/react_families_r7_32ppm.mp4`).
- **Five standard deaths, each ending in its own corpse** (sheet `evidence/deaths_r7_64ppm_sheet.png`, one row per death):
  - bullet: falls back or crumples by direction;
  - melee: curled round the blow;
  - blast: thrown, lands twisted with one leg up;
  - burn: charred over soot, smoking, no red;
  - electro: stiff fall along the shot over an inked scorch.
- **Blood pools** come from d5-combat under every corpse except the burn kill.

### 2. The live game, not only the dev pit
These runs use the real Rivet with the real pistol, flamethrower, rocket or electro gun, through gunplay's bot: `--arena --rigs --bot=gunplay --weapon=<id> --start=pit --clean`.

- Electro death at 48 px/m: `pit_electro_alongshot_48ppm.mp4` and `_sheet.png` (kill at frame 653); 64 px/m: `pit_electro_scorch_64ppm_sheet.png`.
- Burn death: `pit_burn_death_32ppm.mp4` and `_zoom.png`.
- Blast death: `pit_blast_death_32ppm_sheet.png` (clip `evidence/pit_blast_death_32ppm.mp4`).
- Knockdown, lie, get-up, then the blast death: `pit_knockdown_getup_32ppm.mp4`, `_32ppm_zoom.png`, `pit_knockdown_getup_64ppm.mp4`. These use `--armored=12`, a dev hp multiple so that a human survives a splash. The run is deterministic: the death lands at frame 962 in both runs.
- Mixed squads in the pit: `evidence/pit_squads_32ppm.mp4`.
- Armored pistol fight with the limp: `evidence/arena_armored_limp_32ppm.mp4` and `_64ppm.mp4`.
- City block (game-city): `city_pit_rigs_32ppm.mp4`.

### 3. Each cop type shot from four directions
The arena station `react_line` (`project/data/tables/arena_stations/human-reactions.json`) holds four never-dying dummies: patrol, riot, pedestrian and SWAT. `--bot=react_line` walks Rivet round each one.

- 64 px/m: `react_line_cops4_64ppm.mp4` (36 s, 16 shots, 16 wounds); 32 px/m: `evidence/react_line_cops4_32ppm.mp4`.
- **Riot shield slab** with white metal sparks off its face when a round from the front is blocked: `arena_shield_sparks_64ppm.mp4` and `_sheet.png`, plus `riot_shield_48ppm_sheet.png` (before and after).

### 4. Crowd reactions (city sim)
- **`CityScare`** feeds a shot into the native `CityCore::scare` (made public; parity stays bit-exact).
- **`CrowdReact`** makes pedestrians cower (hands over the head, a glance back at the bang), flee, and trip over bodies. The fight's own dead count as bodies too (`extra_bodies`).
- A death startles the living within 2.5 m.
- Quest 1 on the city also gets `CityScare`.

Clips:
- `city_scare_32ppm.mp4`, `city_scare_64ppm.mp4` (game-city, `--crowd=420`)
- `street_startle_64ppm.mp4`
- `riot_crowd_64ppm.mp4` and `riot_crowd_32ppm.mp4`: a riot with fleeing rioters, trips, the blue shield line and the standard deaths with red pools

Cost: `CrowdReact.observe` dropped from 1744 to 330 to 150 µs per tick in a 30 s riot. This was measured headless and CONTENDED.

### 5. The death hook for brutality
`DeathPipe.add_signature(func(rig, hit_class, dir, weapon) -> bool)`. A signature kill returns true and the standard death never starts. `DeathPose.stiff_channels` is public so brutality's electro kill can lay the body down (REQUEST 29).

### 6. Scenarios with planted faults
| Scenario | Fault it catches |
|---|---|
| `scenario_human_react` (timings per family, direction from four sides, digest twice) | inverted direction, a missing burn row, a signature kill taking the death |
| `scenario_react_line` | every spot on the west |
| `scenario_city_scare` | scare turned off: 0 fled |
| `scenario_crowd_react` | `STARTLE_M` set to 0 |
| `scenario_bodies_crowd` | |
| `scenario_arena_pit` | |

All six live in `project/tests/scenarios/` and are part of the 33/33.

### 7. Robot thug (light, as briefed)
- `ThugPlan` (`d4556023`) gives the thug its own proportions: a squat brawler with long arms.
- It has its own parts (`c819d6be`, `ArtDir` thug, no longer King's).
- Each hit throws sparks and oil.
- The thug lives in enemy-ai's dev pit only. Clip: `evidence/thug_plan_32ppm.mp4` (King's parts, before `c819d6be`).

## What does not work / honest gaps
- ~~No robot death pose~~: done after 09:00 (see the top). It still lives only in the dev pit: the live `CombatArena` has no robot `Fighter.Kind`.
- **The riot shield is render-only.** The sim still takes the hp of a round the shield "blocked".
- ~~A knocked-down guard can fire as it rises~~: fixed after 09:00 (gunplay `83429487` cherry-picked, re-filmed).
- **Gunplay's shield sparks are not wired in.** `ReactLink.shield_test` exists to plug into gunplay's `GunFx.shield_test`, but the one wiring line waits for the merge.
- **The burn death clip shows gunplay's old 2.1 m flame stars.** The cherry-pick of their thinner flames (`e1b22073`) conflicted and was aborted.
- **Trip over bodies is hard to see live.** It is proven on the board, in unit tests and in the riot log (4 trips in 30 s), but one trip in a 300-person riot is hard to pick out by eye.
- **The limp is small at 32 px/m** (clear at 64).
- **Near-miss ducks are rare against the bot**, which seldom misses. The forced-miss clip is `evidence/near_miss_line_64ppm.mp4`.
- **Electro kills still spray red.** Gunplay passes the `shot` kill kind for the electro gun.
- **No idle bench.** The only bench was CONTENDED (07:42: riot p99 8.6 ms, not comparable with the idle record of 6.007). The CrowdReact saving is unbenched on an idle machine.

## What blocked, and for how long
- Nothing blocked for more than one iteration.
- FRICTION about 20 min (02:20): look goldens drifted under load. The real cause was the shield slab, bisected and re-blessed in iteration 9.
- FRICTION about 10 min (iteration 13): the gunplay cherry-pick conflict, aborted cleanly.
- Iterations 14-17 (08:09-08:33) changed no code on purpose. Each window was too short to land an edit plus gates plus a 32/64 px/m clip.

## Calls for the owner
Each call is one value or flag. A is what is live now.

1. **Electro corpse** (`pit_electro_scorch_64ppm_sheet.png`; before: `evidence/death_electro_stiff_64ppm_halfspeed.mp4`):
   - A: falls back on the heels along the shot, over a scorch;
   - B: the old plank;
   - C: A without the scorch.
2. **Burn corpse** (`pit_burn_death_32ppm_zoom.png`):
   - A: no red, charred over soot;
   - B: blood like any kill (`CombatBlood.DRY_KILLS = []`).
   - Also: should electro kills go dry too (needs a `shocked` kill kind from gunplay)?
3. **Riot shield** (`arena_shield_sparks_64ppm_sheet.png`):
   - Look: A, the slab (1.9 x 1.45); B, a flat rectangular shield (needs new art).
   - Sim: should the shield also stop the hp (replay re-bless)?
4. **Knockdown** (`pit_knockdown_getup_64ppm.mp4`):
   - A: the guard aims while rising (this branch);
   - B: fire held until fully up (gunplay `83429487`; live on this branch since 09:00, `pit_knockdown_rise29_64ppm.mp4`).
5. **Corpse variety** (`evidence/deaths_r7_64ppm_sheet.png`):
   - A: five distinct corpses;
   - B: one shared sprawl.
6. **Crowd startle radius** (`street_startle_64ppm.mp4`):
   - A: 2.5 m;
   - B: 4 m.
7. **Limp strength** (`evidence/arena_armored_limp_32ppm.mp4` vs `_64ppm.mp4`):
   - A: render-only;
   - B: also slow the wounded walk in the sim (moves replays).
8. **Crowd density around a fight** (`city_scare_32ppm.mp4` at 420 people):
   - A: keep the block's 120;
   - B: raise it for the arena.

## Next steps (in order)
1. After the merge with n-gunplay:
   - add `gun_fx.shield_test = link.shield_test` (one line in `fx_view`) and film `react_line` at 64 px/m;
   - re-film the burn death with the thin flames.
2. A robot `Fighter.Kind` in the live fight, so the thug's power-down death plays in the arena, not only the dev pit.
3. An idle bench of the riot p99.
4. Check brutality's REQUEST 29 electro drop on a director reel (48 px/m).
