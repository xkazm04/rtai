# REPORT: lane gunplay (`n-gunplay`), night 2026-11-04

Final, iteration 18 (REPORT, 08:40). Code head 83429487; branch head is docs only. Every path cited below was checked to exist at 08:41.

(Copy of `docs/night/2026-11-04/gunplay/REPORT.md`; the two files are identical in content.)

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
| Riot blood: drop redraw split, A/B of settled 6 vs 30 (kept at 6: within noise), bench metrics | `WT/evidence/n3/riot-blood-ab.md`; bench runs `WT/evidence/n1/bench-after.log`, `WT/evidence/n3/bench/`, `WT/evidence/n{6,8,9}/bench.log` |
| Time to kill per weapon, range and target (24 seeds a cell); the shard's reach, and the electro tap vs charge | `WT/evidence/n6/ttk-shard.md`, `WT/evidence/n8/ttk-electro.md`, raw `ttk.json` |
| Fire patches print an ink char (a splash burn: soot wedges, floor hatch, a broken edge), and the burnt ground stays 15 s after the fire; a rocket blast scorches the ground it hit (view only) | `fight_scorch.gd`, `fight_scorch_art.gd`; `test_fight_scorch*.gd`; `MASTERS/molotov_scorch_ab_city_32ppm.mp4` (+ `.png`), `MASTERS/camfight11_molotov/`, `MASTERS/rocket_scorch_ab_city_32ppm.png`, `MASTERS/camfight11_rocket/` |
| A body that falls in a fire patch stays visible: 0.1 s after the kill the flames within 2.2 m shrink and are pushed off it (open by 0.4 s, while brutality's char silhouette still stands), so the fire burns in a ring round the charred corpse (showcase REQUEST 27, the director cut's molotov chapter; view only) | `FightAreasArt.clear/away`, `test_fight_areas_clear.gd`; `MASTERS/molotov_corpse_clear_ab_48ppm.mp4` (showcase ch 07 before / after, same sim), `MASTERS/ch07_molotov_open_64ppm/` |
| A burning human stays readable: three small flames (0.3x the fire loop) trail off his back against his panic run, where one 2.1 m flame centred on him hid the body (human-reactions NEXT 4; view only, same sim) | `FightAreasArt.burn_flames`, `test_fight_areas_clear.gd`; `MASTERS/burning_human_ab_48ppm.mp4` (arena pit, before over after), `MASTERS/burn_after_64ppm/`, city block 32 px/m `MASTERS/city13_flamethrower/` |
| A knocked-down human cannot shoot from the half-sprawl: he stays held 29 ticks (0.48 s) after his 0.9 s lie while human-reactions' view plays the rise (human-reactions REQUEST 30; `FighterFx.RISE_TICKS`, 0 = old). Stuck homing shards are no longer drawn on a corpse, so brutality's burst kill pops clean (brutality REQUEST 30; `FightShardArt.STUCK_ON_CORPSE`). No clip yet: human-reactions re-films the get-up | `test_fight_areas.gd` (rise window), `test_gun_fx.gd` (shards); 83429487, 8ea3a2e5 |
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
- Merge notes for the Director: human-reactions' get-up and brutality's burst kill read right only with n-gunplay 83429487 / 8ea3a2e5 merged. Brutality REQUEST 29 (molotov corpse under the patch flames) is answered by 0b2541a9 + aa471560 (flames shrink, fade and move off a body, from gunplay's own dead list); recheck it in the merged-main re-film in case a brutality kill drops the body from that list while its print stays.

## What blocked me, and for how long

Nothing blocked the lane. No BLOCKED entry in JOURNAL. The friction that cost time:

- The bench lock was held by another lane once (05:05, iteration 7), so I skipped that round's bench. About 0 minutes lost; the next round benched.
- Every bench run shared the machine with five other lanes rendering. So the riot numbers are all CONTENDED. That cost the idle number of record, not time.
- Tooling, about 10-15 minutes all night: `run_unit.mjs` needs `GODOT_BIN` exported (otherwise it reports "import exit -1"); `--arena` is not a boot arg (the arena runs as `res://dev/arena/arena.tscn -- ...`); Git Bash `timeout` does not kill a windowed Godot child (two hung renders, killed by PID); Windows Python needs `C:/` paths and `newline=''`.
- The arena molotov never landed at first (01:31: `StagePilot` overrode the throw), and the first impact sweep was one tick short of the body. Both were fixed the same iteration.
- Iterations 15-17 (08:0x-08:33) built no code because a full unit run does not fit before the 08:30 freeze. In iteration 16 I misread brutality REQUEST 29 as unanswered; it was already done (0b2541a9 + aa471560), and JOURNAL corrects it.

## Next steps (in order)

1. The Director merges n-gunplay. human-reactions' get-up and brutality's burst kill need 83429487 / 8ea3a2e5.
2. Re-film on merged main: the molotov patch beside a brutality kill (check that a brutality kill never drops the body from `FightAreas`' dead list while its print stays), and human-reactions' get-up with the 29-tick rise hold.
3. Take the idle riot + drive bench of record on merged main, with no other lane running (`node tools/bench/run.mjs`). Expect the blood to be about 1 % of the riot p99. The remaining riot cost is not the blood, so it needs its own bisect.
4. Wire `GunHand` and `LiveInput.px_per_m` into quest 1, so the quest fight fires the table guns instead of the evening pistol path.
5. Split the city camera's view point from the sim focus (`CitySystem.focus`), so the fight camera (gunplay-12) can leave dev and serve the city.
6. Make a table gun the arena default instead of Gloria, and re-bless the arena scenarios on purpose.
7. If the burn re-film reads thin, raise `BURN_SCALE` from 0.3 to 0.38. That one value is the alternative.
8. Apply the owner's answers to gunplay-7 to gunplay-13. Each one is a single value.

## After 09:00 (extension, iteration 19)

- **The kills read one at a time.** A dev capture flag, `--lone` (23f0fe22, 265b7f37), makes every arena pit wave one guard. With `--cam=fight`, the camera leans 0.65 toward the victim and holds his corpse 2.5 s. So each table-gun kill is filmed on a cop standing alone, in or near the middle third of a 48 px/m frame, with the aftermath (the 04:00 checkpoint rule). This is a dev view only: no sim, replay or golden change. Clip: `MASTERS/lone_kills_table_six_48ppm.mp4` (33 s: pistol, machine pistol, rocket, electro, flamethrower, molotov; the full 20 s runs are in `MASTERS/lone19_<gun>/`). It replaces the HUD-covered six-tile reel at the top of frames.json.
- The unique five and a close-up, filmed the same way: `MASTERS/lone_kills_unique_five_48ppm.mp4` (27.5 s: hand cannon, plasma rifle, ray gun, homing shard, mini-nuke, each one-shotting a lone cop) and `MASTERS/lone_kills_closeup_64ppm.mp4` (16 s: pistol, rocket, hand cannon at 64 px/m). These clips show gunplay's projectile, impact, blood and fall. Brutality's signature kill animations come with that branch at the merge. These two clips and the six-gun reel are now the top three entries in frames.json, replacing the HUD-covered tiles and the still sheet.
- At 64 px/m the corpse slides to the frame's right edge about 1.5 s after the kill, as Rivet walks on to the next spawn.
- The flamethrower's burning cop runs more than 14 m. With `--lone`, the bot now walks after him (`GunplayBot.follow_burning`, d35ffdf3), so the reel shows the stream, the ignition, the panic run, the fall and the corpse (in the bottom third). A 30 m camera hold was tried first and rejected, because it framed empty ground.
- Gates on 265b7f37: lint 13/13, unit 756/756 (+4; also on the follow_burning commit), scenarios 29/29 (on 23f0fe22; 265b7f37 touches only the dev camera and its test), parity unchanged (no sim or native change since 83429487).

## After 09:30 (iteration 21)

- **The lone kills now play in the city proving block too** (`source: game-city`). `--lone` already worked on `--arena=city`. The city camera stayed on Rivet, though, so the pistol's second kill fell below the frame. `--cam=fight` on the city now leans the view only (9a1bec62, 3c472354): `CollectCallView.city_lean_m` feeds `CityView.kick_px`. `city.focus`, which streams the chunks and steers the spawner, stays on Rivet. The lean is 0.65 toward the victim, at most 6 m, and holds the corpse 2.5 s. `CityView` widens its actor window by the offset, so no edge pedestrian drops (one line in a city file; a zero offset gives the same window). The kill ticks are identical with and without the lean. This is a dev view only, with no sim, replay or golden change.
- Clips (48 px/m, no HUD, sound off, 0 script errors): `MASTERS/city_lone_kills_seven_48ppm.mp4` (35 s: pistol, machine pistol, rocket, flamethrower from the ignition, electro, molotov, hand cannon), `MASTERS/city_lone_kills_unique_four_48ppm.mp4` (20 s: plasma, ray gun, homing shard, mini-nuke) and the A/B `MASTERS/city_lone_lean_ab_pistol_48ppm.mp4` (camera on Rivet vs the lean, the same kill). The A/B was filmed without `--reach`, so it isolates the lean.
- The kills now land in the middle third. At the bot's own reach (up to 9 m), the city guards died 10-12 m out, in the frame's lower third. A dev arg `--reach=<m>` (70894746; no arg means no change) lets the capture fire from 6 m. Both city reels are re-filmed with `--reach=6`: the pistol, rocket, electro, plasma, ray gun and hand cannon kills fall mid-left in the middle third, the molotov's victim runs out of the fire near the centre, and the nuke's ring catches its victim in the upper middle. The flamethrower's victim still dies at the top edge, by the barrier. Full runs: `MASTERS/citylone21r_48_<gun>/`.
- A city close-up at 64 px/m: `MASTERS/city_lone_kills_closeup_64ppm.mp4` (15 s: pistol, rocket, hand cannon). It shows the muzzle, the tracer or the rocket's smoke puffs on the told line, the blast ring, the fall and the blood.
- Labels: in the city block the victims are quest 1's inked guard sprites (orange hi-vis, hard hat: the quest's own city fight draws them the same way, since `--rigs` applies only on the pit's printed path), so the city reels say "one guard". In the arena pit they are the blue cop rigs ("one cop"). The guards' orange sits close to the reserved vermilion (quest 1's cast, not gunplay's).
- Cherry-picked showcase 8a8215a3 (2c27580e): on the city, the pit's high walls print as grey concrete instead of black debug bars.
- Gates of record now on dfa5f508 (the iteration 21 code head is 70894746; later commits are docs): `node tools/evidence/run.mjs --no-bench --allow-dirty` (`WT/evidence/n12/evidence-21b.log`; the dirty paths are untracked evidence stills and logs). Lint 13/13, unit 757/757 (+1: the city lean cap), scenarios 29/29, parity bit-exact (the planted mutation caught at step 629). The selftest's look goldens hold 11/11 and its block goldens 5/5. It fails only on the same two accent rows as before (vermilion 8 px on vehicles at 48 px/m, 28 px on a cop at 64 px/m: blood edges, see Gates of record below). So the one-line `CityView` change moves no golden. The first run (`evidence-21.log`) flagged unit only because I committed JOURNAL during it; 757 passed there too.

## Gates of record

`node tools/evidence/run.mjs --no-bench --allow-dirty` on 83429487, the final code head of iteration 14 (`WT/evidence/n10/evidence-final-14.log`; the dirty paths are untracked evidence stills and logs only): lint, unit, scenarios and parity PASS. The selftest fails on the accent audit only, as below.

- lint 13/13 (the pre-commit hook on every commit).
- unit 752/752 (83429487; the new rise-window test included).
- scenarios 29/29 (83429487).
- parity bit-exact, the planted mutation caught at step 629 (83429487).
- selftest: look goldens 11/11 and block 5/5 within mean 4, and the world lock holds. The accent audit flags vermilion 8 px on vehicles at 48 px/m and 28 px on a cop at 64 px/m, the same two rows as on d7820eeb, 47476501 and 2d7efa51. These are blood edges: the audit compares a full capture with a layer-hidden capture taken a frame later (d5-city's fix; see JOURNAL showcase REQUEST 7). The audit is not one of this lane's four gates.
- bench: every run tonight was CONTENDED (riot p99 7.09 to 13.09 ms; the blood was 0.8 to 1.0 % of it). There is no idle number of record. Iterations 12 and 13 changed view code only; iteration 14 added the 29-tick rise hold after a knockdown, which is a sim change but costs nothing (no bench run).
