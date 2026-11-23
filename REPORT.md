# REPORT - n25 lane `yard`: the destroyed factory (2026-11-23)

DRAFT (session 3, 03:55): sections marked TODO are filled by the last session after the gate and films.

Branch `n25-yard` from `main` `b3f4727c0`. Worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`. Director: Opus; builder: Astra (all product changes). Owner's word: "Concept art for the destroyed factory next, then rebuild the yard from it."

Gate: TODO `node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path.

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
| Before/after films from one fixed camera at three places (plain left, torn_line right, 960 px crops of the same camera) | masters `pair_{mid,gate,harbor}_32ppm.mp4`, `pair_{mid_64ppm_t2290,gate_64ppm_t6400,harbor_64ppm_t8460}.png`, `stills_sheet.png`; manifest `evidence/yard/films.json` | 3 films, each h264 1920x1080 60 fps 26.67 s (ffprobe) |
| The prologue played through on the new yard | masters `prologue_torn_line.mp4` (seed-7 pilot to the end card), `excerpt_wave1.mp4`, `excerpt_wave2.mp4`, `excerpt_end_card.mp4` | 176.8 s; excerpts 30 / 30 / 15 s, 1920x1080 60 fps |
| Frame time plain vs torn_line under the bench lock (held 04:15:39-04:23:18), 60 s uncapped, 3 rounds A B | `evidence/yard/frame-cost.md`, `evidence/yard/frame-cost.json` | p50 torn_line minus plain -0.601 ms [-1.009, -0.231]; p99 -1.455 [-3.126, +0.787]; no measurable cost. Plain rounds 2 and 3 had other-process CPU over 60 %, so this is no speed-up claim; clean round 1: p50 2.312 -> 2.081 ms |

## What does not
TODO

## What blocked or slowed you
- Image runner stalled before the copy to `./out` on 2 of 3 plates and all 5 piece sheets (images copied by hand from `~/.codex/generated_images/`): about 10 min.
- Call 04 stopped on the debt ratchet (`dev_loc`, the film entry) because `tools/debt/baseline.json` was not in its allowlist: one bounce, about 20 min.
- TODO

## Calls for the owner
1. **Which factory?** I picked A (the line torn out). B and C are plates in masters `concepts\`. Switching back to the old clean yard is `"dressing": "plain"` (or `--yard-dressing=plain`); B or C would need their own piece round and dressing row.
2. TODO (tilt 55 hall blocks, fence sheet)

## Merge notes
- `prologue_stage.json`: only `yard.dressing` changed (`plain` -> `torn_line`). No `MILESTONE yard-shape`: walkable area, spawn and trigger points unchanged.
- Path served our NEED (`--yard-dressing` in the prologue entry's `KNOWN_FLAGS`) on `n25-path` `3aead09f1`.
- Shared files touched: `docs/decisions.md` (appended lines), `steam/ai-provenance/2026-11.jsonl` (appended), `tools/debt/baseline.json` (through the debt tool).
- Root `JOURNAL.md`/`REPORT.md`: add/add conflict with path's; keep each lane's own.

## Next steps
TODO

## Astra ledger
| Call | Tag | Minutes | Verdict |
|---|---|---|---|
| 01 | dressing | 57 | accepted |
| 02 | torn-line | 52 | accepted |
| 03 | yard-faults | 43 | accepted |
| 04 | films-cost | 18 | bounced (debt NEED) |
| 04b | films-cost (resume) | 33 | accepted |
| 05 | lot-tests | TODO | TODO |

What I would brief differently: put `tools/debt/baseline.json` (through the tool, with `--accept-regression`) in every allowlist that adds dev code; ask for a footprint coverage test in the first art call, not the third.
