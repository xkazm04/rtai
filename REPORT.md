# REPORT - lane `street`, run n23 (2026-11-22)

Branch `n23-street`, cut from `main` `76111adec`. Director: Opus (this lane's sessions 1-6); builder: GPT-6.2 Astra.
DRAFT written 05:25 in session 4; TODO markers are filled by the session that gates.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. A timed-out wave stacks (`on_timeout: next_wave`, `max_alive` 40, `spawn_delayed`, `capped`, tick cap 216000, `death.wave` = newest) | `e24cc3847`; `evidence/street/stacking-seeds.md`; `evidence/street/stack-seed7.json` | seed 7 average with the dev timer `--wave-timeout=12`: waves 8-16 stacked in block 8, peak 8 waves alive, 28 spawns delayed by the cap, death on wave 16; two runs byte-identical (sha256 `25bff7c6...`) |
| 1. Seed 7 average, real 90 s timer, no wave limit, ends in death | `evidence/street/s7a.json`, `evidence/street/s7b.json` | death wave 35 by stomp; the two runs byte-identical (cmp) |
| 1. Stacking on film (2 and 3 waves alive) | `C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-seed7-32.mp4` (26.5 s, 32 px/m, tilt 70, 1080p60); stills `stack-1-alive.png`, `stack-2-alive.png`, `stack-3-alive.png` | HUD "Wave 9 - 2 alive", "Wave 10 - 3 alive" (war machine arriving on top) |
| 1. Owed picks after a stacked block, one after another, with a counter | `e95cf7b5f`; still `stack/pick-counter.png` | "Wave 2 cleared / Pick 2 of 3"; the total counts only waves with a non-empty offer |
| 1. Wave timer turns amber in its last 10 s | TODO (stackfilm Part C) | |
| 2. Budget in tenths, one to one | `fc06b8e4f`; `evidence/street/budget-one-to-one.md` | seeds 1-3 average 10 waves: 3/3 results byte-identical before/after (cmp re-run by the director) |
| 2. Opening waves longer | `b98480af1`; `evidence/street/budget-opening.md` | `budget{base:180, per_wave:16}`, `cost{patrol_cop:15, war_machine:200}`: waves 1-5 pooled median 7.10 s -> 11.67 s over 5 seeds x 5 waves |
| 3. Enemy rounds not red | `90bad0b11`; stills `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/`, `rounds-review.jpg`; `evidence/street/rounds.md` | small `#FFE6A8` on `#E08A1E` amber, large `#E8F7FF` on `#92C9F5` ice blue, enemy muzzle `#FFDC8C`; seed 7 average 10 waves cmp identical, 60 s replay `cbeb734ff9b97c41` unchanged |
| 3. Enemy rounds while Rivet is on hands | TODO (brief 04 Part 0) | |
| 4. Shove wedge at full reach | TODO (brief 04) | |
| NEEDs served | `c48fe5489` (prologue: `roster_exclude`), `cdacafe98` (loop: gauntlet `rivet{repair_per_s, repair_delay_s}`) | seed 7 average 10 waves cmp identical across both |

## What does not

- With the real 90 s timer the bots clear nearly every wave in time: no bot run of mine timed out (3 novice runs, 5x5 opening runs). Loop measured on the street merge (its JOURNAL 04:59): average median wave 60.5, 3 of 6 alive at the 216000 cap. "Until Rivet dies" is now the tuner's job (repair, enemy damage); stacking itself is proven with the dev timer only.
- Opening waves reach 11.67 s, not 15 s: 180/10 gave 13.9 s but broke the three-wave live-wave fixture at the 40 cap. Wave 1 is 13 patrol cops and wave 5 four units (boss): an odd shape for loop to tune.

## What blocked or slowed you

- Astra calls 1 and 2 ran to the 75 min cap without a final report (each ~20 min of my review time rebuilding the result from artifacts). Cause: a full gauntlet sweep beside code work. Fix used from call 3: mutate last, report first, one sweep per call.
- No bot run times out on the real timer, so the stacking film needed a dev timer flag (one extra call, ~70 min).

## Calls for the owner

1. **Large enemy rounds are ice blue** (`#92C9F5` / `#E8F7FF`). Cops are a saturated darker blue (`#3870D9`); on the stills they read apart, but blue means "cop" by the colour law. Alternative = one constant in `project/features/combat/enemy_round_look.gd`. Still: `rounds-review.jpg`.
2. **The boss wave may arrive on top of an unfinished wave** (decided yes: that is the pressure asked for). Alternative = one data value. Still: `stack/stack-3-alive.png` (war machine arriving over waves 8 and 9).
3. **`max_alive` = 40** live hostiles across all waves; extra members wait and spawn in roster order.
4. **The opening shape**: wave 1 = 13 patrol cops, wave 5 = boss + 3. Loop's tuner moves it.
5. **A timer that shortens with the wave number** would make stacking the run-ender for strong players; not built (owner said 90 s).

## Merge notes

Previewed at 05:50 with `git merge-tree --write-tree n23-street n23-<lane>` (no checkout):

- **loop** (has merged street up to `eab93e6b2`/`c48fe5489`; merges again): conflicts in `project/dev/gauntlet/gauntlet.gd` `KNOWN_FLAGS` (keep the union: street adds `--wave-timeout`, loop adds `--bot-salt`, `--pick-filter`), `project/features/gauntlet/gauntlet_draw.gd` (loop carries moves' line, see below), `tools/debt/baseline.json` (`node tools/debt/merge_baseline.mjs`, then `--update`), `JOURNAL.md` (keep loop's).
- **moves**: `project/features/gauntlet/gauntlet_draw.gd`. Street moved the eligibility loop out of `offer()` into `_eligible()` (for the pick counter's `offer_count`). Resolution: keep street's split and put moves' condition into `_eligible()`'s loop: `if first > wave or taken.has(id) or not MoveBonus.offerable(row, taken, moves):`, keep moves' `var moves: MoveTable = MoveTable.shipped()`. `tools/debt/baseline.json` as above.
- **controls**, **prologue**: only `JOURNAL.md` (add/add: keep each lane's own) and `tools/debt/baseline.json`.
- Street touched two files outside its list, each a one-line call site named in JOURNAL: `project/boot/collect_call/view/fx_view.gd` (enemy round colour on hands, brief 04 Part 0) and `project/features/combat/squad/foe_shield.gd` (the shove hit test calls `FoeShoveZone.connects`, brief 04; moves owns the file).

## Next steps

TODO

## Astra ledger

| Call | Tag | Minutes | Verdict | What I would brief differently |
|---|---|---|---|---|
| 1 | stack | 75 | accepted | half the size; mutate last; report before mutate |
| 2 | budget | 75 | accepted | no 20-run sweep in a code call |
| 3 | rounds | 65 | accepted (gap: stills staged with a pistol, not on hands) | name the state the owner sees (Rivet on hands) |
| 4 | stackfilm | TODO | | |
| 5 | wedge | TODO | | |
