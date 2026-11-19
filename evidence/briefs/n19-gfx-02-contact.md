# Brief n19-gfx-02-contact: shadows and contact (probe first, then fix)

Lane `gfx`, night run n19, NEW session (fresh context). You build; the director reviews every diff and frame. Engine polish only. Branch n19-gfx; read `git log --oneline -12` and `AGENTS.md` first. Time box: commit each finished sub-item as it lands; if you run short, A first, then C, then B.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time. `--rendering-driver d3d12` for anything that renders; any windowed run takes `--position 0,1440`. Kill only your own PIDs.
- Never push, never read other `n19-*` worktrees.

## Ownership (strict)
gfx owns `project/features/city/**`, `project/features/police/**`, `native/**`, shaders and look profiles. `project/features/characters/**` (rigs, `rig_cast_shadows.gd`, `rig_depth_*`, crowd atlas, ped/SWAT art) belongs to the `anim` lane; `project/features/arena/**` (incl. `prop_crowd_occluders.gd`, `prop_lying.gd`) to `ai`. Do the fix on the gfx side (`features/city/view/crowd_layers.gd`, `city_occlusion.gd`, `city_crowd_occlusion.gd`, sim render, shaders). If the only sane fix is in another lane's file, a one-line call site is allowed: name it in your report; anything bigger: stop, write what is needed (file, why, the patch idea) in your report, the director files the NEED.

## Three sub-items. For each: PROBE first (a frame that shows the fault today, or proof it is already gone), then fix, then the same-tick after frame.

### A. The far, baked crowd floats (no contact shadow matching the rigs')
The full rigs (16 nearest) draw a contact shadow (`project/features/characters/rig_cast_shadows.gd`: under the shipped view row, cast_k < `CONTACT_BELOW_K` draws a soft contact ellipse, `CONTACT_R_HIPS` 0.5, `CONTACT_FLAT` 0.62, `CONTACT_SLIDE_HIPS`, ink `SHADOW` Color(0.09,0.075,0.106,0.38)). The baked crowd is drawn by the sim render layers (`project/features/city/view/crowd_layers.gd`, it already has a "people shadows" MultiMesh layer: find out what it draws today and at which views). What the director already read (verify, do not trust): native `native/sim_core/src/render.cpp` `fill_render` (~line 84) writes an `RL_PED_SHADOWS` blob for EVERY ped/cop, rigged or not: a round 25.6 px (`SH`) blob offset (+2, +3) px, ink `INK_PED`, the rigged `continue` comes after it. The GDScript twin is in `project/features/city/sim/sim_render.gd`. So the probe must answer: is the blob drawn at all today (which views, which band, is it hidden under tilt / combo / by a look profile), why the owner sees the far crowd floating, and whether a rigged person shows the blob AND the rig's contact ellipse (double shadow). The rig's contact is a flattened (0.62) ellipse of radius hip*0.5 slid along the cast dir; the blob is round and fixed. Any change to the buffer written by render.cpp must change both writers identically (parity) and rebuild native debug+release.
Make the baked crowd's contact shadow match the rig's in size, offset, flatness and ink at the LOD switch, so a person crossing the 16-rig boundary does not pop. Read the shadow values from the rig's constants (reference `RigCastShadows.CONTACT_*`, do not copy numbers) so they cannot drift.
Evidence: same tick, a person crossing the rig/baked boundary: 3-frame strip before (rig) / at switch / after (baked), before and after the fix; 32 and 64 px/m; top and tilt 70. A unit test pinning that the baked shadow size equals the rig's for the same height.
Cost: `"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=...` before and after, **under the bench lock**: create `C:/Users/kazda/kiro/gtai-n19/bench.lock` exclusively (if it exists and is younger than 20 min, skip the bench and say so; older = stale, delete it), delete it right after. If you cannot get the lock, run it anyway and label the numbers CONTENDED.

### B. Heads without drawn cards read top-down under tilt (SWAT, six ped heads)
`docs/day/2026-11-06/chars/REPORT.md` line ~25 claims p55 head cards for SWAT and all ped heads landed (`rig_card_sets.gd`). Probe: at tilt 70 and p55, 64 px/m, render each street-cast head type (SWAT, patrol cop, riot helmet, thug, each ped head) and list which still draw a plan (top-down) head. If none: a contact sheet proving it and stop (no change). If some: report which; this is `anim` art, so do NOT make art; write the NEED (which heads, which view) in your report.

### C. Corpse heads draw over kerb barriers at tilt 70 (depth-order fault)
Known since 2026-11-07: `docs/day/2026-11-07/view/JOURNAL.md` ~line 1436-1450 and `docs/day/2026-11-08/world/JOURNAL.md` ~98-102: the city block, tilt 70, 32 px/m, seed 5, tick 900: two dead cops lying just north of the kerb barrier draw heads/shoulders over the barrier's top face. Measured cause then: after the 90-tick hold the corpse leaves its rig for the crowd atlas (actors canvas over the world canvas); `CityCrowdOcclusion` patches lying crowd bodies (`LYING_HALF_M`) only behind buildings, not behind the kerb barriers; `CityOcclusion.extra` (fed by the arena floor view) may since cover it. Reproduce at that seed/tick first (frame). If still there, fix it in `city_crowd_occlusion.gd` / `city_occlusion.gd` (lying crowd bodies are patched behind every tall prop in `extra`, not only buildings). Unit test that fails before the fix. Same-tick after frame.

## Evidence
Frames to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/` (not git); use `tools/film/` (`compare.mjs` for side-by-sides, `sheet.mjs`). Before/after at the same tick and zoom; label each PNG name with item, view, ppm, tick. Write `C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/frames.json` (best first, `[{file,title,ppm,before,note}]`).

## Acceptance (run all, quote results)
- `node tools/lint/lint.mjs` green; `node tools/tests/run_unit.mjs --changed` then the full run green; scenarios green; `node tools/tests/run_parity.mjs` green.
- Look goldens: run the look golden selftest (`project/dev/selftest/look_golden.gd`, see `project/tests/golden/README.md`). Re-bless ONLY a golden your change moved on purpose, and name it (file + frame) in your report and in the decision line.
- `node tools/gate/quick.mjs` before each commit; one commit per sub-item, staged per path.
- One `docs/decisions.md` line per landed sub-item: `- [2026-11-18] DECISION city/<slug> (n19 gfx item 3<A|C>): what, why, what rejected.`
- After committing, `node tools/mutate/mutate.mjs --file=<the main changed file> --max=20`; quote killed/(killed+survived).

## Report back
Per sub-item: probe result (frame path), fix (files, commit hash) or why none, tests, bench numbers (with LOCKED or CONTENDED), goldens re-blessed, mutate score, frames.json path.
