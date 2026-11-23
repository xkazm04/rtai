# REPORT - n25 lane `yard`: the destroyed factory (2026-11-23)

Branch `n25-yard` from `main` `b3f4727c0`. Worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`. Director: Opus; builder: Astra (all product changes). Owner's word: "Concept art for the destroyed factory next, then rebuild the yard from it."

Gate: `node tools/gate/run.mjs --rev=HEAD` on `0dba79170` (the last code commit; every later commit touches only inert paths: `evidence/**`, `JOURNAL.md`, `REPORT.md`): `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n25-yard\build\gate\0dba79170e71\gate.json` (lint 19 checks; unit 3804 passed, 0 failed, 2 skipped; scenarios 67 passed; parity bit for bit over 1200 steps, planted mutation caught at step 629; selftest; release-compile 931 loaded, 0 failed).

## What works
| Item | Evidence | Number |
|---|---|---|
| Three concept directions for the wrecked appliance factory (A the line torn out through the loading doors, B burnt paint shop under a fallen saw-tooth roof, C crushed stock and toppled cranes), each a wide view + a tilt-70 inset with Rivet and a cop | `C:\Users\kazda\kiro\gtai-art\factory-n25\out\`, notes `factory-n25\notes.md`; masters `concepts\plate_*.png`, film `concept_plates_a_b_c.mp4` | 3 plates, 27.0 s film |
| Director's pick A (`torn_line`): readable floor with ochre bay lines, long waist-high cover with a story, landmarks at the script's places | JOURNAL 01:07, `factory-n25\notes.md` PICK | - |
| Five scenery piece sheets drawn at about 70 degrees (cover-line, cover-machines, front-hall, ground-decals, ground-concrete-b; concrete v1 rejected as a slab grid) and cut by a repo tool | `tools/art/prologue_yard_cut.py` (+ pytest), `evidence/yard/cuts-torn_line.png` | 28 pieces |
| Yard dressing as data: `prologue_yard_dressings.json` rows `plain` and `torn_line`; `yard.dressing` in `prologue_stage.json` picks one; `--yard-dressing=<id>` overrides | `project/boot/prologue/prologue_yard_dressing.gd`, `project/data/tables/prologue_yard_dressings.json` | default `torn_line`, `plain` one value away |
| The walkable area, spawns and triggers did not move: seed-7 pilot byte-identical with the new yard | `evidence/yard/pilot-before.json` vs `pilot-torn_line.json`: `cmp` 0 | 0 bytes differ |
| Cover art fills its collision footprints (no invisible walls) | `evidence/yard/footprints_mid_64ppm.png`, `test_prologue_yard_footprints.gd` | all 11 rows >= 85 %, lowest 89.7 % |
| Wrecked floor: one continuous concrete swatch, nine floor marks, oil drag trail, scorch, tyre streaks; chain-link fence on posts and a bent sliding gate leaf | `evidence/yard/pairs/{gate,mid,harbor}_{32,64}ppm.png` | no tile grid |
| End card void fixed: the street, pavements and frontage run 40 m past both edges; the works continue east into a loading lot | `evidence/yard/end-card-before.png` vs `end-card-after.png` | - |
| Before/after films from one fixed camera at three places (plain left, torn_line right, 960 px crops of the same camera) | masters `pair_{mid,gate,harbor}_32ppm.mp4`, `pair_{mid_64ppm_t2290,gate_64ppm_t6400,harbor_64ppm_t8460}.png`, `stills_sheet.png`, west close-up `west_64ppm_torn_line.png`; manifest `evidence/yard/films.json` (sha256 of every file). All re-recorded 05:44-06:09 from the final art (call 06) | 3 films, each h264 1920x1080 60 fps 26.67 s, 1600 frames (ffprobe) |
| The prologue played through on the new yard | masters `prologue_torn_line.mp4` (seed-7 pilot to the end card), `excerpt_wave1.mp4`, `excerpt_wave2.mp4`, `excerpt_end_card.mp4` | 176.8 s (10610 frames); excerpts 30 / 30 / 15 s from ticks 2858 / 5496 / 9710, 1920x1080 60 fps; seed-7 result and hit log byte-identical to the 04:24 recording |
| Outside the yard dressed as the works going on: a west loading annex, an east loading lot and a walled receiving lot across Harbor Road, all fitted between the city roof blocks | `evidence/yard/west_32ppm.png`, `evidence/yard/pairs/harbor_32ppm.png`, `project/tests/unit/test_prologue_yard_outside.gd` | 80 stamps clear all 7 roof blocks, min clearance 0.10 m |
| Gate posts drawn as solid steel; fence bays, posts and the parked gate leaf measured by a test | `evidence/yard/pairs/gate_32ppm.png`, `project/tests/unit/test_prologue_yard_fence.gd` | 5 fence tests |
| Boss view (tilt 55, Mulroney engaged at the gate): hall fronts face the gate, no wrong-way lean, so no separate 55-degree art set | `evidence/yard/gate_tilt55_32ppm.png` | tick 6000 |
| Mutation score of the yard draw code | `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard_paint.gd --max=20` and `.../prologue_yard_fence.gd --max=20` | paint 18/(18+0); fence 15/(15+3); dressing loader 11/(11+0) |
| Frame time plain vs torn_line under the bench lock (held 04:15:39-04:23:18), 60 s uncapped, 3 rounds A B | `evidence/yard/frame-cost.md`, `evidence/yard/frame-cost.json` | p50 torn_line minus plain -0.601 ms [-1.009, -0.231]; p99 -1.455 [-3.126, +0.787]; no measurable cost. Plain rounds 2 and 3 had other-process CPU over 60 %, so this is no speed-up claim; clean round 1: p50 2.312 -> 2.081 ms |

## What does not
- **Only direction A is built.** B (burnt paint shop) and C (crushed stock) exist as plates only: no piece sheets, no dressing rows.
- **The fence wire is the existing `cage_mesh` (quest art `project/features/quest/art/collect_call/cage_mesh.png`) mounted on steel posts and rails by `tools/art/prologue_yard_perimeter.py`**, not a chain-link drawn for this yard; at 64 px/m it reads as a city cage (masters `pair_gate_64ppm_t6400.png`).
- **One piece set, drawn at about 70 degrees.** No 55-degree set: the boss-view still at 55 (`evidence/yard/gate_tilt55_32ppm.png`) shows no wrong lean, but that capture's Godot log names missing p55 variants for some city props (pre-existing city art, not the yard's).
- Fence mutate leaves 3 survivors, all cosmetic (line 12 panel orientation, 35 highlight removal, 36 cap thickness).
- Frame cost: plain rounds 2 and 3 ran with other processes over 60 % CPU, so the measurement says "no measurable cost", not "faster".
- The full film and the wave excerpts are large: about 52 Mbit/s for the full film; the wave excerpts needed CRF 20 and a 59 Mbit/s cap (the follow camera moves the floor grain every frame).
- The dressing is art only: wreck pieces block only where the script already had cover; nothing new blocks shots or movement (by the lane contract the walkable area did not move).

## What blocked or slowed you
- Image runner stalled before the copy to `./out` on 2 of 3 plates and all 5 piece sheets (images copied by hand from `~/.codex/generated_images/`): about 10 min.
- Call 04 stopped on the debt ratchet (`dev_loc`, the film entry) because `tools/debt/baseline.json` was not in its allowlist: one bounce, about 20 min.
- The first masters films went out of date when call 05 changed the art at the edges (west annex, lot refit, steel gate posts): one extra film-only call (06).

## Calls for the owner
1. **Which factory?** I picked A (the line torn out). B and C are plates in masters `concepts\`. Switching back to the old clean yard is `"dressing": "plain"` (or `--yard-dressing=plain`); B or C would need their own piece round and dressing row.
2. **Fence: reused cage mesh or a factory chain-link sheet?** Tonight the yard fence reuses the quest `cage_mesh` wire on new steel posts and rails (masters `pair_gate_64ppm_t6400.png`, right half). A dedicated sheet is one piece round and a re-run of `tools/art/prologue_yard_perimeter.py` into `project/boot/prologue/art/torn_line/fence_panel.png`.
3. **How much of the works shows outside the fight?** The west annex, the east loading lot and the walled receiving lot across Harbor Road are dressing only, no collision (`evidence/yard/west_32ppm.png`, `evidence/yard/pairs/harbor_32ppm.png`). If they pull the eye off the fight, they are entries in the `outside` list of the `torn_line` row and can be cut.

## Merge notes
- `prologue_stage.json`: only `yard.dressing` changed (`plain` -> `torn_line`). No `MILESTONE yard-shape`: walkable area, spawn and trigger points unchanged.
- Path served our NEED (`--yard-dressing` in the prologue entry's `KNOWN_FLAGS`) on `n25-path` `3aead09f1`.
- Shared files touched: `docs/decisions.md` (appended lines), `steam/ai-provenance/2026-11.jsonl` (appended), `tools/debt/baseline.json` (through the debt tool).
- Root `JOURNAL.md`/`REPORT.md`: add/add conflict with path's; keep each lane's own.

## Next steps
1. If the owner overrules the pick: a piece round for B or C (prompts in `C:\Users\kazda\kiro\gtai-art\factory-n25\notes.md`) and a new dressing row; the loader, cut tool and tests take it as data.
2. A factory chain-link and gate sheet to replace the reused quest `cage_mesh` wire.
3. Wreck pieces as real cover (collision) where the fight wants more: a path-lane decision, because it moves the walkable area and needs `MILESTONE yard-shape`.
4. Kill the 3 fence mutants when the fence art changes.

## Astra ledger
| Call | Tag | Minutes | Verdict |
|---|---|---|---|
| 01 | dressing | 57 | accepted |
| 02 | torn-line | 52 | accepted |
| 03 | yard-faults | 43 | accepted |
| 04 | films-cost | 18 | bounced (debt NEED) |
| 04b | films-cost (resume) | 33 | accepted |
| 05 | lot-tests | 39 | accepted |
| 06 | films-final | 44 | accepted |

What I would brief differently: put `tools/debt/baseline.json` (through the tool, with `--accept-regression`) in every allowlist that adds dev code; ask for a footprint coverage test in the first art call, not the third; record the owner films only after the last art call (calls 04 and 06 recorded the same films twice).
