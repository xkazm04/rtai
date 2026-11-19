# REPORT - lane `ai`, night n19 (2026-11-18 -> 11-19): the real enemy AI in production

Final at report (07:45), session 8. Branch `n19-ai`, head `e11581e9b`, base `28302bd3c`. Squad brain ships ON (`--enemy-brain=squad` default; `--enemy-brain=guard` restores the old brain); stations and quest 1 stay on the guard brain by explicit wave ownership.

Gate: `node tools/gate/run.mjs --rev=HEAD --reels` started 07:31 on `e11581e9b`. At 07:44 it was still running after its scenario stage, which ended **56/57 ok, 1 FAIL**: `scenario_rivet_city_melee` - "planted fault not caught: a bot at gun reach still dropped 4" (log `build/gate/e11581e9b7e5/evidence.log`, line 44). The run's verdict will land in `build/gate/e11581e9b7e5/gate.json`; expect **FAIL**. Treat the branch as **not gate-green** until that scenario is fixed (see What does not). Director checks already run at this head: lint 19/19 (06:13), 8/8 arena/enemy/quest scenarios headless (06:06). Unit 2987/0/2 and 56/56 scenarios passed at `b2f600280`/`21de802b9`, so the fault came in later.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Fight probe, production path | `evidence/n19-ai/probe-baseline.md`, `.json`; `project/dev/enemy_ai/` fight probe | baseline city crowded 30.3 %, LOS 14 %, cover 44 %; pit crowded 0.4 %, cover 3 %; quest 1 crowded 25 % |
| 2. Squad brain behind production fighters (`--enemy-brain=guard\|squad\|mixed`) | `evidence/n19-ai/probe-squad.md`, `probe-squad-final.md` | city crowded 30.3 % -> 0.23 %, cover 44 -> 55 %; pit cover 3 -> 20 %; FLANK ticks > 0 |
| 3. Fairness (bot, 20 seeds, director-verified at `91644f6cf`) | `evidence/n19-ai/fair20.md` (13 city trials + before/after; regenerate: `node tools/dev/run.mjs fight_probe --encounter=city\|pit --seeds=20 --enemy-brain=guard\|squad --out=...`); earlier 5-seed tables `evidence/n19-ai/tune.md`, `ownership.md`, `zebra.md` | city: guard 17.68 s / 3.15 HP lost, squad 18.13 s / 2.91 HP (**+2.5 % clear, -7.6 % HP**; was +19.6 % / -32.4 % before the city-only `city.squad.contractor_speed_mps` 4.2, `47507d630`, `56b619faa`, `91644f6cf`); pit: guard 14.72 s / 8.13 HP, squad 17.68 s / 7.44 HP (+20.1 %, -8.5 %); deaths 0 in all 80 runs; contractors 4.2 m/s vs Rivet's 6.75 m/s walk |
| 4. Cost | `evidence/n19-ai/cost-profile.md` (section split), `cost.md`, `cost.json`, `cost-digests.json`; cuts `b8d0e2560`, `b037edfa3`, `a2113162a`, `ccde0a69c`; fight gate `build/perf/fight-gate/n19-a4b-complete/gate.json` | per hostile per tick 28.2 -> 14.7 us at 10 guards, 64.9 -> 16.9 us at 40 (2.99 -> 0.98 ms/tick; CONTENDED headless); bit-identical: all 45 five-seed squad/mixed/guard fights matched; searches bounded (<=2 A*/tick); fight gate after the cut, under the bench lock, 4 rounds (`build/perf/fight-gate/n19-a6c-locked/gate.json`): city p99 guard 9.03 / squad 9.22 ms, horde 12.39 / 10.17 ms, all WASH vs the A/A floor, 0 SCRIPT ERROR; every run still CONTENDED (other lanes' tests); one environmental outlier (horde squad round 1, p99 541 ms with 102 s process CPU; the same deterministic fight was clean in the other three rounds) |
| 2b. Squad brain ON by default (pit, street fight, horde); stations and quest 1 stay guard | commits `b2f600280`, `21de802b9`; `evidence/n19-ai/ownership.md` | 56/56 scenarios, unit 2987/0/2; guard 15 digests and quest 1 5 digests = A1; mutate SquadMind 17/20, ArenaSquad 10/20 -> 17/20 (`36baff0c7`), EnemyMotor 13/20, ArenaWaveCards 11/11 valid |
| 2c. City station partners keep apart (`city.station_spacing_m` 1.65, data, city only) | `27fde67fa`, `01781501f`; `evidence/n19-ai/station-spacing.md`; stills `C:/Users/kazda/kiro/gtai-masters/n19/ai/station/before-t0697.png`, `after-t0697.png` | the five sparring riot cops stood within 1 m of another hostile in 36610 of 48000 city hostile-ticks (guard) / 36388 (squad) -> 0 in both; pushes resolved on the guard route map (body centre in a solid after a push 436 -> 0); city fairness unchanged (17.68 s / 3.15 HP vs 18.13 s / 2.91 HP); pit 40 and quest 1 10 digests unchanged; mutate `space_partner` 10/11 |
| 6. Zebra rule: city street-fight walls off the crossings | `f20a377ac`; `evidence/n19-ai/zebra.md`; frames `C:/Users/kazda/kiro/gtai-masters/n19/ai/zebra/` | 4 wall/crossing overlaps -> 0 (47 boxes, 11 decals); city-only `city.shift_props`; `scenario_arena_zebra` fails with the key removed; dev pit digest identical |
| GAME FIX: every living wave member has a drawn body | `3190a93c9`, `42fe4a733`; `evidence/n19-ai/overlay.md`, `evidence/n19-ai/wave-visibility.csv`; unit `test_arena_rigs` | before: 2232 of 3714 pit hostile-ticks undrawn (beyond the 14 m full-rig radius, arenas have no crowd atlas), fighters 9 and 17 fired 5 rounds while invisible (pre-existing: the guard brain film shows the same gap); after: 0 missing over 20418 hostile-ticks in 4 films |
| Films (squad vs guard, same tick and seed) | `evidence/n19-ai/frames.json` (copy of `C:/Users/kazda/kiro/gtai-masters/n19/ai/frames.json`); films `C:/Users/kazda/kiro/gtai-masters/n19/ai/films/` 9 entries (32 px/m twins, two 64 px/m close-ups, zebra before/after); street squad film re-shot at the shipped city tune `61bd372a4` (`f4b08fa71`), street squad/guard 24 s each, pit squad 21.5 s, pit mixed 37.5 s; dev overlay `--squad-overlay` (debug builds only) |
| NEED from gfx: a lying corpse's drawn card goes behind the kerb barrier | `71b0c85f0` (red test), `35264793b`; `evidence/n19-ai/prop-lying.md`; frame `C:/Users/kazda/kiro/gtai-masters/n19/ai/prop-lying/barrier-64ppm-before-after.png` | mutate `prop_lying.gd` 12/12; 16 look goldens unchanged |
| 5. Archetype rows | `project/data/tables/enemies.json`, `evidence/n19-ai/probe-archetypes.md` | six rows differ by cover_bias / preferred / attack / aggression / peek / flanks; no id branches |

## What does not
- **Gate red: `scenario_rivet_city_melee` (in base since `37dbfeab4`, owned by rivet-arsenal) fails its TST-05 planted-fault check at `e11581e9b`.** The planted bot stands off at gun reach and is supposed to drop fewer than 2 guards; it dropped 4. The real run passes. Likely cause, not verified: this lane's city squad tune. Since `21de802b9`, when all 56 scenarios passed, the city contractors were sped up 3.0 -> 4.2 m/s and the squad now closes in on its own (`91644f6cf`, `56b619faa`, `47507d630`), so guards walk into the bot's melee reach without the bot moving. The other change since then is the station spacing (`27fde67fa`, `01781501f`). Nobody spotted this before the freeze: the director's 06:06 scenario subset did not include rivet_* city scenarios. Fix options for the morning: (a) pin the scenario to `--enemy-brain=guard` (the quest 1 approach), or (b) make the oracle a ratio (planted kills well below real kills). Either way, first run it alone with `--enemy-brain=guard` and with `city.squad.contractor_speed_mps` removed to find which change caused it. The fault means a guard can now reach a standing Rivet. That is gameplay, not a sim bug: replay stays identical.
- Pit: the squad takes 20 % longer to clear than the guard brain (within the 25 % line, 20 seeds) and deals 8.5 % less damage; not tuned further.
- Per-hostile cost at 10 hostiles is 14.7 us, over the 12 us aim (40 hostiles 16.9 us is under its 25 us aim); guard brain 3 us. All cost numbers are CONTENDED (five lanes share the machine).
- The street films and stills (`f4b08fa71`) were shot before the station spacing (`27fde67fa`): their five station riot cops still bunch at the north wall's west end. The station still pair shows the fix; a re-shoot (brief `evidence/briefs/a6d-street-final.md`, written, never run: no time before the freeze) is the first next step.
- The station cops still walk to the north wall's west end and wait there (guard path, pre-existing); they no longer stand in each other.

## What blocked or slowed you
- The freeze gate went untimed: it started at 07:31 and was still running at the report. Its scenario stage found the rivet_city_melee failure 8 minutes in, after the freeze, with no time to fix it. Lesson: run the full scenario suite at least once after every tune that changes the fight, not a subset (cost: a red gate at the merge).
- Session handovers killed Astra twice: a4-cost at 23:20 (14 min lost) and a6-clips at 02:13 (work was committed; resumed as a6b).
- The 06:13 -> 07:30 window had no director session running work (session 7 began at the freeze), so the planned street re-shoot (a6d) did not run (~75 min idle).
- The bench lock does not keep other lanes' GUT runs off the machine: every fight gate run stayed CONTENDED (~10 min re-running to confirm an environmental outlier).
- Default flip broke six arena station scenarios (claw cops 3000-3004 and reel victims taken over by the squad); fixed by explicit wave ownership (A7b, ~42 min).
- City fairness: the zebra wall move (A5) pushed city squad damage to -32 %; A9 spent 20 min proving cover-prop layout is the wrong knob before A9b found the city-only contractor speed (42 min).

## Calls for the owner
- Squad default ON with a red rivet-arsenal scenario. Recommendation: keep squad ON and fix the scenario's oracle (pin it to the guard brain), because the city squad's fairness table is inside the 25 % line (+2.5 % clear, -7.6 % HP over 20 seeds). The alternative is to merge with `--enemy-brain=guard` as the default, which is one value in `launch_args`/`ArenaSession`. Clips: `C:/Users/kazda/kiro/gtai-masters/n19/ai/films/street-squad.mp4` vs `street-guard.mp4`.
- Mixed roster (five archetypes): city clear +35.6 %, pit +41.9 % (scoped, `ownership.md`) vs guard (content: robots 4-6 hp, not AI). Clips: `C:/Users/kazda/kiro/gtai-masters/n19/ai/films/pit-mixed.mp4` (37.5 s) vs `pit-squad.mp4`; still `stills/mixed-lines-t2231.png`.

## Merge notes
- `project/boot/launch_args.gd` `KNOWN_FLAGS`: two appended lines, `--enemy-brain` (guard|squad|mixed; default squad) and `--squad-overlay` (dev overlay, debug builds only). Other lanes append too: keep both sides, one line each.
- `tools/debt/baseline.json`: `launch_args.gd` 201 -> 203 (accepted-regression lines, append-only registry), `dev/enemy_ai` 662 -> 1434 dev LOC (probe, cost scene), `combat_arena.gd` 299 -> 251 and `arena_rigs.gd` 294 -> 284 (tighter). On conflict: `node tools/debt/merge_baseline.mjs`, commit, then `--update`.
- `docs/decisions.md`: appended `combat/squad-ai`, `combat/squad-archetypes`, two `ai/brain` lines (guard default kept 11-18, then squad default 11-19) and `arena/zebra`. Read the later 11-19 line as the standing one.
- `arena_city` digest moved on purpose (ai-owned, `f20a377ac`, `evidence/n19-ai/zebra.md`); no gfx-owned sim/replay/parity/bake digest moved.
- `project/features/arena/prop_lying.gd` fix (`35264793b`) is the gfx NEED; gfx item 3C relies on it, so merge ai before or with gfx.

## Next steps
- **First:** bisect and fix the `scenario_rivet_city_melee` planted-fault failure (What does not, first bullet), then re-run `node tools/gate/run.mjs --rev=HEAD` until it is green. Do not merge `n19-ai` while it is red.
- Re-shoot the street films and stills after the station spacing (`evidence/briefs/a6d-street-final.md`).
- Pit squad clears 20 % slower than guard (inside the line); a pit-scoped speed or slot tune like the city one would bring it nearer 0 %.
- Per-hostile cost at 10 hostiles (14 us) still over 12 us: assign (70 us/tick) and plan (48 us/tick) are the next sections (`evidence/n19-ai/cost-profile.md`).
- Station sparring cops still head for the north wall's west end (guard path); giving them the squad's cover use needs the station scenarios re-judged.
- Quest 1 fights stay on the guard brain by design; moving them to the squad needs its own fair-fight table and the owner's word.

## Astra ledger
| Tag | Min | Outcome | Commits / result |
|---|---:|---|---|
| a1-probe + a1b-commit | 15 + 4 | accepted | fight probe + baseline (`a969feeab`); first commit blocked by the debt ratchet |
| a2-squad | 31 | accepted | squad brain behind production fighters, `--enemy-brain` |
| a3-arch | 20 | accepted | six archetype rows, no id branches |
| a4-cost | 14 | abandoned | killed by a director session handover; resumed as a4b |
| a4b-resume | 41 | accepted | search budget, cost probe, first fight gate (CONTENDED) |
| a7-tune | 37 | accepted | shooter slots 3, contractor cover_bias; found the station takeover blocking the flip |
| a7b-scope | 42 | accepted | squad owns only wave fighters; default flipped to squad |
| a5-zebra | 19 | accepted | city north wall off the crossing, `scenario_arena_zebra` |
| a6-clips | 26 | abandoned | killed by handover after committing; resumed as a6b |
| a6b-overlay | 35 | accepted (after a bounce) | game fix for undrawn wave members, overlay colour law, films |
| a8-prop | 18 | accepted | gfx NEED: lying corpse card behind the kerb barrier |
| a9-city | 20 | accepted as measurement | proved cover layout is the wrong knob |
| a9b-city | 42 | accepted | city-only squad override, city fairness inside the line |
| a4c-profile | 31 | accepted | per-hostile cost halved, bit-identical |
| a6c-street | 11 | accepted | street squad film and stills at the shipped tune |
| a10-station | 25 | bounced | spacing worked but the push ignored walls (a cop drawn in the north wall) |
| a10b-walls | 13 | accepted | push resolved on the guard route map |

What I would brief differently: name the station sparring partners and the shared pit rows in the very first squad brief (two sessions went to finding them); ask for the 20-seed fairness run from the start (5 seeds hid a +-15 % noise band); and never start a session in the last 30 minutes of a director session (two were killed at handover).
