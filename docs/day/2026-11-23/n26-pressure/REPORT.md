# REPORT n26 lane `pressure` (2026-11-23, 11:06 to 19:10)

Branch `n26-pressure`, worktree `gtai-wt/n23-loop`, cut from `main` `0779185ac`. Continues
`docs/day/2026-11-23/n24-pressure/`. Director: Opus; builder: Astra (every product change is Astra's; I wrote briefs,
`JOURNAL.md` and this file, reviewed every diff, looked at every still).

Final code HEAD: `0f9baec48` (everything after it is JOURNAL / REPORT / evidence only). Gate
`node tools/gate/run.mjs --rev=HEAD --reels` on `0f9baec48` (results `build/gate/0f9baec4835f/`, git-ignored): evidence
half: lint FAIL 1 of 19 (`tool-tests`: one timing test in `tools/merge/morning_run.break.test.mjs`, not this lane's file,
fails under five-lane load and passes 3 of 3 alone: `evidence/n26-pressure/gate/lint-flake.txt`), unit-tests 4007 passed
0 failed 3 skipped, scenario-tests 68 ran (rig_stress p50 CONTENDED, not judged), parity bit for bit over 1200 steps with
the planted mutation caught, export-audit 968 loaded 0 failed, selftest pass. Reels (top, tilt70, combo): PASS, exit 0.
Verdict line: `gate: FAIL; build/gate/0f9baec4835f/gate.json` (only the lint flake). Re-run without reels on the same code
(`node tools/gate/run.mjs --rev=HEAD` on `7969ed2a4`, started 17:37, ended 18:17): `gate: PASS; build/gate/7969ed2a4872/gate.json`
(lint 19/19, unit-tests 4007 passed 0 failed 3 skipped, scenario-tests 68 passed, parity bit for bit + mutation caught at
step 629, selftest pass, export-audit 968 loaded 0 failed). The reels were judged on `0f9baec48`, same code. This is the
lane's verdict: **PASS**.

## What works

| item | evidence | number |
|---|---|---|
| 1 Trooper rocket drawn as a cased rocket (steel casing, ice-blue rim and under-glow, three ice-blue exhaust frames), clearly larger than Rivet's and never amber | commits `b370c3ba4` (art + cut tool `tools/art/enemy_rocket_cut.py --check`), `dab47bef7` (wiring), `d42706a60` (1.4 m casing, ~1 m jets), `41eccb33e` (rim glow, draw-ownership test); stills `rocket-vs-rivet-32.png`, `rocket-vs-rivet-64.png`, `rocket-enemy-32-pair.png`, `rocket-enemy-64-pair.png` in `gtai-masters/n26/pressure/` | rim and jet sampled `#92c9f5`, casing `#585f61`, Rivet's jet `#e5a12e` (unchanged); war_cannon, replay_60s and quest 1 byte-identical |
| 2 Deflect spread 12 -> 20 degrees | `7d23e60c5` (data + two test bounds re-derived from the configured half-angle + decision line), `ae6a23d1c` (tool + `evidence/n26-pressure/deflect/share.md`) | share of returned pistol rounds that hit the shooter, guard / plasma bat: 4 m 40.7 / 52.2 %, **6 m 24.3 / 30.6 %**, 8 m 16.4 / 19.2 %, 12 m 9.7 / 10.9 % (1000 aimed rounds per cell, seed 90210). Owner's "about a quarter at 6 m" holds for the guard |
| 3 Rocket trooper against a moving player: rest 1.4 -> 1.1 s, lead model `orbit` (data `lead_model`, default `linear`) | `82dbc7258` (lead model + arena and gauntlet probes + tests), `6288453ee` (shipped values), `evidence/n26-pressure/trooper/arena.md`, `evidence/n26-pressure/trooper/gauntlet.md` | arena 10 m, 3 seeds x 30 s: steady circle hit 48/48, circle + dash across the locked line 0/48, standing 48/48; average gauntlet 17 hits / 83 troopers (0.205 per trooper; 1.4 s orbit 0.141, old linear 0.222); rocket-only deaths before wave 6: 0 of 21 runs; mutate `rocket_lead` 12/14 = 85.7 % |
| 4 Stall on seed 9: cause found and fixed in the test bot; a headless bot run now ends on a 60 s damage-free freeze instead of sitting to the tick cap | `bf32bfd1a`, `evidence/n26-pressure/stall/cause.md`, `evidence/n26-pressure/stall/tick-90000.txt`, `evidence/n26-pressure/stall/blink-input.txt`; tests `project/tests/unit/test_gauntlet_kerf_wall.gd` (red on the old bot, green now) and the freeze clock in `project/tests/unit/test_gauntlet_enemy_damage.gd` | average-9 at `548989d7e` reproduced byte for byte: a Kerf slice at tick 77115 picked a different foe than the bot predicted (the bot used its float aim, the pilot the 256-step wheel heading) and landed Rivet beyond the street's south wall; 40 hostiles and Rivet lost sight of each other -> cap at 216000. Paired replay with the fix: wave 40 cleared, exit 0 at tick 82694. Item 5's 60 runs: 0 caps, 0 freezes |
| 5 Three medians on the final state + one tuner cycle for the record (nothing applied) | `evidence/n26-pressure/medians/medians.md`, `evidence/n26-pressure/medians/floors.md`, `evidence/n26-pressure/medians/salt0/report.md`, `evidence/n26-pressure/medians/plan.json` | median death wave, 10 seeds each, salt 0 / salt 1 (paired floor): novice 5 / 5 (0.3), average 7.5 / 5 (3.1), expert 8.5 / 9 (1.5); n24 final (5 seeds): 5 / 8 / 23. Tuner `propose`: one change, `rivet_repair` x1.25 (repair 10 -> 12.5 /s, delay 3 -> 2.4 s), NOT applied |

