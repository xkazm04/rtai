# REPORT lane yard, run n26 (2026-11-23): the factory yard, second pass

Branch `n26-yard`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, cut from `main` `0779185ac`. Merged in: `n26-keys` at `8d8bb3787` (MILESTONE keys, merge `e98906eac`) and `n26-cast` at `8cf84806f` (MILESTONE mulroney, card on; merge `c28b6b5a7`).
The second pass is a new dressing row `line_fire` in `project/data/tables/prologue_yard_dressings.json`, and `prologue_stage.json` now defaults to it. `plain` and `torn_line` stay selectable and keep their pilot bytes.

**Gate:** `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n25-yard\build\gate\ee19d4f9c536\gate.json` at `ee19d4f9c`. Lint 19/19, unit 4034 passed / 0 failed / 2 skipped, scenarios 68 ran (city_chase nav budget CONTENDED: 4 other runs, not judged), parity exact over 1200 steps with the planted mutation caught, selftest, export-audit 974 loaded / 0 failed. **Without `--reels`:** the gate took 42 min on the loaded machine, so no time was left for reels.

**The builder was lost at 16:12:** the Astra account hit its usage limit for every lane (`gtai-n26/logs/yard/astra-05-card.jsonl`: "try again at Nov 28th"). Call 04 ended on that limit, and call 05 (card wiring plus chunky cover art) died after 31 s with nothing changed. The director ran the films after 16:12 using only the dev entries already in the repo.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Plate beside game, the gaps | `JOURNAL.md` session 1 (11:12), ten gaps; masters `plate_vs_game_{gate,mid}_{32,64}ppm.png`, `plate_vs_game_front_64ppm.png` | 10 gaps listed |
| 2. Conveyor and wrecks as real cover | `evidence/yard26/layout_t6000.png`, `evidence/yard26/line_join_32ppm.png`, `evidence/yard26/line_join_64ppm.png`, `evidence/yard26/prologue-yard-pilots.json`, decisions line `DECISION n26 yard: line_fire` | The pilot finishes 5/5 seeds. Deaths 0/1/0/0/1 (seeds 7/3/11/21/42) against torn_line (= main) 0/2/0/0/0. Min hp 36/0/44/28/0 against 36/0/2.8/36/28. Stuck cops 0-2 per run on both dressings, all at the gate arrival (x 35-36, y 31-32.5), none on the new cover. The line now runs as one S from the hall front with five open crossings (5fc1a3258). Cover mutate `prologue_yard.gd` 14/18 = 77.8 % |
| 3. Dusk, fire light, broken front | `evidence/yard26/dusk_front_64ppm.png`, `evidence/yard26/dusk_shade_steps_32ppm.png`, `evidence/yard26/dusk_t6000_32ppm.png`, `evidence/yard26/frame-cost.md` | Ground shade 0.81 on paper 0.92. Against daylight contrast, patrol blue keeps 69.2 %, the rifle round 124.5 % and the pellet 96.2 %. Eight held fire and lamp pools; the hall front is torn open with fire behind the burst doors. Frame cost p50 -0.04 ms [CI -0.70, +0.62] (bench lock, debug build). Embers cut (+0.585 ms upper bound > 0.5). Lights mutate 5/7 |
| 4. Chain-link and gate sheet | `evidence/yard26/fence_gate_32ppm.png`, `evidence/yard26/fence_gate_64ppm.png`, `evidence/yard26/fence_tile_check.png` | 5 cut pieces from `gtai-art/factory-n26/out/fence-gate.png` (0784f9ca4); seam check clean; zebra clear; fence mutate 18/18 |
| 5. Pump tell | `evidence/yard26/pump_32ppm_before_after.mp4`, `evidence/yard26/pump_64ppm.png`; masters `pump_32ppm.mp4`, `pump_64ppm_t6229.png` | Marker 51.2 px at 32 px/m (1.6 m), about twice the old size. Muzzle lifts 28 deg, forearm 0.532 rad (two-beat stroke). Command view mutate 5/20 |
| 6. Keys merge, lesson cards | merge `e98906eac`; `project/boot/prologue/prologue_prompts.gd` (cards name actions, expanded from the live bindings); masters `prologue_menu_to_quest1.mp4` | FILMS-ROW |

## What does not
- **Plate beside game (masters `plate_vs_game_mid_32ppm.png`):** the mid yard is still far from the plate. The floor is pale, the conveyor reads as thin dark strokes rather than the plate's raised belt, no appliances hang from it, and the pallets are small. The hall front comes closest (`plate_vs_game_front_64ppm.png`): fire in the burst bays and the line coming out of the hall, though dimmer than the plate.
- **Mulroney's card is not wired into the prologue.** Cast's card is on (merged `c28b6b5a7`), but `PrologueCommandView._process` still draws the vector dress and does not call `FoeCastView.set_pump`. My 64 px/m still at tick 6229 on this branch shows one Mulroney (the dress with the large marker): the card does not draw on the prologue path, so there is no double draw here. Call 05 was to wire it and died on the usage limit (NEED director below).
- **The six blocking conveyor sections read like loose belt.** Call 04 re-arted them as thin belt strips (`evidence/yard26/line_join_64ppm.png`), so cover does not read as cover at 32 px/m. The chunky rail art back on those six rows was call 05 Part B, which never ran.
- **The dusk is shallower than the plate.** At the measured contrast limit (0.81) the yard reads as grimy evening, not the plate's night. See Calls.
- The dusk-depth comparison clip (0.81 against 0.62) was not made: it needs a `--ground-shade` override in the film script, and no builder was left to write it. The evidence is the still `evidence/yard26/dusk_shade_steps_32ppm.png`.
- The hall-front pair is a 64 px/m still only: `yard_film.gd` has no `front` place.
- Frame cost was measured on a debug build: the release template failed to launch the probe.
- Mutate on the command view is weak (5/20); the survivors are glyph geometry.

