# Brief 05b (lane anim, tag death-cells-b, resume): prove set B on a real card-drawn victim, then C and D

Same machine law and ownership as brief 05 (APPDATA, GODOT_BIN, d3d12, --position 0,1440, one Godot at a time,
stage per path, quick `--no-godot` + `run_unit.mjs --changed`, render only, combat/ is lane ai: READ only).

## Director's read of your B stop
`KillFallCells.attach` returning null when `StreetWalkerCards.hides_parts(rig)` is false is the intended rule ("No card
(a parts rig, a headless run) = no grid"). Your film victim was a lab-guard PARTS rig with a ped head row forced on it,
so it could never show a grid. In the game, a city street ped is drawn as a card (`StreetWalkerCards`), which is the
path these grids are for. Test that, not the override.

## Do
1. Find how a city ped or thug killed by the claw is drawn in the real game at tilt70 (city street walker card? which
   rig/plan?). Write the chain in your report (file:line).
2. A unit or integration test (yours, under `tests/`) that builds a real card rig for each of the 9 kinds (or the
   nearest real path) and asserts `KillFallCells.attach(...)` returns the kind's new claw_throw grid (texture path),
   and that a kind without a grid keeps today's fall grid. Red on HEAD without your B files, green with them.
3. Film one real victim of each of two kinds (hood, thug) dying to the claw at tilt70, 32 and 64 px/m, before/after at
   the same ticks: a dev scene or film setup that spawns a card-drawn city ped as the victim (dev/ is fine; declare any
   flag). Stills + a 10-40 s 32 px/m clip to `gtai-masters/n19/anim/death-cells/B/`. Look and describe.
4. If 2 and 3 hold: commit B (the 9 PNG + .import, `signature_kills.json` cells, test, provenance, packer). If card
   peds never reach `attach` in the real game, commit nothing for B, leave the files, and write the exact `attach()`
   change lane ai would need in `evidence/death-cells/NEED-ai.md`.
5. Then set C (molotov_torch p55, patrol/riot/SWAT), then D from your inventory, as brief 05 says. Commit each.