## What does not

- Item 3 target "one hit per two troopers per wave" (0.5) is not reached on the average bot: 0.205 at the shipped
  1.1 s orbit. The average test bot dashes and breaks line of sight often; the arena shows the circler is hit every
  launch. A faster rest (0.9 / 0.75) was not run: the sweep stopped at the first orbit qualifier
  (`evidence/n26-pressure/trooper/arena.md`).
- Expert median death wave fell from 23 (n24 final, 5 seeds, one censored) to 8.5 / 9: in salt 0 the rocket killed 3 of 10
  experts (0 in salt 1). The faster, orbit-leading trooper is part of it; no retune by the owner's word.
- The player's own Kerf slice can still carry Rivet through a thin wall (souls code, melee lane's): `NEED melee` with a
  patch as text in `evidence/n26-pressure/stall/cause.md`; the player test is pending until then.
- The stall fix (`bf32bfd1a`) has no mutate score: call 06 ran out of time inside its mutate run, and the builder was
  gone after that (see below); the lane's one Godot then went to the films and the final gate, which ended 18:17, too late to
  start a mutate run before the 18:40 freeze. Open: `node tools/mutate/mutate.mjs --file=features/gauntlet/gauntlet_combat.gd --max=10`.
- The two-trooper circling film and a 6 m deflect film were not made: the existing dev takes put ONE rocket trooper in a
  wave-6 crew and the rifles at 9.5 m, and the builder that would have added a two-trooper / 6 m take hit its usage
  limit. The films below use the takes that exist; the 6 m and two-trooper numbers are the measured tables.

## What blocked or slowed you (minutes each)

- Codex image jobs: all three rocket plates hit the known copy stall to `./out` (15 min each), copied by hand from
  `~/.codex/generated_images/` (~3 min each).
- Call 01 (deflect) missed its commit deadline: the full scenario suite took 25+ min under five-lane load; I reviewed the
  staged diff and committed it myself (10 min).
- Pre-commit hook tool-test flake (`timeout must kill a grandchild` under load): one retry, 2 min.
- Call 02 (rocket art) delivered a rocket that read as a 30 px dark sliver at 32 px/m (Rivet's size): bounced, 31 min
  follow-up.
- Call 03 (trooper) read the "nobody dies to rockets alone before wave 6" rule as "no rocket last blow" and shipped
  nothing new; the one novice run whose last blow was a rocket had taken zero rocket hits in four waves. 18 min follow-up.
- Call 06 (stall) used its full 65 min: the 1-tick-precise repro of a 77115-tick run under five-lane load; it ended at its
  time limit inside mutate with no final message (I reviewed and committed the medians, 5 min).
- **Astra usage limit** (16:14): the films call (07) died after 4 s ("usage limit ... try again at Nov 28th"). No builder
  for the last 2.5 h; the code was frozen by then, so I made the films myself with the committed n24 film tool
  (`tools/gauntlet/pressure_films.mjs`), which could only film the takes that exist.

## Calls for the owner

1. **Rocket plate A or C** (`gtai-masters/n26/pressure/rocket-a-vs-c-32.png`): A (built: slim pointed casing, full
   ice-blue rim) or C (blunt nose, three ice-blue bands). One file swap.
2. **Trooper harshness**: at 1.1 s orbit a player who circles steadily at 10 m without dashing loses 75 HP in 10 s and
   dies in 13.3 to 13.5 s against ONE trooper (`evidence/n26-pressure/trooper/arena.md`); a dash across each locked
   line takes nothing. 1.4 s orbit (one value, `enemies.json` rocket `cooldown_s`) is gentler: 0.141 hits per trooper
   on the average bot. Films: `gtai-masters/n26/pressure/standing_punished_32_before_after.mp4` (wave 6, seed 28,
   stand / circle / dash, HP in the caption: before 33.6 / 67.9 / 89.2, after 33.6 / 69.7 / 89.2) and
   `standing_punished_64.png` (a cased rocket on its line as Rivet dashes off it). Honest read: that 7 s mixed-crew take
   does not separate the trooper change; the arena table does. The two-trooper circling film was not made (no take, no
   builder).
3. **Deflect curve**: 20 degrees gives 24 % at 6 m for the guard, 31 % for the plasma bat
   (`evidence/n26-pressure/deflect/share.md`, as a chart `gtai-masters/n26/pressure/deflect_curve.png`). Film:
   `deflect_half_32_before_after.mp4` (12 deg left, 20 deg right; riflemen at 9.5 m, the only take: 5 returns per take
   are too few to show a share, the curve is the measure). If a quarter at 6 m is right for the guard, 20 stays; the
   plasma bat sits at 31 %.
4. **Tuner's record proposal** (not applied, the owner gives numbers): `rivet_repair` x1.25 (repair 10 -> 12.5 /s,
   delay 3 -> 2.4 s) for all three skill misses (`evidence/n26-pressure/medians/plan.json`).
