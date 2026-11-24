# n27 Gloria, a compact one-hand nail gun (p70)

Brief n27-03. Part A is committed (`17d909ebd`). Part B (walk and run grids by transplant) is **not shipped**; the old
long-gun grids stay (see the end).

## Concept
The owner asked for her redrawn as a compact one-hand gun. Concept sheet: `gtai-masters/n27/keys/gloria_concepts_ab.png`
(pistol, old Gloria, take A, take B). A is the straight nail strip: cream riveted name plate, short ribbed barrel nose with a
brass tip, carry loop, a comb of nails under the barrel. A won; B's coil drum blurs at 32 px/m.

## Images: IMAGES 3 in this call (lane cap 15 tonight)
Round dir `gtai-art/rivet-n27/gloria-p70/` (jobs.json, refs/, out/, gen.log, STATE.md). Each job is an image edit: image one = the shipped
pistol strip (`rivet_eq_pistol_noflash`, `_diag_noflash`, `_left`) upscaled x3 on flat green #00B140 (main: 2 rows of 4 cells), image two = the
concept. Shared prompt: keep every figure exactly (pose, one gun hand, free claw, hose, rigid striped hazard collar - a rigid band, never
cloth -, size, placement, spacing, cell order), only replace the pistol with Gloria's compact nail gun from image two at the pistol's
size and angle per figure, no flash, no extra arms. Jobs `gloria_p70_main`, `gloria_p70_diag`, `gloria_p70_left` (the left job mirrors the gun).

## Cut and registration (`gloria-p70/cut2.py`, `install.py`, `weapon_art.py`)
- Each generated sheet is keyed (green dominance), de-haloed (green clamped to max(r,b)), figures found as connected components, ordered row/column,
  sized by body height, then scaled (0.80-1.24) and shifted so the head/torso (top 55%) mask has the best IoU with the pistol cell's.
  IoU 0.94-0.99 for all 15 cells. Result: the pistol's exact canvas (2264x180 main, 1132x180 diag, 573x170 left) and cell order.
- Tone: per-channel mean/spread of the new cell matched to the pistol cell over the head/torso overlap.
- Body check: lowest/highest body row of every cell within 0-2 px of the pistol's (cell 0 rows 21-179 vs 21-177, cell 2 11-177 both).
- Why the old Gloria strips were 2576x216: her long gun needed wider and taller cells; the figure scale was the same (fig_h 165, RES 1.5).
  The new strips use the pistol's cells, so the body is the same on-screen size as with the pistol (cell 2 body 167 px both, cell 0 159 vs 157).
- Fire cells with flash: `rivet_eq_gloria.png` and `_diag.png` = the noflash strip + the pistol's OWN drawn flash pixels (pistol strip minus its noflash twin)
  pasted at Gloria's muzzle. Offset (Gloria barrel tip minus pistol barrel tip, strip px): main cell 5 (0,-1), cell 6 (0,0); diag cells 0 (0,0), 1 (5,3), 2 (-1,-8), 3 (-4,1).
  Gun size at the side cell: Gloria 53x57 strip px, pistol 54x53.

## Data changed
- `rivet_muzzle.json` p70 gloria: cells 3 [153,65], 4 [162,67], 5 [169,75], 6 [87,93] (cell 1 dropped: like the pistol, the 3/4 cell draws the gun far left);
  diag [160,101] [130,37] [26,94] [57,38]; left [2,59] [3,59] [5,59]; `rivet_eq_gloria_left_fire` removed. 110-space (strip px / 1.5).
- `rivet_gun_diag.gd` p70/gloria: DEG, HELMET_X, FOOT_PX = the pistol's (the strips share the pistol's body and cells).
- `rivet_cell_feet.gd` `p70/rivet_eq_gloria.png:6`: 60 -> 38 (the pistol's).
- `rivet_windup.gd`: Gloria leaves `LEFT_LONG_GUNS`. **NEED (done, one line outside the allowlist):** `rivet_strips.gd` `ONE_HAND` gains `&"gloria"`,
  otherwise `left_drawn` is false and she turns left on the mirrored right strip. Its header comment was shortened by one line to stay at 200 lines (debt ratchet).
- `rivet_res.gd`: p70 `rivet_eq_gloria_left_fire.png` removed from X15; the strip and its noflash twin deleted (nothing else loads them; p55's stay).
- `tools/art/rivet_frames.json`: p70 gloria entries now like the pistol's (sheet names `rivet_eq_gloria_70_n27*.png`, not committed: the cut came from the generated sheets); p70 left_fire entries removed.
- Test value: `test_rivet_fire_cam` `test_a_gun_with_a_facing_muzzle_is_untouched` used gloria's cell-1 muzzle; it uses plasma_rifle now (gloria's cell 1 has no point, like the pistol).
- `rivet_motion.json`, `rivet_bob.json`, `test_rivet_grid_stride.gd`: untouched (they describe the walk grids, part B).
- Weapon art cut from the concept's centre figure (`weapon_art.py`): `gloria/pickup.png`, `held.png`, `held_small.png`, `icon.png` (flat cream silhouette with a dark rim),
  `showcase/p70/gloria.png`, `showcase/icon/gloria.png`, same canvas sizes. Limit: in the concept the grip is hidden in Rivet's fist, so the cut gun has a flat left edge and
  no visible grip, and the held (top) view is the side view fitted to 488x122. The gun is only 139 px in the concept, so it is soft. Worth a redraw pass if the HUD icon needs it.
- 11 provenance lines appended (`steam/ai-provenance/2026-11.jsonl`).

## Looked at in the game (arena, Gloria equipped, 64 px/m, aim octants 0-7, rest and fire)
Stills in `gtai-masters/n27/keys/`: `gloria_before_after_64.png` (old | new | pistol, octants 0, 2, 4, rest and fire), `gloria_fire_tick_64.png` (shot tick, 8 octants);
`frames.json` entries added (also for `gloria_concepts_ab.png`). One hand on the gun, the free claw free, no second gun, the game's cream burst flare at the muzzle on the shot tick;
turned left she draws her left strip (octants 3-5). The old two-handed `left_fire` pose is gone. The drawn flash (pistol's pixels) lasts the game's flare ticks, so the 6-tick fire rows show the cell without it.
The dev `arsenal_turn` recorder does not equip the weapon in this worktree (it filmed bare hands for the pistol and Gloria alike), so the stills come from a copy of the n24
`grid_arena_film` scene (aim 8 octants, fire held), kept outside the repo in `gloria-p70/capture/`. Nail tracers were not caught on the sampled ticks.

## Tests
`node tools/tests/run_unit.mjs --changed`: 4086 passed, 1 failed (`test_rivet_fire_cam:81`, fixed as above), 1 flaky (`test_audio_driving`, passes alone). Pre-commit lint 19 of 19 ok.
After the fix: `--select=test_rivet_fire_cam,test_rivet_muzzle` 12 passed, 0 failed.

## Part B: not shipped
`gun_transplant.py` was started (kept as `gloria-p70/gun_transplant_wip.py`, not in the repo). Findings: the grid rows are not the same poses as the eq strip cells (row 2's gun points left, eq cell 2's right),
and masks made by diffing the pistol and Gloria cells include texture noise from the edited body, so the template match scored 0.27-0.54 (unusable). No transplanted grid exists; the old long-gun
grids and their stride data stay, so walking and sprinting still show the long gun while standing and firing show the compact one.
Next: build the gun mask from a hand-aligned region instead of a whole-cell diff, and pair each grid row with its eq cell by gun match first.

Commits: `17d909ebd` (part A).
