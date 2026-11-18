# n18 police: heat drives the city's police (REPORT, draft updated at session 4, 03:50)

Branch `n18-police`, worktree `C:\Users\kazda\kiro\gtai-wt\n18-police`, cut from `int-n17` at
`36dd26ba6`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n18\police\` (`frames.json`) and
`evidence/n18-police/` (timelines). Journal: `JOURNAL.md`. This draft is updated by later sessions.

## What works (with its evidence)

| Item | What | Test (before -> after) | Number | Clip |
|---|---|---|---|---|
| 1 | Sim cop steers straight only with line of sight on the cell map, else the flow field (native + reference) | `test_city_cop_sight`: never in 3000 ticks -> tick 617 / 615 | parity bit-exact | item1 stills (the n15 wall cops are arena pit guards, not sim cops: NEED director, enemy_motor.gd) |
| 2 | Heat as a sim input (`set_heat(level, x, y)`, replay-safe) + `CityHeat` on the sandbox boot (a kill a sim cop sees raises, unseen drains) | `test_city_heat` | state hash carries level + point | - |
| 3 | Heat 1: the nearest `foot_cops[1]` (3) cops path to the last-seen point, search 10 s, walk again | `test_city_police_heat` | 3 cops at A by t808; pre-n18: 0 | item3_heat1_pair |
| 4 | Heat 2: `cars[2]` (2) police cars dispatched 60-110 m out; park within 12 m or bail out of traffic after 4 s; crew of 2 walk in; the search waits for cars and crews | `test_city_police_cars`, `test_city_dispatch` | all 4 crew within 4 m of A by t2244 (before: 0) | item4_heat2_living_e7cb74202 |
| 5 | Heat 3: squads of 4 (riot / SWAT looks) + a roadblock of 2 cruisers across the road past the junction ahead of Rivet | `test_city_roadblock` (4), squad test, heat 3 parity | 12 squad cops at A by t2176; block at t524 | item5_* |
| 6a | Quest 1's own HeatMeter drives the slice city's sim police (stage patrols stay); a hidden Rivet = sim heat 0 | `test_quest1_city_heat` (null/-1 -> heat 2, 4 engaged), hide test | quest scenarios 11/11 | item6_quest1_before_unfixed_fixed_t1200 |
| 6b | `--sim-police`: the stage's scripted patrols replaced by 10 city sim cops whose sight is the patrols' (off by default) | `test_quest1_sim_police` | quest1_input paid with it on (18.2 s); the hide clears at t720 vs t756 off | item6_quest1_simpolice_off_on_t120-1320_32ppm (20 s pair) |
| 7 | Cost probe `dev/sim/heat_cost.tscn`; the sim answers CityHeat's sighting (`CitySimBackend.cop_sees`, no snapshot copy per tick) | `test_city_cop_sees` (native == reference == the old snapshot walk, 4320 questions) | heat 3, 400 peds, A/B x2 (CONTENDED): sim step 34-40 us either way; CityHeat 76.7 -> 55.1 us mean, p50 68 -> 48 | - |

## What does not (yet)

- Item 7's bench (0022e89a5, CONTENDED, exit 0, section 20 held: p99 3.29 ms, 1 % low 248 fps,
  worst frame 34.3 ms, 3 hitches > 25 ms, riot 281 visible) runs the city at heat -1: the bench
  scene mounts no CityHeat, so it is a regression check of the native changes, not a heat 3
  number. Heat 3 cost = the probe (row 7). A `--heat` bench flag is a tools REQUEST.
- (Closed, session 4) Quest 1's t1200 corner figures (one cop, one ped lying) are not deaths: sim
  dead 0, killed 0 and stage hostiles dead 0 every 60 ticks t60-1320 (`evidence/n18-police/s4/
  quest1_flag_off_deaths_t60-1320.txt`); rig reaction poses, as in the heat 3 clip.
- Quest 1 with the city's car ladder: the quest1_input bot never finishes the heat 3 hot walk, so
  quest 1 dispatches no cars (`city.quest1_cars` [0,0,0,0]).
- (Closed, session 4) the peds lying beside a dispatched car in the heat 3 clip are not dead: sim dead 0
  and knocked-down 0 at t2176/t2400 (`evidence/n18-police/s4/heat3_bodies.json`); they are rig reaction
  poses (n17 npc-react cower/cover). The pre-n18 police arm of the same seed has up to 3 real bodies
  within 4 m of a police car (the old pursuit drives through people); the living police none.
- NEED director (characters/, no lane owns it): every city foot cop carries art variant 7 (ART_COP,
  main's spawner since before n18), and the LOD-1 baked crowd path (`character_rigs.gd:135`,
  `CrowdAtlas.cell_for(feed.look_of(i), ..)`) prints atlas row 7 = the overalls-bald ped, while the
  full rig path falls back to a cop look on the kind mismatch (`:194-196`). A far cop may draw as a
  ped. Traced in code only (the sim's own render path, render.cpp frame_of, uses the same row 7);
  NOT seen by eye: in the heat 3 frames every visible cop draws blue (all may have been full
  rigs). Fix if confirmed: the same kind fallback at :135 and in frame_of, or the cops' art id 5.

## Calls for the owner

1. The ladder's numbers (heat.json `city`): foot cops 0/3/4/6, cars 0/0/2/3 (crew 2, heat 3
   squad 4 riot/SWAT), roadblock 0/0/0/2 cruisers 6 m past the first junction 25-90 m ahead,
   delays: cars 3 s, roadblock 2 s; search 10 s; city drain 25 s/level. Clip: item5_heat2_vs_heat3.
2. The nav fix's before/after: unit repro never -> 617/615 ticks; the n15 street-fight wall cops are
   arena pit guards, a different motor (NEED director).
3. Quest 1 cars: none (as built) or the city's ladder (breaks the bot's hot walk today).
4. `--sim-police` by default on quest 1? Built off (the stage's scripted patrols are what the quest
   was tuned on); the bot is paid with it on. Clip `item6_quest1_simpolice_off_on_t120-1320_32ppm.mp4`
   (left off, right on): the same beats, the hide clears 36 ticks sooner with it, no blue stage
   patrol walks past the dumpster, and the flag-off arm's left-corner bodies at t1200 are absent.
   Recommend: keep off tonight (one clip of the opening, the hot walk not filmed with it).
5. Cost at heat 3 (CONTENDED, 400 peds): the sim step 34-40 us with or without living police;
   CityHeat 55 us after the sim-side sighting query (was 77): together < 0.6 % of the 16.7 ms tick.
   The bench (heat -1 only, CONTENDED) held every section 20 limit: see What does not.

## Merge notes

- Parity/replay goldens: none re-blessed so far (the n18 sim changes are behind heat >= 0; the
  parity gate and replay goldens run at heat -1 and stayed bit-exact).
- Files outside the police list touched with one line each: `boot/collect_call/quest1_session.gd`
  (`CityHeat.mount_quest` call), `boot/quest1_game.gd` (`--sim-police` read), `boot/launch_args.gd`
  (the flag in KNOWN_FLAGS). Debt baseline accepted rises: dev_loc (heat_clip, heat_cost) and
  launch_args.gd 200 -> 201.
- Sim tune grew PT_LEN 10 -> 13 (tools/gen_constants; native + reference regenerated).
- New sim API: `CitySimBackend.cop_sees(x, y, r)` (native binding + reference); read-only, no digest moves.
- One-line dev edit outside the lists: `dev/frames/quest1_clip.gd` KNOWN_FLAGS gains `--sim-police`.