5. **Both rockets in a fight**: `gtai-masters/n26/pressure/rocket_pair_32.mp4` (16 s, 238 frames with both in flight),
   `rocket_pair_64_before_after.png` (solid ice shape -> cased rocket, same tick).

## Merge notes

- Pressure touched `combat.json` (`deflect.spread_deg`), the rocket rows of `enemies.json` / `weapons.json`, enemy round
  art and `project/features/combat/enemy_round_look.gd`. The stall fix touched gauntlet code only:
  `project/features/gauntlet/gauntlet_combat.gd`, `project/features/gauntlet/bot/bot_arena_moves.gd`,
  `project/features/gauntlet/bot/bot_view_arena.gd`, `project/dev/gauntlet/gauntlet.gd`, two unit tests and
  `tools/debt/baseline.json` (merge with `node tools/debt/merge_baseline.mjs` on conflict).
- The melee lane owns `project/features/souls/kerf_stage.gd`: the player-side Kerf wall fix is its call (`NEED melee`,
  patch text in `evidence/n26-pressure/stall/cause.md`); `test_player_kerf_slice_keeps_the_street_in_reach` is pending.
- Root `JOURNAL.md` / `REPORT.md`: add/add conflict with other lanes, keep each lane's own.
- Digests: replay_60s, quest 1 tapes and war_cannon held byte-identical through the rocket and deflect commits
  (calls 01 to 03 checked them); the trooper rest/lead and the stall bot fix change gauntlet bot results (every
  gauntlet batch differs from main's; that is item 3's and 4's point), not a shipped replay. A deliberate change
  is recorded in `docs/decisions.md` (pressure trooper and stall lines).
- After `MILESTONE keys` (re-check of item 3, static, by reading `git diff 0779185ac n26-keys`; no Godot was free to
  re-run it): keys sets `rivet_motion.json` `hold_sprints` false, stops Rivet's motion while a car is driven or its door
  is open (`player_motion.gd`), and gives the gauntlet bot a per-number deploy choice (`bot_forms.gd`). The rocket arena
  drives Rivet at `sprint_mps` directly and the gauntlet bot presses `sprint` and `dash` as separate actions, so item 3's
  arena table should not move; the bot's ghost deploys do change, so **the item 5 medians are pre-merge numbers**:
  re-run them on the merged tree before quoting them to the owner (`tools/gauntlet/batch.mjs` with the args recorded in
  `evidence/n26-pressure/medians/salt0/batch.json`: profile all, pick greedy, controls wheel, 10 seeds, 40 waves, salt 0).

## Next steps

- The owner plays the 1.1 s orbit trooper and gives numbers; 1.4 s orbit is one value away (`enemies.json` rocket
  `cooldown_s`), `lead_model: linear` restores the old aim.
- A two-trooper circling take and a 6 m guard take in `project/dev/gauntlet/pressure_take.gd`, then the two films the
  brief asked for (needs a builder).
- Mutate the stall fix (`gauntlet_combat.gd`, `bot_arena_moves.gd`) if this session's run did not finish.
- Melee lane: the player Kerf wall crossing (patch text ready).

## Astra ledger

| # | tag | minutes | verdict | what it delivered |
|---|---|---:|---|---|
| 1 | deflect | 61 | accepted (committed by me) | spread 20, re-derived bounds, share tool + curve |
| 2 | rocket-art | 64 | bounced | cut tool, wiring, stills; rocket too small at 32 px/m |
| 3 | rocket-read | 31 | accepted | 1.4 m casing, ice jets, rim glow, ownership test, A-vs-C still |
| 4 | trooper | 52 | bounced in part | lead model + probes + tests; shipped nothing (misread rule) |
| 5 | trooper-ship | 18 | accepted | 1.1 s orbit shipped, harshness measured, test bounds |
| 6 | stall | 65 | accepted | cause, bot fix, freeze clock, red-then-green test, item 5 batches (staged; I committed them) |
| 7 | films | 0 | abandoned | usage limit after 4 s; films made by me with the committed tool |

What I would brief differently: give every call a commit-before-suites order from the first brief (call 01 lost its
deadline to the scenario suite); state a numeric "reads large" bar for art (on-screen pixels at 32 px/m against
Rivet's) up front; and spell out how a rule is measured ("rockets alone" = rocket damage share, not the last blow).
