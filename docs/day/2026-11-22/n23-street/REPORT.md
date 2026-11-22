# REPORT - lane `street`, run n23 (2026-11-22)

Branch `n23-street`, cut from `main` `76111adec`. Director: Opus (this lane's sessions 1-6); builder: GPT-6.2 Astra.
Final, 08:40. Seven product calls and one film call; every change below is on `n23-street`, and the final gate passed on its code.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. A timed-out wave stacks (`on_timeout: next_wave`, `max_alive` 40, `spawn_delayed`, `capped`, tick cap 216000, `death.wave` = newest) | `e24cc3847`; `evidence/street/stacking-seeds.md`; `evidence/street/stack-seed7.json` | seed 7 average with the dev timer `--wave-timeout=12`: waves 8-16 stacked in block 8, peak 8 waves alive, 28 spawns delayed by the cap, death on wave 16; two runs byte-identical (sha256 `25bff7c6...`) |
| 1. Seed 7 average, real 90 s timer, no wave limit, ends in death | `evidence/street/s7a.json`, `evidence/street/s7b.json` | death wave 35 by stomp; the two runs byte-identical (cmp) |
| 1. Stacking on film (2 and 3 waves alive) | `C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-seed7-32.mp4` (26.5 s, 32 px/m, tilt 70, 1080p60); stills `stack-1-alive.png`, `stack-2-alive.png`, `stack-3-alive.png` | HUD "Wave 9 - 2 alive", "Wave 10 - 3 alive" (war machine arriving on top) |
| 1. Owed picks after a stacked block, one after another, with a counter | `e95cf7b5f`; still `stack/pick-counter.png` | "Wave 2 cleared / Pick 2 of 3"; the total counts only waves with a non-empty offer |
| 1. Wave timer turns amber in its last 10 s | `f0ac04fe5`; `project/tests/unit/test_gauntlet_wave_timer.gd`; still `stack/timer-warning.png` | amber at exactly 10 s left (`GauntletWaves.seconds_left`); the readout counts elapsed seconds, so amber from 80 s on the real timer; mutate `gauntlet_waves.gd` changed lines 15/(15+1) = 93.8 % |
| 2. Budget in tenths, one to one | `fc06b8e4f`; `evidence/street/budget-one-to-one.md` | seeds 1-3 average 10 waves: 3/3 results byte-identical before/after (cmp re-run by the director) |
| 2. Opening waves longer | `b98480af1`; `evidence/street/budget-opening.md` | `budget{base:180, per_wave:16}`, `cost{patrol_cop:15, war_machine:200}`: waves 1-5 pooled median 7.10 s -> 11.67 s over 5 seeds x 5 waves |
| 3. Enemy rounds not red | `90bad0b11`; stills `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/`, `rounds-review.jpg`; `evidence/street/rounds.md` | small `#FFE6A8` on `#E08A1E` amber, large `#E8F7FF` on `#92C9F5` ice blue, enemy muzzle `#FFDC8C`; seed 7 average 10 waves cmp identical, 60 s replay `cbeb734ff9b97c41` unchanged |
| 3. Enemy rounds while Rivet is on hands | `29d3080e4` (one line in `project/boot/collect_call/view/fx_view.gd`); stills `rounds/rounds-hands-{before,after}-32.png` | `cc205aac9` (`ShotDraw.bare`): was a vermilion dash, now the amber rim + light core of the gun path at tick 306 seed 7 (4x crop `build/street/crop/hands-pair-2.png`, scratch) |
| 4. Shove wedge at full reach | `a6135a129`; `project/features/combat/squad/foe_shove_zone.gd`, `project/tests/unit/test_foe_shove_zone.gd`; `evidence/street/shove-wedge.md`; stills `wedge/shove-{before,after}-{32,64}.png` | 2.20 m x 0.64 m strip from the planted tell (0.40 m lunge + 1.80 m reach), one source with the hit test (`FoeShoveZone.connects`); body 0.05 m in/out of rails and tip tested over 3 aims x 3 speeds x 2 reaches; seed 7 cmp identical, replay `cbeb734ff9b97c41` |
| Mutation scores (killed / decided, 0 timeouts) | `evidence/street/brief06-mutations.md` | `gauntlet_composer.gd` 20/20; `gauntlet_waves.gd` changed lines 15/16, the first-owed-pick line 1/1 after `a51a6b1b9`; `foe_shove_zone.gd` 19/20, the survivor's line 4/4 after `1818deb63`; `gauntlet_draw.gd` offer_count/_eligible 15/16 -> 16/16 after `79844f671`; `foe_shield.gd` hit line 1/1; `shot_draw.gd` 5/20 (15 survivors are draw calls: checked by the stills, not by tests) |
| NEEDs served | `c48fe5489` (prologue: `roster_exclude`), `cdacafe98` (loop: gauntlet `rivet{repair_per_s, repair_delay_s}`), `574e313a2` (loop: gauntlet `enemy_damage_k`, applied to damage foes deal to Rivet; `evidence/street/enemy-damage.md`; k 2.0 on seed 7 average: death on wave 10 instead of surviving 20) | seed 7 average 10 waves cmp identical across both |
| Films (32 px/m, tilt 70, 1080p60) | `evidence/street/films.md`; `C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-32.mp4`, `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-32.mp4`, `C:/Users/kazda/kiro/gtai-masters/n23/street/frames.json` (15 entries) | shove film 15.6 s: the same carrier misses at 9.58 s (Rivet 0.67 m outside the mark), then hits at 12.97 s (125 -> 111). Rounds film 20.2 s on hands: amber rounds over blood at 10.6 s, ice-blue rockets at 15.57 s and 18.87 s. I checked frames of both myself |

**Gate** (`node tools/gate/run.mjs --rev=HEAD` on `7277e1f8`; the code matches the last product commit `574e313a2`, since the later commits touch only JOURNAL and REPORT): `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n23-street\build\gate\7277e1f8575f\gate.json`. Lint 19/19 checks over 1951 files. Unit 3662 passed, 0 failed, 2 skipped. Scenarios 65 passed. Parity was bit for bit over 1200 steps and caught the planted mutation. Selftest goldens 11/11 and 5/5. Release compile 884 loaded, 0 failed. Reels gate after the last commit (`node tools/gate/run.mjs --rev=HEAD --reels` on `3b446472`, same code): `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n23-street\build\gate\3b446472c539\gate.json`. Every stage passed again, plus `reels: exit 0`.

## What does not

- With the real 90 s timer the bots clear nearly every wave in time: no bot run of mine timed out (3 novice runs, 5x5 opening runs). Loop measured on the street merge (its JOURNAL 04:59): average median wave 60.5, 3 of 6 alive at the 216000 cap. "Until Rivet dies" is now the tuner's job (repair, enemy damage); stacking itself is proven with the dev timer only.
- Opening waves reach 11.67 s, not 15 s: 180/10 gave 13.9 s but broke the three-wave live-wave fixture at the 40 cap. Wave 1 is 13 patrol cops and wave 5 four units (boss): an odd shape for loop to tune.
- **A full street can freeze on the merged game** (loop JOURNAL 07:08: 4 of 30 merged runs, 0 of 60 on street alone). In loop's `expert-1.json` wave 32 timed out at tick 56851 (= start + 5400) and wave 33 came on top as built. Wave 33 timed out too, and wave 34 has no row: its whole roster waited on the 40-alive cap. From then until the 216000-tick cap nobody was hurt (wave 33 hp min = max = 137.5). The wave rules worked (stack, cap, `capped: true`). The freeze is in combat: about 40 live foes deal no damage and take none. `NEED moves` (JOURNAL 08:00) asks whether a move state (short circuit, blink, armour crack) can stay on forever or hold the squad's attack slots. Not changed tonight. The Director can raise `max_alive` in `gauntlet.json` (one data value).

## What blocked or slowed you

- Astra calls 1 and 2 ran to the 75 min cap without a final report (each ~20 min of my review time rebuilding the result from artifacts). Cause: a full gauntlet sweep beside code work. Fix used from call 3: mutate last, report first, one sweep per call.
- No bot run times out on the real timer, so the stacking film needed a dev timer flag (one extra call, ~70 min).

## Calls for the owner

1. **Large enemy rounds are ice blue** (`#92C9F5` / `#E8F7FF`). Cops are a saturated darker blue (`#3870D9`); on the stills they read apart, but blue means "cop" by the colour law. Alternative = one constant in `project/features/combat/enemy_round_look.gd`. Still: `rounds-review.jpg`.
2. **The boss wave may arrive on top of an unfinished wave** (decided yes: that is the pressure asked for). Alternative = one data value. Still: `stack/stack-3-alive.png` (war machine arriving over waves 8 and 9).
3. **`max_alive` = 40** live hostiles across all waves; extra members wait and spawn in roster order.
4. **The opening shape**: wave 1 = 13 patrol cops, wave 5 = boss + 3. Loop's tuner moves it.
5. **The shove slab looks wider than it hits.** The mark now draws the real hit lane (0.64 m + Rivet's radius each side); the drawn door slab is about 2.5 m across. Stills `wedge/shove-after-32.png`, `wedge/shove-after-64.png`. The shove's numbers belong to the enemy lanes.
6. **A timer that shortens with the wave number** would make stacking the run-ender for strong players; not built (owner said 90 s).

## Merge notes

Previewed at 05:50 with `git merge-tree --write-tree n23-street n23-<lane>` (no checkout):

- **loop** (has merged street up to `eab93e6b2`/`c48fe5489`; merges again): conflicts in `project/dev/gauntlet/gauntlet.gd` `KNOWN_FLAGS` (keep the union: street adds `--wave-timeout`, loop adds `--bot-salt`, `--pick-filter`), `project/features/gauntlet/gauntlet_draw.gd` (loop carries moves' line, see below), `tools/debt/baseline.json` (`node tools/debt/merge_baseline.mjs`, then `--update`), `JOURNAL.md` (keep loop's).
- **moves**: `project/features/gauntlet/gauntlet_draw.gd`. Street moved the eligibility loop out of `offer()` into `_eligible()` (for the pick counter's `offer_count`). Resolution: keep street's split and put moves' condition into `_eligible()`'s loop: `if first > wave or taken.has(id) or not MoveBonus.offerable(row, taken, moves):`, keep moves' `var moves: MoveTable = MoveTable.shipped()`. `tools/debt/baseline.json` as above.
- **controls**, **prologue**: only `JOURNAL.md` (add/add: keep each lane's own) and `tools/debt/baseline.json`.
- Street touched two files outside its list, each a one-line call site named in JOURNAL: `project/boot/collect_call/view/fx_view.gd` (enemy round colour on hands, brief 04 Part 0) and `project/features/combat/squad/foe_shield.gd` (the shove hit test calls `FoeShoveZone.connects`, brief 04; moves owns the file).

## Next steps

1. Stacking only ends runs when the bots cannot clear a wave in 90 s; on the real timer that almost never happens (loop: 1 timed-out wave in 29 runs). Tune toward it with loop's levers (gauntlet `rivet.repair_*`, `enemy_damage_k`) before touching the timer; if it still never fires, offer the owner a timer that shortens with the wave (call 6).
2. Opening waves: 11.67 s median against the 15 s target, with wave 1 = 13 patrol cops. A per-wave budget curve (more in waves 2-5, less in wave 1) or a cap on how many of one row a wave may hold would fix the shape; loop's tuner reads `budget.unit` = 10 and the `cost{}` map.
3. `shot_draw.gd` drawing calls survive mutation (5/20): a pixel probe of one tracer on ShotDraw's canvas would pin the rim and core widths.
4. The shove slab is drawn ~2.5 m across but hits a 0.64 m lane (call 5): the enemy lanes decide whether the hit widens or the slab art narrows.
5. Plate-stopped enemy rounds in `plate_sparks.gd` still draw vermilion (`NEED moves` 04:43): check after the merge.
6. The merged-game freeze (What does not): find which move or AI state stops damage either way, then re-run loop's `expert-1` (seed 1, expert, greedy, `--waves=40`). Loop's runs had n23-moves only up to `73eec563c`, without moves' Ohm fix `a8a060feb` (moves journal 07:44); merge `n23-moves` at `81723e268` first, so the re-run says whether that fix already ends the freeze.
7. Moves' NEED 06:42 (not built tonight: after the last-code line): the bonus card view reads `<name>__DESC` when that loc key exists and shows it as one line under the name, so a rank 2 card says in plain words what it adds.
8. Loop's NEED 08:51 (found at 09:31, after the freeze; not investigated): the gauntlet HUD showed `Health 111 / 110` on the merged game (average seed 1, wave 9, Tonnage form; still `C:/Users/kazda/kiro/gtai-masters/n23/loop/average-wave-9-at-10s.png`), while the telemetry says hp max 110. Check first whether a regen or repair tick adds hp without clamping to `rivet.max_hp` in Tonnage form, then whether the HUD rounds hp and max differently. `gauntlet_bonus_apply.gd:69` clamps the hp_max bonus correctly.

## Astra ledger

| Call | Tag | Minutes | Verdict | What I would brief differently |
|---|---|---|---|---|
| 1 | stack | 75 | accepted | half the size; mutate last; report before mutate |
| 2 | budget | 75 | accepted | no 20-run sweep in a code call |
| 3 | rounds | 65 | accepted (gap: stills staged with a pistol, not on hands) | name the state the owner sees (Rivet on hands) |
| 4 | stackfilm | 63 | accepted | ask for a forced short timer from the start instead of a 90 s search |
| 5 | wedge | 30 | accepted (Part 0 rim gap, sent to call 6) | ask for the crop of the changed pixels, not only the full frame |
| 6 | decisions | 73 | accepted | give the mutate `--file=` in the runner's form (`features/...`, no `project/`): the briefed form exits 2 |
| 7 | edmg | 25 | accepted (mutate `gauntlet_combat.gd` changed lines 5/5) | name the semantics of a field before quoting a NEED's suggested spot (loop's spot scaled damage TAKEN) |
| 8 | films | 17 | accepted | nothing: a no-code film call with named seconds to check works |
