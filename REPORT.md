# REPORT - lane d5-city (branch `d-city`), day run 2026-11-03

Mission: make the real generated city at gameplay zoom look like the D5 hero scene (H2) and target T1.
Branch head at report time: `d267935` plus this report. 23 feat/fix commits sit on top of main.
Every performance number here is **CONTENDED**: seven lanes shared one GPU all day.

Paths are relative to the lane cwd unless they start with `masters/`, which means
`C:\Users\kazda\kiro\gtai-masters\day-d5\d5-city\`. I checked every cited path at 17:31.

## For the 18:00 page
- Owner frames: `masters/frames.json`. It has 15 entries. Every `file` and `before` it names exists (0 missing, checked 17:31).
- Ladder: `masters/ladder.png` shows 7 real-city foci, before (merged main) and after at 32/48/64 px/m, beside T1 and H2. The copy in the repo is `evidence/d5-city/ladder-iter6.png`.
- Evidence index: `evidence/d5-city/README.md` (adopted, rejected and owner calls).
- Camera-break rejects: 0 all day. Changes rejected by eye: 8, listed below.

## What works (each with evidence)

**Gates of record.** At `bba930d` on a clean tree, all of these PASS: lint 13/13, unit 335/335, scenarios 8/8, parity (1200 steps exact, planted mutation caught) and selftest (look goldens 11/11 worst 0.78, block 5/5, world lock 0 %).
- Evidence: `evidence/d5-city/evidence-bba930d/` (lint, unit-tests, scenario-tests, parity, selftest JSON).
- `git diff bba930d HEAD -- project tools native` is empty, so these gates stand for HEAD.
- Lint also ran green at `9ccc7af` (pre-commit hook).
- The replay golden `cbeb734ff9b97c41` and parity did not move all day: no sim data changed.

**1. Doctrine** (`e9b9323`, `f0cedb3`), evidence `evidence/d5-city/01-doctrine/` and `06-siren/`:
- `palette.json` gets `blood` #A30509, `blood_dark` #540005, `cop_blue` #3A4766 (luma 0.28, next to the charcoal's 0.29) and `cop_blue_hi` #4F86E0.
- Vermilion loses its `cop` use and the `vehicles` layer.
- The accent audit counts all four inks plus "vermilion on cop". Its debt rows are `cop_vermilion_32/48/64`.
- `noir` is a row in `look_profiles.json` (opt-in, never in auto).
- The siren strobes `cop_blue_hi`.

**2. D5 as the city's look**:
- **D5 overlay from 32 px/m** (`bf43a68`): amount 0.5 at 32, 0.75 at 48, 1 at 64.
  - Readability gate against D4 on 3 real foci: edge energy 96-98 % of D4, ink +1 %, paper dE to T1 2.9-9.5 (D4: 12.5-14).
  - Evidence: `evidence/d5-city/18-d5-earlier/` (`gate-32ppm.txt`, strips).
- **Pixel-snapped world camera** (`a4f3d56`): on a real-city pan at 48 px/m the mean change per frame is 0.02 (0 % px flipped) snapped, against 6.9 (8.2 %) sub-pixel.
  - Evidence: `evidence/d5-city/17-snap-cam/` (`swim-crop-3x.png`, `swim.jsonl`).
- The `--look=` overrides are kept.

**3. Hero-scene pieces moved into the generator and the view**. Each has before/after real-city frames in its folder:
- the hatched cast-shadow lengths for props and parked cars (`03-prop-shadows/`);
- the 7 landmark roofs drawing the D5 plates (`04-d5-roofs/`);
- a parapet ink core on every building (`05-parapets/`);
- the zebras moved to T1's place, kerb to kerb outside the crossing, with a plain junction box (`07-zebras/`, `12-open-roads/`);
- lane dashes that stop 2 m short of the zebras (`08-dash-stop/`);
- no edge lines and no lane arrows (`12-open-roads/`, `16-no-arrows/`);
- wall-side clutter (`09-wall-clutter/`);
- plaza dressing with no vermilion barrels (`14-plaza/`);
- the inked D5 lamp post (`15-lamp/`), also on two junction corners (`19-corner-lamps/`);
- H2's STRIKE and union-fist road paint (`20-story-paint/`).

**4. Roof coarseness toward T1**:
- **Finding:** T1 is not denser than our city. It is coarser.
  - T1 sits at about 38 px/m. Its buildings span about 15 m and carry 5-6 big items each, about 0.03 items/m².
  - Ours were 8.4 m roofs at about 0.17 items/m², with items half T1's size.
  - The working is in JOURNAL.md, iteration 4.
- **What I built:** 4 Codex plates at 80 px/m (inside the locked texel density). Each has a provenance line in `steam/ai-provenance/2026-11.jsonl`.
  - Three 16.4 m plates (A/B/C) cover the 2 x 2 interior of 35 % of blocks, cycling A-B-C along each block row (`2b2fa98`, `fba312e`, `4ed459e`).
  - One 16.4 x 8.4 m plate sits in the long street-facing slots (`b08a010`).
  - Evidence: `evidence/d5-city/22-big-roof/`, `23-big-roof-b/`, `25-big-roof-c/`, `27-long-t1/`.
  - Focus 10 (`masters/i5/city-10-32ppm.png`) is the closest street-level frame to T1 so far.

**5. Proof**:
- The 3+ real-city foci at 32/48/64 px/m, before and after, beside H2 and T1: `masters/ladder.png`.
- The 48 px/m car drive: `evidence/d5-city/10-drive/` and `masters/drive/i5/drive.720.png`. This tree has no player car, so the frame comes from the bench drive route.
- D5 cost per pass at 64 px/m, GPU median, 16 rigs: d4 0.068, then part overlays 0.269, then look_d5 world 0.447, then rig shadows 0.611 ms. Evidence: `evidence/d5-city/13-bench/README.md`.
- D5 overlay cost on the real city at 32 px/m, best (lightest) baseline: +0.51 ms GPU (0.640 to 1.148). Earlier runs measured +0.90 and +0.875 ms on heavier baselines, so part of that was contention. At 48 px/m it is +0.27 to +0.42 ms.
  - Evidence: `evidence/d5-city/21-overlay-cost/`, `24-bench-end/`, `28-bench-final/README.md`.
- **Bench.** All runs were CONTENDED, under the lock.

| run | code | result | evidence |
|---|---|---|---|
| 16:00 | `61e9222` | PASS: p99 3.16 ms | `24-bench-end/` |
| 16:42 | `1e7caef` | FAIL: p99 CPU 8.7 ms | `28-bench-final/` |
| 17:05, pass 2 | same code as 16:42 | inside every §20 limit: worst p99 4.54 ms, 1 % low 132 fps, worst swap 14.4 ms | `29-bench-stabilize/` |

The 16:42 riot scenario is stationary and streams nothing, yet it regressed as much as drive48. That points at machine load, not at the new plates. Treat it as supporting evidence, not proof.

## What does not work, or is not proven
- **No idle full-gate bench verdict.** The 17:05 run lost pass 1 (its JSON was overwritten) and pass 3 (killed by my too-short 540 s timeout). The branch has only "pass 2 inside limits, CONTENDED", so it should not be called a bench PASS yet.
- **Package v9 print (`d5c`) is not adopted.** At 32 px/m it erases the hatched cast shadows, and its street edge drops car outlines. Evidence: `evidence/d5-city/02-d5c-print/`, `masters/cmp-d4-vs-d5c-city-2-32ppm.png`.
- **D5 ground tiles are only partly done.**
  - Joints, zebras, dashes, kerb line and paint are in.
  - The D5 sidewalk tile is not: on its own it patchworks against the D4 kerb tiles (`evidence/d5-city/rejected-d5-sidewalk-32ppm.png`). It needs kerb and corner tiles 7-10 redrawn in the same joint language first.
- **Rejected by eye (8), all reverted:**
  1. package v9 at 32 px/m;
  2. the D5 sidewalk alone;
  3. the plain D5 lamp (`evidence/d5-city/rejected/`);
  4. axis-aligned corner signals (`evidence/d5-city/rejected/`);
  5. full D5 at 32 px/m (`18-d5-earlier/`);
  6. a flipped corner lamp (`19-corner-lamps/`);
  7. the chalk robot decal (`20-story-paint/`);
  8. a 2 x 2 plate rotated 180° (`22-big-roof/`).

  A what-if with a 70 % 2 x 2 share was also not adopted (`26-whatif-share/`).
- **The biggest gap left against T1 is road width.** Our streets are about 17 m kerb to kerb; T1's are about 10 m. Frames at 48 px/m are mostly asphalt. This is sim data, so I did not change it alone (see owner calls).
- **Cops still show vermilion in the frames.** It is tracked as accent debt. The rigs and crowd atlas belong to d5-cast, and the cruiser belongs to vehicles.

## What blocked me, and for how long
- 09:04-10:04 (about 1 h): iteration 1 died on a billing error before its first turn.
- About 13:10-15:40 (about 2.5 h): no lane session ran. The cause is not recorded in my journal. The 2 x 2 roof built at 13:10 was committed at 15:4x, after its gates.
- **The bench lock** cost about 45 min of waiting in total, and no idle number was possible all day:
  - 11:37: d5-combat;
  - 12:50-13:00: vehicles, then slice-play;
  - 16:38: d5-cast;
  - 16:46-16:54: d5-combat;
  - 17:11-17:18: collisions, then slice-play.
- **Friction** (fixed or worked around):
  - A parse error hung a windowed run. I now pre-check with `--headless --check-only`.
  - A unit test was flaky on shared thread loads. Fixed in `000087f`: no sub-threads.
  - A generator "before" frame needs a re-bake, because `bake --check` does not rewrite the chunks.
  - The look goldens shift with the prewarm wall-clock budget (recorded in `docs/decisions.md`).

## Owner calls for the 18:00 sync
1. **Road width:** about 17 m against T1's 10 m. The what-if is `evidence/d5-city/11-road-width-mock/` (a labelled concept). A change means sim data, a decisions line, a replay/parity re-bless, and agreement from the vehicles and slice-play lanes.
2. **Plazas:** 12 % of blocks are plazas. T1 has none. Keep them?
3. **Roof coarseness:** 2 x 2 buildings are on 35 % of blocks, plus the long plate. T1 is that coarse almost everywhere. Should the share go up?
4. **D5 at gameplay zoom:** it is 0.5 at 32 px/m and 0.75 at 48. Going back to pure D4 is one number in `look_profiles.json`.

## Requests still open (for the Director to relay)
- **REQUEST 1 -> d5-cast:** cop rigs and crowd atlas to `cop_blue`/`cop_blue_hi`, plus the blood and blue gates in `print_part.gdshader`. Then delete the debt rows `cop_vermilion_*`.
- **REQUEST 2/4 -> d5-combat:** paint blood in `blood` and `blood_dark` (gate: r >= 0.30, max(g,b) < 0.18 r).
- **REQUEST 3 -> vehicles:** repaint the cruiser accents `cop_blue` and its light bar `cop_blue_hi`.

## Next steps
0. **Bench:** run one idle full-gate bench at the branch head (`node tools/bench/run.mjs`, about 14 min, timeout >= 900 s, no other lane on the GPU) before the branch merges as "bench PASS".
1. **Owner calls:** act on the 4 calls above, road width first.
2. **Long plates:** make 2-3 more T1-scale long plates (same layout-template + `fit_roof.py` route; 4 of about 30 Codex images used). Put long slots on street-facing rows more often.
3. **Overlay cost:** profile the D5 overlay at 32 px/m idle (`hatch 0` / `street_hatch 0` A/B).
4. **Tiles:** redraw kerb and corner tiles 7-10 in the D5 joint language, then retry the D5 sidewalk (13).
