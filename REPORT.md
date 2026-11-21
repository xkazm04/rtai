# REPORT lane street, n22 (2026-11-21): the gauntlet street, the run and the bonuses

Every number below was checked by the director at the time noted in JOURNAL.md.

Branch `n22-street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`. Interface tag `n22-street-iface` (4b1634334).
Final gate on the last code commit 7967a0cfa: `node tools/gate/run.mjs --rev=HEAD --reels` -> `gate: PASS; build/gate/7967a0cfacfc/gate.json` (git-ignored, in this worktree): lint 19/19 over 1857 files, unit 3458/0/2, scenarios 65, parity bit-exact over 1200 steps with the planted mutation caught at step 629, selftest, export-audit 843/0, reels top/tilt70/combo exit 0; evidence 605 s, reels 281 s per view. Commits after it are JOURNAL, REPORT, briefs and `evidence/street/late_film.json` only (all inert to the gate).

## What works (item, evidence, number)
- Interface: `StatMods`, `GauntletPilot` (bot hook `pick(offered) -> int`), `gauntlet.json` / `gauntlet_bonuses.json` + schemas, scene `project/dev/gauntlet/gauntlet.tscn` launched by `node tools/dev/run.mjs gauntlet` (a6b5b9702, 4b1634334).
- Seeded street of six 30 m templates, window of three blocks streamed ahead (01a3671db). Stills: `C:\Users\kazda\kiro\gtai-masters\n22\street\segment_*_32.png`.
- Run loop + composer: wave starts on entering a block, Rivet held at the far seam until the wave is down, war_machine on every fifth wave (f81c937d6, 14076ccc8, 9159b0d85). Composer mutate 19/20.
- Bonuses: weighted draw without repeats on stream `gauntlet_offers` (6ac380558, mutate 15/16 + 4 timeouts); picks change Rivet: hp 100 -> 125, speed 6.046 -> 7.321 m per 60 ticks, repair 10 -> 12.5 HP/s, hit 2 -> 2.5 (26c606322).
- Pick screen (keys 1-3 / click, sim paused) and HUD with the guard meter slot `GauntletHud/Status/GuardMeter` (ec142944f, 7a3ce0bc1). Still: `pick_screen_32.png`.
- Telemetry: per wave `seconds`, `enemies`, `damage_taken`, `rolls`, `form_seconds`, `shots`, `hits` (56868b5ae); seed 7 wave 5: 2 rolls, 13.82 s as Rivet, 26 shots. Bonus-apply mutate 18/18 (+2 invalid), draw 16/16 (+4 timeouts) after c78f76d5c.
- Film (bot-driven, `--pick-view`): `gauntlet_waves1-3_32.mp4` 28.7 s and `gauntlet_waves4-5_32.mp4` 23.1 s, five waves, five pick screens, the wave-5 war machine; `fight_cover_64.png` (380877aa2, frames.json cc33fbfdf).
- Street quality (session 3, c7e8fbe07..a3a06df84): eight templates dressed with the shipped city art (plain_block, crosswalk, barricade_line, loading_bay, alley_neck, kiosk_plaza, underpass, market_stalls), before/after stills per template; bodies settle on the road side of solids (4ff9fc1a7, 7baa66c58), blood and machine oil stay off wall tops (4ea7a3fe3, `war_machine_rest_32.png`); health bar cream on ink (f7f0ab15b, `health_100_50_10.png`); `death.by` always names the killer (d1d2a9ce1); pilot counters hook for loop (cd77c6507). Dressing left seed 7 byte-identical (5213 B, sha256 1d653a07...); eight templates: seed 7 twice identical, 5238 B, sha256 e54f8a6f... (`evidence/street/street_quality.json`).
- Paint matches collision (235a117ce, f2c53044b): every solid box in all eight templates has a drawn obstacle and every drawn obstacle a box; the underpass cross street is closed by a drawn rail at the kerb (`evidence/street/solid_audit.json`, overlays `segment_*_solids_32.png`). Seed 7 unchanged across the paint fix.
- Per-wave `hits_gun` (direct contacts by rounds Rivet fired, comparable with `shots`) and `hits_melee` beside the unchanged `hits`, with schema descriptions (88fbbac62, loop's NEED 04:00). Seed 8 wave 5: hits 1264 (every wounding event, incl. area and burn), hits_gun 77 of 187 shots, hits_melee 43.
- Re-shot film on the dressed street (1f520b13b, `evidence/street/film.json`): `gauntlet_waves1-3_32.mp4` 28.1 s, `gauntlet_waves4-5_32.mp4` 24.8 s, 1080p60, befores kept as `*_before_32.mp4`; same-frame pairs `pair_wave2_32.png`, `pair_war_machine_32.png`, `pair_pick_32.png`; `fight_cover_64.png` (+ `fight_cover_before_64.png`). `frames.json` 15 entries, best first. Final source reproduces both captures byte for byte.
- Late-wave film on the final code (1bcbc6695, `evidence/street/late_film.json`): `gauntlet_wave8_32.mp4` 38.1 s, 1080p60, seed 7 wave 8 on the crossings block; recorded wave 8 = 34.88 s, equal to the headless run, all eight waves and picks match. Stills `wave8_{130,520,1450,2220}.png` (director looked at 520 and 1450: Rivet backs off at 39/100 to regenerate while sentry turrets and robots hold beyond the crossing, then finishes them with claw and Gatling). In `frames.json` at position 3.
- Pacing measured (`evidence/street/pacing.json`, 1997f94a9): seeds 7/8/9 median 7.19 / 11.04 / 11.50 s per wave against the 15 s target.
- Contact counter mutate (`gauntlet_combat.gd` lines 32-75, sampled 12): 9/12, then after 7967a0cfa line 71 5/5 (100 %); the remaining survivor (`:37` set_meta true -> false) is equivalent (`has_meta` tests presence).
- Determinism (director, 05:22, final code): seed 7 ten waves twice byte-identical, sha256 808cd831c557743d..., `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh`; seed 8 sha256 cbb1bd891053af9a..., different street order, offers and rosters. Earlier: seed 7 four runs byte-identical (5213 B, sha256 1d653a07..., with and without `--pick-view`); earlier seed 7 twice byte-identical (4660 B); seed 8 differs in street order, rosters and offers. 60 s replay `cbeb734ff9b97c41` unchanged; scenarios 65/65.
- Result validates (director, 05:56, final code): `build/director/s7a.json` and `s8.json` pass `project/data/schemas/gauntlet_run.schema.json` under an independent validator (every keyword incl. `uniqueItems`); seed 7: `wave_reached` 10, 10 waves, 10 picks, `mods` damage 1.1 / regen 1.375 / speed 1.1, `death` omitted (no death inside `--waves=10`).
- Two seeds, two streets (final code, run logs in `build/dev/`): seed 7 blocks per wave plain_block, alley_neck, loading_bay, plain_block, market_stalls, alley_neck, barricade_line, crosswalk, crosswalk, plain_block; seed 8 plain_block, market_stalls, underpass, crosswalk, barricade_line, underpass, market_stalls, underpass, underpass, plain_block (the first block is always plain_block). Picks differ from wave 2 (seed 7 stat_damage_10, seed 8 weapon_gloria).

## What does not
- Colour law, outside street's files: enemy rounds are drawn as thin red streaks (`wave8_520.png`, over the zebra); red is blood only. Shipped projectile art (guard / arena owner), not changed tonight.
- Late waves are far over the 15 s target with street's fallback walker. Final code: seed 7 waves 1-10 at 5.6 7.3 6.7 2.6 15.3 4.4 5.4 34.9 49.6 66.9 s (median 7.0), seed 8 at 5.1 6.5 2.2 2.9 22.8 25.9 9.5 20.8 17.7 40.8 s (median 13.6); earlier code, seed 9 wave 8 at 76.8 s (`evidence/street/pacing.json`); no death in 10 waves on seeds 7-9, so the run never ends on its own before wave 10. Loop's tuner owns the numbers.
- `guard_deflects` omitted (guard's deflect code is not on this branch); street counts it through `GauntletPilot.wave_counters()` / `GauntletWaveStats` once merged.
- The guard meter does not yet scale with the `guard_meter` stat (guard's `meter_k` is on guard's head, not its iface tag): recorded in `mods` only.
- Street mutate `gauntlet_street.gd` 6/8 (75 %): two equivalent survivors (road union unchanged in all eight templates).

## What blocked or slowed you (minutes each)
- `tools/dev/run.mjs` swallowed `--result` (fixed in 4b1634334): ~10 min.
- First Astra call stopped at the debt ratchet and asked for authorisation instead of accepting the KNOWN_FLAGS line: ~11 min (one resume).
- `tools/godot/check.mjs` fails standalone on two foes files after the foes iface merge (autoloads unresolved; project-load tests pass): ~5 min to rule out, not ours.
- Waiting on Astra while it holds the lane's one Godot: my own seed checks and the gate had to queue behind each call (~10 min a session).

## Calls for the owner
- **The five-wave film is bot-driven, not a human at the keys.** No human was present tonight; the film runs street's fallback walker with the dev-only `--pick-view` flag (offers held 90 ticks on screen, the bot's choice highlighted). `--pick-view` off is byte-identical. The human path (keys 1-3 / click, sim paused) is the same pick screen (`pick_screen_32.png`). Call: accept the bot film as the pick-screen evidence, or ask for a human take.
- **Late-wave pacing.** Watch `gauntlet_wave8_32.mp4` (38 s): the wave drags because the bot retreats to regenerate while turrets hold. Waves 1-7 sit near or under the 15 s target, waves 8-10 run 29 to 77 s with the fallback walker (hands + picks, no guard, no roll): `evidence/street/pacing.json`. Street did not move any number (the loop's tuner owns them). Call: whether the budget slope (`budget.per_wave` in `gauntlet.json`) should be the tuner's first knob.
- **Sidewalks are paint.** The dressed street draws cream sidewalks and building fronts, but the walkable street is the road between the side walls (the kerb line). Reads as a real street; plays as a corridor. Call: keep (simple, cover stays readable), or widen the walkable band onto the sidewalks in a later night.
- **Leftover enemies.** DECISION: Rivet is held at the block's far seam until the wave is down, so no enemy is ever left behind; the alternative (enemies chase into the next block) is one change in `GauntletWaves` (`forward_limit`).

## Merge notes
- Wire guard's meter: `GauntletHud.set_guard_meter(session.pilot.guard.meter(), session.pilot.guard.broken())` and `PlayerGuard.meter_k = run.mods.value(&"guard_meter")` once guard's head is merged.
- Guard's NEED (04:32): the gauntlet should run the wheel controls by default. After guard's head is merged, make an absent `--controls` mean `wheel` inside the gauntlet scene only (`project/dev/gauntlet/gauntlet.gd:31`, `run.controls = ControlsMode.id()`), legacy still selectable; outside the gauntlet legacy stays the default. Not done on street's branch (guard iface only, no live guard; it would only move every seed's sha). Until then launch with `--controls=wheel`.
- Optional: 161c32453 recolours the shipped ghost HUD's Madness notch from teal to ink inside the gauntlet (a colour-predicate shader). Teal is lawful there (ghosts are souls); the Director may drop the commit, which changes only the film's look.
- Loop: `GauntletPilot.wave_counters()` / `reset_wave_counters()` (cd77c6507) carry the bot's rolls/deflects per wave; `death.by` always names the killer or `unknown`/`timeout` (d1d2a9ce1); `hits_gun` / `hits_melee` (88fbbac62).
- Loop's NEED (06:05, after street's freeze, not built): the 90 s wave timer ends a wave `by: timeout`, which ends many bot runs before death (loop's Call 3). If the owner picks loop's option A, add `on_timeout: next_wave | end_run` to `gauntlet.json` (plus its schema) and read it where `GauntletWaves` ends a timed-out wave; `end_run` keeps today's behaviour byte-identical.
- Loop's bot: a zero-arg `GauntletPilot` subclass at `res://features/gauntlet/bot/gauntlet_bot.gd` is picked up by the scene.

## Next steps
- Merge guard's head, then wire `meter_k` and the HUD meter (two call sites above) and `GauntletWaveStats.append_guard_deflects`.
- Run the loop's real bot over the street on seeds 1-50 and let the tuner own the budget slope.
- A human five-wave take of the pick screen when the owner is at the keys.

## Astra ledger
| call | minutes | verdict |
|---|---:|---|
| iface-street | 11 | bounced (stopped at debt ratchet) |
| iface-commit | 14 | accepted |
| run-composer | 70 | accepted |
| bonuses | 45 | accepted |
| telemetry-film | 55 | accepted |
| street-quality | 62 | accepted |
| refilm | 48 | accepted |
| contact-tests | 4 | accepted |
| late-film | 9 | accepted |

Total 9 calls, about 319 minutes of builder time (11+14+70+45+55+62+48+4+9), 8 accepted, 1 bounced. What I would brief differently: put the paint-vs-collision audit inside the dressing brief (it came one call later and found the underpass mouths); state the colour-law exemption for the shipped ghost HUD explicitly (Astra recoloured the Madness notch on an over-reading of "no teal"); ask for the per-source hit split in the first telemetry brief (loop needed it at 04:00); give the debt-ratchet acceptance line in the very first brief.
