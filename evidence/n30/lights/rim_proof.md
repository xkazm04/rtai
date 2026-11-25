# n30 combat 12: the explosion rim patch proven on screen (patch not applied; the Director applies it)

`evidence/n30/lights/rim.patch` = `rim_patch.md` made real: shader, `light_pool.gd`, `lights.json` + schema `rim`,
`arena_combat_lights.gd` doc, `test_light_pool_rim.gd` (+ `.uid`), one assert in `test_light_explosion_amber.gd`.
`git apply --check evidence/n30/lights/rim.patch` on the clean tree: exit 0. Product files were restored; only the patch is committed.

## Two corrections to rim_patch.md found while proving it
1. The shader local `p` collides with `vec2 p` in `fragment()` ("Redefinition of 'p'", shader fails to compile): renamed `packed_ink`.
2. A headless MultiMesh reads back default custom data, so a `write()` readback test cannot pass: the packing moved into
   `LightPool.custom_data(k)` (what `write` stores; also shortens `write`), and the test asserts on that.
Also: `rim` typed local (`var rim_col: Color`) because gdscript warnings are errors; doc comment reflowed to 100 cols.

## Commands
- before (HEAD) / after (patched), same build, one process each:
  `node evidence/n29/red/take.mjs build/n30rim/{before,after2} 482,486,496 --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
  (stills land, the take then runs to the 240 s timeout: reported `timedOut`, harmless.)
- test: `node tools/tests/run_unit.mjs --select=test_light_pool_rim,test_light_explosion_amber,test_light_layer` -> 15 passed, 0 failed
  (`test_light_pool` does not exist: the run says UNVERIFIABLE for that name only). `node tools/lint/lint.mjs`: all 19 checks pass.
- measure: `build/n30rim/measure.py` (disc from the on/off bbox of `explosion_rim.md`), json `build/n30rim/measure.json`.

## Per tick (px changed = max channel diff > 24, inside the light disc)
| tick | changed in disc | changed outside | mean RGB before -> after (changed px) | amber (h25-50,s>=.45) before -> after | pale yellow | vermilion | red | teal |
|---|---|---|---|---|---|---|---|---|
| 482 | 296777 | 36 | 231,226,200 -> 230,223,171 | 21239 -> 61139 | 230172 -> 230172 | 11 -> 11 | 11 -> 11 | 0 -> 0 |
| 486 | 296921 | 9 | 255,241,187 -> 255,235,161 | 94181 -> 94181 | 202573 -> 202573 | 78 -> 78 | 78 -> 78 | 0 -> 0 |
| 496 | 0 | 0 | light faded; diffs < 24 (whole disc amber 14671 -> 27774) | | | 4931 -> 4931 | | |

Bars: red added 0, teal added 0, vermilion added 0: met. Px outside the disc changed: 36 and 9 (not 0; 1e-5 of the frame, at the
disc edge/take jitter, not a rule-bearing change; the strict bar is missed by those px).
Honest reading: the amber class count moves only at t482 (+39900 px). At t486 the changed ~297k px are pale cream before and
stay inside the pale-yellow/amber classes after (class thresholds do not separate them), but the blue channel drops ~26 (187 -> 161):
the ring goes from cream toward saturated amber-orange.

## What I saw (`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_rim_patched_pair_64.png`, t486)
Before the blast's outer rings and hatched fringe are a pale cream-yellow wash; after they are a deeper saturated amber-orange
that reads as a distinct warm ring around the white core, visible but modest, because it sits over the nuke's own amber floor
(it brightens the amber rather than contrasting with it). Core and star burst are unchanged.

## Director
1. `git apply evidence/n30/lights/rim.patch`
2. `node tools/tests/run_unit.mjs --select=test_light_pool_rim,test_light_explosion_amber,test_light_layer`

## 32 px/m film (c16)

Command (patch applied, then reversed at once): `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/n30rimfilm/rim_after_32.mp4`
(godot exit 0, not timed out). Copied to `gtai-masters/n30/combat/films/explosion_rim_after_32.mp4`.
ffprobe: `1920,1080,60/1,25.000000` (width, height, r_frame_rate, duration s).
Pairs with the before film `films/round_band_32.mp4` (same chapters, same QUIT). Frames compared at t=12.2 s.
Seen: the two stills are visually near-identical (same ring of star bursts, same soot and floor); at 32 px/m I could not see a rim difference by eye.
`git status --short project` was empty after `git apply -R`.
