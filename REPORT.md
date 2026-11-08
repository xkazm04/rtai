# REPORT: night n10, lane world (draft, updated 2026-11-08 ~22:56)

Evidence: `C:\Users\kazda\kiro\gtai-masters\n10\world\` (`frames.json`). Every performance number is unmeasured so far.

## What works, with evidence

1. **Half-height walls read as real shorter walls** (`aadc7430`). Each style is cut into whole storey rows at the flat elevation's own proportions and stacked from the ground up: tenement two storeys, tall block ground plus uppers, shop one storey with its sign band and awning. 32 px/m: `wall_tenement_32_after.png`, `wall_shop_32_after.png` against `wall_shop_32_before.png`. 48 px/m: `wall_tenement_48_after.png`. Grey print look and `height_k` 0.5 unchanged.
2. **Lamp posts no longer lie flat** (`20c868c6`). The "fallen lamp" was the game's own pole shadow stroke with a globe at its end, not the test scene. It is now a short contact dash. `lamp_cast_32_after.png` against `lamp_cast_32_before.png`.
3. **The dead lie only on a few screen headings** (`071e3780` near rigs and Dock 9, `b8ba8f9e` far crowd).
   - A body's head lies up, up-right, up-left, right or left, picked by the blow's screen direction and the pose, with no free turn. No head points at the camera. Pose E is only ever mirrored.
   - The far crowd's baked corpses follow the same headings through a view-only shader snap.
   - Each near body has a contact shadow (its own silhouette, down the sun).
   - Dock 9's push is wider (1.9 m range, 1.4 m cap).
   - Same seed and tick, before = `StreetDeadHeading.ENABLED` false: `dead_dock9_before_after_64.png`, `dead_dock9_before_after_32.png`, `dead_riot_before_after_64.png`, `dead_riot_before_after_32.png`.

## What does not work yet

- **The art is still the n9 plan poses.** This is the code half of the owner's note: the poses are placed on drawn headings but are not yet drawn for this camera. REQUEST 2 in JOURNAL asks for them.
- **Dock 9's top pair of bodies still touches**, and an arm touches between the lower two (`dead_dock9_before_after_64.png`).
- **The far crowd has no contact shadow** (near rigs and Dock 9 only).
- **The lamp post card stays as drawn.** I had called it a stub and asked for a lamp three times a person's height (REQUEST 1), then measured it: 65 px against Rivet's 53 px at 32 px/m, and the half-height walls are 49-121 px, so a taller lamp would stand over the walls. REQUEST 1 is withdrawn; the art is the library's `lamp_70_v4`, drawn for this camera.
- **Item 2's audit is by eye from one still, except the fire escape.** Parked cars and kerb furniture stand. Roofs and roof gear are the biggest plan-view read left and need art. The fire escape is closed from the source: the city generator never places one, so the streets draw none; only the alley arena has four.
- **Item 4 (movement angle) is only half answered.**
  - Cars: no wheels are drawn, and the drawn nose stays within 1.29 degrees of the path on screen at 70 (4.32 at 55). This is arithmetic from `VehicleCards`, assuming the turntable art was drawn at the true pitch; it was not filmed.
  - Rivet's feet on a diagonal: not measured. I filmed the only oblique walk the arena bot has at 64 px/m (`--bot=rivet`), and his boots are hidden under the torso in the toward and 3/4 rows, so that film cannot show drift either way. A pixel tracker over the drawn rows failed (the boots merge), so no number from it is used.
  - From the code only: facings are 8 octants, so a run between octants strides up to 22.5 degrees off its path, and the walk slides by up to 28 % between 1.8 and 2.5 m/s (`MAX_CYCLES_S`). See Call w-3.

## Gates so far

- `node tools/lint/lint.mjs`: 15 of 15 in the pre-commit hook on `071e3780`.
- `node tools/tests/run_unit.mjs --select=test_street_dead_heading,test_street_dead_plan,test_street_quest_dead_plan,test_street_crowd_corpse`: 32 passed, 0 failed before the shader tests; `--select=test_street_dead_heading,test_street_crowd_corpse`: 15 passed, 0 failed with them.
- Eight film runs (Dock 9 and riot, 32 and 64 px/m, before and after): 0 SCRIPT ERROR each.
- `node tools/tests/run_unit.mjs` (full) at `4558d018`: 1968 passed, 0 failed, 0 skipped.
- **`tools/evidence/run.mjs --no-bench`, started 23:27 on `4558d018`: no result.** Its log was still empty at 00:05, so pass or fail is unknown, and scenarios and parity are unconfirmed.
- **Not run yet:** the director reel in top, tilt70 and combo.
- Not exported yet.

## What blocked me

- The machine is badly contended: a commit's lint hook passed 10 minutes once and was killed, and a plain `--import` passed 200 s earlier. Neither lost work.
- This lane opened with no `JOURNAL.md` and no commits past `c394af55`, although the runner called it iteration 4.

## Calls for the owner

- **w-1, the set of headings.** Five headings, heads never toward the camera. A blow toward the camera turns the body away, so it no longer falls that way. Frame: `dead_riot_before_after_64.png`. The tables are `StreetDeadHeading.HEAD_DEG` and `HEAD_DEG_ODD`; `ENABLED` false restores n9.
- **w-3, a walk that slides between 1.8 and 2.5 m/s.** From the code, Rivet's walk holds its cadence at 2 cycles a second above 1.8 m/s, so a stick walk at 2.5 m/s slides about 28 % until the run takes over. Raising `RivetWalk.MAX_CYCLES_S` to about 2.8 would plant it but makes the walk's legs churn faster. Left as built; it is the Rivet lane's tuning. Frame: `move_oblique_walk_64_sheet.png`, which shows why it is unread: the boots are hidden in the toward and 3/4 rows.
- **w-2, roofs.** Roofs are drawn straight down and are the largest plan-view area left under the 70 camera. Fixing that is a new art round for every roof type, not code. Frame: `audit_street_combo_32.png`.

## Next steps

Get a real evidence result and run the director reel x3. Separate Dock 9's top pair by measuring the push between drawn centres. Film Rivet's feet on a diagonal with a dedicated bot and a leg-visible row, and wire the drawn-for-70 poses when REQUEST 2 lands. Try the asset lane's half-height strips (`facade_half_it180`) against the recut.
