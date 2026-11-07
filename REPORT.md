# REPORT: d9 lane `seams` (running; final at 18:40)

Branch `d9-seams`. Evidence: `C:\Users\kazda\kiro\gtai-masters\d9\seams\` (`frames.json`), logs in
`evidence/d9-seams/`. Journal: `JOURNAL.md`.

## What works (with evidence)
1. **The dead behind the arena's kerb barrier** (item 1, commit 38a90b52). Measured cause: the two
   dead cops were still full rigs (hiding the dead rigs emptied the frame), fallen south onto the
   barrier; PropOcclusion boxed every body as standing. `PropLying` boxes a corpse from its ground
   point to its drawn head; the barrier is redrawn over it. Hidden body-frames 2 -> 95 / 901 frames,
   0 SCRIPT ERROR. City's agreed `CityOcclusion.extra` seam is landed and fed with the arena's tall
   props (`PropCrowdOccluders`) for the baked crowd. `kerb_corpse_before_after_tilt70_{32,48}ppm_*`.
2. **The King's legs, quick half** (item 2, 493d845c). The cream backing was RivetPlan's leg
   sticker rim inherited by KingPlan (the PNGs are ink-outlined); off under every card view, kept
   in `top`. `king_legs_rim_before_after_combo_{64,32}ppm_*`. Drawn legs: REQUEST to assets
   (`king_legs_55/70`, layout in JOURNAL).
3. **The 55 planter** (item 4, 3272969d): planter_v3 cut with city's tool (byte-identical to n8's
   checked cut), provenance line. `planter_p55_v2_vs_v3_and_p70_strips.png`. In-game frame owed.
4. **release_compile per worktree/pid** (item 6, 6e49a298): two passes in parallel in one
   worktree, 599 loaded / 0 failed each, both scratch dirs removed (`evidence/d9-seams/`).

Gates this iteration: lint 15/15; unit no-arg 1696 passed / 0 failed (at 966a2a79);
director reel (`--fixed-fps 60 --quit-after 14000`) top 19/19, tilt70 19/19, combo 19/19 down,
0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it1-*.log`). Not yet run: `tools/evidence/run.mjs --no-bench`.

## What does not work yet
- Item 2's drawn legs: the assets lane served king_legs 55/70; `KingLegsCard` is built but OFF: with
  the bust raised onto the legs the press-plate arm parts stay behind (still:
  `WIP_king_drawn_legs_lift0.5_combo_64ppm_seed2_f150_parts_vs_legs.png`). Next: lift the arms too.
- Item 3 (sim bike), item 5 (armed city cops walk).

## Calls for the owner
1. **The King's legs meet the bust** (when `king_legs_*` lands). The 2.0x bust card reaches the ground,
   so drawn legs mean a taller King: default I build, the bust rises by half the legs' cell (it1 WIP
   still shows the legs reading well) with the hem over the legs' hips, the legs scaled with the bust (cell width =
   the bust's cell width), short wide-set legs. Option: legs hidden entirely under a longer drawn
   robe on the bust (an asset ask). Today: the cream backing is gone (stills above).
2. **A corpse that fell "through" the barrier** reads as lying behind it (its boots show north of
   the barrier, the rest is hidden). Default built. Option (sim work, not built): stop a falling
   body at a wall.

## Next steps
See JOURNAL `NEXT:`.
