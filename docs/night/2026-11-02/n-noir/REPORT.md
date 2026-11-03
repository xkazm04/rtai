# REPORT - lane noir (D-Noir), night 2026-11-02 to 11-03

Branch `n-noir` (base main 721fbbb). The project tree is unchanged since 641d2b1 (07:09). After that there were journal commits only.
Paths starting `evidence/` are in this worktree (an untracked folder, by design). `M/` is
`C:\Users\kazda\kiro\gtai-masters\night\noir\` (masters, clips, the ladder). The full log is in `JOURNAL.md` and the item-by-item table is in `evidence/NOIR.md`.

**Start here:** `evidence/showcase-hero-current.png` (the current build: D4 48 | noir 48 | noir 64, the street
fight). Then the clips `M/stab21/48/showcase-noir-48.mp4`, `M/stab21/64/showcase-noir-64.mp4` and
`M/stab21/d4/showcase-d4-48.mp4`, and the running ladder `evidence/ladder.png` (37 rows, also in `M/ladder.png`).

## Gates (green)
At 1d152e0 (iteration 28, 08:07; project/ and tools/ = 641d2b1):
- lint 13/13 over 243 files;
- unit 206/0/0;
- scenarios 8 ran, 0 failed, replay_60s final `cbeb734ff9b97c41`.

Logs: `evidence/gates-1d152e0-{lint,unit,scenarios}.log`. The full `node tools/evidence/run.mjs --no-bench --allow-dirty` at 641d2b1 also passed parity (1200 steps, the mutation caught at step 629) and selftest. Its JSONs are in `evidence/gates-641d2b1/`. Bench was not run by this lane.

## What works (opt-in: `--look=noir`; D4 frames stay byte-identical with it off)
| Work order | Claim | Evidence |
|---|---|---|
| 1 look profile | `look_noir.gdshader` + `look_noir.params.json` (`gtai.look-noir-params/1`, one `frame` table + `shadows`) + `features/fx/noir/noir_look.gd`. It does hard-threshold ink, crushed blacks, a white rim, rain + paper grain, and protected blood red. It replaces the D4 print instead of stacking on it. | `M/look-v4/sheet.png` (junction / street / roofs at 32/48/64, D4 vs noir); `project/dev/noir/noir_frames.tscn` re-shoots it |
| 1 cost | Noir frame on the RTX 4090: 0.85 / 0.75 ms GPU vs D4's 1.44 ms. On the AMD iGPU: 6.61 vs 8.17 ms (1080p). | `evidence/noir-cost-1080p-z1.5.json`, `-z2.0.json`, `evidence/noir-cost-1080p-igpu.json` |
| 1 light carving the black | Lamp pools of paper, white headlight cones, cars as ink hulks with glass | `evidence/light-street-48.png`, `light-street-32.png`, `light-junction-48.png`, `car-ink-junction-48.png`, `car-glass-48.png` |
| 1 cast shadows | Props/parked cars sweep hard ink shadows (+0.32 ms iGPU) | `evidence/cast-shadows-before-after.png`, `evidence/cost-shadows-quad-roofs-z1.5-igpu.json` |
| 1 figure shadows | The rigs cast ink figures (a big gain in headlight cones). +0.45 ms on the iGPU junction riot | `evidence/figure-shadows-before-after.png`, `figure-shadows-city-street-64.png`, `evidence/cost-figures-index-junction-igpu-a.json` |
| 2 characters | The default noir print makes cops ink masses with a white rim and Rivet the one lit figure (claw, visor). Opt-in `--noir-parts`: noir Rivet (an ink helmet plate with a bold white visor U, a B/W striped collar from 48 px/m) and noir cop parts (a cap badge, a checkered band), all on the same rig, sliced with the original alpha | `evidence/rivet-before-after.png`, `evidence/parts-before-after.png`, `evidence/band-compare.png` |
| 3 blood | Pooled directional spurts, teardrop splats with satellites, pools with wet edges spreading over 7 s, drip trails, stains on bodies, wall splats. Decals persist 60 s and fade over 120 s. Data: `blood_fx.json`. Unit-tested | `evidence/blood-before-after.png`, `drip-crops.png`, `stain-before-after-64.png`, `wall-crops-64.png`, `M/fight-v4/fight-48.mp4` |
| 3 comic impact frames | Silhouette flash x2, then an inverted panel, then the held knockback boxed as a comic panel | `evidence/showcase-hero.png` row 1, `evidence/flash-32-48-64.png` |
| 3 combat wiring | `noir_combat_fx.gd` listens to the real `Events.actor_killed` / `player_hit`. Proven on quest 1's real CombatArena (15 kills) | `M/quest-v2/quest-fight-48.mp4` |
| 3 doctrine | Rivet is a robot, so his hits throw white sparks and black oil, and red is human blood only. The objective rings as white arcs; the pickup reads as a paper-white box | `evidence/oil-before-after-64.png`, `objective-cue-48.png`, `pickup-cash-48.png` |
| 4 feel | Hit-stop (8 ticks), a held knockback panel, a kill silhouette, a muzzle starburst + a 1-frame ragged light pool, rain splash rings, a long coat on a spring (opt-in `--coat`) | `evidence/flash-before-after-48.png`, `evidence/f230-3way.png`, `evidence/coat-before-after.png`, `evidence/coat-motion-strip.png`, `M/coat-v1/showcase-noir-64-coat.mp4` |
| photosensitivity | One shared flash budget keeps the showcase at 2 flashes/s (it was 3, the WCAG limit). The flashes-off mode gives 0 (a calm beat) | `evidence/safety-before-after-48.png`, `evidence/safety-calm-beat-48.png`, `M/safe-v2/showcase-noir-48-budget.mp4`, `M/safe-v3/showcase-noir-48-flashes-off.mp4`, meter `M/tools/flash_check.py` |
| 5 showcase | `dev/noir/showcase_fight.tscn`: Rivet vs 2 cop rigs in rain, deterministic (unit-tested; the noir 48 re-record at 4761ffa was byte-identical to iteration 16's). Junction, street-lamp and police-car variants; `--d4` gives the same fight in D4 | `evidence/showcase-hero-current.png`, `showcase-hero-car.png`, `showcase-hero-street.png`, `showcase-hero.png`, `showcase-figure-shadows-48.mp4`; clips `M/oilcar/48/`, `M/oilcar/64/`, `M/lamp-show3/48/`, `M/show-final5/` |

## Honest comparison with D4 (details in `evidence/NOIR.md`, "Honest comparison")
- **Readability.** At 64 px/m the fight reads well: Rivet is lit, the cops are ink masses, and blood is the only colour. At 48 px/m the rain is busy around small figures. D4 parses faster: vermilion cops pop, while a noir cop is told apart from a ped only by value and shape. Without lights, pavement and road both print black.
- **Colour doctrine.** Black and white plus blood red; no orange is left. Teal (souls) is reserved but not on screen. The protected red channel would print any future saturated red as "blood".
- **Comic feel.** The biggest gain over D4, and cheap: the kill beat + the held panel are one shader mode with no new art.
- **Cost to produce.** Low for the world and FX: no new textures, everything procedural. Medium for characters: 1-2 Codex edits per character on the same rig (Rivet: 2 images, 145 s, 19 parts). Only bold, wide whites survive at 32-48 px/m.

## What does not work / not adopted
- **Ink-people mode** (everyone an ink mass): it loses figures on black asphalt, so it is not the default (`M/rig-ink-v2/compare.png`).
- **Noir ped parts:** the cops lose their value cue among ink peds. This is an owner choice of value roles (`evidence/ped-before-after.png`, `ped-cop-read.png`).
- **Crowd shadows:** the hard-ink version was reverted (d6daee0) because it leaves body-less blots on lit pavement (`evidence/crowd-shadow-before-after-NOT-adopted.png`). The root cause is not found; the suspect is `sim_render.gd`, which writes blobs before the `_rigged` check. Crowd figure casting was reverted at +2.3 ms (`evidence/figure-shadows-crowd-casting-street32-NOT-adopted.png`).
- **Junction riot figure shadows are mixed:** 16 near rigs cast murky merged masses, and the atlas crowd casts none (`evidence/figure-shadows-city-junction-48-mixed.png`).
- **Other reverts:** per-light shadow directions (`evidence/figure-shadows-per-light-NOT-adopted.png`), traffic through the fight (`evidence/cars-through-fight-NOT-adopted.png`), the riot helmet part (`evidence/helmet-rejected-zoom.png`).
- **Dev-only, not in the game:** the coat, the car pass (a shader shape, not art), the noir HUD print (quest 1 dev host), and the objective cue.
- **Smaller limits:**
  - wall splats are a line, because top-down hides the wall face;
  - oil is near-invisible on asphalt;
  - quest 1's view draws no city chunks;
  - the flash meter is a smoke test, not a certification, and has no red-flash test;
  - `showcase_fight.gd` is 227 lines (over the soft 200, under 300).

## Blockers and time lost
- **Leonardo:** 0 API tokens all night (probed every session, the key never printed). I used Codex image_gen instead: **7 images, 0 rejected as images, 1 reverted in-engine** (helmet), no rate limit hit. Provenance is in `steam/ai-provenance/2026-11.jsonl`.
- **Worktree setup:** no native DLL or baked city. I copied them from the n-visual worktree (build output, not committed). About 5 min.
- **Hung movie recordings, about 58 min in total:** 2 x 5 + 10 + 10 + 10 (04:10-04:20) + 8 (04:44-04:52) + 10 min. The cause was typed-GDScript parse errors that lint does not catch, which left Godot open. The fix is a short headless check before every record.
- **Merge fix:** the fix for the city_view `set_look_enabled` clash cannot land on n-noir, because the code exists only on n-visual. It is written as a patch instead.
- **Freeze 07:30 to 08:15:** stabilize only (gates and merge checks); no features.

## Merging (for the Director)
See `evidence/MERGE-noir.md`. main merges clean, and n-d4 / n-d5 conflict only on `JOURNAL.md`. For n-visual:
1. Take n-visual's `project/boot/launch_args.gd`.
2. Apply `evidence/merge-noir-city_view.patch`. It fixes a latent clash that re-shows the D4 print under noir on an explicit `set_look_enabled`. It is unverified in engine.
3. Re-shoot noir_frames junction 48 against `M/crowdshadow-v1/before/`.

Shared files touched (minimal): `boot/launch_args.gd`, `features/city/view/city_view.gd`, `features/characters/part_materials.gd`, `features/characters/print_part.gdshader` (both default OFF), and `dev/bots/collect_call_play.gd` (a `bus()` accessor).

## Next steps
1. The owner picks from `evidence/showcase-hero-current.png` and the stab21 clips: noir vs D4/D5, and a value-roles choice for peds vs cops.
2. Merge per `evidence/MERGE-noir.md`, then make `noir` a row in n-visual's `look_profiles.json`.
3. Crowd shadows: dump the baked atlas, fix the body-less blob at its source (parity with native), then re-apply 01409e4.
4. A prop/shadow mask channel for the junction asphalt; per-light shadow directions only mid-beam.
5. Move the coat and noir parts from dev flags into the game's rigs. Draw the souls (teal) above the pass. Split `showcase_fight.gd`.
