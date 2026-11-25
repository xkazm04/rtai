# n30 decals over the i55 impression: evidence (finished: tyre depth, contrast, bars, film)

Change under test: `5950ceb34` + `ed6b97278` (stain layer, non-ochre torn_line stamps and ochre bay lines print above the i55 impression). Before = `6c32defe4`, after = `aacc0c87e` (same code as `ed6b97278`), i20 = `c649a15d6` (n30 shade05's own i20 stills `build/shade/d05/i20_{mid,gate}_32.png`, not re-rendered).
Renders came from two overlay projects (junctions to this worktree's project, the listed code/table files taken from git at each rev), because `git worktree add` and `git archive` stalled for 20+ min on the 23 000-file repo; both through `runGodot` with cwd = the overlay.

## Pilots
Seeds 7, 3, 11, 21, 42 in one Godot process (`yard_pilot_rows`): ticks, deaths, min_hp, stuck and sha256 IDENTICAL to `evidence/yard30/prologue-yard-pilots-shade05.json` -> `evidence/yard30/prologue-yard-pilots-decals.json`.

## Tyre depth (`decal_over_alpha`, commit `7236d6218`)
Optional `arched_line` row value `"decal_over_alpha": 1.4`: multiplies the tint alpha (clamped to 1) of the tyre-mark stamps (`tyre_turn`, `tyre_sweep`) that print over the impression; absent = 1.0. Scoped to the tyre arts so the stains stay where they were (a multiplier on the stain layer was tried at 1.5: stain 2 went to 152 % / 140 % of before and both bay-line runs fell to 76-86 %, so it was dropped). Pilots seeds 7, 3, 11, 21, 42 in one process: IDENTICAL (`evidence/yard30/prologue-yard-pilots-decals-alpha.json`, vs `prologue-yard-pilots-decals.json`).

Finding: tyre B (the faint wide arcs, box (1330,5,1560,100)) is NOT a decal stamp. Those arcs are drawn in `raised_line/floor_stains.png` (the stain ground layer, tint `ffffff58`, `over_impression`), so the stamp value cannot move it: 76 % at mid, 77 % at gate, unchanged by 1.4. Reaching 100 % there needs the stain layer's alpha at about 1.75x, which pushes stain 2 well over 140 % and costs the bay lines (see above). The bar "every class after >= before" is therefore NOT met for tyre B (and gate bay run 2 at 95 %).

## Decal contrast (method: `evidence/yard30/decal_contrast.py`; tables `decals_over_mid_table.txt`, `decals_over_gate_table.txt`)
Mean |decal - floor ring| luminance, Rec.709 linear, 32 px/m, tick 300, seed 7, after = 1.4 build. Mid camera, after / before:

| decal box | i20 | before | after | after / before | after / i20 |
|---|---|---|---|---|---|
| tyre sweep A | 0.1395 | 0.0792 | 0.0890 | 112 % | 64 % |
| tyre sweep B (stain-layer arcs) | 0.1324 | 0.0680 | 0.0518 | 76 % | 39 % |
| bay line run 1 | 0.1210 | 0.0645 | 0.0663 | 103 % | 55 % |
| bay line run 2 | 0.1210 | 0.0650 | 0.0652 | 100 % | 54 % |
| stain 1 (oil) | 0.1854 | 0.1199 | 0.1493 | 125 % | 81 % |
| stain 2 | 0.0734 | 0.0419 | 0.0497 | 119 % | 68 % |

Gate camera: tyre A 117 %, tyre B 77 %, bay 99 % / 95 %, stain 1 99 %, stain 2 117 % (all stains under 140 %). Floor L* between pools 50.8 (after) vs 51.6 (before).

## Readability bars, both arms (n29 method: `evidence/yard29/sweep_measure.py` on day + dusk captures; before = `6c32defe4` overlay, after = `7236d6218` overlay; the day arm is an `arched_day` row added to each overlay's own table copy, which the first attempt lacked, so its dusk-vs-day pairing was wrong and gave no cops)
| measure | before | after | bar | verdict |
|---|---|---|---|---|
| patrol blue outside (retained %) | 80.4 | 80.3 | >= 65 | pass |
| patrol blue inside | 87.5 | 87.7 | >= 65 | pass |
| rifle | 104.4 | 104.5 | >= 95 | pass |
| pellet (shotgun) | 98.4 | 99.0 | >= 90 | pass |
| Rivet luminance delta (mean of 10 exposures) | 0.1479 | 0.1340 | after >= before - 0.01 | FAIL (-0.0139) |
| floor between pools L* | 51.6 | 50.8 | info | |

Cops are in view in every dusk frame used (cops 5 / 5 / 9). The Rivet delta drop (0.005 to 0.019 per exposure) is not from the tyre value: the stamps draw below the actors, and the arms (6c32defe4 vs 7236d6218) differ by the whole n30 floor work (shade 0.5, decals over the impression), not by this commit alone. Not tuned; the owner decides.

## Film and stills
`C:/Users/kazda/kiro/gtai-masters/n30/yard/decals_over_before_after_mid_32ppm.mp4` (before 6c32defe4 | after, 32 px/m, 1080p60, 23 s, ticks 1757..3136) and `decals_over_64ppm.png`; both in `frames.json`. `decals_over_before_after_mid_32ppm.png` left half now labelled `before: 6c32defe4`. Seen: after, the dark tyre sweep and the oil stains read crisper and the bay lines keep their ochre; the faint wide arcs at the right are fainter than before.

## Not done
Tyre B and gate bay run 2 below before; a before | after crop of tyre B at 64 px/m (only the 32 px/m crop was looked at).
