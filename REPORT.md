# n19 lane gfx: graphics polish, native and the digests (DRAFT, session 5, 03:40)

Branch `n19-gfx`, cut from `int-n19` at `28302bd3c`. Director Claude Opus 5.5, builder GPT-6.2 Astra.
Evidence root: `C:/Users/kazda/kiro/gtai-masters/n19/gfx/` (written M below). Gate: TODO (`node tools/gate/run.mjs --rev=HEAD`, quote line + gate.json).

## What works

| Item | Commits | Evidence | Number |
|---|---|---|---|
| 1 Zones drive the traffic | `0f11a6936`, `f94ca6118`, `49146d65f`, `b22af79bb`, `de01ecf7c`, `b095bdf0c` | M `zones/districts3-top.png`, `zones/docks3-top-64*.png` | seed 91, 150-frame in-view census: docks vans+pickups 53 %, taxis 1 %; downtown taxis 40 %; mixed identical before/after. No digest moved (sim hash omits car variants). |
| 2 Far cops draw cop rows (anim NEED 22:12) | `b9cddfe91`, `ca6438e84`, `2e1fa4d76` (6 junction goldens) | M `farcop/top-32-cop-details.png`, `farcop/*-before-after.png` | heat 3 seed 18 tick 90, 16 px/m top: 70 civilian row-7 -> 33 patrol + 37 riot. Replay final `7571fcfe027f9994`, 60 s `cbeb734ff9b97c41`, parity exact: unchanged. |
| 3A Baked crowd contact shadow | `268960380`, `1c4183544` | M `contact/A-compare-tilt70-64ppm-t31-32-33.png`, `contact/item3a-contact-tilt70-32ppm.mp4` | tilt 70: rig and baked bounds 30x18 px (32 px/m), 59x34 px (64 px/m); baked carries 100.17 % of the rig's darkening. |
| 3B Heads under tilt | none needed | M `contact/B-tilt70-p70-64ppm-t60.png`, `contact/B-heads.json` | 13/13 street heads (SWAT, patrol, riot, thug, 9 civilians) already draw cards at both pitches. |
| 4 Docks roof wedges | `6ead32adc`, `77ad43790`, `8519afcd4`, `e5872048b`, `df39aece8` | M `gen/yard_compare_tilt70_64ppm_t150.png`, `gen/item4-apron-tilt70-32ppm.mp4`, `gen/apron_edge_before_tilt70_64ppm_t150.png` | a 3 m loading apron where a docks yard meets a warehouse's north wall (v34), marked by a bollard row (v35): walkers turn short of the wall, no ink wedge. 813 apron tiles in 46 docks chunks; v35 moved 46/48 docks chunks, downtown and mixed 0; sim digests unchanged. Mutate dock_painter changed lines 11/12, v35 18/19. |
| 5 Zebra rule | `08db28411` | `project/tests/unit/test_city_zebra_clear.gd` | 0 / 3712 zebra cells under a solid over 256 chunks; a planted fault fails with the chunk and zebra named. |
| 6 Heat-3 bench re-run | none (measurement) | M `bench-10-REPORT.md` | gate exit 0: p99 6.399 ms, 1 % low 127 fps, hitches >25 ms 3, >50 ms 0. Still CONTENDED: 6-16 other Godot processes in every run (other lanes' mutate runs and another project's worktrees); the machine never went quiet tonight. |

## What does not

- 3C Corpse heads over kerb barriers at tilt 70: reproduced here (seed 5, tick 900, riot cop 3002); the fault sits in `project/features/arena/prop_lying.gd` `patch` (ai lane). NEED filed 00:30 with a red GUT case (M `contact/C-NEED.md`); ai fixed it on `n19-ai` (`71b0c85f0` red test, `35264793b` fix, `0925e0399` evidence, mutate 12/12). Not on this branch, so no after frame from gfx: it lands at the merge.
- 3A cost not isolated: four paired rig-bench runs, all CONTENDED and all over the 1 ms p99 hard limit both before and after (50 people p50 0.801 -> 0.815 and 0.761 -> 0.843 ms; 200 people 0.758 -> 0.896 and 0.799 -> 0.843 ms). RigStress times posing, not the native contact draw. Unmeasured, not zero.

## What blocked or slowed you

- Astra `gen` call killed at my 00:51 session handover (background shell child): ~25 min of its work unreported, mutate scores re-asked. Fixed by launching every later call detached (WMI `Win32_Process.Create`).
- Astra `polish` hit the 75 min cap with no final message: report re-asked by --resume.
- TODO

## Calls for the owner

TODO

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
| polish2 (resume) | TODO | TODO |
