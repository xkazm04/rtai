# n18 police: heat drives the city's police (REPORT, draft at session 3, 03:00)

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
| 6b | `--sim-police`: the stage's scripted patrols replaced by 10 city sim cops whose sight is the patrols' (off by default) | `test_quest1_sim_police` | quest1_input paid with it on (18.2 s) | stills to do |
| 7 | Cost probe `dev/sim/heat_cost.tscn` | - | sim +0..20 us/tick at heat 3; CityHeat 58-96 us/tick (CONTENDED) | - |

## What does not (yet)

- Item 7's bench section 20 numbers: not measured (no quiet machine / bench lock this session).
- Quest 1 (b1418a966 film t1200): one cop and one ped still lie at a corner with the sim police on
  (none without); untraced.
- Quest 1 with the city's car ladder: the quest1_input bot never finishes the heat 3 hot walk, so
  quest 1 dispatches no cars (`city.quest1_cars` [0,0,0,0]).
- Two peds lie dead beside a dispatched car in the heat 3 clip (not traced).

## Calls for the owner

1. The ladder's numbers (heat.json `city`): foot cops 0/3/4/6, cars 0/0/2/3 (crew 2, heat 3
   squad 4 riot/SWAT), roadblock 0/0/0/2 cruisers 6 m past the first junction 25-90 m ahead,
   delays: cars 3 s, roadblock 2 s; search 10 s; city drain 25 s/level. Clip: item5_heat2_vs_heat3.
2. The nav fix's before/after: unit repro never -> 617/615 ticks; the n15 street-fight wall cops are
   arena pit guards, a different motor (NEED director).
3. Quest 1 cars: none (as built) or the city's ladder (breaks the bot's hot walk today).
4. `--sim-police` by default on quest 1? Built off (the stage's scripted patrols are what the quest
   was tuned on); the bot is paid with it on. Recommend: keep off until a clip of the hot walk with it.
5. Cost: CityHeat's per-tick sighting copies the whole sim snapshot (as costly as the sim step);
   fine at < 0.3 ms, a sim-side query is the cheap fix if the bench says so.

## Merge notes

- Parity/replay goldens: none re-blessed so far (the n18 sim changes are behind heat >= 0; the
  parity gate and replay goldens run at heat -1 and stayed bit-exact).
- Files outside the police list touched with one line each: `boot/collect_call/quest1_session.gd`
  (`CityHeat.mount_quest` call), `boot/quest1_game.gd` (`--sim-police` read), `boot/launch_args.gd`
  (the flag in KNOWN_FLAGS). Debt baseline accepted rises: dev_loc (heat_clip, heat_cost) and
  launch_args.gd 200 -> 201.
- Sim tune grew PT_LEN 10 -> 13 (tools/gen_constants; native + reference regenerated).
