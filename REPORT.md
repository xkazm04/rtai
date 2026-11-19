# n19 lane gfx: graphics polish, native and the digests (DRAFT, session 5, 03:40)

Branch `n19-gfx`, cut from `int-n19` at `28302bd3c`. Director Claude Opus 5.5, builder GPT-6.2 Astra.
Evidence root: `C:/Users/kazda/kiro/gtai-masters/n19/gfx/` (written M below). Gate (snapshot, mid-night): `gate: PASS` at `030352b1d`, `build/gate/030352b1d48b/gate.json` (lint 19/19, unit 2,976 with 2 skips, scenarios 55, parity exact over 1,200 steps, bake matches). Final gate with `--reels` after the freeze: TODO.

## What works

| Item | Commits | Evidence | Number |
|---|---|---|---|
| 1 Zones drive the traffic | `0f11a6936`, `f94ca6118`, `49146d65f`, `b22af79bb`, `de01ecf7c`, `b095bdf0c` | `M/zones/docks-vs-downtown-top-64.png` (best, 10 s read), `M/zones/districts3-top.png`, `M/zones/docks3-top-64.png` | seed 91, 150-frame in-view census: docks vans+pickups 53 %, taxis 1 %; downtown taxis 40 %; mixed identical before/after. Same seed and tick, 64 px/m, in view: docks 1 van + 2 pickups, downtown 3 taxis + 1 sedan (all moving). No digest moved (sim hash omits car variants). |
| 2 Far cops draw cop rows (anim NEED 22:12) | `b9cddfe91`, `ca6438e84`, `2e1fa4d76` (6 junction goldens) | `M/farcop/top-32-cop-details.png`, `farcop/*-before-after.png` | heat 3 seed 18 tick 90, 16 px/m top: 70 civilian row-7 -> 33 patrol + 37 riot. Replay final `7571fcfe027f9994`, 60 s `cbeb734ff9b97c41`, parity exact: unchanged. |
| 3A Baked crowd contact shadow | `268960380`, `1c4183544` | `M/contact/A-compare-tilt70-64ppm-t31-32-33.png`, `contact/item3a-contact-tilt70-32ppm.mp4` | tilt 70: rig and baked bounds 30x18 px (32 px/m), 59x34 px (64 px/m); baked carries 100.17 % of the rig's darkening. |
| 3B Heads under tilt | none needed | `M/contact/B-tilt70-p70-64ppm-t60.png`, `contact/B-heads.json` | 13/13 street heads (SWAT, patrol, riot, thug, 9 civilians) already draw cards at both pitches. |
| 4 Docks roof wedges | `6ead32adc`, `77ad43790`, `8519afcd4`, `e5872048b`, `df39aece8` | `M/gen/yard_compare_tilt70_64ppm_t150.png`, `gen/item4-apron-tilt70-32ppm.mp4`, `gen/apron_edge_before_tilt70_64ppm_t150.png` | a 3 m loading apron where a docks yard meets a warehouse's north wall (v34), marked by a bollard row (v35): walkers turn short of the wall, no ink wedge. 813 apron tiles in 46 docks chunks; v35 moved 46/48 docks chunks, downtown and mixed 0; sim digests unchanged. Mutate dock_painter changed lines 11/12, v35 18/19. |
| 5 Zebra rule | `08db28411` | `project/tests/unit/test_city_zebra_clear.gd`, `M/gen/zebra-closest-64ppm.png`, `M/gen/zebra-gaps-v35.json` | 0 / 3712 zebra cells under a solid over 256 chunks; a planted fault fails with the chunk and zebra named. Closest call citywide: 3.46 m (downtown bollards, chunk (7, 10)); docks 3.73 m (a planter by the cold-store warehouse); no solid within 2 m of any crossing. |
| Tilted city draws repeatably (found while making item 4's sheets) | `030352b1d` | `M/tilt-11-REPORT.md`, `gen/apron_edge_before_tilt70_32ppm_t150.png` | lifted canvas items of neighbouring 64 m quadrants shared a z band and drew in pool order, so the same seed, tick and camera could stack a container over or under a warehouse roof. Now a world-quadrant draw index (lifted views only). Reversed pool history: 33,475 px changed before, 0 after. Mutate changed lines 11/12 (survivor order-preserving). |
| anim NEED part 1: baked crowd body carries its slot | `0dc71557a` | `M/tilt-11-REPORT.md` | custom.y = slot + 1 on every baked people body (native + GDScript), tested at slots 0/15/511 across a rigged slot. No look golden moved (16/16 captures, 0 changed pixels); parity exact; mutate 3/3 GDScript, 4/4 native. Invisible alone: on a rehearsed anim + gfx merge the baked people keep the rig heights at the 16-rig switch (tilt 70, 64 px/m: 115 / 118 / 122 px; anim alone 101 / 104 / 107), `M/merge/crowd-switch-merged-64ppm.png`. |
| 3A cost, measured | `3a69fe5a0` (dev probe) | `M/cost-12-REPORT.md`, `M/bench/crowd-contact-cost.json` | interleaved in one process, ON / OFF (old blob) / ON again, 24 rounds x 60 frames, 400-person heat-3 riot at tilt 70, 32 px/m, 1080p: native writer +0.0003 ms [CI95 -0.0005, +0.0011] against an A/A floor of 0.0034 ms; viewport GPU +0.004 ms [-0.002, +0.010] against a floor of 0.021 ms; viewport CPU +0.007 ms against 0.103 ms. All below the noise floor (not zero). 345 contacts per frame (the blob drew 363: it also shadowed rigged and fallen people). CONTENDED (10/6 other Godot processes), debug editor build. |
| 6 Heat-3 bench re-run | none (measurement) | `M/bench-10-REPORT.md`, `M/cost-12-REPORT.md` Part B | two runs, both exit 0. 02:43: p99 6.399 ms, 1 % low 127 fps, hitches >25 ms 3, >50 ms 0. 04:54-05:07 (lock, 20 min quiet wait): p99 5.702 ms, 1 % low 150 fps, worst frame 40.7 ms, hitches >25 ms 20, >50 ms 0 (unexplained 0), rigs p99 1.305 ms. The 20 hitches are all `present` waits (game 0.01 ms, render CPU/GPU under 0.6 ms, the rest waiting on the swapchain), not frame work. Still CONTENDED: 2-9 other runs active in the second, 6-16 Godot processes in the first; the machine never went quiet tonight. |

## What does not

- 3C Corpse heads over kerb barriers at tilt 70: reproduced here (seed 5, tick 900, riot cop 3002); the fault sits in `project/features/arena/prop_lying.gd` `patch` (ai lane). NEED filed 00:30 with a red GUT case (`M/contact/C-NEED.md`); ai fixed it on `n19-ai` (`71b0c85f0` red test, `35264793b` fix, `0925e0399` evidence, mutate 12/12). Not on this branch, so no after frame from gfx: it lands at the merge.

## What blocked or slowed you

- Astra `gen` call killed at my 00:51 session handover (background shell child): ~25 min of its work unreported, mutate scores re-asked. Fixed by launching every later call detached (WMI `Win32_Process.Create`).
- Astra `polish` hit the 75 min cap with no final message: report re-asked by --resume.
- A non-repeatable tilt-70 frame (02:41) made one apron sheet lie about a container. Finding the cause and fixing it took one call (tilt11, about 20 min of it). It was a real draw-order fault, now fixed (`030352b1d`).
- merge13 bounced after 2 min on my own brief (it said stop on any non-golden conflict; the debt baseline has a repo resolver). The resume took 26 min.
- The machine was never quiet: 6-16 other Godot processes in every bench run (other lanes' mutate runs, another project's worktrees). Every performance number tonight is CONTENDED. Bench and rig bench under the lock: about 35 min.

## Calls for the owner

1. **Docks roof wedges: layout, not occlusion** (item 4). Built: a 3 m loading apron where a docks yard meets a warehouse's north wall, marked by the quay bollards (v35). Walkers turn short of the wall, so no roof wedge can form. The other way: change the shared occlusion and silhouette ink, which would touch every district, downtown included. Recommended: keep the apron. Pair: `M/gen/yard_compare_tilt70_64ppm_t150.png` (wedge before, clean after), `M/gen/apron_edge_before_tilt70_32ppm_t150.png` (unmarked v34 apron vs bollards).
2. **How strong the district traffic mix is** (item 1). Built from the zone data as it stood: docks 53 % vans and pickups and 1 % taxis, downtown 40 % taxis. A stronger or weaker mix is one data edit in `project/features/city/gen/city_zone.gd` (`car_art`), and it moves no digest. Recommended: keep it. Still: `M/zones/districts3-top.png`.
3. **The far crowd's contact shadow is rings, not a blob** (item 3A). Built: the baked crowd draws the rigs' contact rings scaled by hip height, so nothing pops at the 16-rig switch. The old round blob comes back with contact hips of zero. Recommended: keep the rings. Clip: `M/contact/item3a-contact-tilt70-32ppm.mp4` (feet inset at 64 px/m).

## Merge notes

- Digests: items 1 and 2 moved no sim, replay or parity digest (decisions `city/spawner-zone-cars`, `city/far-cop-rows`). Item 4 re-baked the GTCH golden hash list twice: GENERATOR_VERSION 34 (decision `city/zones-v34-loading-apron`), then 35 (bollards). On merge, if another lane bumped GENERATOR_VERSION, take the higher number + 1 and re-bake (`res://dev/bake_city.gd`, then `-- --check`).
- Look goldens re-blessed for item 2: `project/tests/golden/look/{d4-48ppm,d5-48ppm-ov,d5-64ppm-ov,auto-48ppm-ov,auto-56ppm-ov,auto-64ppm-ov}.png` (decision `look/junction-crowd-rows`). They pass on `28302bd3c` and `f94ca6118` and first cross at `b9cddfe91` (item 2): moved by item 2 alone.
- anim x gfx merge, rehearsed tonight (int-n19 + n19-anim `3232206dc` + n19-gfx `7229660b4`, temp worktree, removed after; `M/merge-13-REPORT.md`, section Resume):
  - **The crowd switch fix needs both lanes.** At tilt 70, 64 px/m, slot 15, rig at ticks 31-32, baked at 33: anim alone shrinks the baked people to 101 / 104 / 107 px (hat / riot / overalls). The merged tree holds the rigs' 115 / 118 / 122 px. Sheet: `M/merge/crowd-switch-merged-64ppm.png`. gfx's half is `0dc71557a` (slot + 1 in the body custom.y).
  - **Conflicts: six.** Five look goldens plus `tools/debt/baseline.json`.
  - **Debt: lint goes red on the merged tree** after `node tools/debt/merge_baseline.mjs`: `project/dev/sim grew from 923 to 1091 lines` (base 725; anim adds `far_cop_rows.gd`, gfx adds `far_cop_frame.gd` and `zone_car_census.gd`; each lane fits its own baseline). Fix at the merge: `node tools/debt/debt.mjs --accept-regression="n19 anim + gfx dev probes in dev/sim"` (dev-only evidence probes), or drop one far-cop probe (anim's and gfx's both measure item 2). `M/merge/resume/debt-sides.json`.
  - **Look goldens: re-bless seven on the merged revision, not five.** The five conflicted (`auto-48ppm-ov`, `auto-56ppm-ov`, `auto-64ppm-ov`, `d4-48ppm`, `d5-48ppm-ov`) plus `d4-64ppm` and `d4-48ppm-night`. Those two fail against both sides (far-pixel 2.35 % and 2.54 % against the 2 % limit) because the two lanes' crowd changes add up. Neither lane changed those two, so they still hold the base PNG. The eight goldens only anim changed pass against anim's PNG, and `d5-64ppm-ov` (only gfx changed it) passes against gfx's; git takes those sides by itself. Table: `M/merge-13-REPORT.md`; merged renders `M/merge/goldens/`, `M/merge/resume/look/outside-conflicts/`.
  - **Noir (anim NEED part 2):** apply `M/merge/anim-need-part2.patch` after both merges (two files; forward and reverse apply-check pass; 18 noir frames render, crowd inked).
  - **Merged-tree gates with the patch and re-blessed goldens:** fast unit 3,002 passed, 2 skipped; scenarios 55; parity exact over 1,200 steps; bake `--check` matches; lint red only on the debt ratchet above.
- `tools/debt/baseline.json` conflicts with n19-anim too (anim `b472095b6` x gfx `3a69fe5a0`): run `node tools/debt/merge_baseline.mjs` inside the merge, then `node tools/debt/debt.mjs --check` (rehearsal: `M/merge/conflicts.json`).
- 3C: merge n19-ai's `prop_lying.gd` fix; re-check seed 5 tick 900 tilt 70 on the merged revision.
- Native rebuilt (render.cpp row_of + crowd contact): every merge must rebuild the DLLs (debug + release) and `--import`.
- Out-of-lane call site: `project/boot/city_characters.gd:60` (one line, after the crowd bake).
- `030352b1d` (tilted quadrant draw order) touches `project/features/city/view/chunk_view.gd` only: lifted views get a world-quadrant `canvas_item_set_draw_index`; the top view is untouched, so no top golden moves.
- anim's `c07cab306` closed our triangulation NEED (`rig_cast_shadows.gd`); nothing to do here.
- Dev-only probe `project/dev/bench/crowd_contact_cost.gd` (`3a69fe5a0`) declares its own `KNOWN_FLAGS` (no `launch_args.gd` line) and raises the debt baseline by its dev lines (reason recorded).

## Next steps

1. Merge order for gfx: after anim, then apply anim NEED part 2 (the noir crowd include) and re-render the five shared look goldens on the merged revision after the DLL rebuild.
2. Re-run the heat-3 bench and the rig bench on a quiet machine (no other lanes, no other project's worktrees) to drop CONTENDED; every number tonight carries it.
3. Draw art for the docks loading apron (paint, kerb line) so the 3 m stop zone reads as a place, not only a bollard row.
4. The baked crowd still draws the hat-man smaller with a flat-cut crown at the 16-rig switch on n19-gfx alone; anim's slot-scaled cell plus our slot write fix it only together (check on the merged tree).

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
| cost12 | 52 | accepted (dev cost probe `3a69fe5a0`: 3A below the A/A floor; heat-3 bench retry PASS, still CONTENDED) |
| merge13 | 2 | bounced (my brief said stop on any non-golden conflict; the debt baseline has a resolver) |
| merge15 (resume) | 26 | accepted (merged crowd-switch sheet, golden table, noir patch, merged gates; report only) |
| eye14 | 19 | accepted (docks vs downtown 64 px/m sheet, zebra closest-call sheet; dev-only `cbb8cebf3`; evidence folders tidied, 53 files to `_scratch/`) |
