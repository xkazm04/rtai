# human-reactions: night report (2026-11-04, 01:10-08:30)

Branch `n-human-reactions` (118 commits over main `9ebc5918`). The last code commit is `fdff7990`. Every commit
after it changes only JOURNAL. Evidence: `C:\Users\kazda\kiro\gtai-masters\n4\human-reactions\`
(`frames.json`, 15 entries, all files present) plus `evidence/` in the lane cwd (untracked clips).
Paths below are relative to the masters folder unless they start with `evidence/` or `project/`.

## After 09:00 (extension, updated in place)
- **09:49-10:30 (iteration 21): the reel's electro signature corpse, checked and a fix handed over.** Showcase's
  round 17 electro chapter (48 px/m, 3x crop) shows brutality's signature corpse lying with the arms flung wide across
  the shot and stub legs, so it reads as a cop seen from above with the arms out, not as my stiff plank. The cause is in
  brutality's `KillSprawlCut.cut`: it sets `c_sprawl` but not `c_plank`/`plank_feet`, and it never runs `RigGait`,
  where the plank places its feet. I proved a one-file fix in a throwaway worktree on showcase round 18 (`9c9f59a5`).
  It sets the plank channels and snaps the legs, then puts the live rig's feet back. Filmed with showcase's own command
  before and after: `evidence/reel_electro_signature_plank_ab_48ppm.mp4` + `_ab_48ppm.png` (left: round 18, right:
  patched). The body now lies full length along the shot, the arms at the sides and the shoes toward Rivet, steady from
  the drop to the end. Unit 929/929 on the patched tree. The patch is `evidence/request_brutality_electro_plank_legs.patch`
  (REQUEST 30 -> brutality). It is not committed here because the file is brutality's and does not exist on this
  branch. If it misses the final round, the 10:30 reel keeps the spread-armed corpse.
  - **Routed as merge glue (10:00).** Brutality agreed but cannot land it: n-brutality has no `c_plank`, which exists only
    on this branch and showcase's main. With their OK, I sent it to showcase as glue for the final round. Patch v2
    (`9e5ab448`) also puts back every foot state `RigGait` writes, after the cut. A first try restored the shoe
    texture before the cut and the copy got the toe-off shoe; the film caught that and v2 fixes it. v2 was re-filmed
    with the same result as v1, unit 929/929. **Showcase applied it in round 19 (`08e1b72f`)**. I checked it at 10:08 in their final
    round 19 cut (`electro_gun.mp4`): the corpse lies full length to the last frame.
    Showcase also split `cut()`: v2 failed the repo's `gd-size` lint (44 > 40 lines), which I had not run on the
    patch. Behaviour is unchanged.
  - Also checked the reel's pistol and riot-cop chapters: the standard bullet sprawl with red and the shield sparks
    read cleanly. Nothing changed.
  - **Open, found at 10:00 in the claw chapter:** the claw's kills lie in the bullet X sprawl, and the second one
    folds under Rivet's feet. Raising `death_melee.travel_m` from 0.5 to 0.9 changed nothing on film (A/B on round 18,
    not kept), so these kills do not play my melee death. Traced at 10:07 (read-only, showcase main): `PlayerMelee._land` (rivet-arsenal,
    `features/player/player_melee.gd:89`) calls `arena.damage` but never emits `arena.struck`; `PlayerShock` does
    (`player_shock.gd:125`). `ReactLink` plays reactions and deaths only from `struck`, so claw and blade hits that are
    not signatures bypass the reaction layer: no melee spin, no fold, and the generic rig fall. Not fixed tonight: it is
    rivet-arsenal's file, and showcase's final reel was already running. Next step 7.
  - **10:11, the in-lane half (`1623e625`):** `ReactLink.hit_class_of` now maps the melee ids (claw, chainsaw,
    electro_baton, katana, plasma_sword) to `melee`, unit-tested. It changes nothing on screen until `PlayerMelee`
    emits `struck` (rivet-arsenal, plus the HitLink stacking call), so it is not filmed. Gates: lint 13/13, unit
    755/755, scenarios 33/33.
- **09:20-10:20 (iteration 20), two readability fixes, both in time for showcase's 09:45 merge:**
  - **The robot thug's lighter spray** (`e00a0041`): its hits now throw their own `blood_fx` row `thug_hit` (10 drops in
    a 70 deg cone along the blow) instead of Rivet's `robot_hit` (26 drops in a 160 deg fan). Six hits leave one
    streak behind the thug instead of an oil field over a third of the frame, so the power-down silhouette reads on
    clean ground. Filmed with showcase's own ROBOT THUG command: `robot_powerdown_light_48ppm.mp4` + `_sheet.png`
    (before: `robot_powerdown_48ppm.mp4`). Rivet keeps `robot_hit`.
  - **The electro corpse reads as lying** (`907d7282`, showcase r16 remainder: "a low blue lump, the legs short"): the
    navy trousers sank into the dark soot blot. Its blot and core now draw at 0.6 (`CorpseScorch.SHOCK_SOOT`), and
    the burn star keeps full ink. Both legs now read to the shoes. `pit_electro_legs_48ppm.mp4` +
    `pit_electro_legs_48ppm_ab.png` (frame 760, before on the left, after on the right). This is the standard
    electro death (live arena pit, city). Brutality's signature electro kill lays its own cut
    (`KillSprawlCut`, my end pose without the scorch), so the reel's electro chapter keeps its look. A longer plank (feet 460 px) was filmed
    and rejected because the feet come off the shins (`evidence/electro_plank_feet460_rejected_48ppm_zoom.png`).
  - **Tried and not done: the burn deaths in the middle third.** The burning victims run about 11 m from Rivet before
    they fall. The arena view scales to the window, so a 2560x1440 render shows the same 26.7 m. At 48 px/m, no crop
    can centre the victim without losing the scale. Fixing it needs a directed camera that leans to the kill (the
    arena camera, not this lane).
  - **The city block** (`--arena=city`, 48 px/m): the standard electro corpse on the cream paving, both legs and the
    star readable: `city_electro_corpse_48ppm_zoom.png` (clip `city_electro_death_48ppm.mp4`, kills near the frame edge).
  - Showcase round 18 already holds all of this code (`38b0f3df`); only JOURNAL/REPORT differ.
  - No golden, sim or replay change. Full evidence on `38b0f3df` (`--no-bench --allow-dirty`): lint 13/13, unit 755/755,
    scenarios 33/33, parity bit-exact (mutation caught at step 629), look 11/11 (worst 1.87), block 5/5 (worst 1.77).
    The selftest FAIL is the same known accent-audit rows as before (48 px/m vermilion/blood on vehicles).
- **Robot thug power-down death** (`fbfa406b`, `3cf3ce29`): its own death, no longer the human fall. The knees give into a
  crouch, it pitches flat on the spot (0.2 m, no slide), the head drops last, the plates darken; sparks and oil, no
  blood. `death_robot` is outside `death_map` and the signature hooks, so no human can ever play it. Dev pit only (the
  live `CombatArena` has no robot fighter). Clips: `robot_powerdown_48ppm.mp4` (follow camera), `robot_powerdown_64ppm.mp4`
  + `_64ppm_sheet.png`, `robot_powerdown_32ppm.mp4`; death frame 138 at every zoom. Honest read: at 48 px/m the thug is
  weapon-art's ink mass, so the fall reads by silhouette (crouch, then a flat X); the plates go dark and the pale
  optic goes out at every zoom (dim 0.7; 0.45 was filmed first and left the optic lit at 32 px/m).
  The oil spray from six hits was busy (fixed at 09:25, see above).
- **Knockdown: no shot from the floor** (`117152b6`, gunplay `83429487` cherry-picked, `FighterFx.RISE_TICKS` 29):
  re-filmed `pit_knockdown_rise29_48ppm.mp4` (follows Rivet) and `_64ppm.mp4` + `_64ppm_sheet.png`. The guard is blown
  flat, lies, rises, and his next aim tell starts only once he stands. Call 4 is now answered B on this branch.
- The pit's dev camera keeps a fresh corpse in frame for 3 s (the 04:00 aftermath rule); `--zoom=` films 48/64 px/m.
- 48 px/m re-films for the 04:00 rule: `pit_burn_death_48ppm.mp4` (+ sheet; the victims die near the frame edge
  because Rivet stands still, and the old flame stars still hide the burning body) and `riot_crowd_48ppm.mp4` (the city
  riot: 20 cowers, 3 trips, 12 deaths, the same counts as before). `pit_blast_death_48ppm_sheet.png` replaces the 32 px/m
  blast sheet (thrown, a twisted landing, red, 2 s of aftermath).
- Full evidence on `035435e7` (code = `530830e9`; `tools/evidence/run.mjs --no-bench --allow-dirty`): lint 13/13, unit
  754/754 (the run's verdict reads FAIL only because I edited REPORT.md during it: "tree changed during run"),
  scenarios 33/33, parity bit-exact (mutation caught at step 629), look goldens 11/11 (worst 1.87), block 5/5 (worst
  1.77). Selftest FAIL only on the known accent-audit rows (48 px/m vermilion/blood on vehicles, gunplay's blood flicker).

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

9. **Robot thug death** (`robot_powerdown_48ppm.mp4`, `robot_powerdown_64ppm_sheet.png`; before: `thug_plan_32ppm.mp4`):
   - A: power-down: knees give, flat on the spot, the plates darken and the optic goes out (`DeathPose.ROBOT_DIM` 0.7);
   - B: the same at dim 0.45 (the optic stays lit at 32 px/m);
   - C: the old generic rig fall (as before tonight; one line: drop the `kill_robot` call in the dev pit).

## Next steps (in order)
1. After the merge with n-gunplay:
   - add `gun_fx.shield_test = link.shield_test` (one line in `fx_view`) and film `react_line` at 64 px/m;
   - re-film the burn death with the thin flames.
2. A robot `Fighter.Kind` in the live fight, so the thug's power-down death plays in the arena, not only the dev pit.
3. An idle bench of the riot p99.
4. Apply REQUEST 30 (brutality's `KillSprawlCut` plank legs, the patch in `evidence/`) if the final round missed it; then
   pass the shot `dir` so a victim shot from behind lies with the feet the other way.
5. A directed arena camera that leans to a kill, so a victim who falls about 11 m from a standing Rivet sits in the
   middle third at 48 px/m.
6. Dry electro kills, render-only, on the merged build. There, `CombatBlood._on_killed` defers to `_bleed_killed` once
   a signature `veto` is set, and by then `CombatArena.kill_weapon` is already set. So the fix is one more early
   return in `_bleed_killed`: a `dry_kill` Callable that the collect_call composition answers with
   `arena.kill_weapon == &"electro_gun"`. `combat_arena` needs no change, and brutality's `electro_shock` signature
   is untouched because its veto already skips this path. Not done tonight: it edits the same lines as showcase's
   final merge.
7. Melee hits reach the reaction layer:
   - in `PlayerMelee._land`, add `arena.struck.emit(f, dir, not f.alive(), weapon_id)` after `arena.damage`
     (rivet-arsenal, as `PlayerShock` does);
   - ~~in `ReactLink.hit_class_of`, return `melee` for the melee weapon ids~~ **done 10:11** on this branch
     (`ReactLink.MELEE_IDS`: claw, chainsaw, electro_baton, katana, plasma_sword -> `melee`; `claw_shock` unchanged;
     unit-tested; on `1623e625`: lint 13/13, unit 755/755, scenarios 33/33). Inert until the `struck` emit above lands; not filmed;
   - but `struck` also drives `HitLink._on_struck` (a `feel.land` hit-stop hold plus hit/kill counters), which would
     stack on melee's own feel. Pick one with rivet-arsenal: HitLink skips the melee ids, or ReactLink gets its own
     melee signal;
   - film the claw chapter A/B.
