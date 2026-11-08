# REPORT: night n10, lane world (draft, updated 2026-11-08 ~21:50)

Evidence: `C:\Users\kazda\kiro\gtai-masters\n10\world\` (`frames.json`). Every performance number is unmeasured so far.

## What works, with evidence

1. **Half-height walls read as real shorter walls** (`aadc7430`). Each style is cut into whole storey rows at the flat elevation's own proportions and stacked from the ground up: tenement two storeys, tall block ground plus uppers, shop one storey with its sign band and awning. 32 px/m: `wall_tenement_32_after.png`, `wall_shop_32_after.png` against `wall_shop_32_before.png`. 48 px/m: `wall_tenement_48_after.png`. Grey print look and `height_k` 0.5 unchanged.
2. **Lamp posts no longer lie flat.** The "fallen lamp" was the game's own pole shadow stroke with a globe at its end, not the test scene. It is now a short contact dash. `lamp_cast_32_after.png` against `lamp_cast_32_before.png`.

## What does not work yet

- The lamp post card itself is still a stub about one person tall. It needs new art (REQUEST 1 in JOURNAL).
- Item 2's audit is not finished: parked cars, kerb furniture, fire escapes, roof edges and contact shadows are looked at in stills only, not measured.
- Item 3 (the dead) and item 4 (movement angle) are not started.

## Gates so far

- `node tools/lint/lint.mjs`: 15 of 15 on the wall commit `aadc7430`; not re-run on the shadow data change.
- `node tools/tests/run_unit.mjs --select=test_facade_storeys,test_chunk_lift,test_prop_cards`: 26 passed, 0 failed (walls); `--select=test_chunk_lift,test_prop_cards`: 21 passed, 0 failed (shadow change).
- **Not run yet:** the full unit suite, scenarios, parity, `tools/evidence/run.mjs`, the director reel.
- Not exported yet.

## What blocked me

- The machine is badly contended: a plain `--import` passed 200 s and was killed once, which left one stale shop sheet and cost a re-film.
- This session opened with no `JOURNAL.md` and no commits past `c394af55`, although the runner called it iteration 4: nothing from earlier iterations exists to build on.

## Calls for the owner

None yet.

## Next steps

Finish the item 2 audit by measured gap, then the dead (item 3), then movement angle (item 4).
