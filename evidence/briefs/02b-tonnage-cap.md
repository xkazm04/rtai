# Brief 02b (lane anim, tag tonnage-cap, resume): the hold bar is missed; try a capped step table

Same machine law and ownership as brief 02 (APPDATA/GODOT_BIN exports, d3d12, --position 0,1440, one Godot at a time,
stage per path, quick gate before commit, render only).

Your 02 result is accepted as a step (commits fe890210d, 18c38e915, 27d2338bd stay). The bar (worst hold < 9 px@32)
is missed: 15.5 px (48 ticks), 25.4 px (110 ticks). The cause is structural: `GhostStride.TABLES["tonnage/p70"]`
holds a frame until the body has walked that frame's drawn stance-foot step, and step 5 is 44.5 cell px, so column 5
holds ~12 ticks and its planted pad rides with the body.

## Do
1. Add a render-only cap: `GhostStride.MAX_STEP_SHARE` (or a per-table cap, your call; name it clearly): no frame's
   timing step may exceed `cap x (cycle / frames)`; the excess is spread over the other frames proportionally so the
   table still sums to the same cycle (the cycle length and the walk speed do not change). `0` / `INF` = off = today.
   Pure function, unit-tested (sum preserved, no step over the cap, off = identical table).
2. Sweep the cap on Tonnage p70 (off, 2.0, 1.75, 1.5, 1.25, 1.0 = even) with the SAME 110-tick film each time and
   measure THREE numbers per value: worst hold ride and mean hold ride (`hold_ride.py`), and the frame-to-frame
   drift of the stance foot at the pose changes in world space (the n15 it13 method: `evidence/it13/ghost_slip.txt`
   and its tool under `evidence/it13/tools/`; or `feet_track.py`'s pad ground-x jump at each pose change). Level 3 bar
   is drift < 3 px@32 AND sawtooth < 9; level 4 adds worst hold < 9.
   Write the table to `evidence/tonnage-hold/cap_sweep_32ppm.md`.
3. Ship the value that meets worst < 9 with drift < 3 if one exists. If none does, ship the value that minimises
   max(worst/9, drift/3), and say plainly which bar it misses and by how much. Same for p55's table if it has the
   same long-step problem (measure p55 worst hold first; ship only if it improves and you filmed it).
4. Frames to `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/`: the feet trace (32 px/m) for off vs shipped
   cap side by side, and a 12 s 32 px/m clip of the shipped value (real time + 1/3 speed as before). Look and say if
   the foot reads planted or skates.
5. Unit tests, `run_unit.mjs --changed`, quick gate, commit. `node tools/mutate/mutate.mjs --file=features/souls/ghost_stride.gd --lines=<the new function lines>`
   and quote killed/(killed+survived).
6. Then append to `LEVEL.md`'s Tonnage "Planted feet" cell one sentence with the n19 numbers and evidence paths
   (do not change the level number; I judge it).

End with: commits, the sweep table, the shipped value, the mutate score, frame paths.
