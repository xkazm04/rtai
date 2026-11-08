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
- **The lamp post card** is still a stub about one person tall (REQUEST 1).
- **Item 2's audit is by eye from one still, not measured.** Parked cars and kerb furniture stand. Roofs and roof gear are the biggest plan-view read left and need art. The fire escape stays flat and was not in that frame, so it is uncounted.
- **Item 4 (movement angle) has only a code trace, nothing filmed.** Cards have no wheel animation to drift. Walk phase and drawn displacement are both in ground px. Facings are 8 octants, so a run between octants strides up to 22.5 degrees off its path: unmeasured.

## Gates so far

- `node tools/lint/lint.mjs`: 15 of 15 in the pre-commit hook on `071e3780`.
- `node tools/tests/run_unit.mjs --select=test_street_dead_heading,test_street_dead_plan,test_street_quest_dead_plan,test_street_crowd_corpse`: 32 passed, 0 failed before the shader tests; `--select=test_street_dead_heading,test_street_crowd_corpse`: 15 passed, 0 failed with them.
- Eight film runs (Dock 9 and riot, 32 and 64 px/m, before and after): 0 SCRIPT ERROR each.
- **Not run yet:** scenarios, parity, `tools/evidence/run.mjs`, the director reel. The full unit suite was started once and TERMINATED by its own 800 s timeout under load at 23:09, so it has no result.
- Not exported yet.

## What blocked me

- The machine is badly contended: a commit's lint hook passed 10 minutes once and was killed, and a plain `--import` passed 200 s earlier. Neither lost work.
- This lane opened with no `JOURNAL.md` and no commits past `c394af55`, although the runner called it iteration 4.

## Calls for the owner

- **w-1, the set of headings.** Five headings, heads never toward the camera. A blow toward the camera turns the body away, so it no longer falls that way. Frame: `dead_riot_before_after_64.png`. The tables are `StreetDeadHeading.HEAD_DEG` and `HEAD_DEG_ODD`; `ENABLED` false restores n9.
- **w-2, roofs.** Roofs are drawn straight down and are the largest plan-view area left under the 70 camera. Fixing that is a new art round for every roof type, not code. Frame: `audit_street_combo_32.png`.

## Next steps

Finish item 2 by measurement (fire escape census, roofs as the Call above), film item 4 on a diagonal run, wire the drawn-for-70 poses when REQUEST 2 lands, then the remaining gates.
