# JOURNAL - night lane n5-look (2026-11-04/05)

Branch `n5-look` cut from main `a1275c82`. Evidence: `evidence/look/` (lane) + `C:\Users\kazda\kiro\gtai-masters\n5\look\` (clips, frames.json).

## Iteration 1 (16:43-17:43, BUILD)
- Read TARGETS.md + r2_a5 / r1_a1. Today's print: look_d4 world pass + look_d5 overlay (`look_profiles.json` overlays row `d5_world`, amount 0.5 at 32 px/m, 1 at 64), params `assets/shaders/look_d5.params.json`.
- Long cast shadows today: `data/tables/cast_shadows.json` building class offset_m 1.1 m (35 px at 32 px/m) down-right, hatched by look_d5_shadow; props 0.2-0.45 m, cars 0.4 m.
- Plan item 1: riso features (halftone dots, per-plate misregistration on coloured plates, paper fibre, toned-down grain) inside look_d5.gdshader behind a `riso` dial (0 = today bit-identical), a second params key `world_riso` and overlay row so `--look=auto` = new and `--look=today` = the old auto (A/B one flag).
- 16:50 MILESTONE before frames: `evidence/look/01-print/before/city-{0,4}-{32,64}ppm.png` (city_frame, seed 91, --fixed-fps 60).
- Registry rules applied (shader-budget-authoring, by the lane's reading of the existing d5 budget): no new full-screen pass, the riso layer reuses the D5 overlay's one BackBufferCopy; 2 extra screen fetches (plate) + ~5 lattice fetches; early-out when riso = 0.
- 16:58 FRICTION first fibre try (unbroken ridged value noise) read as a contour map on the paper; fixed by a coarse fragment mask + higher frequency (fibre_scale 0.13).
- 17:05 measured: asphalt mean RGB 80.5/71.2/71.7 -> 81.0/71.6/72.1, paper 211.7 -> 211.9 (halftone keeps the mean tone; the flatter look is the grain 0.5 -> 0.3).
- DECISION riso layer inside look_d5 behind `world_riso.riso` dial; `--look=today` = old print. DECISION building cast 1.1 -> 0.45 m. (docs/decisions.md)
- Composite: `gtai-masters/n5/look/print-3way-city-32ppm.png` (today | middle ground | r2_a5). Gap to the target: paper warmth (sepia) and stain mottle; next tuning.
- 17:13 MILESTONE commit ab742c31 (riso layer + building cast 0.45 m). Unit gate: 937/938 first run, the one failure was test_look_overlay expecting a single overlay row; rewritten (two rows, one look id per row) and green; lint green.
- 17:16 look goldens: junction moved 2.9-3.3 mean (under gate), block site over the gate; with main's tables restored the block site passes (1.3-1.8), so only this change moved it. Re-blessed (a8e01890) with a decisions line.
- 17:22 shimmer: 10 s pan at 32 px/m, residual after camera shift identical today vs riso (1.29 %, actors). World-locked halftone holds under the snapped camera.
- FRICTION `--arena` is not a launch flag here: the arena is `res://dev/arena/arena.tscn` (project.godot main_scene.showcase). `--write-movie` works on it for in-game clips.
- 17:26 arena director reel 25 s, both looks, side by side in masters; same fight tick for tick; no SCRIPT ERROR.
- NOT RUN this iteration: scenarios gate, evidence gate (run.mjs), frame cost.

NEXT:
1. Run the scenarios gate + `node tools/evidence/run.mjs --no-bench` on n5-look; fix anything red.
2. Frame cost of the riso layer (bench lock, d5_cost_run.gd / D5 cost at 64 px/m vs `--look=today`), against registry `shader-budget-authoring` (read the subject first).
3. Tune toward the target: paper warmth (age / age_floor in world_riso), stain mottle at 32 px/m; keep blood the only deep red; a 64 px/m three-way with r2_a5; check the full director reel kill chapters (longer --quit-after, ~4 min) for regressions.
4. Then item 2: the alley stage (`res://dev/arena/` station or arena site, 48 px/m).
