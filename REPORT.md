# n19 lane gfx: graphics polish, native and the digests (DRAFT, session 5, 03:40)

Branch `n19-gfx`, cut from `int-n19` at `28302bd3c`. Director Claude Opus 5.5, builder GPT-6.2 Astra.
Evidence root: `C:/Users/kazda/kiro/gtai-masters/n19/gfx/` (written M below). Gate (snapshot, mid-night): `gate: PASS` at `030352b1d`, `build/gate/030352b1d48b/gate.json` (lint 19/19, unit 2,976 with 2 skips, scenarios 55, parity exact over 1,200 steps, bake matches). Final gate with `--reels` after the freeze: TODO.

## What works

| Item | Commits | Evidence | Number |
|---|---|---|---|
| 1 Zones drive the traffic | `0f11a6936`, `f94ca6118`, `49146d65f`, `b22af79bb`, `de01ecf7c`, `b095bdf0c` | M `zones/districts3-top.png`, `zones/docks3-top-64*.png` | seed 91, 150-frame in-view census: docks vans+pickups 53 %, taxis 1 %; downtown taxis 40 %; mixed identical before/after. No digest moved (sim hash omits car variants). |
| 2 Far cops draw cop rows (anim NEED 22:12) | `b9cddfe91`, `ca6438e84`, `2e1fa4d76` (6 junction goldens) | M `farcop/top-32-cop-details.png`, `farcop/*-before-after.png` | heat 3 seed 18 tick 90, 16 px/m top: 70 civilian row-7 -> 33 patrol + 37 riot. Replay final `7571fcfe027f9994`, 60 s `cbeb734ff9b97c41`, parity exact: unchanged. |
| 3A Baked crowd contact shadow | `268960380`, `1c4183544` | M `contact/A-compare-tilt70-64ppm-t31-32-33.png`, `contact/item3a-contact-tilt70-32ppm.mp4` | tilt 70: rig and baked bounds 30x18 px (32 px/m), 59x34 px (64 px/m); baked carries 100.17 % of the rig's darkening. |
| 3B Heads under tilt | none needed | M `contact/B-tilt70-p70-64ppm-t60.png`, `contact/B-heads.json` | 13/13 street heads (SWAT, patrol, riot, thug, 9 civilians) already draw cards at both pitches. |
| 4 Docks roof wedges | `6ead32adc`, `77ad43790`, `8519afcd4`, `e5872048b`, `df39aece8` | M `gen/yard_compare_tilt70_64ppm_t150.png`, `gen/item4-apron-tilt70-32ppm.mp4`, `gen/apron_edge_before_tilt70_64ppm_t150.png` | a 3 m loading apron where a docks yard meets a warehouse's north wall (v34), marked by a bollard row (v35): walkers turn short of the wall, no ink wedge. 813 apron tiles in 46 docks chunks; v35 moved 46/48 docks chunks, downtown and mixed 0; sim digests unchanged. Mutate dock_painter changed lines 11/12, v35 18/19. |
| 5 Zebra rule | `08db28411` | `project/tests/unit/test_city_zebra_clear.gd` | 0 / 3712 zebra cells under a solid over 256 chunks; a planted fault fails with the chunk and zebra named. |
| Tilted city draws repeatably (found while making item 4's sheets) | `030352b1d` | M `tilt-11-REPORT.md`, `gen/apron_edge_before_tilt70_32ppm_t150.png` | lifted canvas items of neighbouring 64 m quadrants shared a z band and drew in pool order, so the same seed, tick and camera could stack a container over or under a warehouse roof. Now a world-quadrant draw index (lifted views only). Reversed pool history: 33,475 px changed before, 0 after. Mutate changed lines 11/12 (survivor order-preserving). |
| anim NEED part 1: baked crowd body carries its slot | `0dc71557a` | M `tilt-11-REPORT.md` | custom.y = slot + 1 on every baked people body (native + GDScript), tested at slots 0/15/511 across a rigged slot. No look golden moved (16/16 captures, 0 changed pixels); parity exact; mutate 3/3 GDScript, 4/4 native. |
| 3A cost, measured | `3a69fe5a0` (dev probe) | M `cost-12-REPORT.md`, M `bench/crowd-contact-cost.json` | interleaved in one process, ON / OFF (old blob) / ON again, 24 rounds x 60 frames, 400-person heat-3 riot at tilt 70, 32 px/m, 1080p: native writer +0.0003 ms [CI95 -0.0005, +0.0011] against an A/A floor of 0.0034 ms; viewport GPU +0.004 ms [-0.002, +0.010] against a floor of 0.021 ms; viewport CPU +0.007 ms against 0.103 ms. All below the noise floor (not zero). 345 contacts per frame (the blob drew 363: it also shadowed rigged and fallen people). CONTENDED (10/6 other Godot processes), debug editor build. |
| 6 Heat-3 bench re-run | none (measurement) | M `bench-10-REPORT.md` | gate exit 0: p99 6.399 ms, 1 % low 127 fps, hitches >25 ms 3, >50 ms 0. Still CONTENDED: 6-16 other Godot processes in every run (other lanes' mutate runs and another project's worktrees); the machine never went quiet tonight. |

## What does not

- 3C Corpse heads over kerb barriers at tilt 70: reproduced here (seed 5, tick 900, riot cop 3002); the fault sits in `project/features/arena/prop_lying.gd` `patch` (ai lane). NEED filed 00:30 with a red GUT case (M `contact/C-NEED.md`); ai fixed it on `n19-ai` (`71b0c85f0` red test, `35264793b` fix, `0925e0399` evidence, mutate 12/12). Not on this branch, so no after frame from gfx: it lands at the merge.

## What blocked or slowed you

- Astra `gen` call killed at my 00:51 session handover (background shell child): ~25 min of its work unreported, mutate scores re-asked. Fixed by launching every later call detached (WMI `Win32_Process.Create`).
- Astra `polish` hit the 75 min cap with no final message: report re-asked by --resume.
- A non-repeatable tilt-70 frame (02:41) made one apron sheet lie about a container. Finding the cause and fixing it took one call (tilt11, about 20 min of it). It was a real draw-order fault, now fixed (`030352b1d`).
- The machine was never quiet: 6-16 other Godot processes in every bench run (other lanes' mutate runs, another project's worktrees). Every performance number tonight is CONTENDED. Bench and rig bench under the lock: about 35 min.

## Calls for the owner

1. **Docks roof wedges: layout, not occlusion** (item 4). Built: a 3 m loading apron where a docks yard meets a warehouse's north wall, marked by the quay bollards (v35). Walkers turn short of the wall, so no roof wedge can form. The other way: change the shared occlusion and silhouette ink, which would touch every district, downtown included. Recommended: keep the apron. Pair: M `gen/yard_compare_tilt70_64ppm_t150.png` (wedge before, clean after), M `gen/apron_edge_before_tilt70_32ppm_t150.png` (unmarked v34 apron vs bollards).
2. **How strong the district traffic mix is** (item 1). Built from the zone data as it stood: docks 53 % vans and pickups and 1 % taxis, downtown 40 % taxis. A stronger or weaker mix is one data edit in `project/features/city/gen/city_zone.gd` (`car_art`), and it moves no digest. Recommended: keep it. Still: M `zones/districts3-top.png`.
3. **The far crowd's contact shadow is rings, not a blob** (item 3A). Built: the baked crowd draws the rigs' contact rings scaled by hip height, so nothing pops at the 16-rig switch. The old round blob comes back with contact hips of zero. Recommended: keep the rings. Clip: M `contact/item3a-contact-tilt70-32ppm.mp4` (feet inset at 64 px/m).

## Merge notes

- Digests: items 1 and 2 moved no sim, replay or parity digest (decisions `city/spawner-zone-cars`, `city/far-cop-rows`). Item 4 re-baked the GTCH golden hash list twice: GENERATOR_VERSION 34 (decision `city/zones-v34-loading-apron`), then 35 (bollards). On merge, if another lane bumped GENERATOR_VERSION, take the higher number + 1 and re-bake (`res://dev/bake_city.gd`, then `-- --check`).
- Look goldens re-blessed for item 2: `project/tests/golden/look/{d4-48ppm,d5-48ppm-ov,d5-64ppm-ov,auto-48ppm-ov,auto-56ppm-ov,auto-64ppm-ov}.png` (decision `look/junction-crowd-rows`). They pass on `28302bd3c` and `f94ca6118` and first cross at `b9cddfe91` (item 2): moved by item 2 alone.
- anim NEED (02:12, `n19-anim/evidence/crowd-pop/NEED-gfx.md`): part 1 (slot + 1 in the people body custom.y) lands here (brief 11 Part 0). Part 2 (the noir crowd shader `project/assets/shaders/look_noir_crowd.gdshader` includes `crowd_atlas_vertex.gdshaderinc`; `NoirFrames._ink_crowd()` calls `configure_material`) cannot land on this branch: both live only on `n19-anim`. Apply it after merging anim. Part 3: five goldens changed on both branches (`auto-48ppm-ov`, `auto-56ppm-ov`, `auto-64ppm-ov`, `d4-48ppm`, `d5-48ppm-ov`): re-render them on the merged revision after the DLL rebuild, and take neither side's PNG.
- 3C: merge n19-ai's `prop_lying.gd` fix; re-check seed 5 tick 900 tilt 70 on the merged revision.
- Native rebuilt (render.cpp row_of + crowd contact): every merge must rebuild the DLLs (debug + release) and `--import`.
- Out-of-lane call site: `project/boot/city_characters.gd:60` (one line, after the crowd bake).
- TODO

## Next steps

TODO

## Astra ledger

| Call | Minutes | Verdict |
|---|---|---|
| zones | 40 | accepted |
| farcop (resume) | 45 | accepted |
| zonesfilm (resume) | 21 | accepted |
| contact | 35 | accepted |
| gen | 26 | accepted (killed at handover before its report) |
| polish | 75 | bounced-partial (cap, no final message) |
| polish2 (resume) | 30 | accepted (code); its apron sheets bounced (a spurious container change) |
| bench10 | 59 | accepted (measurement only, no commit) |
| tilt11 | 37 | accepted (anim NEED part 1, tilted draw-order fix, honest apron sheets, gate PASS) |
| cost12 | TODO | TODO |
