# REPORT - lane visual-engine (`n-visual`), night 2026-11-02 -> 2026-11-03

Written at 08:15-08:30 in the REPORT phase. No code was changed after 8bd2ec0:
`git diff 8bd2ec0 HEAD -- project tools native` is empty. The evidence stamp is **8bd2ec0**
(`evidence/pof/*.json`, all `status: pass`).

`M` = `C:\Users\kazda\kiro\gtai-masters\night\visual-engine\` (frames, outside git).
The ladder is `M\ladder.png` (1280 x 27482, 54 numbered rows, 00 baseline to 54).
`JOURNAL.md` has the full log, with times, for every claim below.

## Headline

All 7 brief items are built and evidenced on this branch. The visual engine is data-driven:

| Table | What it holds |
|---|---|
| `render_layers.json` | the layers |
| `look_profiles.json` | the looks |
| `palette.json` | the colour doctrine |
| `accent_debt.json` | known accent debt |
| `lights.json` | lights and grades |
| `fx.json`, `fx_triggers.json` | the FX |
| `camera.json` | camera feel |
| `world_markers.json` | world UI |
| `cast_shadows.json` | building shadows |

The selftest gates three things: the golden frames, the colour doctrine (at 2 sites) and world-lock.

**The big caveat:** the art lanes' outputs (n-d4's sheets and atlases, n-d5's `look_d5`) were never merged
into this branch. They were integrated as **capture-only plug-ins** and in **trial merges**. Most of the
engine's "live with real art" state is therefore proven on scratch merges, not on `n-visual` alone (see
"What does not work").

## Gates at the evidence stamp 8bd2ec0

| Gate | Result | Evidence |
|---|---|---|
| lint | 13/13 over 221 files | `evidence/pof/lint.json` |
| unit | 247 passed / 0 failed | `evidence/pof/unit-tests.json` |
| scenarios | 8 passed (`replay_60s` identical) | `evidence/pof/scenario-tests.json` |
| parity | bit-exact over 1200 steps, planted mutation caught at step 629 | `evidence/pof/parity.json` |
| selftest | PASS: junction goldens 11/11 + block 5/5 (worst mean 0.00); accents clean at both sites; world lock 0.00 % at 32/48/64 | `evidence/pof/selftest.json`, `look-golden-result.json`, `accent-audit.json`, `world-lock.json`, `evidence/pof/block/` |

The gates were re-checked at later journal-only HEADs, on identical code:
- lint at 8d4750d;
- unit 247 at 0ea52b9;
- scenarios 8 at 03d79cd.

Re-run commands: `node tools/evidence/run.mjs --no-bench`, or each gate on its own (AGENTS.md table).

## What works (brief item -> evidence)

### 1. Render layer stack as data
- **What:** `project/data/tables/render_layers.json` (gtai.render-layers/1) with `core/render/render_layers.gd`
  and `project/core/render/README.md`.
- **Layers:**
  - world bands: ground, decals, building shadows, props, roofs;
  - actors: people 100, vehicles 200;
  - the canvases: fx, light (grade 0 / lights 100), emissive, world_ui and hud.
- **Test:** `tests/unit/test_render_layers.gd` builds the real city scene and audits it against the
  declared layers.
- **Frames:** `M\01-layers\`. Cars now draw above people, and rigs are no longer under the crowd.
- **Building cast shadows** carry the height cue as a hatched 1.1 m band (`cast_shadows.json`, 55f60d5).
  Frames: `M\34-buildings\`.
- **DEVIATION §20-draw:** a chunk is now 20 canvas items instead of 8. This is logged in `docs/decisions.md`.

### 2. Look profiles as data
- **What:** `look_profiles.json` holds the d1, d4 and d5 rows of every print uniform. Tones come from
  `palette.json` (f5fb578).
- **Zoom blend:** `auto` is pure D4 up to 48 px/m and smoothsteps to D5 at 64 px/m.
- **D5 overlay plug-in:** n-d5's `look_d5` is an overlay pass (`core/render/look_overlay.gd`, 94f6e44).
- **Launch flag:** `-- --look=<id|auto|off>`.
- **Golden frames:** `dev/selftest/look_golden.gd` under `--fixed-fps 60`.
  - 11 junction and 5 block goldens in `project/tests/golden/look/` (21 files, including the `-ov` and
    night goldens).
  - They gate `selftest` at a mean of 4/255 or less.
- **Frames:** `M\02-looks\`, `M\08-d5-overlay\`.
- **Tuned toward the target frame (`d4h2_mock.jpg`):**
  - warm charcoal: the street measures 81,71,72, the same as the mock (aa8a5f7, `M\29-tones\`);
  - aquatint grain inside the washes (2a51fe3, `M\30-mottle\`);
  - page age, solved so the aged street and paper land on the mock's medians (6592ebd, `M\51-age-gains\`);
  - page age also applied to the lights and emissive FX (aa15198, `M\52-age-emissive\`).

### 3. The colour doctrine, enforced
- **Tables:** `palette.json` holds the tokens and the 2 accents, with their allowed uses and layers.
  `core/render/palette_tokens.gd` classifies pixels.
- **Per-layer audit:** `dev/selftest/accent_audit.gd` counts accent pixels per layer. It **gates** the
  selftest through `accent_debt.json` (7222102).
- **The audit runs at 2 sites**, the riot junction and a building block (c89365e).
- **Current numbers:**
  - frame vermilion is 0.93 / 0.95 / 0.25 % at 32 / 48 / 64 px/m (junction), all on actors;
  - 6/6 pedestrian crowd looks are on doctrine.
- **Doctrine by construction:** the world print carries no accent plate (c31574a), so a red prop prints as
  ink density. The block audit found the plaza barrels at 4324-5632 px of world vermilion, now 0.
  Frames: `M\31-block\`, `M\32-world-no-accent\`.
- **Tests:** `test_palette_tokens.gd` covers the classifier. `test_look_profiles.gd` ties every profile's
  world plates to the palette's layer rule (a planted d4 `verm` of 0.5 fails it).

### 4. 2D lighting
- **What:** `lights.json`, `core/render/light_layer.gd` + `light_pool.gd`, and `assets/shaders/light_ink.gdshader`.
  Lights are additive hatched bands on a screen-space canvas.
- **Light kinds:** muzzle, explosion, headlight, siren (vermilion and paper, never red and blue) and fire.
- **Night grade:** `grade_ink.gdshader` re-prints luminance and keeps accents (c31559a).
  - The old multiply erased 100 % of the vermilion-gate pixels at night. The new grade keeps 97-99 %.
  - Frames: `M\37-night\`.
- **In-city lights:** car headlights and sirens at night (`M\38-car-lights\`) and street-lamp pools
  (`M\39-street-lamps\`).
- **Photosensitivity cap:** `max_flash_hz` 3, with fire at 2.5 Hz (5557cfe). This is unit-tested.
- **Cost:**

  | What | 4090 | 2-CU iGPU (1280x800) |
  |---|---|---|
  | full light budget | +0.29 to +1.35 ms | +0.59 ms |
  | night grade | +0.04 ms | +0.40 to +0.46 ms |

  Sources: `evidence/light-cost/`, `evidence/light-cost/night-grade/`.

### 5. FX system
- **What:** `fx.json` (10 kinds), `core/render/fx_system.gd` + `fx_pool.gd` and `fx_ink.gdshader`. Emitters are
  pooled, with a budget per frame.
- **Sheet plug-in:** n-d4's `fx_atlas.png` is used when it is present (267722f). Frames: `M\07-fx-atlas\`.
- **Emissive twin:** emissive kinds draw above the lights (0b60126).
- **Splats:** they sit on the ground-decal band, under the bodies (`M\10-fx-feed\`).
- **Triggers:** `fx_triggers.json` + `core/render/fx_triggers.gd`.
  - In the riot, the CitySim projectile snapshot drives muzzle, casing, impact and splat
    (`features/city/view/city_fx_feed.gd`, 65762d3).
  - F-04 `player_hit` / `player_hit_robo_tazer` fires the crackle (a103850).
  - The crackle has an ink rim so it reads on Rivet (3de7eca, `M\53-crackle-rim\`).
- **Cost:** the feed costs +0.07 ms average after the no-tick skip (9f8c83e, `evidence/fxfeed-ab2/`).
- **Tests:** `test_fx_system.gd`, `test_fx_triggers.gd`, `test_fx_rim.gd`.

### 6. Camera feel
- **What:** `camera.json` + `core/render/camera_rig.gd`.
  - zoom ease between 32, 48 and 64 px/m;
  - shakes and hit-stops as data, with reduced-motion scales.
- **Wired in the game path (7dcb210, 2a50244):**
  - **car look-ahead.** Frames: `M\41-lead\`, `evidence/camera-iter13/lead-showcase-car*.json`.
  - **hit-stop** through `SimClock.hold`. It holds exactly 3 frames in-engine (`lead-showcase-tazer.json`)
    and is replay-safe (decision line).
  - **boss_engaged -> arena 64 px/m.** Frames: `M\42-arena\`, `evidence/camera-iter13/arena-showcase-*.json`.
- **`world_px` fed every frame:**
  - every print shader hashes `FRAGCOORD + world_px`;
  - `tests/unit/test_shader_world_lock.gd` enforces it;
  - `dev/selftest/world_lock.gd` gates 0.00 %.
- **Zoom anchor:** it removes the print swim during zoom eases (`M\43-zoom-swim\`,
  `evidence/camera-iter13/zoom-swim-metric.txt`).
- **`--reduced-motion` launch flag** (204a0c6). Frames: `M\47-reduced\`.

### 7. Performance
- **The cheap rig fix:** the rig pass skips frames with no sim tick. Then came selection decimation and a
  quarter-rate LOD for ranks 8-15, with sub-stepped springs.
- **Riot rig cost per tick:** 0.457 -> 0.338 ms. Sources: `evidence/rig-quarter/`,
  `evidence/bench-*-quarter.json`.
- **Frames:** `M\15-rig-quarter\`, including the motion GIFs.
- **Print pass on the low-end GPU (2-CU iGPU at 1280x800):**
  - early-outs: -45 % (1871a36);
  - grime lattice: -17 % (52bec98);
  - sources: `evidence/pass-cost/`, `evidence/pass-cost/hash-ab/`.
  - The honest low-end figure is a frame of about 3.1 ms GPU, of which the print is about 1.4 ms.
- **Bench, §20 hard limits:** PASS on every run tonight.
  - Latest on this branch: **4d83199**, p99 2.81 ms, 1% low 209 fps, 0 frames over 50 ms, riot rigs p99
    0.448 ms per frame. Sources: `evidence/bench-iter13-contended.txt`, `evidence/bench-*-iter13-contended.json`.
  - 4-lane merged build: p99 2.47 ms (`evidence/trial-merge14/`).
  - The last PoF `bench.json` is `build/evidence/bench.json` at 56d23e7 (p99 3.25 ms, contended, git-ignored).

### Also built
- **PrintStage** (`core/render/print_stage.gd`, d5ac536, 7e3eb68). This is the whole engine as one node for
  non-city views, with `listen()` for the game-feel events. The demo is in `M\44-print-stage\`.
- **A tested patch that moves main's quest 1 onto PrintStage.**
  - Patch: `M\49-quest1-v2\quest1-on-print_stage-v3.patch`, with `README.txt` next to it.
  - It is not committed, because the files are on main / n-noir.
- **World-UI markers** (`world_markers.json`, `core/render/world_markers.gd`). The doctrine is checked at
  load (`M\11-markers-night\`).
- **Merge prep:**
  - the last `merge-tree` check showed only JOURNAL.md conflicts with n-d4, n-d5 and n-noir;
  - n-d4 and n-d5 conflict with each other (add/add) on `evidence/README.md`;
  - trial merges were done at 01:xx, 05:17 and 06:12 (lint, unit 309, scenarios 8 green on the merged tree).

## What does not work / is not done

1. **Rig target 0.3 ms per tick is NOT met.**
   - Measured: 0.338 ms per tick (release, iteration 8). Riot p99 is 0.43-0.45 ms per frame in later
     contended benches.
   - The remaining cost is GDScript maths in `RigArm` and `RigGait`, about 28 us per drive. Engine calls
     are about 0.2 us.
   - The fix is native work (characters owner). The DEVIATION in decisions.md stands.
2. **No idle bench of the final code.**
   - The last bench on this branch is 4d83199 (contended). Several changes since are not on the bench path
     or are 0-cost at 48 px/m or below:
     - camera wiring;
     - PrintStage;
     - the hit-stop;
     - page age (no-op without `look_d5`);
     - the crackle rim;
     - the reduced-motion flag.

     That was argued, not measured.
   - The only idle runs tonight were 22:13 and 23:00 (`evidence/bench-*-idle.json`, `*-final.json`).
3. **The art lanes are not live on this branch.**
   - The selftest still reports 22 placeholder textures. Moving traffic is the steel placeholder quad.
   - The FX use the analytic placeholders. D5 is my placeholder row, because `look_d5` is not in the tree.
   - Every plug-in path was proven with the files copied in for the capture only. After the merge, the
     goldens must be re-blessed once (n-d4's art moves every D4 golden).
4. **Two `look_d5` patches are for n-d5's file and are not applied:**
   - `evidence/pass-cost/look_d5-early-outs-lattice.patch` (D5 overlay -0.57 ms on the iGPU);
   - `evidence/pass-cost/look_d5-tones.patch`.

   The D5 overlay still costs about +1.3 ms at 64 px/m on the iGPU after the patch.
5. **Gameplay sources still missing:**
   - explosions, smoke and debris have no emitter in the game (no grenades or vehicle explosions in CitySim);
   - the night grade has no gameplay trigger (`CityView.lights.set_grade(&"night")` exists);
   - traffic damage and hijack states need a sim `custom.y`.
6. **D3 Clear Line profile:** not added. It was "later" in the brief and never reached.
7. **4090 GPU timings are not trustworthy.** Other lanes rendered on the same GPU all night. Per-pass costs
   were taken on the idle iGPU (a pessimistic Deck proxy) instead. There was no real Steam Deck measurement.
8. **No AI images were generated** by this lane (it is a code lane), so there are no provenance lines.

## What blocked me, and for how long

| Blocker | Time lost / span | Workaround |
|---|---|---|
| No positional shot / hit / explosion events in F-04 | 21:30 -> 23:10 (FX and lights were API-only) | Diffed the CitySim projectile snapshot (65762d3) with no `events.json` change. Explosions are still sourceless. |
| Shared machine: other lanes' Godot runs, MovieWriter captures and the GPU | All night. The idle bench was owed from 04:28 to the freeze (about 3 h, never had); 4 benches were recorded as CONTENDED or INVALID | Interleaved A/B on the idle iGPU for pass costs; benches labelled as contended. |
| Art lanes unmerged | All night | Plug-ins live only when the files exist, capture-only copies, and 3 scratch trial merges. |
| Parse errors in a windowed scene never quit | About 15-20 min over 4 incidents | Killed only my own PIDs, by PID. Rule: run once to a file first. |
| An LFS pointer copied as the real asset (FX sheet, traffic atlas) | About 10 min, twice | Copy from the checked-out worktree file and check its size. |
| Traffic atlas re-laid out by n-d4 mid-night (2x4 -> 3x3) | 02:02 -> 02:15 (plug-in reverted, then re-applied) | The grid is read from the texture size (7bfb6b9). |

## Rejected or reverted tonight

These are the main ones. All are listed with frames in JOURNAL.md.
- stipple light edges (`M\04-lights\`);
- FX as one `multimesh_set_buffer` (slower; `M\13-fx-buffer\`);
- crowd quad trim (no gain);
- integer hash (+0.75 ms on the iGPU);
- all-noise lattice (no gain);
- smooth tone mottle and sin-hash grain (`M\30-mottle\`);
- quest patch v2 (it broke n-noir's quest_fight; superseded by v3);
- the shared-`_build()` fixed-tick switch;
- the first traffic plug-in (2a72129, re-done in 7bfb6b9).

Frames rejected for camera breaks: **0**. Every capture is the engine's straight-down camera.

## Next steps (morning, in order)

1. **Director merge.** Only JOURNAL.md conflicts are expected, plus n-d4 vs n-d5 on `evidence/README.md`. After it:
   - Re-bless the look goldens once and look at them:
     `godot --fixed-fps 60 --path project res://dev/selftest/look_golden.tscn -- --out=<dir> --bless`, both sites.
   - Do NOT also apply n-d4's `traffic_atlas_wiring*.patch`, because 7bfb6b9 already wires the atlas.
   - Apply `look_d5-early-outs-lattice.patch`, then `look_d5-tones.patch`. Re-bless the `-ov` goldens.
   - Apply `M\49-quest1-v2\quest1-on-print_stage-v3.patch` AFTER n-noir. Then call `print_stage.listen(...)`
     once quest 1 runs on World's SimClock.
   - Move CityView onto PrintStage.
   - Re-check the sheet crackle on Rivet at 32 px/m.
   - Run `node tools/evidence/run.mjs` (full, with the bench, on an idle machine).
2. **Owner calls.** Each one is a single number or line, and frames are ready:

   | Call | Frames |
   |---|---|
   | objective solid vermilion vs paper + core | `M\16-objective-core\` |
   | cop vermilion body vs cream body + cap | `M\17-cop-accent\` |
   | 15 Hz outer rigs | `M\15-rig-quarter\*.gif` |
   | D4->D5 ramp start (48 px/m today vs 0.35 at 48) | `M\42-arena\` |
   | `age_floor` | `M\50-age-floor\` |
   | paper warmth | `M\35-paper-option\` |
   | night tuning | `M\40-night-options\` |
   | fire flicker style | — |
   | hard-fail on unknown launch args | — |

3. **Native `RigArm` / `RigGait`** (characters owner), to reach 0.3 ms.
4. **Sources and states:**
   - explosion and smoke emitters;
   - a night trigger from acts;
   - sim `custom.y` for traffic damage and hijack;
   - `print_part` taking `ink_tone` / `paper_tone`.
5. **Measure on a real Steam Deck:** the print pass, the D5 overlay at 64 px/m and the light budget.
6. **D3 Clear Line** as a fourth profile row, if the owner still wants the fallback live.