## What blocked or slowed you
- **Astra usage limit at 16:12:** two packages lost (card wiring, chunky cover art) and the films done by hand.
- **Cast merge blocked by pre-commit tool tests:** three tries (13:56, 15:08, 16:24), ~45 min. Kill-reel break tests fail when the class cache is stale; `staged_tree` and `step_guard` are timing and hook-env flakes. Landed on the fourth commit attempt; the hook was never skipped.
- **Codex image stall on the copy to `./out`** (11:17 to 11:27): ~12 min. `grab.sh` now copies by session id.
- **Call 01 hit the 75 min cap without a final message:** ~10 min of review from the event log.
- **Final gate took 42 min on the loaded machine** (16 min last time).

## Films
Masters in `C:\Users\kazda\kiro\gtai-masters\n26\yard\` with `frames.json` (13 entries, best first). The director rendered them after the builder was lost, using the existing `yard_film.tscn` through the 1080p capture profile `build/prologue-film` (driver script `build/films26/films.sh`, git-ignored). ffprobe:
- `pair_gate_32ppm.mp4` h264 1920x1080 60/1 25.0 s
- `pair_mid_32ppm.mp4` h264 1920x1080 60/1 25.0 s
- `pump_32ppm.mp4` h264 1920x1080 60/1 20.0 s
- `pump_32ppm_before_after.mp4` 20.0 s

Stills: `plate_vs_game_{gate,mid}_{32,64}ppm.png`, `plate_vs_game_front_64ppm.png`, `pair_gate_64ppm_t6400.png`, `pair_mid_64ppm_t2290.png`, `pump_64ppm_t6229.png`, `dusk_depth_steps_32ppm.png`. FILMS-MENU

## Calls for the owner
1. **Dusk depth.** Shipped: ground shade 0.81, the deepest level at which the patrol cop's blue keeps the measured readability floor (69.2 % of daylight contrast). At 0.62 the yard looks like the plate's dusk with lamp pools, and to my eye the cops still read by their ink outline, but the metric says patrol blue keeps only ~29 %. Evidence: `evidence/yard26/dusk_shade_steps_32ppm.png` (same tick, each step labelled). The switch is one data value, `ground_shade` in the `line_fire` row.
2. **The conveyor: one S of thin belt, or chunky rails.** Today it is one S with five crossings (`evidence/yard26/line_join_32ppm.png`), but the blocking parts look like loose belt. The alternative is chunky rail art on the six blocking sections with thin belt only in the gaps (the brief is ready: `evidence/briefs/n26-06-card.md` Part B).
3. **Pump tell on the vector dress or on cast's card.** Tonight it plays on the vector dress (1.6 m marker and arm stroke). Cast's card carries pump rows 2 and 3; wiring it is five lines (Merge notes).

## Merge notes
- `prologue_stage.json`, `prologue_yard_dressings.json` and `project/boot/prologue/**` are yard's. The pilot pins moved (decisions line `DECISION n26 yard: line_fire`); `plain` and `torn_line` keep their result bytes.
- **NEED director (cast card, yard-owned code):** in `project/boot/prologue/prologue_command_view.gd` `_process`, add `_dress.visible = _bar.visible and CastCards.current(&"sergeant_mulroney") == null`; then `if _bar.visible: var p: float = _battle.fire.shotgun.pump_progress(_stage.tick); FoeCastView.set_pump(boss, p, p == 0.0); _dress.pump = p`. Keep the marker and sound on `_dress.pump`.
- **NEED director (tools):** `tools/film/kill_reel_*.break.test.mjs` must not depend on a fresh class cache (the fake runner gets the launcher's `--import` call without `--film-dir`). Until then a merge that stages tools and project fails its hook whenever the cache is stale.
- Root `JOURNAL.md` and `REPORT.md`: keep each lane's own.

## Next steps
1. Wire Mulroney's card (the five lines above), then film the pump on the card at 32 px/m.
2. Chunky rail art on the six blocking conveyor sections (`evidence/briefs/n26-06-card.md` Part B).
3. The dusk-depth pair clip once the owner picks a direction: a dev-only `--ground-shade` in `yard_film.gd`.
4. A `front` place in `yard_film.gd` for a moving hall-front pair, then `--reels` on the gate.
5. Frame cost in a release build under the bench lock.
6. Strengthen the command view tests (mutate 5/20: glyph geometry survives).

## Astra ledger
| Call | Tag | Minutes | Verdict |
|---|---|---|---|
| 01 | cover | 84 (cap) | accepted |
| 02 | dusk | 71 | accepted |
| 03 | fence-pump | 68 | accepted |
| 04 | line-card | 63 (died on the usage limit) | accepted (B sent back) |
| 05 | card | 0.5 (usage limit) | abandoned |

Total ~287 min over 5 calls, 4 accepted. What I would brief differently:
- **One question per art call.** Call 04 joined the line and also re-arted the cover, and the re-art made the cover worse. Art that changes how cover reads should be its own call, with a 32 px/m look check before the commit.
- **Contrast metric first.** The dusk took three calls because each one stepped the screen grade before the metric showed that the floor, not the screen, had to darken. A one-shot measurement brief first would have saved a call.
- **Front-load must-haves.** The builder can vanish without warning. The card wiring (five lines) should have gone in an earlier call rather than waiting for the art.
