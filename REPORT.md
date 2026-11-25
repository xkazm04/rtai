# REPORT lane yard, run n29 (2026-11-25), branch `n29-yard`, base `c649a15d6`. Images 7 of 25 (none after session 2). Last code commit `f5898d1b2`; everything after it is docs and evidence.

**Gate:** `node tools/gate/run.mjs --rev=HEAD` on `f5898d1b2` (last code commit; `eb5f5ab19` and later are inert docs): `gate: PASS; build/gate/f5898d1b2074/gate.json` (scenarios 68/68, parity, selftest, export-audit 998 loaded / 0 failed). The earlier gate on `f090247dd` also passed (`build/gate/f090247ddeab/gate.json`). **Reels gate:** `node tools/gate/run.mjs --rev=HEAD --reels` on `29749d82c` (same code as `f5898d1b2`), started 07:08 instead of after the 08:45 freeze because the lane's code was frozen and the machine was light: `gate: PASS; build/gate/29749d82c140/gate.json` at 07:40 (lint 19/19, unit 4251 passed / 0 failed / 2 skipped, scenarios 68 with `city_chase.nav_max_us` CONTENDED (2 other runs, budget not judged), parity, selftest, export-audit 998 / 0, reels exit 0).

## What works
| item | evidence | number |
|---|---|---|
| 1. Floor i55 (owner's pick) | `a880ea994`, `4dfce5328`; `evidence/yard29/floor_i55_bars.md`, `evidence/yard29/floor_i20_vs_i55_mid_32ppm.png`, `evidence/yard29/floor_i20_vs_i55_gate_32ppm.png`, `evidence/yard29/floor_i55_64ppm.png`; masters `n29/yard/floor_i20_vs_i55_mid_32ppm.mp4` (23.0 s, 1920x1080, 60 fps) | floor C* 13.0 -> 18.3, L* 54.4 -> 51.9; patrol 80.6 / 88.7 %, rifle 104.5 %, pellet 100.9 %; pilots identical on 5 seeds (`evidence/yard29/prologue-yard-pilots-i55.json`) |
| 2. Taller lit hall facade with a roof glow | `4e2302840`, `7d4926a06`, `d8dd15d98` (tall collapsed bay), `d838f9e66` (roof glow `PrologueRoofGlow`, mouth pools), `73a4d9968` (fire mouths as a wall light `yard_hall_mouth_wall`), `62982244a` (two bays flipped against the plume stamp), `4fc898482`, `9021d82cd`, `5479f91df`; `evidence/yard29/hall_before_after_front_32ppm.png`, `evidence/yard29/plate_vs_game_front_32ppm.png`, `evidence/yard29/plate_vs_game_front_64ppm.png`, `evidence/yard29/frame-cost.md`; cut tool `tools/art/prologue_yard_hall_tall.py` | lit wall band ~70 -> ~150 px at 32 px/m (2.1x); red share 0.00 % on every cut; frame cost vs n28 p50 -0.040 ms, CI95 upper +0.255 ms (bar 0.5, bench lock, machine saturated); lower window rows burst 116.0 / collapsed 90.8 vs feed 86.9 / shutter 67.2 (fire mouths brightest), floor under the front +0.95 R max; pilots identical (`evidence/yard29/prologue-yard-pilots-hall.json`, `evidence/yard29/prologue-yard-pilots-hall2.json`) |
| 3. Belt as one snaking line | `5d373c8e6`, `ffeeb3165`, `6cb6cdef6`, `96852d911`, `b74df5c69`, `fca8ecd4c`; `evidence/yard29/belt_snake_before_after_mid_32ppm.png`, `evidence/yard29/plate_vs_game_mid_snake_32ppm.png`, `evidence/yard29/belt_snake_64ppm.png`, `evidence/yard29/belt_bars.md`, `evidence/yard29/belt_lanes.txt`; masters `n29/yard/belt_snake_before_after_mid_32ppm.mp4` (h264 1920x1080 yuv420p 60/1, 23.000 s) | five overhead spans, joins 0.05..0.293 m; lanes 31 ok / 0 FAIL (same as n28); no cover or collision; pilots identical (`evidence/yard29/prologue-yard-pilots-spans.json`); patrol blue under a span 84.1 % (one sample 60.4 %) |
| 4. The whole prologue film; plate beside game | `cc53b7202`; masters `n29/yard/prologue_menu_to_quest1.mp4` (menu Start to quest 1's first line, 189.32 s, 1920x1080, 60 fps, video only); `evidence/yard29/plate_vs_game_gate_32ppm.png`, `evidence/yard29/plate_vs_game_gate_64ppm.png`, `evidence/yard29/plate_vs_game_mid_32ppm.png`, `evidence/yard29/plate_vs_game_mid_64ppm.png`, `evidence/yard29/plate_vs_game_front_32ppm.png`, `evidence/yard29/plate_vs_game_front_64ppm.png`, `evidence/yard29/plate_judgement.md` | handover tick 10792, first line 10793 (unchanged from n27). How far it still is: the front is closest (burning lit facade, the snake running toward it) but the hall is a strip with no roof, torn brick or fire inside the mouths; mid reads as one snaking line but has no hanging appliances in the air, no wrapped pallets, no oil trail and a pale sand floor where the plate is dark cracked concrete; the gate camera does not see the hall at all |
| 5. Impression stops hazing the printed wrecks; overhead spans draw last | `1d5f5767f`, `b17d4a741` (span order + recording test `test_prologue_yard_overprint.gd`), `f82ec8cac`, `e023e35f5`, `b2563edc5`, `38b12720e`; `evidence/yard29/impression_props.md`, `evidence/yard29/impression_props_before_after_mid_32ppm.png`, `evidence/yard29/span_order_before_after_64ppm.png`, `evidence/yard29/prologue-yard-pilots-props.json`; masters `n29/yard/impression_props_before_after_32ppm.mp4` (h264 1920x1080 yuv420p 60/1, 20.000 s) | `burnt_pickup`, `press_carcass`, `fallen_fridges`, `scrap_skip` in `arched_line.over_print`; impression rect ends y 33.3 north of the fence; south fence luminance contrast 113 % of i20 (was 62 %); pilots identical on 5 seeds |
| 6. Gate lamp pool without losing the pellet (brief item 5) | `8652d29b1`, `f090247dd`; `evidence/yard29/gate_lamp_sweep.md`, `evidence/yard29/gate_lamp_before_after_32ppm.png`, `evidence/yard29/gate_lamp_64ppm.png`, `evidence/yard29/prologue-yard-pilots-lamp.json` | `yard_lamp_gate` floor glow strength 0 -> 0.30, radius 8 -> 5 m: pool gain +3.4 -> +7.0 L*; pellet 101.2 -> 98.4 % (bar 90), patrol 80.4 / 87.5 %, rifle 104.4 % unchanged; pilots identical |
| 7. Over-print shade, one value for the owner's wreck call (default off) | `785d96bc9`, `d2285992b`, `f5898d1b2`, `eb5f5ab19`; `evidence/yard29/impression_props.md`, `evidence/yard29/impression_props_shade_mid_32ppm.png`, `evidence/yard29/impression_props_shade_fridges_64ppm.png`, `evidence/yard29/overprint_mutate.txt` | key absent: max channel diff 0 (1920x1080); 0.5 puts forklift / skip / fridges at 110 / 94 / 100 % of i20 contrast; mutate `prologue_yard_overprint.gd` 10 killed / 11 |

## What does not
- Floor i55: Rivet's luminance delta 0.147 (bar 0.19; i20 0.183, also under) and pool gain +2.0 (bar +4; i20 +2.6, also under since n28's hall lights). The brown impression also hazes every printed thing on the floor (stains, bay lines, forklift, skip, crate, the fence at the south edge).
- Belt: Rivet over a span keeps 20.9 % of his floor-only luminance delta (0.021 vs 0.101, worst-case points on the beam): copper on copper; he reads by silhouette, helmet and collar.
- Impression props: the wrecks over the impression now draw in their own colours without the dusk grade; their luminance contrast is 55 / 47 / 29 % of i20 (forklift / skip / fridges; bar 90 %). They read better by hue and chroma (yellow forklift, white scrap, grey fridges; still `evidence/yard29/impression_props_before_after_mid_32ppm.png`), but the luminance bar FAILS.
- Mutate: `prologue_yard_overprint.gd` 10 killed / 11 (was 0 / 7; the survivor is the canvas-stacking sublayer literal, not readable without a renderer); `prologue_roof_glow.gd` 13 / 14 (was 4 / 12); the survivor, the `_stage != null` guard, is now pinned (`930b18274`, the mutant killed 1 / 1 on a re-run).
- Hall: the plumes no longer stamp every half bay but still stand on one even row; no roof surface is visible from the game camera; the snake does not come out of a fire mouth as in the plate.

## What blocked or slowed you
- Codex image jobs stall on the copy to `./out` (11 to 15 min a job instead of 90 s; 7 images, about 90 min of stall in total; images copied by hand from `~/.codex/generated_images/`).
- The pre-commit hook takes 8 to 12 min a commit on the shared machine (about 15 commits).
- One Godot slot per lane shared by two builders through `build/yard-godot.lock`: builders queued behind each other several times (5 to 10 min each); builders deleted each other's lock three times and ran three read-only renders without it (no broken run seen).
- `tools/art/prologue_yard_film.mjs --movie` launched with `--path project`, which fails the 1920x1080 movie check (about 10 min lost); fixed in `930b18274` (the tool prepares `build/prologue-film` and runs it through runGodot).
- `evidence/yard29/film.sh` ran its movie through a raw `$GODOT_BIN` instead of runGodot (fixed in the later briefs: `tools/art/prologue_yard_film.mjs --movie`).

## Calls for the owner
- **Rivet over a copper span**: he keeps 20.9 % of his floor luminance delta on a beam (0.021 vs 0.101); he reads by silhouette, helmet and collar. Options: a darker or desaturated beam top, or a soft drop shadow under Rivet when he stands on a span. Still: `evidence/yard29/belt_snake_64ppm.png`.
- **The hall is still a strip**: from the game camera (tilt 70) the hall is a lit two-storey facade with a roof edge of plumes and a glow band, but no roof surface, no torn brick around the mouths and no fire seen inside the openings as in the plate. Next step would be per-bay roof art (a roof slab with skylights and fire holes drawn north of the eave) and per-bay plume art (the plumes are one stamp; two bays are flipped to break the rhythm). Still: `evidence/yard29/plate_vs_game_front_32ppm.png`.
- **The snake does not come out of a fire mouth**: the line starts at the door section a few metres south of the facade; joining it to the burst mouth needs one more span drawn into the opening. Still: `evidence/yard29/plate_vs_game_mid_snake_32ppm.png`.
- **Own-colour wrecks or darker ones**: the four wrecks lifted over the i55 impression keep their own paint (yellow forklift, white scrap and appliances, as in the plate), but sit lighter than the n28 look (luminance contrast 29 to 55 % of i20). They still take the dusk grade; what they skip is the print pass that used to darken them. Default kept as own colour; the alternative is one value, `over_print_shade` (`785d96bc9`, `d2285992b`, mutate `f5898d1b2` 10 killed / 11; absent = today, no row carries it; key absent renders pixel-identical). Contrast against i20: 0.6 gives forklift 103 / skip 87 / fridges 91 %, 0.5 gives 110 / 94 / 100 % (all within the 10 % bar). Trade-off seen at 0.6: the fridge bank, crate and skip sit down into the floor, but the forklift loses its yellow (the plate's is yellow). To adopt: `"over_print_shade": 0.5` in `arched_line`. Film: masters `n29/yard/overprint_shade_today_vs_05_32ppm.mp4` (today | 0.5, mid yard fight, 23.0 s, 1920x1080, 60 fps). Stills: `evidence/yard29/impression_props_shade05_mid_32ppm.png` (today | 0.5), `evidence/yard29/impression_props_shade_mid_32ppm.png` (today | 0.6), `evidence/yard29/impression_props_shade_fridges_64ppm.png`; numbers in `evidence/yard29/impression_props.md`.
- **i55 and the printed floor detail**: i55 hazes ground decals (tyre marks, bay lines, stains) printed under the impression; the wrecks are lifted over it now. Lowering the tint again is the one value (`arched_line.ground_impression.tint`); a draw-order change is the code route. Still: `evidence/yard29/floor_i20_vs_i55_mid_32ppm.png`.

## Merge notes
- Yard-only paths: `project/boot/prologue/**` (new `prologue_roof_glow.gd` + `.gdshader`, `prologue_yard_overprint.gd`, `prologue_yard_dressing.gd`, one line in `prologue_game.gd`), `project/data/tables/prologue_yard_dressings.json` + its schema (new optional `roof_glow` and `over_print_shade` keys, light kind `yard_hall_mouth_wall`), `prologue_yard_paint.gd` (`skin_tint` member), art under `project/boot/prologue/art/arched_line/`, `tools/art/prologue_yard_{hall_tall,spans,spans_layout}.py` + tests, `project/dev/prologue_yard/yard_{dusk_capture,stills}.gd`, `project/tests/unit/test_prologue_*`.
- Shared, append-only: `docs/decisions.md`, `steam/ai-provenance/2026-11.jsonl` (17 lines). No `KNOWN_FLAGS` change, no debt baseline change.
- No replay, tape, pilot or scenario digest moved: every change is visual (over-print, lights, facade art); pilots identical on five seeds after each item.
- Root `JOURNAL.md` / `REPORT.md`: keep the yard lane's own on an add/add conflict.

## Next steps
- Per-bay roof and plume art for the hall (the roof slab north of the eave), and one span into the burst mouth so the line comes out of the fire.
- Ground decals under the i55 impression: draw-order or a lower tint (`evidence/yard29/impression_props.md`).

## Builder ledger
| tag | model | minutes | verdict |
|---|---|---|---|
| floor-i55 | Sonnet | 48 | accepted |
| hall-art | Opus | 74 | accepted |
| hall-finish | Opus | 51 | accepted |
| belt-snake | Opus | 66 | accepted |
| belt-finish | Sonnet | 25 | accepted |
| hall-polish | Opus | 63 | accepted |
| prologue-film | Sonnet | 22 | accepted |
| impression-props | Sonnet | 13 | accepted |
| span-order | Sonnet | 23 | accepted |
| impression-evidence | Sonnet | 26 | accepted |
| gate-lamp | Sonnet | 33 | accepted |
| film-tool | Sonnet | 34 | accepted |
| overprint-shade | Sonnet | 20 | accepted |
| decisions-shade | Sonnet | 2 | accepted |
| shade-film | Sonnet | 4 | accepted |
| lamp-film | Sonnet | (running) | |

What I would brief differently:
- Give the lane's Godot slot lock an owner field (the builder's tag and a long-lived pid such as its node process, not a shell that exits), and forbid deleting a lock whose tag is not your own: three builders removed another's lock this run.
- Send every film through `tools/art/prologue_yard_film.mjs` from the first brief (it now makes 1080p movies through runGodot); two early calls used a raw `$GODOT_BIN` or `--path project`.
- Give one builder the whole evidence tail of an item (pilots, stills, film, decisions line) in the same brief as the change: the split hall-finish / hall-polish and belt-snake / belt-finish calls re-read the same context twice.
- Ask for a 64 px/m crop of every place two over-print layers meet before the commit: the span-under-fridges order fault was caught only by my look after the props move.
