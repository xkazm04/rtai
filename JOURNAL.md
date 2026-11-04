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
- 17:33 scenarios gate on a8e01890+: 46 ran, 0 failed (exit 0). 17:35 full unit gate: 938 passed, 0 failed. NOT RUN this iteration: the evidence gate (run.mjs), frame cost.

NEXT:
1. Run `node tools/evidence/run.mjs --no-bench` on n5-look (lint, unit, scenarios already green this iteration); fix anything red.
2. Frame cost of the riso layer (bench lock, d5_cost_run.gd / D5 cost at 64 px/m vs `--look=today`), against registry `shader-budget-authoring` (read the subject first).
3. Tune toward the target: paper warmth (age / age_floor in world_riso), stain mottle at 32 px/m; keep blood the only deep red; a 64 px/m three-way with r2_a5; check the full director reel kill chapters (longer --quit-after, ~4 min) for regressions.
4. Then item 2: the alley stage (`res://dev/arena/` station or arena site, 48 px/m).
- Registry `shader-budget-authoring` read (for NEXT 2). Rules to apply when costing: state the class budget, the share consumed and the headroom in one sentence (both halves named); state every feature's cost next to a cheaper substitute and what it gives up (here: the plate pass's 2 extra screen fetches vs dropping the sliver; fibre's 4 lattice fetches vs reusing the tooth's mottle); cost the combination, not the parts. d5-city's bench put look_d5 world at 0.447 ms cumulative at 64 px/m (evidence/d5-city/13-bench).

## Iteration 2 (17:36-18:36, BUILD)
- 17:38 tuning toward r2_a5's warm stained sheet. FRICTION `world_riso.age_floor 0.5` was a no-op: the d5 zoom ramp already ages the page 0.5 at 32 px/m (page_age = max(age x amount, age_floor)); reverted to 0.
- First stain try (stain_scale 0.011, one octave) read as big rounded-square blobs (lattice shape); fixed with two octaves (0.024 + x3.7) and a tide line, stain_k 0.6 -> 0.35.
- New riso keys: `tan_k` 1.0 (light neutral ground x TAN 0.92/0.875/0.8, under the actors) and `stain_k` 0.35 / `stain_scale` 0.024. Paper at 32 px/m: 231/214/191 -> 208/189/158 (target 149/131/109). Cream peds, cars and cops pop more on the darker ground. Blood untouched (stains are neutral, tan only on neutral pixels).
- Composites: `gtai-masters/n5/look/print-3way-city-{32,64}ppm-it2.png` (today | it2 | r2_a5).
- 17:47 look goldens unblessed run: only riso-carrying frames moved (junction d5-48 5.84, auto-48 5.71, auto-56 4.31; block auto-64 7.81 / night 6.03); every d1/d4 frame mean 0.00. Re-blessed (9a39a701), DECISION lines in docs/decisions.md (tan sheet + stains; re-bless).
- MILESTONE 0d975f81 (riso paper), 9a39a701 (goldens), 152b0aad (cost harness + evidence).
- 17:55 frame cost: `dev/showcase/riso_cost.gd` (RisoCostRun on the D5 cost frame, 64 px/m, 16 rigs). CONTENDED (another lane's Godot rendering): d4 0.230 / d5 0.188 / riso 0.148 / d5 0.138 / riso 0.176 ms GPU median, so the noise (~0.1 ms) is above the riso delta; reported as unresolved < 0.05 ms, plus the static fetch count (evidence/look/01-print/cost/README.md). Registry shader-budget-authoring applied: class budget (16.6 ms frame, no separate post budget), share (< 1 %), headroom, a cheaper substitute per feature and what it gives up.
- FRICTION `--check-only` on the launcher missed a parse error in the loaded run script (float(Variant) is a warning-as-error): the launcher hung with no output. Now the launcher quits 1 when the script fails to load; check-only the run script itself too.
- 18:05 FRICTION (and a correction): the dev arena ignored `--look=` (only boot/world.gd reads it), so iteration 1's arena "today | riso" clip showed riso twice and its note was wrong. Fixed 4c42f589 (arena_game sets view.print_stage.look_id); re-filmed 40 s A/B, 76 % of pixels differ, the fight identical tick for tick (kills, blood, cop blue read the same). Old clip deleted, frames.json corrected.
- MILESTONE item 1 evidenced: 3-way city 32/64 (it2), pan shimmer (it1, world-locked lattice: the tan/stain terms use the same world coords), arena fight A/B 40 s, 64 px/m still, cost (CONTENDED), goldens re-blessed with decisions lines.
- 18:12 gates (unit + scenarios) started on 4c42f589+docs.

### Alley stage design (item 2; the registry rule applied: depth-ordered-layered-art)
- Area `alley` in arena.json at x 41..50, y -23..32 (9 x 55 m, east of the range/pit, overlaps nothing); `arena_station.schema.json` area enum + "alley".
- Station file `data/tables/arena_stations/look.json` (lane look, station `alley`, script `res://features/alley/alley_hook.gd`):
  props = `wall_high` building-edge strips on both long sides (2 m deep, broken by recessed doorways so the edge line is not a ruler), `cover_high` dumpsters (the city's dumpster art), `cover_low` trash-bag piles (solid, low). No `enemy` spawns (outside the pit they become dummies).
- AlleyHook: owns an ArenaPit instance (zone = alley inset 3 m, points = 3 spawns at the north end + 3 at the south end, so cops come in from both ends; waves 2,+1, max 6, gap 2.0 s), stepped in hook.step, write_state folds wave/kills into the replay hash. Check stage.pit reset on Rivet's death -> reset ours too.
- AlleyDecor (view, attach_view): data table `data/tables/alley_decor.json` (puddles: ink-dark ovals with a cream highlight edge; a chain-link fence along the side lot = fine 45-degree crosshatch with posts, against a wall so no collision is needed; fire escapes = landings + zigzag stair treads seen from straight above; the building edges' roof line). Puddles under the cast; fire escapes ABOVE the cast (measured: 3 m+ high, always over a 1.8 m fighter -> one order, no interlock), placed over the wall strips with <= 0.8 m overhang so they never hide a fighter for long.
- `--arena=alley` in arena_game = `--start=alley` + `--ppm=48` (the close-up zoom). Bot: AlleyBot (copy ArenaPitBot's aim/fire loop against the hook's standing list) for the 20 s clip beside r2_a6.
- Risk: new solid props in the shared arena may move the arena scenario replay hashes -> run scenarios; if they move, record a decisions line and re-bless deliberately (or keep the alley's walls only when the station is wanted).
