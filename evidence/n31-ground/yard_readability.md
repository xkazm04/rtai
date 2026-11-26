# n31-32: n30-yard readability bars, main | HEAD

Arms: before = `ba8e470b0` (main), after = `88bc88996` (HEAD product; later commits are docs/evidence only, `git status project/` clean).

## How
Two overlay projects under `build/n31/n31-32/{main,head}/` (git-ignored): a copy of the live `project/` (with `.godot`), `tools/`, `evidence/yard29/`, `versions.toml`. The main overlay then had all 81 files that differ under `project/` (`git diff --name-status ba8e470b0 88bc88996 -- project/`) taken from git at `ba8e470b0` (M files restored, 52 A files deleted); checked byte-equal with `cmp` per file, both overlays. No LFS file was in the diff. An `arched_day` row (day grade, no pools, `floor_glow` dropped, as in `evidence/yard29/hall_polish/temprows.py`) was added to each overlay's own `prologue_yard_dressings.json` only. Captures with cwd = overlay: `node tools/art/prologue_yard_stills.mjs --dusk --dressing=arched_line|arched_day --out=cap/dusk|day` (all four exit 0, SCRIPT ERROR 0), then `python -W ignore -I evidence/yard29/sweep_measure.py cap` from the overlay. No `mem-budget: waiting` lines in any of the four logs (0 minutes waited).

## Table
| measure | main | HEAD | bar | verdict |
|---|---|---|---|---|
| patrol blue outside (retained %) | 80.2 | 79.9 | >= 65 | pass |
| patrol blue inside | 87.7 | 89.9 | >= 65 | pass |
| rifle | 104.5 | 100.4 | >= 95 | pass |
| pellet (shotgun) | 99.0 | 106.9 | >= 90 | pass |
| Rivet luminance delta (mean of exposures) | 0.1340 (10 exposures) | 0.1341 (9 exposures) | HEAD >= main - 0.01 | pass (+0.0001) |
| floor between pools L* | 50.8 | 50.7 | info | |
| pool gain L* (core - between) | 5.7 | 4.5 | info | |

## Cops in view
Dusk frames used: main 5 (outside), 5 (inside), 9 (between); HEAD 7, 10, 9. All > 0, so the day/dusk pairing is right.

## Caveats
- The two arms did not sample the same ticks: main's Rivet exposures are t2858..t6257 (10), HEAD's are t2858..t11762 (9), and the cop/rifle/pellet sample counts differ (rifle 161 px vs 94 px, shotgun 266 vs 283). Item 4 moved the footprints, so frames pick different moments; every bar has wide margin, but individual per-arm numbers (rifle 104.5 vs 100.4, pellet 99.0 vs 106.9, inside 87.7 vs 89.9) are not a controlled A/B of the same pixels.
- One capture per arm; no repeat run, so no noise estimate. Pellet HEAD 106.9 above 100 is a sampling effect of the small mask, not a gain.
- Not measured: the info-only `appliance_delta` and film frames; the 64 px/m views.
