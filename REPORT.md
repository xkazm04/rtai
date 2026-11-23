# REPORT n26 lane `pressure` (2026-11-23, 11:06 to 19:10)

Branch `n26-pressure`, worktree `gtai-wt/n23-loop`, cut from `main` `0779185ac`. Continues
`docs/day/2026-11-23/n24-pressure/`. Director: Opus; builder: Astra (every product change is Astra's; I wrote briefs,
`JOURNAL.md` and this file, reviewed every diff, looked at every still).

Final HEAD: TODO. Gate: TODO (`node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path).

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
  launch. A faster rest (0.9 / 0.75) was not run: the sweep stopped at the first orbit qualifier. TODO confirm.
- Expert median death wave fell from 23 (n24 final, 5 seeds, one censored) to 8.5 / 9: in salt 0 the rocket killed 3 of 10
  experts (0 in salt 1). The faster, orbit-leading trooper is part of it; no retune by the owner's word.
- The player's own Kerf slice can still carry Rivet through a thin wall (souls code, melee lane's): `NEED melee` with a
  patch as text in `evidence/n26-pressure/stall/cause.md`; the player test is pending until then.
- TODO

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
- TODO

## Calls for the owner

1. **Rocket plate A or C** (`gtai-masters/n26/pressure/rocket-a-vs-c-32.png`): A (built: slim pointed casing, full
   ice-blue rim) or C (blunt nose, three ice-blue bands). One file swap.
2. **Trooper harshness**: at 1.1 s orbit a player who circles steadily at 10 m without dashing loses 75 HP in 10 s and
   dies in 13.3 to 13.5 s against ONE trooper (`evidence/n26-pressure/trooper/arena.md`); a dash across each locked
   line takes nothing. 1.4 s orbit (one value, `enemies.json` rocket `cooldown_s`) is gentler: 0.141 hits per trooper
   on the average bot. Film: TODO.
3. **Deflect curve**: 20 degrees gives 24 % at 6 m for the guard, 31 % for the plasma bat
   (`evidence/n26-pressure/deflect/share.md`). Film: TODO.
4. TODO

## Merge notes

- Pressure touched `combat.json` (`deflect.spread_deg`), the rocket rows of `enemies.json` / `weapons.json`, enemy round
  art and `project/features/combat/enemy_round_look.gd`. TODO stall files.
- Root `JOURNAL.md` / `REPORT.md`: add/add conflict with other lanes, keep each lane's own.
- TODO digests moved.

## Next steps

- TODO

## Astra ledger

| # | tag | minutes | verdict | what it delivered |
|---|---|---:|---|---|
| 1 | deflect | 61 | accepted (committed by me) | spread 20, re-derived bounds, share tool + curve |
| 2 | rocket-art | 64 | bounced | cut tool, wiring, stills; rocket too small at 32 px/m |
| 3 | rocket-read | 31 | accepted | 1.4 m casing, ice jets, rim glow, ownership test, A-vs-C still |
| 4 | trooper | 52 | bounced in part | lead model + probes + tests; shipped nothing (misread rule) |
| 5 | trooper-ship | 18 | accepted | 1.1 s orbit shipped, harshness measured, test bounds |
| 6 | stall | TODO | TODO | TODO |
| 7 | films | TODO | TODO | TODO |

What I would brief differently: give every call a commit-before-suites order from the first brief (call 01 lost its
deadline to the scenario suite); state a numeric "reads large" bar for art (on-screen pixels at 32 px/m against
Rivet's) up front; and spell out how a rule is measured ("rockets alone" = rocket damage share, not the last blow).
